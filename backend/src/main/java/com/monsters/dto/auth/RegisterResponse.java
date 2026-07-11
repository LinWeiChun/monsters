package com.monsters.dto.auth;

public record RegisterResponse(
        Long userId,
        String account,
        String email,
        String userName
) {
}
