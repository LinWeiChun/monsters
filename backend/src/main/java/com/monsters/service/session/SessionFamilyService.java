package com.monsters.service.session;

import com.monsters.dto.auth.AuthenticatedMemberResponse;
import com.monsters.entity.audit.SessionSecurityAudit;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.session.RefreshSessionCredential;
import com.monsters.entity.session.UserSession;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
import com.monsters.exception.auth.RefreshReuseDetectedException;
import com.monsters.exception.auth.SessionInvalidException;
import com.monsters.repository.audit.SessionSecurityAuditRepository;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.session.RefreshSessionCredentialRepository;
import com.monsters.repository.session.UserSessionRepository;
import com.monsters.security.common.JwtProperties;
import com.monsters.security.common.JwtTokenService;
import com.monsters.security.session.RefreshCredentialGenerator;
import com.monsters.security.session.SessionProperties;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SessionFamilyService {

    private static final String AGGREGATE_TYPE = "USER_SESSION";
    private static final String SESSION_CREATED = "SESSION_CREATED";
    private static final String SESSION_REFRESH_ROTATED = "SESSION_REFRESH_ROTATED";
    private static final String SESSION_REFRESH_REUSE_DETECTED = "SESSION_REFRESH_REUSE_DETECTED";

    private final UserSessionRepository sessionRepository;
    private final RefreshSessionCredentialRepository credentialRepository;
    private final SessionSecurityAuditRepository auditRepository;
    private final OutboxEventRepository outboxRepository;
    private final RefreshCredentialGenerator credentialGenerator;
    private final JwtTokenService jwtTokenService;
    private final JwtProperties jwtProperties;
    private final SessionProperties sessionProperties;
    private final Clock clock;

    public SessionFamilyService(
            UserSessionRepository sessionRepository,
            RefreshSessionCredentialRepository credentialRepository,
            SessionSecurityAuditRepository auditRepository,
            OutboxEventRepository outboxRepository,
            RefreshCredentialGenerator credentialGenerator,
            JwtTokenService jwtTokenService,
            JwtProperties jwtProperties,
            SessionProperties sessionProperties,
            Clock clock
    ) {
        this.sessionRepository = sessionRepository;
        this.credentialRepository = credentialRepository;
        this.auditRepository = auditRepository;
        this.outboxRepository = outboxRepository;
        this.credentialGenerator = credentialGenerator;
        this.jwtTokenService = jwtTokenService;
        this.jwtProperties = jwtProperties;
        this.sessionProperties = sessionProperties;
        this.clock = clock;
    }

    @Transactional
    public SessionAuthenticationResult create(User user) {
        credentialGenerator.requireDerivationKey(sessionProperties.refreshDerivationKey());
        LocalDateTime now = now();
        UserSession session = sessionRepository.save(new UserSession(
                user,
                now,
                sessionProperties.idleExpirationSeconds(),
                sessionProperties.absoluteExpirationSeconds()
        ));
        String refreshCredential = credentialGenerator.initialCredential();
        credentialRepository.save(new RefreshSessionCredential(
                session,
                credentialGenerator.hash(refreshCredential),
                0,
                now
        ));
        recordSecurityEvent(session, SESSION_CREATED, now, 0);
        return result(session, refreshCredential, now);
    }

    @Transactional(noRollbackFor = {
            RefreshReuseDetectedException.class,
            SessionInvalidException.class
    })
    public SessionAuthenticationResult refresh(String presentedCredential) {
        credentialGenerator.requireDerivationKey(sessionProperties.refreshDerivationKey());
        RefreshSessionCredential credential = credentialRepository.findForRotation(
                        credentialGenerator.hash(presentedCredential)
                )
                .orElseThrow(SessionInvalidException::new);
        UserSession session = credential.getSession();
        LocalDateTime now = now();
        if (!session.isActiveAt(now) || session.getUser().getMemberState() != MemberState.ACTIVE) {
            throw new SessionInvalidException();
        }

        if (credential.isRotated()) {
            if (credential.isWithinGrace(now)) {
                return replayRotation(credential, presentedCredential);
            }
            credential.markReuseDetected(now);
            session.revoke(now, SESSION_REFRESH_REUSE_DETECTED);
            recordSecurityEvent(
                    session,
                    SESSION_REFRESH_REUSE_DETECTED,
                    now,
                    credential.getSequenceNumber()
            );
            throw new RefreshReuseDetectedException();
        }

        long nextSequence = credential.getSequenceNumber() + 1;
        String successor = deriveSuccessor(credential, presentedCredential, nextSequence);
        credential.markRotated(now, sessionProperties.refreshConcurrencyGraceSeconds());
        credentialRepository.save(new RefreshSessionCredential(
                session,
                credentialGenerator.hash(successor),
                nextSequence,
                now
        ));
        session.recordActivity(now, sessionProperties.idleExpirationSeconds());
        recordSecurityEvent(session, SESSION_REFRESH_ROTATED, now, nextSequence);
        return result(session, successor, now);
    }

    private SessionAuthenticationResult replayRotation(
            RefreshSessionCredential credential,
            String presentedCredential
    ) {
        long successorSequence = credential.getSequenceNumber() + 1;
        String successor = deriveSuccessor(credential, presentedCredential, successorSequence);
        RefreshSessionCredential storedSuccessor = credentialRepository
                .findBySessionAndSequenceNumber(credential.getSession(), successorSequence)
                .orElseThrow(SessionInvalidException::new);
        if (!storedSuccessor.getTokenHash().equals(credentialGenerator.hash(successor))) {
            throw new SessionInvalidException();
        }
        return result(credential.getSession(), successor, credential.getRotatedAt());
    }

    private String deriveSuccessor(
            RefreshSessionCredential credential,
            String presentedCredential,
            long nextSequence
    ) {
        return credentialGenerator.deriveSuccessor(
                presentedCredential,
                credential.getSession().getPublicId(),
                nextSequence,
                sessionProperties.refreshDerivationKey()
        );
    }

    private SessionAuthenticationResult result(
            UserSession session,
            String refreshCredential,
            LocalDateTime issuedAt
    ) {
        User user = session.getUser();
        return new SessionAuthenticationResult(
                jwtTokenService.createAccessToken(
                        user,
                        session.getPublicId(),
                        issuedAt.atZone(clock.getZone()).toInstant()
                ),
                refreshCredential,
                "Bearer",
                jwtProperties.accessTokenExpirationSeconds(),
                new AuthenticatedMemberResponse(
                        user.getPublicId(),
                        user.getEmail(),
                        user.getUserName()
                )
        );
    }

    private void recordSecurityEvent(
            UserSession session,
            String eventType,
            LocalDateTime occurredAt,
            long sequence
    ) {
        String eventId = UUID.randomUUID().toString();
        auditRepository.save(new SessionSecurityAudit(
                session,
                eventId,
                eventType,
                occurredAt
        ));
        outboxRepository.save(new OutboxEvent(
                eventId,
                AGGREGATE_TYPE,
                session.getPublicId(),
                eventType,
                "{\"sequence\":" + sequence + "}",
                occurredAt
        ));
    }

    private LocalDateTime now() {
        return LocalDateTime.now(clock);
    }
}
