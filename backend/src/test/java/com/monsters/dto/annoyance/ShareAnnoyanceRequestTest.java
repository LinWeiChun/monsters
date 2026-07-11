package com.monsters.dto.annoyance;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.Test;

class ShareAnnoyanceRequestTest {

    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    void shouldRequireExplicitSharedStateAndAllowBothTargets() {
        assertThat(validator.validate(new ShareAnnoyanceRequest(true))).isEmpty();
        assertThat(validator.validate(new ShareAnnoyanceRequest(false))).isEmpty();
        assertThat(validator.validate(new ShareAnnoyanceRequest(null)))
                .extracting(violation -> violation.getPropertyPath().toString())
                .containsExactly("isShared");
    }
}
