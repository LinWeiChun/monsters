package com.monsters.security.password;

public class PasswordPolicyException extends RuntimeException {

    private final String fieldErrorCode;

    public PasswordPolicyException(String fieldErrorCode) {
        super("Password does not meet requirements");
        this.fieldErrorCode = fieldErrorCode;
    }

    public String getFieldErrorCode() {
        return fieldErrorCode;
    }
}
