package com.monsters.exception.common;

import org.springframework.http.HttpStatus;

public class RateLimitException extends BusinessException {

    private final long retryAfter;

    public RateLimitException(long retryAfter) {
        super(HttpStatus.TOO_MANY_REQUESTS, "RATE_LIMITED", "Request rate limit exceeded");
        this.retryAfter = retryAfter;
    }

    public long getRetryAfter() {
        return retryAfter;
    }
}
