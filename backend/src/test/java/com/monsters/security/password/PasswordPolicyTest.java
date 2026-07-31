package com.monsters.security.password;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.nio.charset.StandardCharsets;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ByteArrayResource;

class PasswordPolicyTest {

    private final PasswordPolicy policy = new PasswordPolicy(new PasswordBlocklist(
            new ByteArrayResource(
                    PasswordBlocklist.sha256("passwordpassword")
                            .concat(System.lineSeparator())
                            .getBytes(StandardCharsets.UTF_8)
            )
    ));

    @Test
    void shouldAcceptFifteenAndOneHundredTwentyEightUnicodeCodePoints() {
        assertThat(policy.normalizeAndValidate("a".repeat(15))).isEqualTo("a".repeat(15));
        assertThat(policy.normalizeAndValidate("a".repeat(128))).isEqualTo("a".repeat(128));
    }

    @Test
    void shouldRejectFourteenAndOneHundredTwentyNineUnicodeCodePoints() {
        assertThatThrownBy(() -> policy.normalizeAndValidate("a".repeat(14)))
                .isInstanceOf(PasswordPolicyException.class)
                .extracting("fieldErrorCode")
                .isEqualTo("PASSWORD_TOO_SHORT");
        assertThatThrownBy(() -> policy.normalizeAndValidate("a".repeat(129)))
                .isInstanceOf(PasswordPolicyException.class)
                .extracting("fieldErrorCode")
                .isEqualTo("PASSWORD_TOO_LONG");
    }

    @Test
    void shouldCountEmojiAsUnicodeCodePoints() {
        String password = "😀".repeat(15);

        assertThat(policy.normalizeAndValidate(password)).isEqualTo(password);
    }

    @Test
    void shouldNormalizeToNfcWithoutTrimmingSpaces() {
        String decomposed = " cafe\u0301 password ";

        assertThat(policy.normalizeAndValidate(decomposed))
                .isEqualTo(" café password ");
    }

    @Test
    void shouldRejectAnExactNormalizedBlocklistMatch() {
        assertThatThrownBy(() -> policy.normalizeAndValidate("passwordpassword"))
                .isInstanceOf(PasswordPolicyException.class)
                .extracting("fieldErrorCode")
                .isEqualTo("PASSWORD_TOO_WEAK");
    }
}
