package com.monsters.service.eligibility;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import org.junit.jupiter.api.Test;

class EligibilityRulesTest {

    private static final ZoneId TAIPEI = ZoneId.of("Asia/Taipei");
    private static final Clock BOUNDARY_CLOCK = Clock.fixed(
            Instant.parse("2026-08-01T16:00:00Z"),
            TAIPEI
    );

    @Test
    void classifiesMemberTurningThirteenOnTheTaipeiCalendarDateAsMinor() {
        EligibilityRules rules = new EligibilityRules(BOUNDARY_CLOCK);

        EligibilityAgeBand result = rules.classifyAge(LocalDate.of(2013, 8, 2));

        assertThat(result).isEqualTo(EligibilityAgeBand.MINOR);
    }

    @Test
    void classifiesTwelveThirteenSeventeenAndEighteenAtTaipeiDateBoundary() {
        EligibilityRules rules = new EligibilityRules(BOUNDARY_CLOCK);

        assertThat(rules.classifyAge(LocalDate.of(2013, 8, 3)))
                .isEqualTo(EligibilityAgeBand.UNDERAGE);
        assertThat(rules.classifyAge(LocalDate.of(2013, 8, 2)))
                .isEqualTo(EligibilityAgeBand.MINOR);
        assertThat(rules.classifyAge(LocalDate.of(2008, 8, 3)))
                .isEqualTo(EligibilityAgeBand.MINOR);
        assertThat(rules.classifyAge(LocalDate.of(2008, 8, 2)))
                .isEqualTo(EligibilityAgeBand.ADULT);
    }

    @Test
    void rejectsFutureBirthday() {
        EligibilityRules rules = new EligibilityRules(BOUNDARY_CLOCK);

        assertThatThrownBy(() -> rules.classifyAge(LocalDate.of(2026, 8, 3)))
                .isInstanceOf(EligibilityValidationException.class)
                .hasMessage("Birthday must not be in the future");
    }

    @Test
    void normalizesNicknameToNfcAndStripsOuterWhitespace() {
        EligibilityRules rules = new EligibilityRules(BOUNDARY_CLOCK);

        assertThat(rules.normalizePublicNickname("  e\u0301貘  ")).isEqualTo("é貘");
    }

    @Test
    void countsUnicodeCodePointsInsteadOfUtf16Units() {
        EligibilityRules rules = new EligibilityRules(BOUNDARY_CLOCK);

        assertThat(rules.normalizePublicNickname("😀貘")).isEqualTo("😀貘");
        assertThatThrownBy(() -> rules.normalizePublicNickname("貘"))
                .isInstanceOf(EligibilityValidationException.class);
        assertThatThrownBy(() -> rules.normalizePublicNickname("貘".repeat(31)))
                .isInstanceOf(EligibilityValidationException.class);
    }

    @Test
    void rejectsInvisibleBidiControlAndOfficialImpersonationNames() {
        EligibilityRules rules = new EligibilityRules(BOUNDARY_CLOCK);

        assertThatThrownBy(() -> rules.normalizePublicNickname("貘\u200B友"))
                .isInstanceOf(EligibilityValidationException.class);
        assertThatThrownBy(() -> rules.normalizePublicNickname("貘\u202E友"))
                .isInstanceOf(EligibilityValidationException.class);
        assertThatThrownBy(() -> rules.normalizePublicNickname("管理員"))
                .isInstanceOf(EligibilityValidationException.class);
        assertThatThrownBy(() -> rules.normalizePublicNickname("  \n\t  "))
                .isInstanceOf(EligibilityValidationException.class);
    }
}
