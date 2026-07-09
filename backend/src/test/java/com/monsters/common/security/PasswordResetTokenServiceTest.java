package com.monsters.common.security;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class PasswordResetTokenServiceTest {

    private final PasswordResetTokenService tokenService = new PasswordResetTokenService();

    @Test
    void createTokenShouldReturnUrlSafeToken() {
        String token = tokenService.createToken();

        assertThat(token).isNotBlank();
        assertThat(token).doesNotContain("+", "/", "=");
    }

    @Test
    void hashTokenShouldReturnStableHash() {
        String hash = tokenService.hashToken("reset-token");

        assertThat(hash).isEqualTo(tokenService.hashToken("reset-token"));
        assertThat(hash).isNotEqualTo("reset-token");
    }
}
