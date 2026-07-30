package com.monsters.dto.auth;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@JsonIgnoreProperties(ignoreUnknown = false)
public record RegistrationRequest(
        @NotBlank(message = "Email is required")
        @Email(message = "Email format is invalid")
        @Size(max = 255, message = "Email is too long")
        String email,

        @NotBlank(message = "Password is required")
        @Size(min = 8, max = 72, message = "Password length must be between 8 and 72")
        String password,

        @NotBlank(message = "Accepted Terms version is required")
        @Size(max = 80, message = "Accepted Terms version is too long")
        String acceptedTermsVersion,

        @NotBlank(message = "Accepted Privacy version is required")
        @Size(max = 80, message = "Accepted Privacy version is too long")
        String acceptedPrivacyVersion
) {
}
