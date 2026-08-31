package com.monsters.service.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

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
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class PasswordResetOutboxWorkerTest {

    private static final Clock CLOCK = Clock.fixed(
            Instant.parse("2026-08-28T03:00:00Z"),
            ZoneOffset.UTC
    );

    @Mock private OutboxEventRepository outboxRepository;
    @Mock private UserRepository userRepository;
    @Mock private PasswordResetTokenRepository tokenRepository;
    @Mock private PasswordResetTokenService tokenService;
    @Mock private ObjectProvider<EmailDeliveryPort> emailDeliveryProvider;
    @Mock private EmailDeliveryPort emailDelivery;

    @Test
    void shouldGenerateRawTokenOnlyInsideWorkerAndDeliverFifteenMinuteLink() {
        PasswordResetProperties properties = properties();
        User member = new User("legacy_account", "member@example.test", "Synthetic Member");
        OutboxEvent event = new OutboxEvent(
                "00000000-0000-0000-0000-000000000001",
                "MEMBER",
                member.getPublicId(),
                PasswordResetService.REQUESTED_EVENT,
                "{}",
                now()
        );
        ReflectionTestUtils.setField(event, "id", 1L);
        when(outboxRepository
                .findTop50ByEventTypeAndStatusAndAvailableAtLessThanEqualOrderByIdAsc(
                        PasswordResetService.REQUESTED_EVENT,
                        OutboxStatus.PENDING,
                        now()
                )).thenReturn(List.of(event));
        when(outboxRepository.existsByEventTypeAndAggregateIdAndIdGreaterThan(
                PasswordResetService.REQUESTED_EVENT,
                member.getPublicId(),
                1L
        )).thenReturn(false);
        when(userRepository.findByPublicId(member.getPublicId())).thenReturn(Optional.of(member));
        when(tokenService.createToken()).thenReturn("raw-token");
        when(tokenService.hashToken("raw-token")).thenReturn("a".repeat(64));
        when(emailDeliveryProvider.getIfAvailable()).thenReturn(emailDelivery);

        int completed = worker(properties).processPending();

        assertThat(completed).isEqualTo(1);
        assertThat(event.getStatus()).isEqualTo(OutboxStatus.COMPLETED);
        ArgumentCaptor<PasswordResetToken> tokenCaptor =
                ArgumentCaptor.forClass(PasswordResetToken.class);
        verify(tokenRepository).save(tokenCaptor.capture());
        assertThat(tokenCaptor.getValue().getTokenHash()).isEqualTo("a".repeat(64));
        assertThat(tokenCaptor.getValue().getExpiresAt()).isEqualTo(now().plusMinutes(15));
        ArgumentCaptor<EmailDeliveryRequest> emailCaptor =
                ArgumentCaptor.forClass(EmailDeliveryRequest.class);
        verify(emailDelivery).deliver(emailCaptor.capture());
        assertThat(emailCaptor.getValue().recipient()).isEqualTo("member@example.test");
        assertThat(emailCaptor.getValue().templateId()).isEqualTo("password-reset");
        assertThat(emailCaptor.getValue().variables().get("resetUrl"))
                .isEqualTo("https://app.example.test/reset-password?token=raw-token");
    }

    @Test
    void shouldSkipSupersededPendingRequest() {
        PasswordResetProperties properties = properties();
        OutboxEvent event = new OutboxEvent(
                "00000000-0000-0000-0000-000000000001",
                "MEMBER",
                "00000000-0000-0000-0000-000000000002",
                PasswordResetService.REQUESTED_EVENT,
                "{}",
                now()
        );
        ReflectionTestUtils.setField(event, "id", 1L);
        when(outboxRepository
                .findTop50ByEventTypeAndStatusAndAvailableAtLessThanEqualOrderByIdAsc(
                        PasswordResetService.REQUESTED_EVENT,
                        OutboxStatus.PENDING,
                        now()
                )).thenReturn(List.of(event));
        when(outboxRepository.existsByEventTypeAndAggregateIdAndIdGreaterThan(
                PasswordResetService.REQUESTED_EVENT,
                event.getAggregateId(),
                1L
        )).thenReturn(true);

        assertThat(worker(properties).processPending()).isEqualTo(1);
        assertThat(event.getStatus()).isEqualTo(OutboxStatus.COMPLETED);
        verify(tokenService, org.mockito.Mockito.never()).createToken();
    }

    private PasswordResetOutboxWorker worker(PasswordResetProperties properties) {
        return new PasswordResetOutboxWorker(
                outboxRepository,
                userRepository,
                tokenRepository,
                tokenService,
                emailDeliveryProvider,
                properties,
                CLOCK
        );
    }

    private PasswordResetProperties properties() {
        PasswordResetProperties properties = new PasswordResetProperties();
        properties.setPublicUrl("https://app.example.test/reset-password");
        properties.setTokenTtlMinutes(15);
        properties.setMaxDeliveryAttempts(5);
        return properties;
    }

    private LocalDateTime now() {
        return LocalDateTime.now(CLOCK);
    }
}
