package com.monsters.auth.service;

import com.monsters.auth.dto.AuthUserResponse;
import com.monsters.auth.dto.LoginRequest;
import com.monsters.auth.dto.LoginResponse;
import com.monsters.auth.dto.RegisterRequest;
import com.monsters.auth.dto.RegisterResponse;
import com.monsters.common.exception.ConflictException;
import com.monsters.common.exception.UnauthorizedException;
import com.monsters.common.security.JwtProperties;
import com.monsters.common.security.JwtTokenService;
import com.monsters.user.entity.User;
import com.monsters.user.entity.UserCredential;
import com.monsters.user.repository.UserCredentialRepository;
import com.monsters.user.repository.UserRepository;
import java.util.Locale;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final UserCredentialRepository userCredentialRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenService jwtTokenService;
    private final JwtProperties jwtProperties;

    public AuthService(
            UserRepository userRepository,
            UserCredentialRepository userCredentialRepository,
            PasswordEncoder passwordEncoder,
            JwtTokenService jwtTokenService,
            JwtProperties jwtProperties
    ) {
        this.userRepository = userRepository;
        this.userCredentialRepository = userCredentialRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenService = jwtTokenService;
        this.jwtProperties = jwtProperties;
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

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
