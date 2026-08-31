package com.monsters.service.auth;

import com.monsters.config.auth.PasswordResetProperties;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.outbox.OutboxStatus;
import com.monsters.entity.user.PasswordResetToken;
import com.monsters.entity.user.User;
import com.monsters.notification.email.EmailDeliveryPort;
import com.monsters.notification.email.EmailDeliveryRequest;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.PasswordResetTokenRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.security.common.PasswordResetTokenService;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class PasswordResetOutboxWorker {

    private static final Logger LOGGER = LoggerFactory.getLogger(PasswordResetOutboxWorker.class);

    private final OutboxEventRepository outboxRepository;
    private final UserRepository userRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final PasswordResetTokenService tokenService;
    private final ObjectProvider<EmailDeliveryPort> emailDeliveryProvider;
    private final PasswordResetProperties properties;
    private final Clock clock;

    public PasswordResetOutboxWorker(
            OutboxEventRepository outboxRepository,
            UserRepository userRepository,
            PasswordResetTokenRepository tokenRepository,
            PasswordResetTokenService tokenService,
            ObjectProvider<EmailDeliveryPort> emailDeliveryProvider,
            PasswordResetProperties properties,
            Clock clock
    ) {
        this.outboxRepository = outboxRepository;
        this.userRepository = userRepository;
        this.tokenRepository = tokenRepository;
        this.tokenService = tokenService;
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
                        PasswordResetService.REQUESTED_EVENT,
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
            if (outboxRepository.existsByEventTypeAndAggregateIdAndIdGreaterThan(
                    PasswordResetService.REQUESTED_EVENT,
                    event.getAggregateId(),
                    event.getId()
            )) {
                event.markCompleted();
                outboxRepository.saveAndFlush(event);
                return true;
            }
            validateConfiguration();
            member = userRepository.findByPublicId(event.getAggregateId())
                    .filter(user -> !user.isDeleted())
                    .orElseThrow(() -> new IllegalStateException("Password reset member missing"));
            String rawToken = tokenService.createToken();
            tokenRepository.revokeActiveForUser(member, now);
            tokenRepository.save(new PasswordResetToken(
                    member,
                    tokenService.hashToken(rawToken),
                    now.plusMinutes(properties.getTokenTtlMinutes())
            ));
            EmailDeliveryPort emailDelivery = emailDeliveryProvider.getIfAvailable();
            if (emailDelivery == null) {
                throw new IllegalStateException("Email delivery is not configured");
            }
            emailDelivery.deliver(new EmailDeliveryRequest(
                    member.getEmail(),
                    "password-reset",
                    Map.of("resetUrl", resetUrl(rawToken))
            ));
            event.markCompleted();
            outboxRepository.saveAndFlush(event);
            return true;
        } catch (RuntimeException exception) {
            logDeliveryFailure(exception);
            if (member != null) {
                tokenRepository.revokeActiveForUser(member, now);
            }
            long retryMinutes = Math.min(60, 1L << Math.min(event.getAttempts(), 5));
            event.markDeliveryFailure(
                    now.plusMinutes(retryMinutes),
                    properties.getMaxDeliveryAttempts()
            );
            outboxRepository.saveAndFlush(event);
            if (event.getStatus() == OutboxStatus.FAILED) {
                LOGGER.error("PASSWORD_RESET_DELIVERY_ALERT status=FAILED eventType={}", event.getEventType());
            }
            return false;
        }
    }

    private void logDeliveryFailure(RuntimeException exception) {
        IllegalStateException sanitizedFailure =
                new IllegalStateException("PASSWORD_RESET_DELIVERY_FAILED");
        sanitizedFailure.setStackTrace(exception.getStackTrace());
        LOGGER.error("Password reset delivery failed", sanitizedFailure);
    }

    private void validateConfiguration() {
        if (!StringUtils.hasText(properties.getPublicUrl())
                || !properties.getPublicUrl().startsWith("https://")
                || properties.getTokenTtlMinutes() != 15
                || properties.getMaxDeliveryAttempts() <= 0) {
            throw new IllegalStateException("Password reset configuration is unavailable");
        }
    }

    private String resetUrl(String rawToken) {
        String separator = properties.getPublicUrl().contains("?") ? "&" : "?";
        return properties.getPublicUrl()
                + separator
                + "token="
                + URLEncoder.encode(rawToken, StandardCharsets.UTF_8);
    }
}
