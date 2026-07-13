package com.monsters.dto.annoyance;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.Test;

class SolveAnnoyanceRequestTest {

    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    void shouldRequireExplicitSolvedState() {
        assertThat(validator.validate(new SolveAnnoyanceRequest(true))).isEmpty();
        assertThat(validator.validate(new SolveAnnoyanceRequest(null)))
                .extracting(violation -> violation.getPropertyPath().toString())
                .containsExactly("isSolved");
    }
}
