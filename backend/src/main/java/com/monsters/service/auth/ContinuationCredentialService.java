package com.monsters.service.auth;

import com.monsters.dto.auth.ContinuationNextAction;
import com.monsters.entity.user.MemberContinuationCredential;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
import com.monsters.repository.user.MemberContinuationCredentialRepository;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HexFormat;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.monsters.exception.common.BusinessException;
import org.springframework.http.HttpStatus;

@Service
public class ContinuationCredentialService {

    static final Duration CREDENTIAL_TTL = Duration.ofMinutes(10);
    private static final int CREDENTIAL_BYTES = 32;

    private final MemberContinuationCredentialRepository credentialRepository;
    private final Clock clock;
    private final SecureRandom secureRandom;

    public ContinuationCredentialService(
            MemberContinuationCredentialRepository credentialRepository,
            Clock clock
    ) {
        this.credentialRepository = credentialRepository;
        this.clock = clock;
        this.secureRandom = new SecureRandom();
    }

    public IssuedContinuationCredential issueFor(User user) {
        ContinuationNextAction nextAction = nextActionFor(user.getMemberState());
        LocalDateTime issuedAt = LocalDateTime.now(clock);
        credentialRepository.revokeActiveForUser(user, issuedAt);

        String rawCredential = createCredential();
        credentialRepository.save(new MemberContinuationCredential(
                user,
                hash(rawCredential),
                nextAction,
                issuedAt.plus(CREDENTIAL_TTL)
        ));

        return new IssuedContinuationCredential(
                rawCredential,
                nextAction,
                CREDENTIAL_TTL.toSeconds()
        );
    }

    @Transactional
    public User authenticateEligibility(String rawCredential) {
        if (rawCredential == null || rawCredential.isBlank() || rawCredential.length() > 512) {
            throw invalidCredential();
        }
        LocalDateTime now = LocalDateTime.now(clock);
        MemberContinuationCredential credential = credentialRepository.findByTokenHash(hash(rawCredential))
                .orElseThrow(this::invalidCredential);
        if (credential.getNextAction() != ContinuationNextAction.COMPLETE_ELIGIBILITY
                || !credential.isUsableAt(now)) {
            throw invalidCredential();
        }
        return credential.getUser();
    }

    @Transactional
    public void consumeEligibilityCredential(String rawCredential) {
        MemberContinuationCredential credential = credentialRepository.findByTokenHash(hash(rawCredential))
                .orElseThrow(this::invalidCredential);
        credential.consume(LocalDateTime.now(clock));
    }

    private BusinessException invalidCredential() {
        return new BusinessException(HttpStatus.UNAUTHORIZED, "ELIGIBILITY_CONTINUATION_INVALID",
                "Eligibility continuation is invalid or expired");
    }

    private ContinuationNextAction nextActionFor(MemberState memberState) {
        return switch (memberState) {
            case PENDING_EMAIL_VERIFICATION -> ContinuationNextAction.VERIFY_EMAIL;
            case PENDING_ELIGIBILITY -> ContinuationNextAction.COMPLETE_ELIGIBILITY;
            case USER_DEACTIVATED -> ContinuationNextAction.REACTIVATE_ACCOUNT;
            case ADMIN_SUSPENDED -> ContinuationNextAction.REVIEW_SUSPENSION;
            case DELETION_PENDING -> ContinuationNextAction.REVIEW_DELETION;
            case ACTIVE, DELETED -> throw new IllegalArgumentException(
                    "Member state does not allow a continuation credential"
            );
        };
    }

    private String createCredential() {
        byte[] bytes = new byte[CREDENTIAL_BYTES];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String hash(String credential) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(credential.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("Continuation credential hashing failed", exception);
        }
    }
}
