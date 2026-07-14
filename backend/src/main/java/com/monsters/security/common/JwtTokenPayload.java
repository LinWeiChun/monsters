package com.monsters.security.common;

import java.time.Instant;

public record JwtTokenPayload(
        Long userId,
        String email,
        String tokenType,
        Instant issuedAt,
        Instant expiresAt
) {
}
