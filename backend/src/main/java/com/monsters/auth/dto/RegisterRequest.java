package com.monsters.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
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
