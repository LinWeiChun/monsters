package com.monsters.security.common;

import java.time.Instant;

public record JwtTokenPayload(
        Long userId,
        String email,
        String tokenType,
        String sessionId,
        Instant issuedAt,
        Instant expiresAt
) {

    public JwtTokenPayload(
            Long userId,
            String email,
            String tokenType,
            Instant issuedAt,
            Instant expiresAt
    ) {
        this(userId, email, tokenType, null, issuedAt, expiresAt);
    }
}
