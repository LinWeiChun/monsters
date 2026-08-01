package com.monsters.service.eligibility;

import com.monsters.config.registration.EligibilityPolicyProperties;
import com.monsters.entity.outbox.*;
import com.monsters.entity.user.*;
import com.monsters.notification.email.*;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.time.*;
import java.util.*;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class GuardianConsentOutboxWorker {
    private final OutboxEventRepository outbox;
    private final GuardianConsentRepository consents;
    private final GuardianConsentTokenRepository tokens;
    private final ObjectProvider<EmailDeliveryPort> deliveryProvider;
    private final EligibilityPolicyProperties policy;
    private final Clock clock;
    private final SecureRandom random = new SecureRandom();
    public GuardianConsentOutboxWorker(OutboxEventRepository outbox, GuardianConsentRepository consents,
            GuardianConsentTokenRepository tokens, ObjectProvider<EmailDeliveryPort> deliveryProvider,
            EligibilityPolicyProperties policy, Clock clock) {
        this.outbox = outbox; this.consents = consents; this.tokens = tokens;
        this.deliveryProvider = deliveryProvider; this.policy = policy; this.clock = clock;
    }
    @Transactional
    public int processPending() {
        int completed = 0; LocalDateTime now = LocalDateTime.now(clock);
        for (String type : List.of("GUARDIAN_CONSENT_GRANT_REQUESTED", "GUARDIAN_CONSENT_WITHDRAWAL_REQUESTED")) {
            for (OutboxEvent event : outbox.findTop50ByEventTypeAndStatusAndAvailableAtLessThanEqualOrderByIdAsc(
                    type, OutboxStatus.PENDING, now)) if (deliver(event, now)) completed++;
        }
        return completed;
    }
    private boolean deliver(OutboxEvent event, LocalDateTime now) {
        GuardianConsentToken token = null;
        try {
            event.markProcessing(); outbox.saveAndFlush(event);
            if (!StringUtils.hasText(policy.getGuardianActionPublicUrl())
                    || !policy.getGuardianActionPublicUrl().startsWith("https://")) throw new IllegalStateException("URL unavailable");
            GuardianConsent consent = consents.findByPublicId(event.getAggregateId())
                    .orElseThrow(() -> new IllegalStateException("Consent unavailable"));
            GuardianConsentTokenPurpose purpose = event.getEventType().contains("WITHDRAWAL")
                    ? GuardianConsentTokenPurpose.WITHDRAW : GuardianConsentTokenPurpose.GRANT;
            String raw = rawToken();
            LocalDateTime expiry = purpose == GuardianConsentTokenPurpose.GRANT
                    ? now.plusHours(policy.getGrantTokenTtlHours())
                    : now.plusMinutes(policy.getWithdrawalTokenTtlMinutes());
            tokens.revokeActive(consent, purpose, now);
            token = tokens.save(new GuardianConsentToken(consent, purpose,
                    GuardianConsentService.hash(raw), expiry));
            EmailDeliveryPort delivery = deliveryProvider.getIfAvailable();
            if (delivery == null) throw new IllegalStateException("Email delivery unavailable");
            delivery.deliver(new EmailDeliveryRequest(consent.getGuardianEmail(),
                    purpose == GuardianConsentTokenPurpose.GRANT ? "guardian-consent-grant" : "guardian-consent-withdraw",
                    Map.of(
                            "actionUrl", policy.getGuardianActionPublicUrl() + "?token="
                                    + URLEncoder.encode(raw, StandardCharsets.UTF_8),
                            "consentReference", consent.getPublicId()
                    )));
            event.markCompleted(); outbox.saveAndFlush(event); return true;
        } catch (RuntimeException exception) {
            if (token != null) token.revoke(now);
            event.markDeliveryFailure(now.plusMinutes(Math.min(60, 1L << Math.min(event.getAttempts(), 5))), 5);
            outbox.saveAndFlush(event); return false;
        }
    }
    private String rawToken() { byte[] bytes = new byte[32]; random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes); }
}
