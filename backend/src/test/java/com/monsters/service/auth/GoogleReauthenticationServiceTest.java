package com.monsters.service.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.auth.GoogleReauthenticationRequest;
import com.monsters.dto.auth.SessionReauthenticationResponse;
import com.monsters.entity.session.ReauthenticationPurpose;
import com.monsters.entity.user.User;
import com.monsters.entity.user.UserOAuthAccount;
import com.monsters.exception.common.UnauthorizedException;
import com.monsters.repository.user.UserOAuthAccountRepository;
import com.monsters.security.common.GoogleIdTokenVerifier;
import com.monsters.security.common.GoogleUserInfo;
import com.monsters.service.session.DeviceSessionCommandService;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class GoogleReauthenticationServiceTest {

    @Mock private GoogleIdTokenVerifier googleIdTokenVerifier;
    @Mock private UserOAuthAccountRepository oauthAccountRepository;
    @Mock private DeviceSessionCommandService sessionCommandService;

    private GoogleReauthenticationService service;

    @BeforeEach
    void setUp() {
        service = new GoogleReauthenticationService(
                googleIdTokenVerifier,
                oauthAccountRepository,
                sessionCommandService
        );
    }

    @Test
    void shouldIssuePurposeBoundCredentialForExactlyLinkedGoogleSubject() {
        User member = member(7L);
        when(googleIdTokenVerifier.verify("google-token"))
                .thenReturn(new GoogleUserInfo("google-sub", "changed@example.test", null, null));
        when(oauthAccountRepository.findByProviderAndProviderUserId("google", "google-sub"))
                .thenReturn(Optional.of(new UserOAuthAccount(member, "google", "google-sub")));
        when(sessionCommandService.issueVerifiedReauthentication(
                7L,
                "current-session",
                ReauthenticationPurpose.EMAIL_CHANGE
        )).thenReturn(new SessionReauthenticationResponse("proof", "EMAIL_CHANGE", 300));

        SessionReauthenticationResponse response = service.reauthenticate(
                7L,
                "current-session",
                new GoogleReauthenticationRequest(
                        "google-token",
                        ReauthenticationPurpose.EMAIL_CHANGE
                )
        );

        assertThat(response.credential()).isEqualTo("proof");
        assertThat(response.purpose()).isEqualTo("EMAIL_CHANGE");
    }

    @Test
    void shouldRejectSubjectLinkedToAnotherMemberWithoutIssuingCredential() {
        User anotherMember = member(8L);
        when(googleIdTokenVerifier.verify("google-token"))
                .thenReturn(new GoogleUserInfo("google-sub", "member@example.test", null, null));
        when(oauthAccountRepository.findByProviderAndProviderUserId("google", "google-sub"))
                .thenReturn(Optional.of(new UserOAuthAccount(
                        anotherMember,
                        "google",
                        "google-sub"
                )));

        assertThatThrownBy(() -> service.reauthenticate(
                7L,
                "current-session",
                new GoogleReauthenticationRequest(
                        "google-token",
                        ReauthenticationPurpose.BIRTHDAY_CORRECTION
                )
        )).isInstanceOf(UnauthorizedException.class)
                .hasMessage("Google reauthentication failed");
        verify(sessionCommandService, never()).issueVerifiedReauthentication(
                7L,
                "current-session",
                ReauthenticationPurpose.BIRTHDAY_CORRECTION
        );
    }

    @Test
    void shouldRejectSessionManagementPurposeBeforeGoogleVerification() {
        assertThatThrownBy(() -> service.reauthenticate(
                7L,
                "current-session",
                new GoogleReauthenticationRequest(
                        "google-token",
                        ReauthenticationPurpose.SESSION_MANAGEMENT
                )
        )).isInstanceOf(UnauthorizedException.class);
        verify(googleIdTokenVerifier, never()).verify("google-token");
    }

    private User member(Long id) {
        User user = new User("synthetic_account_" + id, "member@example.test", "Member");
        ReflectionTestUtils.setField(user, "id", id);
        return user;
    }
}
