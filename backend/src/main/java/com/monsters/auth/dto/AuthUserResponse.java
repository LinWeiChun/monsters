package com.monsters.auth.dto;

public record AuthUserResponse(
        Long userId,
        String email,
        String userName,
        String avatarUrl
) {
}
