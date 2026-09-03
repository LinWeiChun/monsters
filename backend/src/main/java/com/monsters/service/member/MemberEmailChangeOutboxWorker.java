package com.monsters.service.member;

import com.monsters.config.member.MemberEmailChangeProperties;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.outbox.OutboxStatus;
import com.monsters.entity.user.MemberEmailChangeRequest;
import com.monsters.entity.user.MemberEmailChangeStatus;
import com.monsters.notification.email.EmailDeliveryPort;
import com.monsters.notification.email.EmailDeliveryRequest;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.MemberEmailChangeRequestRepository;
import com.monsters.security.common.MemberEmailChangeTokenService;
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
public class MemberEmailChangeOutboxWorker {

    private static final Logger LOGGER = LoggerFactory.getLogger(MemberEmailChangeOutboxWorker.class);
    private static final String VERIFICATION_TEMPLATE = "email-change-verification";
    private static final String OLD_NOTIFICATION_TEMPLATE = "email-changed-old";
    private static final String NEW_NOTIFICATION_TEMPLATE = "email-changed-new";

    private final OutboxEventRepository outboxRepository;
    private final MemberEmailChangeRequestRepository requestRepository;
    private final MemberEmailChangeTokenService tokenService;
    private final ObjectProvider<EmailDeliveryPort> emailDeliveryProvider;
    private final MemberEmailChangeProperties properties;
    private final Clock clock;

    public MemberEmailChangeOutboxWorker(
            OutboxEventRepository outboxRepository,
            MemberEmailChangeRequestRepository requestRepository,
            MemberEmailChangeTokenService tokenService,
            ObjectProvider<EmailDeliveryPort> emailDeliveryProvider,
            MemberEmailChangeProperties properties,
            Clock clock
    ) {
        this.outboxRepository = outboxRepository;
        this.requestRepository = requestRepository;
        this.tokenService = tokenService;
        this.emailDeliveryProvider = emailDeliveryProvider;
        this.properties = properties;
        this.clock = clock;
    }

    @Transactional
    public int processPending() {
        LocalDateTime now = now();
        int completed = 0;
        completed += processType(MemberEmailChangeService.REQUESTED_EVENT, now);
        completed += processType(MemberEmailChangeService.OLD_EMAIL_NOTIFICATION_EVENT, now);
        completed += processType(MemberEmailChangeService.NEW_EMAIL_NOTIFICATION_EVENT, now);
        return completed;
    }

    private int processType(String eventType, LocalDateTime now) {
        int completed = 0;
        for (OutboxEvent event : outboxRepository
                .findTop50ByEventTypeAndStatusAndAvailableAtLessThanEqualOrderByIdAsc(
                        eventType,
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
        MemberEmailChangeRequest request = null;
        try {
            event.markProcessing();
            outboxRepository.saveAndFlush(event);
            request = requestRepository.findByPublicId(event.getAggregateId())
                    .orElseThrow(() -> new IllegalStateException("Email change request missing"));
            if (MemberEmailChangeService.REQUESTED_EVENT.equals(event.getEventType())) {
                deliverVerification(request, now);
            } else {
                deliverNotification(request, event.getEventType());
            }
            event.markCompleted();
            outboxRepository.saveAndFlush(event);
            return true;
        } catch (RuntimeException exception) {
            if (request != null && MemberEmailChangeService.REQUESTED_EVENT.equals(event.getEventType())) {
                request.resetDelivery();
            }
            logDeliveryFailure(exception);
            long retryMinutes = Math.min(60, 1L << Math.min(event.getAttempts(), 5));
            event.markDeliveryFailure(now.plusMinutes(retryMinutes), properties.getMaxDeliveryAttempts());
            outboxRepository.saveAndFlush(event);
            if (event.getStatus() == OutboxStatus.FAILED) {
                LOGGER.error("MEMBER_EMAIL_CHANGE_DELIVERY_ALERT status=FAILED eventType={}",
                        event.getEventType());
            }
            return false;
        }
    }

    private void deliverVerification(MemberEmailChangeRequest request, LocalDateTime now) {
        if (request.getStatus() != MemberEmailChangeStatus.PENDING_DELIVERY) {
            return;
        }
        validateConfiguration();
        String rawToken = tokenService.createToken();
        request.awaitVerification(
                tokenService.hashToken(rawToken),
                now.plusHours(properties.getTokenTtlHours())
        );
        deliveryPort().deliver(new EmailDeliveryRequest(
                request.getNewEmail(),
                VERIFICATION_TEMPLATE,
                Map.of("verificationUrl", verificationUrl(rawToken))
        ));
    }

    private void deliverNotification(MemberEmailChangeRequest request, String eventType) {
        if (request.getStatus() != MemberEmailChangeStatus.COMPLETED) {
            throw new IllegalStateException("Email change notification is not ready");
        }
        boolean oldNotification = MemberEmailChangeService.OLD_EMAIL_NOTIFICATION_EVENT.equals(eventType);
        deliveryPort().deliver(new EmailDeliveryRequest(
                oldNotification ? request.getOriginalEmail() : request.getNewEmail(),
                oldNotification ? OLD_NOTIFICATION_TEMPLATE : NEW_NOTIFICATION_TEMPLATE,
                Map.of()
        ));
    }

    private EmailDeliveryPort deliveryPort() {
        EmailDeliveryPort delivery = emailDeliveryProvider.getIfAvailable();
        if (delivery == null) {
            throw new IllegalStateException("Email delivery is not configured");
        }
        return delivery;
    }

    private void validateConfiguration() {
        if (!StringUtils.hasText(properties.getPublicUrl())
                || !properties.getPublicUrl().startsWith("https://")
                || properties.getTokenTtlHours() != 24
                || properties.getMaxDeliveryAttempts() <= 0) {
            throw new IllegalStateException("Email change configuration is unavailable");
        }
    }

    private String verificationUrl(String rawToken) {
        String separator = properties.getPublicUrl().contains("?") ? "&" : "?";
        return properties.getPublicUrl()
                + separator
                + "token="
                + URLEncoder.encode(rawToken, StandardCharsets.UTF_8);
    }

    private void logDeliveryFailure(RuntimeException exception) {
        IllegalStateException sanitizedFailure = new IllegalStateException(
                "MEMBER_EMAIL_CHANGE_DELIVERY_FAILED"
        );
        sanitizedFailure.setStackTrace(exception.getStackTrace());
        LOGGER.error("Member Email change delivery failed", sanitizedFailure);
    }

    private LocalDateTime now() {
        return LocalDateTime.now(clock);
    }
}
