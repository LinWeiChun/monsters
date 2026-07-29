package com.monsters.exception.member;

import com.monsters.exception.common.BusinessException;
import org.springframework.http.HttpStatus;

public class VersionConflictException extends BusinessException {

    public VersionConflictException(String message) {
        super(HttpStatus.CONFLICT, "VERSION_CONFLICT", message);
    }
}
