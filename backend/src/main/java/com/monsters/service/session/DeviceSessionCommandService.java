package com.monsters.service.session;

import com.monsters.dto.auth.SessionReauthenticationResponse;
import com.monsters.entity.audit.SessionSecurityAudit;
import com.monsters.entity.outbox.OutboxEvent;
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
    private static final String PURPOSE = "SESSION_MANAGEMENT";
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
        var user = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(this::invalidReauthentication);
        var passwordCredential = userCredentialRepository.findByUser(user)
                .orElseThrow(this::invalidReauthentication);
        if (!passwordHashService.matches(password, passwordCredential.getPasswordHash())) {
            throw invalidReauthentication();
        }
        UserSession session = activeOwnedSession(userId, currentSessionId);
        LocalDateTime now = now();
        String credential = credentialGenerator.initialCredential();
        reauthenticationRepository.save(new SessionReauthenticationCredential(
                session,
                credentialGenerator.hash(credential),
                PURPOSE,
                now,
                now.plusSeconds(REAUTHENTICATION_SECONDS)
        ));
        recordEvent(session, SESSION_REAUTHENTICATED, now);
        return new SessionReauthenticationResponse(
                credential,
                PURPOSE,
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
        requireReauthentication(userId, currentSessionId, reauthenticationCredential);
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
        requireReauthentication(userId, currentSessionId, reauthenticationCredential);
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
        requireReauthentication(userId, currentSessionId, reauthenticationCredential);
        revokeAll(
                sessionRepository.findAllByUser_IdAndRevokedAtIsNull(userId),
                "ALL_SESSIONS_LOGOUT"
        );
    }

    private void requireReauthentication(
            Long userId,
            String currentSessionId,
            String presentedCredential
    ) {
        if (presentedCredential == null || presentedCredential.isBlank()) {
            throw reauthenticationRequired();
        }
        SessionReauthenticationCredential credential = reauthenticationRepository
                .findByTokenHashAndPurpose(credentialGenerator.hash(presentedCredential), PURPOSE)
                .orElseThrow(this::reauthenticationRequired);
        UserSession session = credential.getSession();
        if (!credential.isUsableAt(now())
                || !session.getPublicId().equals(currentSessionId)
                || !session.getUser().getId().equals(userId)
                || !session.isActiveAt(now())) {
            throw reauthenticationRequired();
        }
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
                "A recent session-management reauthentication is required"
        );
    }

    private LocalDateTime now() {
        return LocalDateTime.now(clock);
    }
}
