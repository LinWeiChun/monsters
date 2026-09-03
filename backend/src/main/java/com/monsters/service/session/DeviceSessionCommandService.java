package com.monsters.service.session;

import com.monsters.dto.auth.SessionReauthenticationResponse;
import com.monsters.entity.audit.SessionSecurityAudit;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.session.ReauthenticationPurpose;
import com.monsters.entity.session.SessionReauthenticationCredential;
import com.monsters.entity.session.UserSession;
import com.monsters.exception.common.BusinessException;
import com.monsters.repository.audit.SessionSecurityAuditRepository;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.session.SessionReauthenticationCredentialRepository;
import com.monsters.repository.session.UserSessionRepository;
import com.monsters.repository.user.UserCredentialRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.security.password.PasswordHashService;
import com.monsters.security.session.RefreshCredentialGenerator;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DeviceSessionCommandService {

    public static final String REAUTHENTICATION_HEADER = "X-Reauthentication-Credential";
    private static final long REAUTHENTICATION_SECONDS = 300;
    private static final String SESSION_REAUTHENTICATED = "SESSION_REAUTHENTICATED";
    private static final String SESSION_REVOKED = "SESSION_REVOKED";

    private final UserRepository userRepository;
    private final UserCredentialRepository userCredentialRepository;
    private final UserSessionRepository sessionRepository;
    private final SessionReauthenticationCredentialRepository reauthenticationRepository;
    private final SessionSecurityAuditRepository auditRepository;
    private final OutboxEventRepository outboxRepository;
    private final PasswordHashService passwordHashService;
    private final RefreshCredentialGenerator credentialGenerator;
    private final Clock clock;

    public DeviceSessionCommandService(
            UserRepository userRepository,
            UserCredentialRepository userCredentialRepository,
            UserSessionRepository sessionRepository,
            SessionReauthenticationCredentialRepository reauthenticationRepository,
            SessionSecurityAuditRepository auditRepository,
            OutboxEventRepository outboxRepository,
            PasswordHashService passwordHashService,
            RefreshCredentialGenerator credentialGenerator,
            Clock clock
    ) {
        this.userRepository = userRepository;
        this.userCredentialRepository = userCredentialRepository;
        this.sessionRepository = sessionRepository;
        this.reauthenticationRepository = reauthenticationRepository;
        this.auditRepository = auditRepository;
        this.outboxRepository = outboxRepository;
        this.passwordHashService = passwordHashService;
        this.credentialGenerator = credentialGenerator;
        this.clock = clock;
    }

    @Transactional
    public SessionReauthenticationResponse reauthenticate(
            Long userId,
            String currentSessionId,
            String password
    ) {
        return reauthenticate(
                userId,
                currentSessionId,
                password,
                ReauthenticationPurpose.SESSION_MANAGEMENT
        );
    }

    @Transactional
    public SessionReauthenticationResponse reauthenticate(
            Long userId,
            String currentSessionId,
            String password,
            ReauthenticationPurpose purpose
    ) {
        var user = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(this::invalidReauthentication);
        var passwordCredential = userCredentialRepository.findByUser(user)
                .orElseThrow(this::invalidReauthentication);
        if (!passwordHashService.matches(password, passwordCredential.getPasswordHash())) {
            throw invalidReauthentication();
        }
        return issueVerifiedReauthentication(userId, currentSessionId, purpose);
    }

    @Transactional
    public SessionReauthenticationResponse issueVerifiedReauthentication(
            Long userId,
            String currentSessionId,
            ReauthenticationPurpose purpose
    ) {
        if (purpose == null) {
            throw invalidReauthentication();
        }
        UserSession session = activeOwnedSession(userId, currentSessionId);
        LocalDateTime now = now();
        String credential = credentialGenerator.initialCredential();
        reauthenticationRepository.save(new SessionReauthenticationCredential(
                session,
                credentialGenerator.hash(credential),
                purpose.name(),
                now,
                now.plusSeconds(REAUTHENTICATION_SECONDS)
        ));
        recordEvent(session, SESSION_REAUTHENTICATED, now);
        return new SessionReauthenticationResponse(
                credential,
                purpose.name(),
                REAUTHENTICATION_SECONDS
        );
    }

    @Transactional
    public void revokeCurrent(Long userId, String currentSessionId) {
        revoke(activeOwnedSession(userId, currentSessionId), "CURRENT_SESSION_LOGOUT");
    }

    @Transactional
    public void revokeOne(
            Long userId,
            String currentSessionId,
            String targetSessionId,
            String reauthenticationCredential
    ) {
        requireReauthentication(
                userId,
                currentSessionId,
                reauthenticationCredential,
                ReauthenticationPurpose.SESSION_MANAGEMENT
        );
        if (currentSessionId.equals(targetSessionId)) {
            throw new BusinessException(
                    HttpStatus.BAD_REQUEST,
                    "CURRENT_SESSION_REQUIRES_LOGOUT",
                    "Use current session logout for this device"
            );
        }
        UserSession target = sessionRepository.findForUpdateByPublicIdAndUserId(targetSessionId, userId)
                .orElseThrow(() -> new BusinessException(
                        HttpStatus.NOT_FOUND,
                        "DEVICE_SESSION_NOT_FOUND",
                        "Device session was not found"
                ));
        revoke(target, "DEVICE_SESSION_LOGOUT");
    }

    @Transactional
    public void revokeOthers(
            Long userId,
            String currentSessionId,
            String reauthenticationCredential
    ) {
        requireReauthentication(
                userId,
                currentSessionId,
                reauthenticationCredential,
                ReauthenticationPurpose.SESSION_MANAGEMENT
        );
        revokeAll(
                sessionRepository.findAllByUser_IdAndRevokedAtIsNullAndPublicIdNot(
                        userId,
                        currentSessionId
                ),
                "OTHER_SESSIONS_LOGOUT"
        );
    }

    @Transactional
    public void revokeAll(
            Long userId,
            String currentSessionId,
            String reauthenticationCredential
    ) {
        requireReauthentication(
                userId,
                currentSessionId,
                reauthenticationCredential,
                ReauthenticationPurpose.SESSION_MANAGEMENT
        );
        revokeAll(
                sessionRepository.findAllByUser_IdAndRevokedAtIsNull(userId),
                "ALL_SESSIONS_LOGOUT"
        );
    }

    @Transactional
    public UserSession consumeReauthentication(
            Long userId,
            String currentSessionId,
            String presentedCredential,
            ReauthenticationPurpose purpose
    ) {
        SessionReauthenticationCredential credential = validatedReauthentication(
                userId,
                currentSessionId,
                presentedCredential,
                purpose,
                true
        );
        credential.revoke(now());
        return credential.getSession();
    }

    @Transactional
    public boolean revokeOthersAfterLoginMethodChange(Long userId, String currentSessionId) {
        List<UserSession> sessions = sessionRepository
                .findAllByUser_IdAndRevokedAtIsNullAndPublicIdNot(userId, currentSessionId);
        revokeAll(sessions, "LOGIN_METHOD_CHANGED");
        return !sessions.isEmpty();
    }

    @Transactional
    public int revokeOthersAfterEmailChange(Long userId, String preservedSessionId) {
        List<UserSession> sessions = sessionRepository
                .findAllByUser_IdAndRevokedAtIsNullAndPublicIdNot(userId, preservedSessionId);
        revokeAll(sessions, "EMAIL_CHANGED");
        return sessions.size();
    }

    @Transactional
    public int revokeAllForMember(Long userId, String reason) {
        List<UserSession> sessions = sessionRepository
                .findAllByUser_IdAndRevokedAtIsNull(userId);
        revokeAll(sessions, reason);
        return sessions.size();
    }

    @Transactional
    public int revokeAllAfterPasswordReset(Long userId) {
        List<UserSession> sessions = sessionRepository
                .findAllByUser_IdAndRevokedAtIsNull(userId);
        revokeAll(sessions, "PASSWORD_RESET");
        return sessions.size();
    }

    private void requireReauthentication(
            Long userId,
            String currentSessionId,
            String presentedCredential,
            ReauthenticationPurpose purpose
    ) {
        validatedReauthentication(userId, currentSessionId, presentedCredential, purpose, false);
    }

    private SessionReauthenticationCredential validatedReauthentication(
            Long userId,
            String currentSessionId,
            String presentedCredential,
            ReauthenticationPurpose purpose,
            boolean lockForUpdate
    ) {
        if (presentedCredential == null || presentedCredential.isBlank()) {
            throw reauthenticationRequired();
        }
        String tokenHash = credentialGenerator.hash(presentedCredential);
        SessionReauthenticationCredential credential = (lockForUpdate
                ? reauthenticationRepository.findForUpdateByTokenHashAndPurpose(
                        tokenHash,
                        purpose.name()
                )
                : reauthenticationRepository.findByTokenHashAndPurpose(tokenHash, purpose.name()))
                .orElseThrow(this::reauthenticationRequired);
        UserSession session = credential.getSession();
        LocalDateTime now = now();
        if (!credential.isUsableAt(now)
                || !session.getPublicId().equals(currentSessionId)
                || !session.getUser().getId().equals(userId)
                || !session.isActiveAt(now)) {
            throw reauthenticationRequired();
        }
        return credential;
    }

    private UserSession activeOwnedSession(Long userId, String sessionId) {
        UserSession session = sessionRepository.findForUpdateByPublicIdAndUserId(sessionId, userId)
                .orElseThrow(this::reauthenticationRequired);
        if (!session.isActiveAt(now())) {
            throw reauthenticationRequired();
        }
        return session;
    }

    private void revokeAll(List<UserSession> sessions, String reason) {
        sessions.forEach(session -> revoke(session, reason));
    }

    private void revoke(UserSession session, String reason) {
        if (session.isRevoked()) {
            return;
        }
        LocalDateTime now = now();
        session.revoke(now, reason);
        recordEvent(session, SESSION_REVOKED, now);
    }

    private void recordEvent(UserSession session, String eventType, LocalDateTime occurredAt) {
        String eventId = UUID.randomUUID().toString();
        auditRepository.save(new SessionSecurityAudit(session, eventId, eventType, occurredAt));
        outboxRepository.save(new OutboxEvent(
                eventId,
                "USER_SESSION",
                session.getPublicId(),
                eventType,
                "{}",
                occurredAt
        ));
    }

    private BusinessException invalidReauthentication() {
        return new BusinessException(
                HttpStatus.UNAUTHORIZED,
                "SESSION_REAUTHENTICATION_FAILED",
                "Password reauthentication failed"
        );
    }

    private BusinessException reauthenticationRequired() {
        return new BusinessException(
                HttpStatus.UNAUTHORIZED,
                "SESSION_REAUTHENTICATION_REQUIRED",
                "A recent purpose-limited reauthentication is required"
        );
    }

    private LocalDateTime now() {
        return LocalDateTime.now(clock);
    }
}
