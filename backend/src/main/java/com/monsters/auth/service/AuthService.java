package com.monsters.auth.service;

import com.monsters.auth.dto.AuthUserResponse;
import com.monsters.auth.dto.GoogleLoginRequest;
import com.monsters.auth.dto.LoginRequest;
import com.monsters.auth.dto.LoginResponse;
import com.monsters.auth.dto.RegisterRequest;
import com.monsters.auth.dto.RegisterResponse;
import com.monsters.common.exception.ConflictException;
import com.monsters.common.exception.UnauthorizedException;
import com.monsters.common.security.GoogleIdTokenVerifier;
import com.monsters.common.security.GoogleUserInfo;
import com.monsters.common.security.JwtProperties;
import com.monsters.common.security.JwtTokenService;
import com.monsters.user.entity.User;
import com.monsters.user.entity.UserCredential;
import com.monsters.user.entity.UserOAuthAccount;
import com.monsters.user.repository.UserCredentialRepository;
import com.monsters.user.repository.UserOAuthAccountRepository;
import com.monsters.user.repository.UserRepository;
import java.util.Locale;
import java.util.Optional;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final UserCredentialRepository userCredentialRepository;
    private final UserOAuthAccountRepository userOAuthAccountRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenService jwtTokenService;
    private final JwtProperties jwtProperties;
    private final GoogleIdTokenVerifier googleIdTokenVerifier;

    public AuthService(
            UserRepository userRepository,
            UserCredentialRepository userCredentialRepository,
            UserOAuthAccountRepository userOAuthAccountRepository,
            PasswordEncoder passwordEncoder,
            JwtTokenService jwtTokenService,
            JwtProperties jwtProperties,
            GoogleIdTokenVerifier googleIdTokenVerifier
    ) {
        this.userRepository = userRepository;
        this.userCredentialRepository = userCredentialRepository;
        this.userOAuthAccountRepository = userOAuthAccountRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenService = jwtTokenService;
        this.jwtProperties = jwtProperties;
        this.googleIdTokenVerifier = googleIdTokenVerifier;
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
}
