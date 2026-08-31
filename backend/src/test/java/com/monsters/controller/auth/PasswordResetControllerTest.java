package com.monsters.controller.auth;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.monsters.dto.auth.PasswordResetCompletionRequest;
import com.monsters.dto.auth.PasswordResetEmailRequest;
import com.monsters.exception.common.GlobalExceptionHandler;
import com.monsters.repository.user.RevokedTokenRepository;
import com.monsters.security.common.JwtTokenService;
import com.monsters.service.auth.PasswordResetService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(controllers = {PasswordResetController.class, LegacyPasswordResetController.class})
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class PasswordResetControllerTest {

    @Autowired private MockMvc mockMvc;
    @MockBean private PasswordResetService passwordResetService;
    @MockBean private JwtTokenService jwtTokenService;
    @MockBean private RevokedTokenRepository revokedTokenRepository;

    @Test
    void formalRequestShouldAlwaysReturnAcceptedWithoutToken() throws Exception {
        mockMvc.perform(post("/api/v1/auth/password-reset-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"member@example.test\"}"))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.code").value("PASSWORD_RESET_REQUEST_ACCEPTED"))
                .andExpect(jsonPath("$.data").doesNotExist())
                .andExpect(jsonPath("$.resetToken").doesNotExist());
        verify(passwordResetService).request(any(PasswordResetEmailRequest.class), any());
    }

    @Test
    void formalCompletionShouldUseTokenFieldAndReturnStableCode() throws Exception {
        mockMvc.perform(post("/api/v1/auth/password-resets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"token":"synthetic-token","newPassword":"correct horse battery staple"}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("PASSWORD_RESET_COMPLETED"));
        verify(passwordResetService).complete(any(PasswordResetCompletionRequest.class));
    }

    @Test
    void legacyRequestShouldBeSafeUntilTask18RemovesPath() throws Exception {
        mockMvc.perform(post("/api/auth/forgot-password")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"member@example.test\"}"))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.code").value("PASSWORD_RESET_REQUEST_ACCEPTED"))
                .andExpect(jsonPath("$.data").doesNotExist());
    }

    @Test
    void malformedEmailShouldReturnValidationError() throws Exception {
        mockMvc.perform(post("/api/v1/auth/password-reset-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"invalid\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"));
    }
}
