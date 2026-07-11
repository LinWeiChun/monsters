package com.monsters.annoyance.dto;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import java.time.OffsetDateTime;
import org.junit.jupiter.api.Test;

class CreateAnnoyanceRequestTest {

    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    void shouldAcceptValidRequestAndDefaultSharingToFalse() {
        CreateAnnoyanceRequest request = new CreateAnnoyanceRequest(
                "ACADEMIC",
                AnnoyanceRecordMethod.TEXT,
                "content",
                4,
                null,
                OffsetDateTime.parse("2026-07-11T12:00:00+08:00")
        );

        assertThat(validator.validate(request)).isEmpty();
        assertThat(request.sharedOrDefault()).isFalse();
    }

    @Test
    void shouldRejectMissingFieldsAndOutOfRangeScore() {
        CreateAnnoyanceRequest request = new CreateAnnoyanceRequest(
                " ",
                null,
                null,
                6,
                false,
                null
        );

        assertThat(validator.validate(request))
                .extracting(violation -> violation.getPropertyPath().toString())
                .containsExactlyInAnyOrder("categoryCode", "recordMethod", "score");
    }
}
