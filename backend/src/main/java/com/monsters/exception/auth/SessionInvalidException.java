package com.monsters.exception.auth;

import com.monsters.exception.common.BusinessException;
import org.springframework.http.HttpStatus;

public class SessionInvalidException extends BusinessException {

    public SessionInvalidException() {
        super(HttpStatus.UNAUTHORIZED, "AUTH_SESSION_INVALID", "Session is invalid");
    }
}
