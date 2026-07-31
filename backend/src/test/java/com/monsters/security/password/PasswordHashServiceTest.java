package com.monsters.security.password;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

class PasswordHashServiceTest {

    private final PasswordHashService passwordHashService = new PasswordHashService();

    @Test
    void shouldCreateVersionedArgon2idHashWithApprovedParameters() {
        String passwordHash = passwordHashService.encode("synthetic-password");

        assertThat(passwordHash).startsWith("$argon2id$v=19$m=19456,t=2,p=1$");
        assertThat(passwordHashService.matches("synthetic-password", passwordHash)).isTrue();
        assertThat(passwordHashService.needsRehash(passwordHash)).isFalse();
    }

    @Test
    void shouldVerifyLegacyBcryptAndMarkItForRehash() {
        String passwordHash = new BCryptPasswordEncoder().encode("synthetic-password");

        assertThat(passwordHashService.matches("synthetic-password", passwordHash)).isTrue();
        assertThat(passwordHashService.needsRehash(passwordHash)).isTrue();
    }

    @Test
    void shouldRejectWrongPasswordAgainstLegacyBcrypt() {
        String passwordHash = new BCryptPasswordEncoder().encode("synthetic-password");

        assertThat(passwordHashService.matches("wrong-password", passwordHash)).isFalse();
    }

    @Test
    void shouldNormalizePasswordBeforeArgon2idHashingAndVerification() {
        String passwordHash = passwordHashService.encode("café password 1");

        assertThat(passwordHashService.matches("cafe\u0301 password 1", passwordHash)).isTrue();
    }

    @Test
    void shouldPreserveLeadingAndTrailingSpaces() {
        String passwordHash = passwordHashService.encode(" synthetic-password ");

        assertThat(passwordHashService.matches(" synthetic-password ", passwordHash)).isTrue();
        assertThat(passwordHashService.matches("synthetic-password", passwordHash)).isFalse();
    }

    @Test
    void shouldRejectLoginInputAboveTheUnicodeCodePointLimit() {
        String passwordHash = passwordHashService.encode("😀".repeat(128));

        assertThat(passwordHashService.matches("😀".repeat(128), passwordHash)).isTrue();
        assertThat(passwordHashService.matches("😀".repeat(129), passwordHash)).isFalse();
    }
}
