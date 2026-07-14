package com.monsters.dto.auth;

public record ForgotPasswordResponse(
        String resetToken,
        long expiresIn
) {
}
