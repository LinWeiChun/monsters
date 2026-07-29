package com.monsters.service.registration;

import com.monsters.dto.auth.EmailVerificationRequest;
import com.monsters.dto.auth.LoginResponse;
import com.monsters.entity.audit.MemberStateActorType;
import com.monsters.entity.audit.MemberStateAudit;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.user.EmailVerificationToken;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
import com.monsters.exception.common.BusinessException;
import com.monsters.repository.audit.MemberStateAuditRepository;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.EmailVerificationTokenRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.service.auth.ContinuationCredentialService;
import com.monsters.service.auth.IssuedContinuationCredential;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EmailVerificationService {

    private final EmailVerificationTokenRepository tokenRepository;
    private final UserRepository userRepository;
    private final MemberStateAuditRepository auditRepository;
    private final OutboxEventRepository outboxRepository;
    private final ContinuationCredentialService continuationCredentialService;
    private final Clock clock;

    public EmailVerificationService(
            EmailVerificationTokenRepository tokenRepository,
            UserRepository userRepository,
            MemberStateAuditRepository auditRepository,
            OutboxEventRepository outboxRepository,
            ContinuationCredentialService continuationCredentialService,
            Clock clock
    ) {
        this.tokenRepository = tokenRepository;
        this.userRepository = userRepository;
        this.auditRepository = auditRepository;
        this.outboxRepository = outboxRepository;
        this.continuationCredentialService = continuationCredentialService;
        this.clock = clock;
    }

    @Transactional
    public LoginResponse verify(EmailVerificationRequest request) {
        LocalDateTime now = LocalDateTime.now(clock);
        EmailVerificationToken token = tokenRepository.findByTokenHash(hash(request.token()))
                .orElseThrow(this::invalidToken);
        if (token.isUsed() || token.isRevoked()) {
            throw invalidToken();
        }
        if (!token.getExpiresAt().isAfter(now)) {
            throw new BusinessException(
                    HttpStatus.BAD_REQUEST,
                    "EMAIL_VERIFICATION_TOKEN_EXPIRED",
                    "Email verification token has expired"
            );
        }

        User member = token.getUser();
        if (member.getMemberState() != MemberState.PENDING_EMAIL_VERIFICATION) {
            throw invalidToken();
        }

        MemberState fromState = member.getMemberState();
        token.markUsed(now);
        tokenRepository.saveAndFlush(token);
        tokenRepository.revokeActiveForUser(member, now);
        member.completeEmailVerification();
        userRepository.saveAndFlush(member);

        String eventId = UUID.randomUUID().toString();
        auditRepository.save(new MemberStateAudit(
                member,
                eventId,
                fromState,
                member.getMemberState(),
                "EMAIL_VERIFIED",
                MemberStateActorType.SYSTEM,
                now
        ));
        outboxRepository.save(new OutboxEvent(
                eventId,
                "MEMBER",
                member.getPublicId(),
                "MEMBER_STATE_CHANGED",
                stateChangedPayload(fromState, member),
                now
        ));
        IssuedContinuationCredential credential = continuationCredentialService.issueFor(member);
        return LoginResponse.continuation(
                credential.credential(),
                credential.nextAction(),
                credential.expiresIn()
        );
    }

    private BusinessException invalidToken() {
        return new BusinessException(
                HttpStatus.BAD_REQUEST,
                "EMAIL_VERIFICATION_TOKEN_INVALID",
                "Email verification token is invalid"
        );
    }

    private String hash(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(
                    digest.digest(token.getBytes(StandardCharsets.UTF_8))
            );
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("Email verification token hashing failed", exception);
        }
    }

    private String stateChangedPayload(MemberState fromState, User member) {
        return """
                {"fromState":"%s","toState":"%s","version":%d}
                """.formatted(fromState, member.getMemberState(), member.getVersion()).trim();
    }
}
