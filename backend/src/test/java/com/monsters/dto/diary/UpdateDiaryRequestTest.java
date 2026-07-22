package com.monsters.dto.diary;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import java.time.OffsetDateTime;
import org.junit.jupiter.api.Test;

class UpdateDiaryRequestTest {

    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    void shouldAcceptCompleteUpdateAndExposeExistingMediaIds() {
        UpdateDiaryRequest request = new UpdateDiaryRequest(
                DiaryRecordMethod.IMAGE,
                null,
                4,
                true,
                OffsetDateTime.parse("2026-07-22T12:00:00+08:00"),
                21L,
                22L
        );

        assertThat(validator.validate(request)).isEmpty();
        assertThat(request.sharedOrDefault()).isTrue();
        assertThat(request.existingContentMediaId()).isEqualTo(21L);
        assertThat(request.existingDrawingMediaId()).isEqualTo(22L);
    }

    @Test
    void shouldRejectMissingRecordMethodAndOutOfRangeScore() {
        UpdateDiaryRequest request = new UpdateDiaryRequest(
                null,
                null,
                6,
                false,
                null,
                null,
                null
        );

        assertThat(validator.validate(request))
                .extracting(violation -> violation.getPropertyPath().toString())
                .containsExactlyInAnyOrder("recordMethod", "score");
    }
}
