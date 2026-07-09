package com.monsters.common.security;

public record AuthenticatedUser(
        Long userId,
        String email
) {
}
