package com.monsters.security.common;

public record AuthenticatedUser(
        Long userId,
        String sessionId
) {
}
