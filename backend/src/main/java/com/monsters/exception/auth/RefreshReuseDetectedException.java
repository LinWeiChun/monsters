package com.monsters.exception.auth;

import com.monsters.exception.common.BusinessException;
import org.springframework.http.HttpStatus;

public class RefreshReuseDetectedException extends BusinessException {

    public RefreshReuseDetectedException() {
        super(
                HttpStatus.UNAUTHORIZED,
                "AUTH_REFRESH_REUSE_DETECTED",
                "Refresh credential reuse was detected"
        );
    }
}
