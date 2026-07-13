package com.monsters.dto.annoyance;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import java.time.OffsetDateTime;
import org.junit.jupiter.api.Test;

class UpdateAnnoyanceRequestTest {

    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    void shouldAcceptCompleteUpdateAndExposeExistingMediaIds() {
        UpdateAnnoyanceRequest request = new UpdateAnnoyanceRequest(
                "ACADEMIC",
                AnnoyanceRecordMethod.IMAGE,
                null,
                4,
                true,
                OffsetDateTime.parse("2026-07-12T12:00:00+08:00"),
                21L,
                22L
        );

        assertThat(validator.validate(request)).isEmpty();
        assertThat(request.sharedOrDefault()).isTrue();
        assertThat(request.existingContentMediaId()).isEqualTo(21L);
        assertThat(request.existingDrawingMediaId()).isEqualTo(22L);
    }

    @Test
    void shouldRejectMissingFieldsAndOutOfRangeScore() {
        UpdateAnnoyanceRequest request = new UpdateAnnoyanceRequest(
                " ",
                null,
                null,
                0,
                null,
                null,
                null,
                null
        );

        assertThat(validator.validate(request))
                .extracting(violation -> violation.getPropertyPath().toString())
                .containsExactlyInAnyOrder("categoryCode", "recordMethod", "score");
        assertThat(request.sharedOrDefault()).isFalse();
    }
}
