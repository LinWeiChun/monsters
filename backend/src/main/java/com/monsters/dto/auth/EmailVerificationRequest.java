package com.monsters.dto.auth;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@JsonIgnoreProperties(ignoreUnknown = false)
public record EmailVerificationRequest(
        @NotBlank(message = "Verification token is required")
        @Size(max = 512, message = "Verification token is invalid")
        String token
) {
}
