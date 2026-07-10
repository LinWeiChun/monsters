package com.monsters.auth.dto;

public record RegisterResponse(
        Long userId,
        String account,
        String email,
        String userName
) {
}
