package com.monsters.service.eligibility;

import com.monsters.dto.auth.*;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.user.*;
import com.monsters.exception.common.BusinessException;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.*;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.time.*;
import java.util.*;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class GuardianConsentService {
    private final GuardianConsentRepository consents;
    private final GuardianConsentTokenRepository tokens;
    private final MemberContinuationCredentialRepository continuations;
    private final OutboxEventRepository outbox;
    private final Clock clock;
    public GuardianConsentService(GuardianConsentRepository consents, GuardianConsentTokenRepository tokens,
            MemberContinuationCredentialRepository continuations, OutboxEventRepository outbox, Clock clock) {
        this.consents = consents; this.tokens = tokens; this.continuations = continuations;
        this.outbox = outbox; this.clock = clock;
    }
    @Transactional(readOnly = true)
    public GuardianConsentActionResponse inspect(String rawToken) {
        GuardianConsentToken token = usableToken(rawToken);
        return new GuardianConsentActionResponse(token.getPurpose().name(), token.getConsent().getStatus().name(),
                token.getConsent().getPublicId());
    }
    @Transactional
    public GuardianConsentActionResponse grant(String rawToken) {
        LocalDateTime now = LocalDateTime.now(clock);
        GuardianConsentToken token = usableToken(rawToken);
        if (token.getPurpose() != GuardianConsentTokenPurpose.GRANT) throw invalidToken();
        GuardianConsent consent = token.getConsent();
        token.consume(now); consent.grant(now); consent.getUser().grantMinorEligibility();
        return new GuardianConsentActionResponse("GRANT", "GRANTED", consent.getPublicId());
    }
    @Transactional
    public void requestWithdrawal(GuardianWithdrawalRequest request) {
        consents.findByPublicId(request.consentReference()).filter(consent ->
                consent.getStatus() == GuardianConsentStatus.GRANTED
                        && consent.getGuardianEmail().equals(request.guardianEmail().strip().toLowerCase(Locale.ROOT)))
                .ifPresent(consent -> outbox.save(new OutboxEvent(UUID.randomUUID().toString(),
                        "GUARDIAN_CONSENT", consent.getPublicId(),
                        "GUARDIAN_CONSENT_WITHDRAWAL_REQUESTED", "{}", LocalDateTime.now(clock))));
    }
    @Transactional
    public GuardianConsentActionResponse withdraw(String rawToken) {
        LocalDateTime now = LocalDateTime.now(clock);
        GuardianConsentToken token = usableToken(rawToken);
        if (token.getPurpose() != GuardianConsentTokenPurpose.WITHDRAW) throw invalidToken();
        GuardianConsent consent = token.getConsent();
        token.consume(now); consent.withdraw(now); consent.getUser().withdrawGuardianEligibility();
        continuations.revokeActiveForUser(consent.getUser(), now);
        return new GuardianConsentActionResponse("WITHDRAW", "WITHDRAWN", consent.getPublicId());
    }
    private GuardianConsentToken usableToken(String rawToken) {
        GuardianConsentToken token = tokens.findByTokenHash(hash(rawToken)).orElseThrow(this::invalidToken);
        LocalDateTime now = LocalDateTime.now(clock);
        if (token.isExpiredAt(now)) throw new BusinessException(HttpStatus.BAD_REQUEST,
                "GUARDIAN_CONSENT_TOKEN_EXPIRED", "Guardian consent link is invalid or expired");
        if (!token.isUsableAt(now)) throw invalidToken();
        return token;
    }
    private BusinessException invalidToken() {
        return new BusinessException(HttpStatus.BAD_REQUEST, "GUARDIAN_CONSENT_TOKEN_INVALID",
                "Guardian consent link is invalid or expired");
    }
    static String hash(String token) {
        if (token == null || token.isBlank() || token.length() > 512) return "invalid";
        try { return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                .digest(token.getBytes(StandardCharsets.UTF_8))); }
        catch (NoSuchAlgorithmException exception) { throw new IllegalStateException("Token hashing failed", exception); }
    }
}
