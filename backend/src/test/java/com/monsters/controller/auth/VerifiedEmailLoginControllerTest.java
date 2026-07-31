package com.monsters.controller.auth;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.monsters.dto.auth.AuthenticatedMemberResponse;
import com.monsters.dto.auth.ContinuationNextAction;
import com.monsters.dto.auth.VerifiedEmailLoginRequest;
import com.monsters.dto.auth.VerifiedEmailLoginResponse;
import com.monsters.exception.common.GlobalExceptionHandler;
import com.monsters.exception.common.UnauthorizedException;
import com.monsters.repository.user.RevokedTokenRepository;
import com.monsters.security.common.JwtTokenService;
import com.monsters.service.auth.AuthService;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(controllers = VerifiedEmailLoginController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class VerifiedEmailLoginControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthService authService;

    @MockBean
    private JwtTokenService jwtTokenService;

    @MockBean
    private RevokedTokenRepository revokedTokenRepository;

    @Test
    void loginShouldExposeOnlyTheV1MemberContract() throws Exception {
        when(authService.loginVerifiedEmail(any(VerifiedEmailLoginRequest.class)))
                .thenReturn(VerifiedEmailLoginResponse.authenticated(
                        "access-token",
                        "refresh-token",
                        "Bearer",
                        600,
                        new AuthenticatedMemberResponse(
                                "00000000-0000-0000-0000-000000000001",
                                "member@example.test",
                                "Member"
                        )
                ));

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "member@example.test",
                                "password", "synthetic-password"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTHENTICATED"))
                .andExpect(jsonPath("$.data.user.publicId")
                        .value("00000000-0000-0000-0000-000000000001"))
                .andExpect(jsonPath("$.data.user.email").value("member@example.test"))
                .andExpect(jsonPath("$.data.user.userName").value("Member"))
                .andExpect(jsonPath("$.data.user.account").doesNotExist())
                .andExpect(jsonPath("$.data.user.userId").doesNotExist());
    }

    @Test
    void loginShouldReturnContinuationWithoutSessionTokens() throws Exception {
        when(authService.loginVerifiedEmail(any(VerifiedEmailLoginRequest.class)))
                .thenReturn(VerifiedEmailLoginResponse.continuation(
                        "synthetic-continuation",
                        ContinuationNextAction.VERIFY_EMAIL,
                        600
                ));

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "pending@example.test",
                                "password", "synthetic-password"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTH_CONTINUATION_REQUIRED"))
                .andExpect(jsonPath("$.data.nextAction").value("VERIFY_EMAIL"))
                .andExpect(jsonPath("$.data.continuationCredential")
                        .value("synthetic-continuation"))
                .andExpect(jsonPath("$.data.accessToken").doesNotExist())
                .andExpect(jsonPath("$.data.refreshToken").doesNotExist());
    }

    @Test
    void loginShouldRejectLegacyAccountAndUnknownFields() throws Exception {
        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "legacy_account",
                                "password", "synthetic-password"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"));

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "member@example.test",
                                "password", "synthetic-password",
                                "account", "legacy_account"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("REQUEST_BODY_INVALID"));
    }

    @Test
    void loginShouldUseTheStableInvalidCredentialsError() throws Exception {
        when(authService.loginVerifiedEmail(any(VerifiedEmailLoginRequest.class)))
                .thenThrow(new UnauthorizedException("Invalid email or password"));

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "missing@example.test",
                                "password", "synthetic-password"
                        ))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH_INVALID_CREDENTIALS"));
    }
}
