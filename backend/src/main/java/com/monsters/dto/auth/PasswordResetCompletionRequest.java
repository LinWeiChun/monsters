package com.monsters.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record PasswordResetCompletionRequest(
        @NotBlank(message = "PASSWORD_RESET_TOKEN_REQUIRED")
        @Size(max = 512, message = "PASSWORD_RESET_TOKEN_INVALID")
        String token,

        @NotNull(message = "PASSWORD_REQUIRED")
        String newPassword
) {
}
