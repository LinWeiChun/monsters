package com.monsters.service.registration;

import com.monsters.config.registration.RegistrationEmailVerificationProperties;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.outbox.OutboxStatus;
import com.monsters.entity.user.EmailVerificationToken;
import com.monsters.entity.user.User;
import com.monsters.notification.email.EmailDeliveryPort;
import com.monsters.notification.email.EmailDeliveryRequest;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.EmailVerificationTokenRepository;
import com.monsters.repository.user.UserRepository;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Map;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class EmailVerificationOutboxWorker {

    private static final String EVENT_TYPE = "EMAIL_VERIFICATION_REQUESTED";
    private static final int TOKEN_BYTES = 32;

    private final OutboxEventRepository outboxRepository;
    private final UserRepository userRepository;
    private final EmailVerificationTokenRepository tokenRepository;
    private final ObjectProvider<EmailDeliveryPort> emailDeliveryProvider;
    private final RegistrationEmailVerificationProperties properties;
    private final Clock clock;
    private final SecureRandom secureRandom = new SecureRandom();

    public EmailVerificationOutboxWorker(
            OutboxEventRepository outboxRepository,
            UserRepository userRepository,
            EmailVerificationTokenRepository tokenRepository,
            ObjectProvider<EmailDeliveryPort> emailDeliveryProvider,
            RegistrationEmailVerificationProperties properties,
            Clock clock
    ) {
        this.outboxRepository = outboxRepository;
        this.userRepository = userRepository;
        this.tokenRepository = tokenRepository;
        this.emailDeliveryProvider = emailDeliveryProvider;
        this.properties = properties;
        this.clock = clock;
    }

    @Transactional
    public int processPending() {
        LocalDateTime now = LocalDateTime.now(clock);
        int completed = 0;
        for (OutboxEvent event : outboxRepository
                .findTop50ByEventTypeAndStatusAndAvailableAtLessThanEqualOrderByIdAsc(
                        EVENT_TYPE,
                        OutboxStatus.PENDING,
                        now
                )) {
            if (deliver(event, now)) {
                completed++;
            }
        }
        return completed;
    }

    private boolean deliver(OutboxEvent event, LocalDateTime now) {
        User member = null;
        try {
            event.markProcessing();
            outboxRepository.saveAndFlush(event);
            validateConfiguration();
            member = userRepository.findByPublicId(event.getAggregateId())
                    .orElseThrow(() -> new IllegalStateException("Email verification member missing"));
            String rawToken = createToken();
            tokenRepository.revokeActiveForUser(member, now);
            tokenRepository.save(new EmailVerificationToken(
                    member,
                    hash(rawToken),
                    now.plusHours(properties.getTokenTtlHours())
            ));
            EmailDeliveryPort emailDelivery = emailDeliveryProvider.getIfAvailable();
            if (emailDelivery == null) {
                throw new IllegalStateException("Email delivery is not configured");
            }
            emailDelivery.deliver(new EmailDeliveryRequest(
                    member.getEmail(),
                    "verify-email",
                    Map.of("verificationUrl", verificationUrl(rawToken))
            ));
            event.markCompleted();
            outboxRepository.saveAndFlush(event);
            return true;
        } catch (RuntimeException exception) {
            if (member != null) {
                tokenRepository.revokeActiveForUser(member, now);
            }
            long retryMinutes = Math.min(60, 1L << Math.min(event.getAttempts(), 5));
            event.markDeliveryFailure(
                    now.plusMinutes(retryMinutes),
                    properties.getMaxDeliveryAttempts()
            );
            outboxRepository.saveAndFlush(event);
            return false;
        }
    }

    private void validateConfiguration() {
        if (!StringUtils.hasText(properties.getPublicUrl())
                || !properties.getPublicUrl().startsWith("https://")
                || properties.getTokenTtlHours() <= 0
                || properties.getMaxDeliveryAttempts() <= 0) {
            throw new IllegalStateException("Email verification configuration is unavailable");
        }
    }

    private String createToken() {
        byte[] bytes = new byte[TOKEN_BYTES];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
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

    private String verificationUrl(String rawToken) {
        String separator = properties.getPublicUrl().contains("?") ? "&" : "?";
        return properties.getPublicUrl()
                + separator
                + "token="
                + URLEncoder.encode(rawToken, StandardCharsets.UTF_8);
    }
}
