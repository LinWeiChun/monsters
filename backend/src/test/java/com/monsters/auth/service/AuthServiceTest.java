package com.monsters.auth.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

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
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private UserCredentialRepository userCredentialRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtTokenService jwtTokenService;

    @Mock
    private JwtProperties jwtProperties;

    @InjectMocks
    private AuthService authService;

    @Test
    void registerShouldCreateUserAndCredential() {
        RegisterRequest request = new RegisterRequest(" USER@example.COM ", "password123", " Wei ");
        when(userRepository.existsByEmail("user@example.com")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(passwordEncoder.encode("password123")).thenReturn("encoded-password");

        RegisterResponse response = authService.register(request);

        assertThat(response.email()).isEqualTo("user@example.com");
        assertThat(response.userName()).isEqualTo("Wei");

        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(userCaptor.capture());
        assertThat(userCaptor.getValue().getEmail()).isEqualTo("user@example.com");
        assertThat(userCaptor.getValue().getUserName()).isEqualTo("Wei");

        ArgumentCaptor<UserCredential> credentialCaptor = ArgumentCaptor.forClass(UserCredential.class);
        verify(userCredentialRepository).save(credentialCaptor.capture());
        assertThat(credentialCaptor.getValue().getPasswordHash()).isEqualTo("encoded-password");
    }

    @Test
    void registerShouldRejectDuplicateEmail() {
        RegisterRequest request = new RegisterRequest("user@example.com", "password123", "Wei");
        when(userRepository.existsByEmail("user@example.com")).thenReturn(true);

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Email already registered");
    }

    @Test
    void loginShouldReturnTokensAndUser() {
        LoginRequest request = new LoginRequest(" USER@example.COM ", "password123");
        User user = new User("user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        UserCredential credential = new UserCredential(user, "encoded-password");

        when(userRepository.findByEmailAndDeletedFalse("user@example.com")).thenReturn(Optional.of(user));
        when(userCredentialRepository.findByUser(user)).thenReturn(Optional.of(credential));
        when(passwordEncoder.matches("password123", "encoded-password")).thenReturn(true);
        when(jwtTokenService.createAccessToken(user)).thenReturn("access-token");
        when(jwtTokenService.createRefreshToken(user)).thenReturn("refresh-token");
        when(jwtProperties.accessTokenExpirationSeconds()).thenReturn(3600L);

        LoginResponse response = authService.login(request);

        assertThat(response.accessToken()).isEqualTo("access-token");
        assertThat(response.refreshToken()).isEqualTo("refresh-token");
        assertThat(response.tokenType()).isEqualTo("Bearer");
        assertThat(response.expiresIn()).isEqualTo(3600);
        assertThat(response.user().userId()).isEqualTo(1);
        assertThat(response.user().email()).isEqualTo("user@example.com");
        assertThat(response.user().userName()).isEqualTo("Wei");
    }

    @Test
    void loginShouldRejectUnknownEmail() {
        LoginRequest request = new LoginRequest("user@example.com", "password123");
        when(userRepository.findByEmailAndDeletedFalse("user@example.com")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessage("Invalid email or password");
    }

    @Test
    void loginShouldRejectWrongPassword() {
        LoginRequest request = new LoginRequest("user@example.com", "wrong-password");
        User user = new User("user@example.com", "Wei");
        UserCredential credential = new UserCredential(user, "encoded-password");

        when(userRepository.findByEmailAndDeletedFalse("user@example.com")).thenReturn(Optional.of(user));
        when(userCredentialRepository.findByUser(user)).thenReturn(Optional.of(credential));
        when(passwordEncoder.matches("wrong-password", "encoded-password")).thenReturn(false);

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessage("Invalid email or password");
    }
}
