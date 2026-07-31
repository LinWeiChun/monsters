package com.monsters.security.common;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.monsters.dto.common.ApiResponse;
import com.monsters.entity.user.User;
import com.monsters.repository.user.RevokedTokenRepository;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.test.util.ReflectionTestUtils;
import static org.mockito.Mockito.when;

@WebMvcTest(SecurityConfigTest.TestController.class)
@Import({
        SecurityConfig.class,
        SecurityExceptionHandler.class,
        JwtAuthenticationFilter.class,
        JwtTokenService.class,
        SecurityConfigTest.TestController.class
})
@EnableConfigurationProperties(JwtProperties.class)
@TestPropertySource(properties = {
        "app.security.jwt.issuer=monsters-test",
        "app.security.jwt.secret=test-secret",
        "app.security.jwt.access-token-expiration-seconds=3600",
        "app.security.jwt.refresh-token-expiration-seconds=2592000"
})
class SecurityConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtProperties jwtProperties;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenService jwtTokenService;

    @MockBean
    private RevokedTokenRepository revokedTokenRepository;

    @Test
    void jwtPropertiesShouldBindFromConfiguration() {
        assertThat(jwtProperties.issuer()).isEqualTo("monsters-test");
        assertThat(jwtProperties.secret()).isEqualTo("test-secret");
        assertThat(jwtProperties.accessTokenExpirationSeconds()).isEqualTo(3600);
        assertThat(jwtProperties.refreshTokenExpirationSeconds()).isEqualTo(2592000);
    }

    @Test
    void passwordEncoderShouldUseBcrypt() {
        String encodedPassword = passwordEncoder.encode("password");

        assertThat(encodedPassword).startsWith("$2");
        assertThat(passwordEncoder.matches("password", encodedPassword)).isTrue();
    }

    @Test
    void authLoginShouldPermitAnonymousRequest() throws Exception {
        mockMvc.perform(post("/api/auth/login"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("login"));
    }

    @Test
    void verifiedEmailLoginShouldPermitAnonymousRequest() throws Exception {
        mockMvc.perform(post("/api/v1/auth/login"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("verified-email-login"));
    }

    @Test
    void authRefreshShouldPermitAnonymousRequest() throws Exception {
        mockMvc.perform(post("/api/auth/refresh"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("refresh"));
    }

    @Test
    void protectedApiShouldReturnUnauthorizedApiResponse() throws Exception {
        mockMvc.perform(get("/api/protected"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value("尚未登入或 Token 無效"))
                .andExpect(jsonPath("$.data").doesNotExist());
    }

    @Test
    void protectedApiShouldPermitValidAccessToken() throws Exception {
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        String token = jwtTokenService.createAccessToken(user);
        when(revokedTokenRepository.existsByTokenHash(jwtTokenService.hashToken(token))).thenReturn(false);

        mockMvc.perform(get("/api/protected")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("protected"));
    }

    @Test
    void protectedApiShouldRejectRevokedAccessToken() throws Exception {
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        String token = jwtTokenService.createAccessToken(user);
        when(revokedTokenRepository.existsByTokenHash(jwtTokenService.hashToken(token))).thenReturn(true);

        mockMvc.perform(get("/api/protected")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false));
    }

    @RestController
    public static class TestController {

        @PostMapping("/api/auth/login")
        public ApiResponse<Map<String, String>> login() {
            return ApiResponse.success(Map.of("status", "login"));
        }

        @PostMapping("/api/v1/auth/login")
        public ApiResponse<Map<String, String>> verifiedEmailLogin() {
            return ApiResponse.success(Map.of("status", "verified-email-login"));
        }

        @PostMapping("/api/auth/refresh")
        public ApiResponse<Map<String, String>> refresh() {
            return ApiResponse.success(Map.of("status", "refresh"));
        }

        @GetMapping("/api/protected")
        public ApiResponse<Map<String, String>> protectedApi() {
            return ApiResponse.success(Map.of("status", "protected"));
        }
    }
}
