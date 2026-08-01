package com.monsters.security.session;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;

class RefreshCredentialGeneratorTest {

    private static final String TEST_KEY = "synthetic-refresh-derivation-key";
    private final RefreshCredentialGenerator generator = new RefreshCredentialGenerator();

    @Test
    void shouldCreateHighEntropyOpaqueInitialCredentialsAndOnlyStableHashes() {
        String first = generator.initialCredential();
        String second = generator.initialCredential();

        assertThat(first).hasSize(43).isNotEqualTo(second);
        assertThat(generator.hash(first)).hasSize(64).doesNotContain(first);
        assertThat(generator.hash(first)).isEqualTo(generator.hash(first));
    }

    @Test
    void shouldDeriveTheSameSuccessorOnlyForTheSameRotationInputs() {
        String first = generator.deriveSuccessor("current", "session-id", 1, TEST_KEY);

        assertThat(first).isEqualTo(
                generator.deriveSuccessor("current", "session-id", 1, TEST_KEY)
        );
        assertThat(first).isNotEqualTo(
                generator.deriveSuccessor("current", "session-id", 2, TEST_KEY)
        );
        assertThat(first).isNotEqualTo(
                generator.deriveSuccessor("current", "other-session", 1, TEST_KEY)
        );
    }

    @Test
    void shouldFailClosedWithoutAnIndependentDerivationKey() {
        assertThatThrownBy(() -> generator.deriveSuccessor("current", "session-id", 1, ""))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("Refresh credential derivation key is not configured");
    }
}
