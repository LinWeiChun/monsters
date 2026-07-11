package com.monsters.common.exception;

import org.springframework.http.HttpStatus;

public class PayloadTooLargeException extends BusinessException {

    public PayloadTooLargeException(String message) {
        super(HttpStatus.PAYLOAD_TOO_LARGE, message);
    }
}
