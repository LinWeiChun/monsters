package com.monsters.service.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.auth.PasswordResetCompletionRequest;
import com.monsters.dto.auth.PasswordResetEmailRequest;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.user.PasswordResetToken;
import com.monsters.entity.user.User;
import com.monsters.entity.user.UserCredential;
import com.monsters.exception.common.BusinessException;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.PasswordResetTokenRepository;
import com.monsters.repository.user.UserCredentialRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.security.common.PasswordResetTokenService;
import com.monsters.security.password.PasswordHashService;
import com.monsters.security.password.PasswordPolicy;
import com.monsters.service.session.DeviceSessionCommandService;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class PasswordResetServiceTest {

    private static final Clock CLOCK = Clock.fixed(
            Instant.parse("2026-08-28T03:00:00Z"),
            ZoneOffset.UTC
    );

    @Mock private UserRepository userRepository;
    @Mock private UserCredentialRepository credentialRepository;
    @Mock private PasswordResetTokenRepository tokenRepository;
    @Mock private OutboxEventRepository outboxRepository;
    @Mock private PasswordResetTokenService tokenService;
    @Mock private PasswordPolicy passwordPolicy;
    @Mock private PasswordHashService passwordHashService;
    @Mock private DeviceSessionCommandService sessionCommandService;
    @Mock private PasswordResetRateLimitService rateLimitService;

    private PasswordResetService service;

    @BeforeEach
    void setUp() {
        service = new PasswordResetService(
                userRepository,
                credentialRepository,
                tokenRepository,
                outboxRepository,
                tokenService,
                passwordPolicy,
                passwordHashService,
                sessionCommandService,
                rateLimitService,
                CLOCK
        );
    }

    @Test
    void requestShouldUseGenericOutboxWithoutEmailOrTokenPayload() {
        User member = member();
        when(userRepository.findByEmailAndDeletedFalse("member@example.test"))
                .thenReturn(Optional.of(member));

        service.request(
                new PasswordResetEmailRequest(" MEMBER@EXAMPLE.TEST "),
                "192.0.2.10"
        );

        verify(rateLimitService).accept("member@example.test", "192.0.2.10");
        verify(tokenRepository).revokeActiveForUser(member, now());
        ArgumentCaptor<OutboxEvent> eventCaptor = ArgumentCaptor.forClass(OutboxEvent.class);
        verify(outboxRepository).save(eventCaptor.capture());
        assertThat(eventCaptor.getValue().getEventType()).isEqualTo("PASSWORD_RESET_REQUESTED");
        assertThat(eventCaptor.getValue().getPayload()).isEqualTo("{}");
        assertThat(eventCaptor.getValue().getPayload()).doesNotContain("member@example.test", "token");
    }

    @Test
    void requestShouldNotRevealOrEnqueueUnknownEmail() {
        when(userRepository.findByEmailAndDeletedFalse("unknown@example.test"))
                .thenReturn(Optional.empty());

        service.request(
                new PasswordResetEmailRequest("unknown@example.test"),
                "192.0.2.10"
        );

        verify(rateLimitService).accept("unknown@example.test", "192.0.2.10");
        verify(outboxRepository, never()).save(any(OutboxEvent.class));
    }

    @Test
    void completeShouldUpdatePasswordUseTokenAndRevokeEverySession() {
        User member = member();
        UserCredential credential = new UserCredential(member, "old-hash");
        PasswordResetToken token = token(member, now().plusMinutes(15));
        when(tokenService.hashToken("raw-token")).thenReturn("a".repeat(64));
        when(tokenRepository.findByTokenHash("a".repeat(64))).thenReturn(Optional.of(token));
        when(passwordPolicy.normalizeAndValidate("correct horse battery staple"))
                .thenReturn("correct horse battery staple");
        when(passwordHashService.encode("correct horse battery staple")).thenReturn("$argon2id$new");
        when(credentialRepository.findByUser(member)).thenReturn(Optional.of(credential));
        when(sessionCommandService.revokeAllAfterPasswordReset(1L)).thenReturn(2);

        service.complete(new PasswordResetCompletionRequest(
                "raw-token",
                "correct horse battery staple"
        ));

        assertThat(credential.getPasswordHash()).isEqualTo("$argon2id$new");
        assertThat(token.getUsedAt()).isEqualTo(now());
        verify(tokenRepository).revokeActiveForUser(member, now());
        verify(sessionCommandService).revokeAllAfterPasswordReset(1L);
        ArgumentCaptor<OutboxEvent> eventCaptor = ArgumentCaptor.forClass(OutboxEvent.class);
        verify(outboxRepository).save(eventCaptor.capture());
        assertThat(eventCaptor.getValue().getEventType()).isEqualTo("PASSWORD_RESET_COMPLETED");
        assertThat(eventCaptor.getValue().getPayload()).isEqualTo("{\"revokedSessions\":2}");
    }

    @Test
    void completeShouldCreateCredentialForGoogleOnlyMember() {
        User member = member();
        PasswordResetToken token = token(member, now().plusMinutes(15));
        when(tokenService.hashToken("raw-token")).thenReturn("b".repeat(64));
        when(tokenRepository.findByTokenHash("b".repeat(64))).thenReturn(Optional.of(token));
        when(passwordPolicy.normalizeAndValidate("correct horse battery staple"))
                .thenReturn("correct horse battery staple");
        when(passwordHashService.encode("correct horse battery staple")).thenReturn("$argon2id$new");
        when(credentialRepository.findByUser(member)).thenReturn(Optional.empty());

        service.complete(new PasswordResetCompletionRequest(
                "raw-token",
                "correct horse battery staple"
        ));

        ArgumentCaptor<UserCredential> credentialCaptor = ArgumentCaptor.forClass(UserCredential.class);
        verify(credentialRepository).save(credentialCaptor.capture());
        assertThat(credentialCaptor.getValue().getUser()).isEqualTo(member);
        assertThat(credentialCaptor.getValue().getPasswordHash()).isEqualTo("$argon2id$new");
    }

    @Test
    void completeShouldReturnStableExpiredCode() {
        User member = member();
        PasswordResetToken token = token(member, now());
        when(tokenService.hashToken("raw-token")).thenReturn("c".repeat(64));
        when(tokenRepository.findByTokenHash("c".repeat(64))).thenReturn(Optional.of(token));

        assertThatThrownBy(() -> service.complete(
                new PasswordResetCompletionRequest("raw-token", "correct horse battery staple")
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getCode()).isEqualTo("PASSWORD_RESET_TOKEN_EXPIRED"));
    }

    @Test
    void completeShouldReturnStableUsedCode() {
        User member = member();
        PasswordResetToken token = token(member, now().plusMinutes(15));
        token.markUsed(now().minusMinutes(1));
        when(tokenService.hashToken("raw-token")).thenReturn("d".repeat(64));
        when(tokenRepository.findByTokenHash("d".repeat(64))).thenReturn(Optional.of(token));

        assertThatThrownBy(() -> service.complete(
                new PasswordResetCompletionRequest("raw-token", "correct horse battery staple")
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getCode()).isEqualTo("PASSWORD_RESET_TOKEN_USED"));
    }

    @Test
    void completeShouldReturnStableInvalidCodeForRevokedToken() {
        User member = member();
        PasswordResetToken token = token(member, now().plusMinutes(15));
        token.revoke(now().minusMinutes(1));
        when(tokenService.hashToken("raw-token")).thenReturn("e".repeat(64));
        when(tokenRepository.findByTokenHash("e".repeat(64))).thenReturn(Optional.of(token));

        assertThatThrownBy(() -> service.complete(
                new PasswordResetCompletionRequest("raw-token", "correct horse battery staple")
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getCode()).isEqualTo("PASSWORD_RESET_TOKEN_INVALID"));
    }

    private User member() {
        User member = new User("legacy_account", "member@example.test", "Synthetic Member");
        ReflectionTestUtils.setField(member, "id", 1L);
        return member;
    }

    private PasswordResetToken token(User member, LocalDateTime expiresAt) {
        return new PasswordResetToken(member, "f".repeat(64), expiresAt);
    }

    private LocalDateTime now() {
        return LocalDateTime.now(CLOCK);
    }
}
