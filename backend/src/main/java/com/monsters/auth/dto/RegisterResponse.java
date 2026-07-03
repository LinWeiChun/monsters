package com.monsters.auth.dto;

public record RegisterResponse(
        Long userId,
        String email,
        String userName
) {
}
