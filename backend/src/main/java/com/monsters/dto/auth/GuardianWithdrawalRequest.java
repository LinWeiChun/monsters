package com.monsters.dto.auth;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.*;
@JsonIgnoreProperties(ignoreUnknown = false)
public record GuardianWithdrawalRequest(@NotBlank @Size(max = 36) String consentReference,
        @NotBlank @Email @Size(max = 255) String guardianEmail) {}
