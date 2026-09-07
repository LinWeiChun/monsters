package com.monsters.service.member;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.config.member.MemberEmailChangeProperties;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.outbox.OutboxStatus;
import com.monsters.entity.session.UserSession;
import com.monsters.entity.user.MemberEmailChangeRequest;
import com.monsters.entity.user.MemberEmailChangeStatus;
import com.monsters.entity.user.User;
import com.monsters.notification.email.EmailDeliveryPort;
import com.monsters.notification.email.EmailDeliveryRequest;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.MemberEmailChangeRequestRepository;
import com.monsters.security.common.MemberEmailChangeTokenService;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.ObjectProvider;

@ExtendWith(MockitoExtension.class)
class MemberEmailChangeOutboxWorkerTest {

    private static final Clock CLOCK = Clock.fixed(
            Instant.parse("2026-09-01T03:00:00Z"),
            ZoneOffset.UTC
    );

    @Mock private OutboxEventRepository outboxRepository;
    @Mock private MemberEmailChangeRequestRepository requestRepository;
    @Mock private MemberEmailChangeTokenService tokenService;
    @Mock private ObjectProvider<EmailDeliveryPort> emailDeliveryProvider;
    @Mock private EmailDeliveryPort emailDelivery;

    @Test
    void shouldCreateHashedTwentyFourHourTokenAndSendRawTokenOnlyInVerificationLink() {
        User member = new User("synthetic_account", "old@example.test", "Synthetic Member");
        UserSession session = new UserSession(member, now(), 300, 600);
        MemberEmailChangeRequest request = new MemberEmailChangeRequest(
                member,
                session,
                member.getEmail(),
                "new@example.test",
                member.getVersion()
        );
        OutboxEvent event = new OutboxEvent(
                "00000000-0000-0000-0000-000000000001",
                "MEMBER_EMAIL_CHANGE",
                request.getPublicId(),
                MemberEmailChangeService.REQUESTED_EVENT,
                "{}",
                now()
        );
        when(outboxRepository.findTop50ByEventTypeAndStatusAndAvailableAtLessThanEqualOrderByIdAsc(
                MemberEmailChangeService.REQUESTED_EVENT,
                OutboxStatus.PENDING,
                now()
        )).thenReturn(List.of(event));
        when(requestRepository.findByPublicId(request.getPublicId()))
                .thenReturn(Optional.of(request));
        when(tokenService.createToken()).thenReturn("raw-token");
        when(tokenService.hashToken("raw-token")).thenReturn("a".repeat(64));
        when(emailDeliveryProvider.getIfAvailable()).thenReturn(emailDelivery);

        assertThat(worker().processPending()).isEqualTo(1);

        assertThat(event.getStatus()).isEqualTo(OutboxStatus.COMPLETED);
        assertThat(request.getStatus()).isEqualTo(MemberEmailChangeStatus.PENDING_VERIFICATION);
        assertThat(request.getTokenHash()).isEqualTo("a".repeat(64));
        assertThat(request.getExpiresAt()).isEqualTo(now().plusHours(24));
        ArgumentCaptor<EmailDeliveryRequest> delivery =
                ArgumentCaptor.forClass(EmailDeliveryRequest.class);
        verify(emailDelivery).deliver(delivery.capture());
        assertThat(delivery.getValue().recipient()).isEqualTo("new@example.test");
        assertThat(delivery.getValue().templateId()).isEqualTo("email-change-verification");
        assertThat(delivery.getValue().variables().get("verificationUrl"))
                .isEqualTo("https://app.example.test/change-email?token=raw-token");
        assertThat(event.getPayload()).doesNotContain("raw-token", "new@example.test");
    }

    private MemberEmailChangeOutboxWorker worker() {
        MemberEmailChangeProperties properties = new MemberEmailChangeProperties();
        properties.setPublicUrl("https://app.example.test/change-email");
        properties.setTokenTtlHours(24);
        properties.setMaxDeliveryAttempts(5);
        return new MemberEmailChangeOutboxWorker(
                outboxRepository,
                requestRepository,
                tokenService,
                emailDeliveryProvider,
                properties,
                CLOCK
        );
    }

    private LocalDateTime now() {
        return LocalDateTime.now(CLOCK);
    }
}
