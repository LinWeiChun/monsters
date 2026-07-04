package com.monsters.auth.service;

import com.monsters.auth.dto.AuthUserResponse;
import com.monsters.auth.dto.ForgotPasswordRequest;
import com.monsters.auth.dto.ForgotPasswordResponse;
import com.monsters.auth.dto.GoogleLoginRequest;
import com.monsters.auth.dto.LoginRequest;
import com.monsters.auth.dto.LoginResponse;
import com.monsters.auth.dto.RegisterRequest;
import com.monsters.auth.dto.RegisterResponse;
import com.monsters.auth.dto.ResetPasswordRequest;
import com.monsters.common.exception.ConflictException;
import com.monsters.common.exception.UnauthorizedException;
import com.monsters.common.security.GoogleIdTokenVerifier;
import com.monsters.common.security.GoogleUserInfo;
import com.monsters.common.security.JwtProperties;
import com.monsters.common.security.JwtTokenService;
import com.monsters.common.security.PasswordResetTokenService;
import com.monsters.user.entity.PasswordResetToken;
import com.monsters.user.entity.User;
import com.monsters.user.entity.UserCredential;
import com.monsters.user.entity.UserOAuthAccount;
import com.monsters.user.repository.PasswordResetTokenRepository;
import com.monsters.user.repository.UserCredentialRepository;
import com.monsters.user.repository.UserOAuthAccountRepository;
import com.monsters.user.repository.UserRepository;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private static final long PASSWORD_RESET_TOKEN_EXPIRATION_SECONDS = 900;

    private final UserRepository userRepository;
    private final UserCredentialRepository userCredentialRepository;
    private final UserOAuthAccountRepository userOAuthAccountRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenService jwtTokenService;
    private final JwtProperties jwtProperties;
    private final GoogleIdTokenVerifier googleIdTokenVerifier;
    private final PasswordResetTokenService passwordResetTokenService;
    private final Clock clock;

    @Autowired
    public AuthService(
            UserRepository userRepository,
            UserCredentialRepository userCredentialRepository,
            UserOAuthAccountRepository userOAuthAccountRepository,
            PasswordResetTokenRepository passwordResetTokenRepository,
            PasswordEncoder passwordEncoder,
            JwtTokenService jwtTokenService,
            JwtProperties jwtProperties,
            GoogleIdTokenVerifier googleIdTokenVerifier,
            PasswordResetTokenService passwordResetTokenService
    ) {
        this(
                userRepository,
                userCredentialRepository,
                userOAuthAccountRepository,
                passwordResetTokenRepository,
                passwordEncoder,
                jwtTokenService,
                jwtProperties,
                googleIdTokenVerifier,
                passwordResetTokenService,
                Clock.systemDefaultZone()
        );
    }

    AuthService(
            UserRepository userRepository,
            UserCredentialRepository userCredentialRepository,
            UserOAuthAccountRepository userOAuthAccountRepository,
            PasswordResetTokenRepository passwordResetTokenRepository,
            PasswordEncoder passwordEncoder,
            JwtTokenService jwtTokenService,
            JwtProperties jwtProperties,
            GoogleIdTokenVerifier googleIdTokenVerifier,
            PasswordResetTokenService passwordResetTokenService,
            Clock clock
    ) {
        this.userRepository = userRepository;
        this.userCredentialRepository = userCredentialRepository;
        this.userOAuthAccountRepository = userOAuthAccountRepository;
        this.passwordResetTokenRepository = passwordResetTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenService = jwtTokenService;
        this.jwtProperties = jwtProperties;
        this.googleIdTokenVerifier = googleIdTokenVerifier;
        this.passwordResetTokenService = passwordResetTokenService;
        this.clock = clock;
    }

    @Transactional
    public RegisterResponse register(RegisterRequest request) {
        String email = normalizeEmail(request.email());
        if (userRepository.existsByEmail(email)) {
            throw new ConflictException("Email already registered");
        }

        User user = new User(email, request.userName().trim());
        User savedUser = userRepository.save(user);

        String passwordHash = passwordEncoder.encode(request.password());
        userCredentialRepository.save(new UserCredential(savedUser, passwordHash));

        return new RegisterResponse(savedUser.getId(), savedUser.getEmail(), savedUser.getUserName());
    }

    @Transactional(readOnly = true)
    public LoginResponse login(LoginRequest request) {
        String email = normalizeEmail(request.email());
        User user = userRepository.findByEmailAndDeletedFalse(email)
                .orElseThrow(() -> new UnauthorizedException("Invalid email or password"));
        UserCredential credential = userCredentialRepository.findByUser(user)
                .orElseThrow(() -> new UnauthorizedException("Invalid email or password"));

        if (!passwordEncoder.matches(request.password(), credential.getPasswordHash())) {
            throw new UnauthorizedException("Invalid email or password");
        }

        return createLoginResponse(user);
    }

    @Transactional
    public LoginResponse googleLogin(GoogleLoginRequest request) {
        GoogleUserInfo googleUser = googleIdTokenVerifier.verify(request.idToken());
        Optional<UserOAuthAccount> oauthAccount = userOAuthAccountRepository
                .findByProviderAndProviderUserId(UserOAuthAccount.PROVIDER_GOOGLE, googleUser.providerUserId());
        if (oauthAccount.isPresent() && oauthAccount.get().getUser().isDeleted()) {
            throw new UnauthorizedException("Invalid Google ID token");
        }

        User user = oauthAccount
                .map(UserOAuthAccount::getUser)
                .orElseGet(() -> findOrCreateGoogleUser(googleUser));

        return createLoginResponse(user);
    }

    @Transactional
    public ForgotPasswordResponse forgotPassword(ForgotPasswordRequest request) {
        String email = normalizeEmail(request.email());
        Optional<User> user = userRepository.findByEmailAndDeletedFalse(email);
        if (user.isEmpty()) {
            return new ForgotPasswordResponse(null, PASSWORD_RESET_TOKEN_EXPIRATION_SECONDS);
        }

        passwordResetTokenRepository.deleteByUserAndUsedAtIsNull(user.get());
        String resetToken = passwordResetTokenService.createToken();
        String tokenHash = passwordResetTokenService.hashToken(resetToken);
        LocalDateTime expiresAt = now().plusSeconds(PASSWORD_RESET_TOKEN_EXPIRATION_SECONDS);
        passwordResetTokenRepository.save(new PasswordResetToken(user.get(), tokenHash, expiresAt));

        return new ForgotPasswordResponse(resetToken, PASSWORD_RESET_TOKEN_EXPIRATION_SECONDS);
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        String tokenHash = passwordResetTokenService.hashToken(request.resetToken());
        PasswordResetToken resetToken = passwordResetTokenRepository.findByTokenHashAndUsedAtIsNull(tokenHash)
                .orElseThrow(() -> new UnauthorizedException("Invalid password reset token"));
        LocalDateTime now = now();
        if (resetToken.isExpired(now) || resetToken.getUser().isDeleted()) {
            throw new UnauthorizedException("Invalid password reset token");
        }

        String passwordHash = passwordEncoder.encode(request.newPassword());
        User user = resetToken.getUser();
        userCredentialRepository.findByUser(user)
                .ifPresentOrElse(
                        credential -> credential.updatePasswordHash(passwordHash),
                        () -> userCredentialRepository.save(new UserCredential(user, passwordHash))
                );
        resetToken.markUsed(now);
    }

    private User findOrCreateGoogleUser(GoogleUserInfo googleUser) {
        String email = normalizeEmail(googleUser.email());
        User user = userRepository.findByEmailAndDeletedFalse(email)
                .orElseGet(() -> userRepository.save(new User(email, displayName(googleUser))));

        userOAuthAccountRepository.save(new UserOAuthAccount(
                user,
                UserOAuthAccount.PROVIDER_GOOGLE,
                googleUser.providerUserId()
        ));

        return user;
    }

    private LoginResponse createLoginResponse(User user) {
        AuthUserResponse authUser = new AuthUserResponse(
                user.getId(),
                user.getEmail(),
                user.getUserName(),
                user.getAvatarUrl()
        );
        return new LoginResponse(
                jwtTokenService.createAccessToken(user),
                jwtTokenService.createRefreshToken(user),
                "Bearer",
                jwtProperties.accessTokenExpirationSeconds(),
                authUser
        );
    }

    private String displayName(GoogleUserInfo googleUser) {
        if (googleUser.name() != null && !googleUser.name().isBlank()) {
            return googleUser.name().trim();
        }
        return googleUser.email().split("@")[0];
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }

    private LocalDateTime now() {
        return LocalDateTime.now(clock);
    }
}
