package com.monsters.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record PasswordResetEmailRequest(
        @NotBlank(message = "EMAIL_REQUIRED")
        @Email(message = "EMAIL_INVALID")
        @Size(max = 255, message = "EMAIL_TOO_LONG")
        String email
) {
}
