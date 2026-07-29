package com.monsters.exception.member;

import com.monsters.exception.common.BusinessException;
import org.springframework.http.HttpStatus;

public class MemberStateConflictException extends BusinessException {

    public MemberStateConflictException(String message) {
        super(HttpStatus.CONFLICT, "MEMBER_STATE_CONFLICT", message);
    }
}
