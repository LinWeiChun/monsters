package com.monsters.service.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.when;

import com.monsters.dto.auth.ForgotPasswordRequest;
import com.monsters.dto.auth.ForgotPasswordResponse;
import com.monsters.dto.auth.LoginRequest;
import com.monsters.dto.auth.LoginResponse;
import com.monsters.dto.auth.GoogleLoginRequest;
import com.monsters.dto.auth.RegisterRequest;
import com.monsters.dto.auth.RegisterResponse;
import com.monsters.dto.auth.RefreshTokenRequest;
import com.monsters.dto.auth.ResetPasswordRequest;
import com.monsters.dto.auth.VerifiedEmailLoginRequest;
import com.monsters.dto.auth.VerifiedEmailLoginResponse;
import com.monsters.exception.common.ConflictException;
import com.monsters.exception.common.UnauthorizedException;
import com.monsters.security.common.GoogleIdTokenVerifier;
import com.monsters.security.common.GoogleUserInfo;
import com.monsters.security.common.JwtProperties;
import com.monsters.security.common.JwtTokenService;
import com.monsters.security.common.PasswordResetTokenService;
import com.monsters.security.password.PasswordHashService;
import com.monsters.security.password.PasswordPolicy;
import com.monsters.service.session.SessionAuthenticationResult;
import com.monsters.service.session.SessionFamilyService;
import com.monsters.entity.user.PasswordResetToken;
import com.monsters.entity.user.User;
import com.monsters.entity.user.UserCredential;
import com.monsters.entity.user.UserOAuthAccount;
import com.monsters.repository.user.PasswordResetTokenRepository;
import com.monsters.repository.user.MemberContinuationCredentialRepository;
import com.monsters.repository.user.UserCredentialRepository;
import com.monsters.repository.user.UserOAuthAccountRepository;
import com.monsters.repository.user.UserRepository;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private UserCredentialRepository userCredentialRepository;

    @Mock
    private UserOAuthAccountRepository userOAuthAccountRepository;

    @Mock
    private PasswordResetTokenRepository passwordResetTokenRepository;

    @Mock
    private PasswordPolicy passwordPolicy;

    @Mock
    private PasswordHashService passwordHashService;

    @Mock
    private JwtTokenService jwtTokenService;

    @Mock
    private JwtProperties jwtProperties;

    @Mock
    private GoogleIdTokenVerifier googleIdTokenVerifier;

    @Mock
    private PasswordResetTokenService passwordResetTokenService;

    @Mock
    private TokenRevocationService tokenRevocationService;

    @Mock
    private MemberContinuationCredentialRepository memberContinuationCredentialRepository;

    @Mock
    private SessionFamilyService sessionFamilyService;

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(
                userRepository,
                userCredentialRepository,
                userOAuthAccountRepository,
                passwordResetTokenRepository,
                passwordPolicy,
                passwordHashService,
                jwtTokenService,
                jwtProperties,
                googleIdTokenVerifier,
                passwordResetTokenService,
                tokenRevocationService,
                new ContinuationCredentialService(
                        memberContinuationCredentialRepository,
                        Clock.systemDefaultZone()
                ),
                sessionFamilyService,
                Clock.systemDefaultZone()
        );
    }

    @Test
    void refreshShouldRotateTokenAndReturnNewLoginResponse() {
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        com.monsters.security.common.JwtTokenPayload payload =
                new com.monsters.security.common.JwtTokenPayload(
                        1L,
                        "user@example.com",
                        "refresh",
                        java.time.Instant.now(),
                        java.time.Instant.now().plusSeconds(3600)
                );
        when(tokenRevocationService.consumeRefreshToken("old-refresh-token")).thenReturn(payload);
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.of(user));
        when(jwtTokenService.createAccessToken(user)).thenReturn("new-access-token");
        when(jwtTokenService.createRefreshToken(user)).thenReturn("new-refresh-token");
        when(jwtProperties.accessTokenExpirationSeconds()).thenReturn(3600L);

        LoginResponse response = authService.refresh(new RefreshTokenRequest("old-refresh-token"));

        assertThat(response.accessToken()).isEqualTo("new-access-token");
        assertThat(response.refreshToken()).isEqualTo("new-refresh-token");
        assertThat(response.user().userId()).isEqualTo(1L);
    }

    @Test
    void refreshShouldRejectDeletedOrMissingUser() {
        com.monsters.security.common.JwtTokenPayload payload =
                new com.monsters.security.common.JwtTokenPayload(
                        99L,
                        "deleted@example.com",
                        "refresh",
                        java.time.Instant.now(),
                        java.time.Instant.now().plusSeconds(3600)
                );
        when(tokenRevocationService.consumeRefreshToken("refresh-token")).thenReturn(payload);
        when(userRepository.findByIdAndDeletedFalse(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> authService.refresh(new RefreshTokenRequest("refresh-token")))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessage("Invalid refresh token");
    }

    @Test
    void registerShouldCreateUserAndCredential() {
        RegisterRequest request = new RegisterRequest(" Wei_Account ", " USER@example.COM ", "password123", " Wei ");
        when(userRepository.existsByAccount("wei_account")).thenReturn(false);
        when(userRepository.existsByEmail("user@example.com")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(passwordPolicy.normalizeAndValidate("password123")).thenReturn("password123");
        when(passwordHashService.encode("password123")).thenReturn("encoded-password");

        RegisterResponse response = authService.register(request);

        assertThat(response.account()).isEqualTo("wei_account");
        assertThat(response.email()).isEqualTo("user@example.com");
        assertThat(response.userName()).isEqualTo("Wei");

        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(userCaptor.capture());
        assertThat(userCaptor.getValue().getAccount()).isEqualTo("wei_account");
        assertThat(userCaptor.getValue().getEmail()).isEqualTo("user@example.com");
        assertThat(userCaptor.getValue().getUserName()).isEqualTo("Wei");

        ArgumentCaptor<UserCredential> credentialCaptor = ArgumentCaptor.forClass(UserCredential.class);
        verify(userCredentialRepository).save(credentialCaptor.capture());
        assertThat(credentialCaptor.getValue().getPasswordHash()).isEqualTo("encoded-password");
    }

    @Test
    void registerShouldRejectDuplicateEmail() {
        RegisterRequest request = new RegisterRequest("wei_account", "user@example.com", "password123", "Wei");
        when(userRepository.existsByAccount("wei_account")).thenReturn(false);
        when(userRepository.existsByEmail("user@example.com")).thenReturn(true);

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Email already registered");
    }

    @Test
    void registerShouldRejectDuplicateAccount() {
        RegisterRequest request = new RegisterRequest("Wei_Account", "user@example.com", "password123", "Wei");
        when(userRepository.existsByAccount("wei_account")).thenReturn(true);

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Account already registered");

        verify(userRepository, never()).existsByEmail("user@example.com");
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void loginShouldReturnTokensAndUser() {
        LoginRequest request = new LoginRequest(" USER@example.COM ", "password123");
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        UserCredential credential = new UserCredential(user, "encoded-password");

        when(userRepository.findByEmailOrAccountAndDeletedFalse("user@example.com")).thenReturn(Optional.of(user));
        when(userCredentialRepository.findByUser(user)).thenReturn(Optional.of(credential));
        when(passwordHashService.matches("password123", "encoded-password")).thenReturn(true);
        when(jwtTokenService.createAccessToken(user)).thenReturn("access-token");
        when(jwtTokenService.createRefreshToken(user)).thenReturn("refresh-token");
        when(jwtProperties.accessTokenExpirationSeconds()).thenReturn(3600L);

        LoginResponse response = authService.login(request);

        assertThat(response.accessToken()).isEqualTo("access-token");
        assertThat(response.refreshToken()).isEqualTo("refresh-token");
        assertThat(response.tokenType()).isEqualTo("Bearer");
        assertThat(response.expiresIn()).isEqualTo(3600);
        assertThat(response.user().userId()).isEqualTo(1);
        assertThat(response.user().account()).isEqualTo("wei_account");
        assertThat(response.user().email()).isEqualTo("user@example.com");
        assertThat(response.user().userName()).isEqualTo("Wei");
    }

    @Test
    void loginShouldFindUserByNormalizedAccount() {
        LoginRequest request = new LoginRequest(" WEI_ACCOUNT ", "password123");
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        UserCredential credential = new UserCredential(user, "encoded-password");

        when(userRepository.findByEmailOrAccountAndDeletedFalse("wei_account")).thenReturn(Optional.of(user));
        when(userCredentialRepository.findByUser(user)).thenReturn(Optional.of(credential));
        when(passwordHashService.matches("password123", "encoded-password")).thenReturn(true);
        when(jwtTokenService.createAccessToken(user)).thenReturn("access-token");
        when(jwtTokenService.createRefreshToken(user)).thenReturn("refresh-token");
        when(jwtProperties.accessTokenExpirationSeconds()).thenReturn(3600L);

        LoginResponse response = authService.login(request);

        assertThat(response.user().account()).isEqualTo("wei_account");
        verify(userRepository).findByEmailOrAccountAndDeletedFalse("wei_account");
    }

    @Test
    void verifiedEmailLoginShouldUseOnlyTheNormalizedExactEmail() {
        VerifiedEmailLoginRequest request =
                new VerifiedEmailLoginRequest(" FIRST.Last+tag@GMAIL.com ", "password123");
        User user = new User("legacy_account", "first.last+tag@gmail.com", "Wei");
        UserCredential credential = new UserCredential(user, "encoded-password");

        when(userRepository.findByEmailAndDeletedFalse("first.last+tag@gmail.com"))
                .thenReturn(Optional.of(user));
        when(userCredentialRepository.findByUser(user)).thenReturn(Optional.of(credential));
        when(passwordHashService.matches("password123", "encoded-password")).thenReturn(true);
        when(sessionFamilyService.create(user)).thenReturn(new SessionAuthenticationResult(
                "access-token",
                "refresh-token",
                "Bearer",
                600,
                new com.monsters.dto.auth.AuthenticatedMemberResponse(
                        user.getPublicId(),
                        user.getEmail(),
                        user.getUserName()
                )
        ));

        VerifiedEmailLoginResponse response = authService.loginVerifiedEmail(request);

        assertThat(response.user().publicId()).isEqualTo(user.getPublicId());
        assertThat(response.user().email()).isEqualTo("first.last+tag@gmail.com");
        assertThat(response.user().userName()).isEqualTo("Wei");
        verify(userRepository).findByEmailAndDeletedFalse("first.last+tag@gmail.com");
        verify(userRepository, never())
                .findByEmailOrAccountAndDeletedFalse("first.last+tag@gmail.com");
    }

    @Test
    void verifiedEmailLoginShouldRejectLegacyAccountIdentifier() {
        VerifiedEmailLoginRequest request =
                new VerifiedEmailLoginRequest("legacy_account", "password123");
        when(userRepository.findByEmailAndDeletedFalse("legacy_account"))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> authService.loginVerifiedEmail(request))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessage("Invalid email or password");
    }

    @Test
    void loginShouldRejectUnknownEmail() {
        LoginRequest request = new LoginRequest("user@example.com", "password123");
        when(userRepository.findByEmailOrAccountAndDeletedFalse("user@example.com")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessage("Invalid email or password");
    }

    @Test
    void loginShouldRejectWrongPassword() {
        LoginRequest request = new LoginRequest("user@example.com", "wrong-password");
        User user = new User("wei_account", "user@example.com", "Wei");
        UserCredential credential = new UserCredential(user, "encoded-password");

        when(userRepository.findByEmailOrAccountAndDeletedFalse("user@example.com")).thenReturn(Optional.of(user));
        when(userCredentialRepository.findByUser(user)).thenReturn(Optional.of(credential));
        when(passwordHashService.matches("wrong-password", "encoded-password")).thenReturn(false);

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessage("Invalid email or password");
        assertThat(credential.getPasswordHash()).isEqualTo("encoded-password");
        verify(passwordHashService, never()).encode("wrong-password");
    }

    @Test
    void loginShouldRehashLegacyCredentialOnlyAfterSuccessfulVerification() {
        LoginRequest request = new LoginRequest("user@example.com", "password123");
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        UserCredential credential = new UserCredential(user, "legacy-bcrypt-hash");

        when(userRepository.findByEmailOrAccountAndDeletedFalse("user@example.com"))
                .thenReturn(Optional.of(user));
        when(userCredentialRepository.findByUser(user)).thenReturn(Optional.of(credential));
        when(passwordHashService.matches("password123", "legacy-bcrypt-hash")).thenReturn(true);
        when(passwordHashService.needsRehash("legacy-bcrypt-hash")).thenReturn(true);
        when(passwordHashService.encode("password123")).thenReturn("argon2id-hash");
        when(jwtTokenService.createAccessToken(user)).thenReturn("access-token");
        when(jwtTokenService.createRefreshToken(user)).thenReturn("refresh-token");
        when(jwtProperties.accessTokenExpirationSeconds()).thenReturn(3600L);

        authService.login(request);

        assertThat(credential.getPasswordHash()).isEqualTo("argon2id-hash");
    }

    @Test
    void googleLoginShouldCreateUserAndOAuthAccount() {
        GoogleLoginRequest request = new GoogleLoginRequest("google-id-token");
        GoogleUserInfo googleUser = new GoogleUserInfo(
                "google-sub",
                " USER@example.COM ",
                " Wei ",
                "https://example.com/avatar.png"
        );
        User savedUser = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(savedUser, "id", 1L);

        when(googleIdTokenVerifier.verify("google-id-token")).thenReturn(googleUser);
        when(userOAuthAccountRepository.findByProviderAndProviderUserId("google", "google-sub"))
                .thenReturn(Optional.empty());
        when(userRepository.findByEmailAndDeletedFalse("user@example.com")).thenReturn(Optional.empty());
        when(userRepository.existsByAccount("user")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(jwtTokenService.createAccessToken(savedUser)).thenReturn("access-token");
        when(jwtTokenService.createRefreshToken(savedUser)).thenReturn("refresh-token");
        when(jwtProperties.accessTokenExpirationSeconds()).thenReturn(3600L);

        LoginResponse response = authService.googleLogin(request);

        assertThat(response.accessToken()).isEqualTo("access-token");
        assertThat(response.user().email()).isEqualTo("user@example.com");

        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(userCaptor.capture());
        assertThat(userCaptor.getValue().getAccount()).isEqualTo("user");

        ArgumentCaptor<UserOAuthAccount> oauthCaptor = ArgumentCaptor.forClass(UserOAuthAccount.class);
        verify(userOAuthAccountRepository).save(oauthCaptor.capture());
        assertThat(oauthCaptor.getValue().getProvider()).isEqualTo("google");
        assertThat(oauthCaptor.getValue().getProviderUserId()).isEqualTo("google-sub");
        assertThat(oauthCaptor.getValue().getUser()).isEqualTo(savedUser);
    }

    @Test
    void googleLoginShouldUseExistingOAuthAccount() {
        GoogleLoginRequest request = new GoogleLoginRequest("google-id-token");
        GoogleUserInfo googleUser = new GoogleUserInfo("google-sub", "user@example.com", "Wei", null);
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        UserOAuthAccount oauthAccount = new UserOAuthAccount(user, "google", "google-sub");

        when(googleIdTokenVerifier.verify("google-id-token")).thenReturn(googleUser);
        when(userOAuthAccountRepository.findByProviderAndProviderUserId("google", "google-sub"))
                .thenReturn(Optional.of(oauthAccount));
        when(jwtTokenService.createAccessToken(user)).thenReturn("access-token");
        when(jwtTokenService.createRefreshToken(user)).thenReturn("refresh-token");
        when(jwtProperties.accessTokenExpirationSeconds()).thenReturn(3600L);

        LoginResponse response = authService.googleLogin(request);

        assertThat(response.accessToken()).isEqualTo("access-token");
        assertThat(response.user().userId()).isEqualTo(1);
    }

    @Test
    void googleLoginShouldLinkExistingEmailUser() {
        GoogleLoginRequest request = new GoogleLoginRequest("google-id-token");
        GoogleUserInfo googleUser = new GoogleUserInfo("google-sub", "user@example.com", "Wei", null);
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);

        when(googleIdTokenVerifier.verify("google-id-token")).thenReturn(googleUser);
        when(userOAuthAccountRepository.findByProviderAndProviderUserId("google", "google-sub"))
                .thenReturn(Optional.empty());
        when(userRepository.findByEmailAndDeletedFalse("user@example.com")).thenReturn(Optional.of(user));
        when(jwtTokenService.createAccessToken(user)).thenReturn("access-token");
        when(jwtTokenService.createRefreshToken(user)).thenReturn("refresh-token");
        when(jwtProperties.accessTokenExpirationSeconds()).thenReturn(3600L);

        LoginResponse response = authService.googleLogin(request);

        assertThat(response.user().email()).isEqualTo("user@example.com");
        verify(userOAuthAccountRepository).save(any(UserOAuthAccount.class));
    }

    @Test
    void forgotPasswordShouldCreateResetTokenForExistingUser() {
        ForgotPasswordRequest request = new ForgotPasswordRequest(" USER@example.COM ");
        User user = new User("wei_account", "user@example.com", "Wei");
        when(userRepository.findByEmailAndDeletedFalse("user@example.com")).thenReturn(Optional.of(user));
        when(passwordResetTokenService.createToken()).thenReturn("reset-token");
        when(passwordResetTokenService.hashToken("reset-token")).thenReturn("token-hash");

        ForgotPasswordResponse response = authService.forgotPassword(request);

        assertThat(response.resetToken()).isEqualTo("reset-token");
        assertThat(response.expiresIn()).isEqualTo(900);
        verify(passwordResetTokenRepository).deleteByUserAndUsedAtIsNull(user);

        ArgumentCaptor<PasswordResetToken> tokenCaptor = ArgumentCaptor.forClass(PasswordResetToken.class);
        verify(passwordResetTokenRepository).save(tokenCaptor.capture());
        assertThat(tokenCaptor.getValue().getUser()).isEqualTo(user);
        assertThat(tokenCaptor.getValue().getTokenHash()).isEqualTo("token-hash");
        assertThat(tokenCaptor.getValue().getExpiresAt()).isAfter(LocalDateTime.now());
    }

    @Test
    void forgotPasswordShouldNotRevealUnknownEmail() {
        ForgotPasswordRequest request = new ForgotPasswordRequest("unknown@example.com");
        when(userRepository.findByEmailAndDeletedFalse("unknown@example.com")).thenReturn(Optional.empty());

        ForgotPasswordResponse response = authService.forgotPassword(request);

        assertThat(response.resetToken()).isNull();
        assertThat(response.expiresIn()).isEqualTo(900);
        verify(passwordResetTokenRepository, never()).save(any(PasswordResetToken.class));
    }

    @Test
    void resetPasswordShouldUpdateExistingCredentialAndMarkTokenUsed() {
        ResetPasswordRequest request = new ResetPasswordRequest("reset-token", "password123");
        User user = new User("wei_account", "user@example.com", "Wei");
        UserCredential credential = new UserCredential(user, "old-password-hash");
        PasswordResetToken resetToken = new PasswordResetToken(
                user,
                "token-hash",
                LocalDateTime.now().plusMinutes(10)
        );

        when(passwordResetTokenService.hashToken("reset-token")).thenReturn("token-hash");
        when(passwordResetTokenRepository.findByTokenHashAndUsedAtIsNull("token-hash"))
                .thenReturn(Optional.of(resetToken));
        when(passwordPolicy.normalizeAndValidate("password123")).thenReturn("password123");
        when(passwordHashService.encode("password123")).thenReturn("new-password-hash");
        when(userCredentialRepository.findByUser(user)).thenReturn(Optional.of(credential));

        authService.resetPassword(request);

        assertThat(credential.getPasswordHash()).isEqualTo("new-password-hash");
        assertThat(resetToken.getUsedAt()).isNotNull();
    }

    @Test
    void resetPasswordShouldCreateCredentialForOAuthOnlyUser() {
        ResetPasswordRequest request = new ResetPasswordRequest("reset-token", "password123");
        User user = new User("wei_account", "user@example.com", "Wei");
        PasswordResetToken resetToken = new PasswordResetToken(
                user,
                "token-hash",
                LocalDateTime.now().plusMinutes(10)
        );

        when(passwordResetTokenService.hashToken("reset-token")).thenReturn("token-hash");
        when(passwordResetTokenRepository.findByTokenHashAndUsedAtIsNull("token-hash"))
                .thenReturn(Optional.of(resetToken));
        when(passwordPolicy.normalizeAndValidate("password123")).thenReturn("password123");
        when(passwordHashService.encode("password123")).thenReturn("new-password-hash");
        when(userCredentialRepository.findByUser(user)).thenReturn(Optional.empty());

        authService.resetPassword(request);

        ArgumentCaptor<UserCredential> credentialCaptor = ArgumentCaptor.forClass(UserCredential.class);
        verify(userCredentialRepository).save(credentialCaptor.capture());
        assertThat(credentialCaptor.getValue().getUser()).isEqualTo(user);
        assertThat(credentialCaptor.getValue().getPasswordHash()).isEqualTo("new-password-hash");
        assertThat(resetToken.getUsedAt()).isNotNull();
    }

    @Test
    void resetPasswordShouldRejectExpiredToken() {
        ResetPasswordRequest request = new ResetPasswordRequest("reset-token", "password123");
        User user = new User("wei_account", "user@example.com", "Wei");
        PasswordResetToken resetToken = new PasswordResetToken(
                user,
                "token-hash",
                LocalDateTime.now().minusMinutes(1)
        );

        when(passwordResetTokenService.hashToken("reset-token")).thenReturn("token-hash");
        when(passwordResetTokenRepository.findByTokenHashAndUsedAtIsNull("token-hash"))
                .thenReturn(Optional.of(resetToken));

        assertThatThrownBy(() -> authService.resetPassword(request))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessage("Invalid password reset token");
    }
}
