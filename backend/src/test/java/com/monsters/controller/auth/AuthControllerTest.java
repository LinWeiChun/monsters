package com.monsters.controller.auth;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.monsters.dto.auth.AuthUserResponse;
import com.monsters.dto.auth.ForgotPasswordRequest;
import com.monsters.dto.auth.ForgotPasswordResponse;
import com.monsters.dto.auth.GoogleLoginRequest;
import com.monsters.dto.auth.LoginRequest;
import com.monsters.dto.auth.LoginResponse;
import com.monsters.dto.auth.RegisterRequest;
import com.monsters.dto.auth.RegisterResponse;
import com.monsters.dto.auth.RefreshTokenRequest;
import com.monsters.service.auth.AuthService;
import com.monsters.service.auth.TokenRevocationService;
import com.monsters.exception.common.GlobalExceptionHandler;
import com.monsters.security.common.JwtTokenService;
import com.monsters.repository.user.RevokedTokenRepository;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(controllers = AuthController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthService authService;

    @MockBean
    private TokenRevocationService tokenRevocationService;

    @MockBean
    private JwtTokenService jwtTokenService;

    @MockBean
    private RevokedTokenRepository revokedTokenRepository;

    @Test
    void registerShouldReturnCreatedResponse() throws Exception {
        when(authService.register(any(RegisterRequest.class)))
                .thenReturn(new RegisterResponse(1L, "wei_account", "user@example.com", "Wei"));

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "wei_account",
                                "email", "user@example.com",
                                "password", "password123",
                                "userName", "Wei"
                        ))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Register success"))
                .andExpect(jsonPath("$.data.userId").value(1))
                .andExpect(jsonPath("$.data.account").value("wei_account"))
                .andExpect(jsonPath("$.data.email").value("user@example.com"))
                .andExpect(jsonPath("$.data.userName").value("Wei"));
    }

    @Test
    void registerShouldValidateRequestBody() throws Exception {
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "abc",
                                "email", "invalid",
                                "password", "short",
                                "userName", "Wei"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void loginShouldReturnOkResponse() throws Exception {
        when(authService.login(any(LoginRequest.class)))
                .thenReturn(new LoginResponse(
                        "access-token",
                        "refresh-token",
                        "Bearer",
                        3600,
                        new AuthUserResponse(1L, "wei_account", "user@example.com", "Wei", null)
                ));

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "user@example.com",
                                "password", "password123"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Login success"))
                .andExpect(jsonPath("$.data.accessToken").value("access-token"))
                .andExpect(jsonPath("$.data.refreshToken").value("refresh-token"))
                .andExpect(jsonPath("$.data.tokenType").value("Bearer"))
                .andExpect(jsonPath("$.data.expiresIn").value(3600))
                .andExpect(jsonPath("$.data.user.userId").value(1))
                .andExpect(jsonPath("$.data.user.account").value("wei_account"))
                .andExpect(jsonPath("$.data.user.email").value("user@example.com"))
                .andExpect(jsonPath("$.data.user.userName").value("Wei"));
    }

    @Test
    void loginShouldAcceptAccountIdentifier() throws Exception {
        when(authService.login(any(LoginRequest.class)))
                .thenReturn(new LoginResponse(
                        "access-token",
                        "refresh-token",
                        "Bearer",
                        3600,
                        new AuthUserResponse(1L, "wei_account", "user@example.com", "Wei", null)
                ));

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "wei_account",
                                "password", "password123"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.user.account").value("wei_account"));
    }

    @Test
    void loginShouldValidateRequestBody() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", " ",
                                "password", "short"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void googleLoginShouldReturnOkResponse() throws Exception {
        when(authService.googleLogin(any(GoogleLoginRequest.class)))
                .thenReturn(new LoginResponse(
                        "access-token",
                        "refresh-token",
                        "Bearer",
                        3600,
                        new AuthUserResponse(1L, "wei_account", "user@example.com", "Wei", null)
                ));

        mockMvc.perform(post("/api/auth/google-login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "idToken", "google-id-token"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Google login success"))
                .andExpect(jsonPath("$.data.accessToken").value("access-token"))
                .andExpect(jsonPath("$.data.user.account").value("wei_account"))
                .andExpect(jsonPath("$.data.user.email").value("user@example.com"));
    }

    @Test
    void googleLoginShouldValidateRequestBody() throws Exception {
        mockMvc.perform(post("/api/auth/google-login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "idToken", ""
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void refreshShouldRotateTokenAndReturnOkResponse() throws Exception {
        when(authService.refresh(any(RefreshTokenRequest.class)))
                .thenReturn(new LoginResponse(
                        "new-access-token",
                        "new-refresh-token",
                        "Bearer",
                        3600,
                        new AuthUserResponse(1L, "wei_account", "user@example.com", "Wei", null)
                ));

        mockMvc.perform(post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "refreshToken", "old-refresh-token"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Token refresh success"))
                .andExpect(jsonPath("$.data.accessToken").value("new-access-token"))
                .andExpect(jsonPath("$.data.refreshToken").value("new-refresh-token"));
    }

    @Test
    void refreshShouldValidateRequestBody() throws Exception {
        mockMvc.perform(post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("refreshToken", ""))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void forgotPasswordShouldReturnOkResponse() throws Exception {
        when(authService.forgotPassword(any(ForgotPasswordRequest.class)))
                .thenReturn(new ForgotPasswordResponse("reset-token", 900));

        mockMvc.perform(post("/api/auth/forgot-password")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "user@example.com"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Password reset token issued"))
                .andExpect(jsonPath("$.data.resetToken").value("reset-token"))
                .andExpect(jsonPath("$.data.expiresIn").value(900));
    }

    @Test
    void forgotPasswordShouldValidateRequestBody() throws Exception {
        mockMvc.perform(post("/api/auth/forgot-password")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "invalid"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void resetPasswordShouldReturnOkResponse() throws Exception {
        mockMvc.perform(post("/api/auth/reset-password")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "resetToken", "reset-token",
                                "newPassword", "password123"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Password reset success"));
    }

    @Test
    void resetPasswordShouldValidateRequestBody() throws Exception {
        mockMvc.perform(post("/api/auth/reset-password")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "resetToken", "",
                                "newPassword", "short"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void logoutShouldReturnOkResponse() throws Exception {
        mockMvc.perform(post("/api/auth/logout")
                        .header("Authorization", "Bearer access-token")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "refreshToken", "refresh-token"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Logout success"));

        org.mockito.Mockito.verify(tokenRevocationService).revokeAccessToken("access-token");
        org.mockito.Mockito.verify(tokenRevocationService).revokeRefreshToken("refresh-token");
    }

    @Test
    void logoutShouldRequireBearerToken() throws Exception {
        mockMvc.perform(post("/api/auth/logout"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false));
    }
}
