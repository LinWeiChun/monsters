package com.monsters.common.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.monsters.common.exception.UnauthorizedException;
import com.monsters.user.entity.User;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

class JwtTokenServiceTest {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void createAccessTokenShouldReturnSignedJwt() {
        JwtProperties jwtProperties = jwtProperties("test-secret");
        JwtTokenService jwtTokenService = new JwtTokenService(jwtProperties, objectMapper);
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);

        String token = jwtTokenService.createAccessToken(user);

        String[] parts = token.split("\\.");
        assertThat(parts).hasSize(3);
        String payload = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8);
        assertThat(payload).contains("\"iss\":\"monsters-test\"");
        assertThat(payload).contains("\"sub\":\"1\"");
        assertThat(payload).contains("\"email\":\"user@example.com\"");
        assertThat(payload).contains("\"type\":\"access\"");
    }

    @Test
    void createRefreshTokenShouldUseRefreshType() {
        JwtProperties jwtProperties = jwtProperties("test-secret");
        JwtTokenService jwtTokenService = new JwtTokenService(jwtProperties, objectMapper);
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);

        String token = jwtTokenService.createRefreshToken(user);
        String payload = new String(Base64.getUrlDecoder().decode(token.split("\\.")[1]), StandardCharsets.UTF_8);

        assertThat(payload).contains("\"type\":\"refresh\"");
    }

    @Test
    void createAccessTokenShouldRequireSecret() {
        JwtProperties jwtProperties = jwtProperties("");
        JwtTokenService jwtTokenService = new JwtTokenService(jwtProperties, objectMapper);
        User user = new User("wei_account", "user@example.com", "Wei");

        assertThatThrownBy(() -> jwtTokenService.createAccessToken(user))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("JWT secret is not configured");
    }

    @Test
    void verifyAccessTokenShouldReturnPayload() {
        JwtProperties jwtProperties = jwtProperties("test-secret");
        JwtTokenService jwtTokenService = new JwtTokenService(jwtProperties, objectMapper);
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        String token = jwtTokenService.createAccessToken(user);

        JwtTokenPayload payload = jwtTokenService.verifyAccessToken(token);

        assertThat(payload.userId()).isEqualTo(1L);
        assertThat(payload.email()).isEqualTo("user@example.com");
        assertThat(payload.tokenType()).isEqualTo("access");
    }

    @Test
    void verifyAccessTokenShouldRejectRefreshToken() {
        JwtProperties jwtProperties = jwtProperties("test-secret");
        JwtTokenService jwtTokenService = new JwtTokenService(jwtProperties, objectMapper);
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        String token = jwtTokenService.createRefreshToken(user);

        assertThatThrownBy(() -> jwtTokenService.verifyAccessToken(token))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessage("Invalid JWT token");
    }

    @Test
    void hashTokenShouldReturnStableHash() {
        JwtProperties jwtProperties = jwtProperties("test-secret");
        JwtTokenService jwtTokenService = new JwtTokenService(jwtProperties, objectMapper);

        assertThat(jwtTokenService.hashToken("token")).isEqualTo(jwtTokenService.hashToken("token"));
        assertThat(jwtTokenService.hashToken("token")).isNotEqualTo("token");
    }

    private JwtProperties jwtProperties(String secret) {
        JwtProperties jwtProperties = new JwtProperties();
        jwtProperties.setIssuer("monsters-test");
        jwtProperties.setSecret(secret);
        jwtProperties.setAccessTokenExpirationSeconds(3600);
        jwtProperties.setRefreshTokenExpirationSeconds(1209600);
        return jwtProperties;
    }
}
