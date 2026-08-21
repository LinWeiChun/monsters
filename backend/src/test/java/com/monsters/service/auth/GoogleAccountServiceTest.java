package com.monsters.service.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.auth.AuthenticatedMemberResponse;
import com.monsters.dto.auth.GoogleAccountLinkRequest;
import com.monsters.dto.auth.GoogleAccountLinkResponse;
import com.monsters.dto.auth.GoogleLoginRequest;
import com.monsters.dto.auth.VerifiedEmailLoginResponse;
import com.monsters.entity.audit.SessionSecurityAudit;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.session.ReauthenticationPurpose;
import com.monsters.entity.session.UserSession;
import com.monsters.entity.user.User;
import com.monsters.entity.user.UserOAuthAccount;
import com.monsters.exception.common.BusinessException;
import com.monsters.repository.audit.SessionSecurityAuditRepository;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.UserOAuthAccountRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.security.common.GoogleIdTokenVerifier;
import com.monsters.security.common.GoogleUserInfo;
import com.monsters.security.session.SessionDeviceContext;
import com.monsters.service.session.DeviceSessionCommandService;
import com.monsters.service.session.SessionAuthenticationResult;
import com.monsters.service.session.SessionFamilyService;
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
class GoogleAccountServiceTest {

    private static final Clock CLOCK = Clock.fixed(
            Instant.parse("2026-08-21T03:00:00Z"),
            ZoneOffset.UTC
    );

    @Mock private GoogleIdTokenVerifier googleIdTokenVerifier;
    @Mock private UserRepository userRepository;
    @Mock private UserOAuthAccountRepository oauthAccountRepository;
    @Mock private ContinuationCredentialService continuationCredentialService;
    @Mock private SessionFamilyService sessionFamilyService;
    @Mock private DeviceSessionCommandService sessionCommandService;
    @Mock private SessionSecurityAuditRepository auditRepository;
    @Mock private OutboxEventRepository outboxRepository;

    private GoogleAccountService service;

    @BeforeEach
    void setUp() {
        service = new GoogleAccountService(
                googleIdTokenVerifier,
                userRepository,
                oauthAccountRepository,
                continuationCredentialService,
                sessionFamilyService,
                sessionCommandService,
                auditRepository,
                outboxRepository,
                CLOCK
        );
    }

    @Test
    void loginShouldRequireExplicitLinkWithoutCreatingSessionForExistingEmail() {
        User existing = activeUser(1L, "member@example.test");
        when(googleIdTokenVerifier.verify("google-token"))
                .thenReturn(googleUser("google-sub", "member@example.test"));
        when(oauthAccountRepository.findByProviderAndProviderUserId("google", "google-sub"))
                .thenReturn(Optional.empty());
        when(userRepository.findByEmailAndDeletedFalse("member@example.test"))
                .thenReturn(Optional.of(existing));

        VerifiedEmailLoginResponse response = service.login(
                new GoogleLoginRequest("google-token"),
                SessionDeviceContext.unknown()
        );

        assertThat(response.requiresGoogleAccountLink()).isTrue();
        assertThat(response.accessToken()).isNull();
        assertThat(response.refreshToken()).isNull();
        verify(oauthAccountRepository, never()).save(any(UserOAuthAccount.class));
        verify(sessionFamilyService, never()).create(any(), any());
    }

    @Test
    void loginShouldAuthenticateOnlyAnExactlyLinkedGoogleSubject() {
        User existing = activeUser(2L, "member@example.test");
        UserOAuthAccount linked = new UserOAuthAccount(existing, "google", "google-sub");
        when(googleIdTokenVerifier.verify("google-token"))
                .thenReturn(googleUser("google-sub", "changed@example.test"));
        when(oauthAccountRepository.findByProviderAndProviderUserId("google", "google-sub"))
                .thenReturn(Optional.of(linked));
        when(sessionFamilyService.create(existing, SessionDeviceContext.unknown()))
                .thenReturn(new SessionAuthenticationResult(
                        "access-token",
                        "refresh-credential",
                        "Bearer",
                        600,
                        new AuthenticatedMemberResponse(
                                existing.getPublicId(),
                                existing.getEmail(),
                                existing.getUserName()
                        )
                ));

        VerifiedEmailLoginResponse response = service.login(
                new GoogleLoginRequest("google-token"),
                SessionDeviceContext.unknown()
        );

        assertThat(response.accessToken()).isEqualTo("access-token");
        assertThat(response.user().publicId()).isEqualTo(existing.getPublicId());
        verify(userRepository, never()).findByEmailAndDeletedFalse(any());
    }

    @Test
    void linkShouldConsumeLinkPurposeAndRevokeOnlyOtherSessions() {
        User existing = activeUser(3L, "member@example.test");
        UserSession currentSession = new UserSession(
                existing,
                LocalDateTime.now(CLOCK),
                300,
                600
        );
        when(googleIdTokenVerifier.verify("fresh-google-token"))
                .thenReturn(googleUser("google-sub", "member@example.test"));
        when(userRepository.findByIdAndDeletedFalse(3L)).thenReturn(Optional.of(existing));
        when(sessionCommandService.consumeReauthentication(
                3L,
                currentSession.getPublicId(),
                "link-proof",
                ReauthenticationPurpose.LOGIN_METHOD_LINK
        )).thenReturn(currentSession);
        when(oauthAccountRepository.findByProviderAndProviderUserId("google", "google-sub"))
                .thenReturn(Optional.empty());
        when(oauthAccountRepository.findByUser_IdAndProvider(3L, "google"))
                .thenReturn(Optional.empty());
        when(sessionCommandService.revokeOthersAfterLoginMethodChange(
                3L,
                currentSession.getPublicId()
        )).thenReturn(true);

        GoogleAccountLinkResponse response = service.link(
                3L,
                currentSession.getPublicId(),
                "link-proof",
                new GoogleAccountLinkRequest("fresh-google-token", true)
        );

        assertThat(response.linked()).isTrue();
        assertThat(response.currentSessionPreserved()).isTrue();
        assertThat(response.otherSessionsRevoked()).isTrue();
        verify(oauthAccountRepository).save(any(UserOAuthAccount.class));
        verify(auditRepository).save(any(SessionSecurityAudit.class));
        ArgumentCaptor<OutboxEvent> event = ArgumentCaptor.forClass(OutboxEvent.class);
        verify(outboxRepository).save(event.capture());
        assertThat(event.getValue().getEventType()).isEqualTo("LOGIN_METHOD_LINKED");
    }

    @Test
    void linkShouldReturnGenericConflictWhenVerifiedEmailsDoNotMatch() {
        User existing = activeUser(4L, "member@example.test");
        UserSession currentSession = new UserSession(
                existing,
                LocalDateTime.now(CLOCK),
                300,
                600
        );
        when(googleIdTokenVerifier.verify("fresh-google-token"))
                .thenReturn(googleUser("google-sub", "other@example.test"));
        when(userRepository.findByIdAndDeletedFalse(4L)).thenReturn(Optional.of(existing));
        when(sessionCommandService.consumeReauthentication(
                4L,
                currentSession.getPublicId(),
                "link-proof",
                ReauthenticationPurpose.LOGIN_METHOD_LINK
        )).thenReturn(currentSession);

        assertThatThrownBy(() -> service.link(
                4L,
                currentSession.getPublicId(),
                "link-proof",
                new GoogleAccountLinkRequest("fresh-google-token", true)
        )).isInstanceOf(BusinessException.class)
                .hasMessage("Google account cannot be linked");
        verify(oauthAccountRepository, never()).save(any(UserOAuthAccount.class));
    }

    private User activeUser(Long id, String email) {
        User user = new User("synthetic_account_" + id, email, "Synthetic Member");
        ReflectionTestUtils.setField(user, "id", id);
        return user;
    }

    private GoogleUserInfo googleUser(String subject, String email) {
        return new GoogleUserInfo(subject, email, "Synthetic Member", null);
    }
}
