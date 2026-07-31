package com.monsters.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record ResetPasswordRequest(
        @NotBlank
        String resetToken,

        @NotNull(message = "PASSWORD_REQUIRED")
        String newPassword
) {
}
