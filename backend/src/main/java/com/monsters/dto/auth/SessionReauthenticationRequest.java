package com.monsters.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SessionReauthenticationRequest(
        @NotBlank @Size(max = 1024) String password
) {
}
