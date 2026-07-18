package com.monsters.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record LoginRequest(
        @NotBlank
        @Size(max = 255)
        String email,

        @NotBlank
        @Size(min = 8, max = 100)
        String password
) {
}
