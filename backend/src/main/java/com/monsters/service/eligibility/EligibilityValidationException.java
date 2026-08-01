package com.monsters.service.eligibility;

import com.monsters.exception.common.BusinessException;

public class EligibilityValidationException extends BusinessException {

    private final String field;
    private final String fieldError;

    public EligibilityValidationException(String field, String fieldError, String message) {
        super(org.springframework.http.HttpStatus.BAD_REQUEST, "VALIDATION_FAILED", message);
        this.field = field;
        this.fieldError = fieldError;
    }

    public String getField() {
        return field;
    }

    public String getFieldError() {
        return fieldError;
    }
}
