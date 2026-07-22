package com.monsters.dto.diary;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.Test;

class ShareDiaryRequestTest {

    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    void shouldAcceptExplicitSharedState() {
        assertThat(validator.validate(new ShareDiaryRequest(true))).isEmpty();
        assertThat(validator.validate(new ShareDiaryRequest(false))).isEmpty();
    }

    @Test
    void shouldRejectMissingSharedState() {
        assertThat(validator.validate(new ShareDiaryRequest(null)))
                .extracting(violation -> violation.getPropertyPath().toString())
                .containsExactly("isShared");
    }
}
