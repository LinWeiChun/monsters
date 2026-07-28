package com.monsters.dto.diary;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import java.time.OffsetDateTime;
import org.junit.jupiter.api.Test;

class CreateDiaryRequestTest {

    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    void shouldAcceptValidRequestAndDefaultSharingToFalse() {
        CreateDiaryRequest request = new CreateDiaryRequest(
                DiaryRecordMethod.TEXT,
                "content",
                4,
                null,
                OffsetDateTime.parse("2026-07-19T12:00:00+08:00")
        );

        assertThat(validator.validate(request)).isEmpty();
        assertThat(request.sharedOrDefault()).isFalse();
    }

    @Test
    void shouldRejectMissingRecordMethodAndOutOfRangeScore() {
        CreateDiaryRequest request = new CreateDiaryRequest(
                null,
                null,
                6,
                false,
                null
        );

        assertThat(validator.validate(request))
                .extracting(violation -> violation.getPropertyPath().toString())
                .containsExactlyInAnyOrder("recordMethod", "score");
    }
}
