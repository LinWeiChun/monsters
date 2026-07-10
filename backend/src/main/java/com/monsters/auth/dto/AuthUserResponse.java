package com.monsters.auth.dto;

public record AuthUserResponse(
        Long userId,
        String account,
        String email,
        String userName,
        String avatarUrl
) {
}
