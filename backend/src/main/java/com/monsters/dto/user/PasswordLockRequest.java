package com.monsters.dto.user;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record PasswordLockRequest(
        @NotBlank(message = "Password lock is required")
        @Pattern(regexp = "\\d{4}", message = "Password lock must be 4 digits")
        String lockPassword
) {
}
