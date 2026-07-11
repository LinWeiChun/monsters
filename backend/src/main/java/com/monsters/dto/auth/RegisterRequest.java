package com.monsters.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank(message = "Account is required")
        @Size(min = 4, max = 50, message = "Account length must be between 4 and 50")
        @Pattern(regexp = "^[A-Za-z][A-Za-z0-9_]*$", message = "Account may contain letters, numbers, and underscores, and must start with a letter")
        String account,

        @NotBlank(message = "Email is required")
        @Email(message = "Email format is invalid")
        String email,

        @NotBlank(message = "Password is required")
        @Size(min = 8, max = 72, message = "Password length must be between 8 and 72")
        String password,

        @NotBlank(message = "User name is required")
        @Size(max = 80, message = "User name length must be less than or equal to 80")
        String userName
) {
}
