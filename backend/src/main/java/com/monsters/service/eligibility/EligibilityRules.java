package com.monsters.service.eligibility;

import java.time.Clock;
import java.time.LocalDate;
import java.time.Period;
import java.time.ZoneId;
import java.text.Normalizer;
import java.util.Locale;
import java.util.Set;
import org.springframework.stereotype.Component;

@Component
public class EligibilityRules {

    private static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Taipei");
    private static final int MINIMUM_AGE = 13;
    private static final int ADULT_AGE = 18;
    private static final int MIN_NICKNAME_CODE_POINTS = 2;
    private static final int MAX_NICKNAME_CODE_POINTS = 30;
    private static final Set<String> RESERVED_NAMES = Set.of(
            "monsters", "貘nsters", "admin", "administrator", "official",
            "官方", "管理員", "客服"
    );

    private final Clock clock;

    public EligibilityRules(Clock clock) {
        this.clock = clock;
    }

    public EligibilityAgeBand classifyAge(LocalDate birthday) {
        LocalDate serviceDate = LocalDate.now(clock.withZone(SERVICE_ZONE));
        if (birthday == null || birthday.isAfter(serviceDate)) {
            throw validation("birthday", "BIRTHDAY_INVALID", "Birthday must not be in the future");
        }
        int age = Period.between(birthday, serviceDate).getYears();
        if (age < MINIMUM_AGE) {
            return EligibilityAgeBand.UNDERAGE;
        }
        if (age < ADULT_AGE) {
            return EligibilityAgeBand.MINOR;
        }
        return EligibilityAgeBand.ADULT;
    }

    public String normalizePublicNickname(String value) {
        if (value == null) {
            throw nicknameValidation("PUBLIC_NICKNAME_REQUIRED", "Public nickname is required");
        }
        String normalized = Normalizer.normalize(value.strip(), Normalizer.Form.NFC);
        int length = normalized.codePointCount(0, normalized.length());
        if (length < MIN_NICKNAME_CODE_POINTS || length > MAX_NICKNAME_CODE_POINTS) {
            throw nicknameValidation(
                    "PUBLIC_NICKNAME_LENGTH_INVALID",
                    "Public nickname must contain 2 to 30 Unicode code points"
            );
        }
        if (normalized.codePoints().anyMatch(this::isForbiddenCodePoint)) {
            throw nicknameValidation(
                    "PUBLIC_NICKNAME_CHARACTER_INVALID",
                    "Public nickname contains a forbidden character"
            );
        }
        String impersonationKey = normalized
                .toLowerCase(Locale.ROOT)
                .replaceAll("[\\p{Z}\\p{P}\\p{S}_]+", "");
        if (RESERVED_NAMES.stream()
                .map(name -> name.toLowerCase(Locale.ROOT))
                .anyMatch(impersonationKey::equals)) {
            throw nicknameValidation(
                    "PUBLIC_NICKNAME_RESERVED",
                    "Public nickname may not impersonate an official account"
            );
        }
        return normalized;
    }

    private boolean isForbiddenCodePoint(int codePoint) {
        int type = Character.getType(codePoint);
        return Character.isISOControl(codePoint)
                || type == Character.FORMAT
                || type == Character.CONTROL
                || type == Character.SURROGATE
                || type == Character.UNASSIGNED
                || codePoint == 0x00A0
                || codePoint == 0x034F
                || codePoint == 0x061C
                || codePoint == 0x180E
                || codePoint == 0xFEFF;
    }

    private EligibilityValidationException nicknameValidation(String error, String message) {
        return validation("publicNickname", error, message);
    }

    private EligibilityValidationException validation(String field, String error, String message) {
        return new EligibilityValidationException(field, error, message);
    }
}
