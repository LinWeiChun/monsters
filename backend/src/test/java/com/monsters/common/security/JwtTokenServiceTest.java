package com.monsters.common.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.monsters.user.entity.User;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

class JwtTokenServiceTest {

    @Test
    void createAccessTokenShouldReturnSignedJwt() {
        JwtProperties jwtProperties = jwtProperties("test-secret");
        JwtTokenService jwtTokenService = new JwtTokenService(jwtProperties);
        User user = new User("user@example.com", "Wei");
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
        JwtTokenService jwtTokenService = new JwtTokenService(jwtProperties);
        User user = new User("user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);

        String token = jwtTokenService.createRefreshToken(user);
        String payload = new String(Base64.getUrlDecoder().decode(token.split("\\.")[1]), StandardCharsets.UTF_8);

        assertThat(payload).contains("\"type\":\"refresh\"");
    }

    @Test
    void createAccessTokenShouldRequireSecret() {
        JwtProperties jwtProperties = jwtProperties("");
        JwtTokenService jwtTokenService = new JwtTokenService(jwtProperties);
        User user = new User("user@example.com", "Wei");

        assertThatThrownBy(() -> jwtTokenService.createAccessToken(user))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("JWT secret is not configured");
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
