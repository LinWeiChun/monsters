package com.monsters.dto.auth;

public record AuthUserResponse(
        Long userId,
        String account,
        String email,
        String userName,
        String avatarUrl
) {
}
