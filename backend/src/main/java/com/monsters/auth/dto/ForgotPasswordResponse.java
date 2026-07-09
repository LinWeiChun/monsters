package com.monsters.auth.dto;

public record ForgotPasswordResponse(
        String resetToken,
        long expiresIn
) {
}
