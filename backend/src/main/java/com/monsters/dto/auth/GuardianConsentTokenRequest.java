package com.monsters.dto.auth;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.*;
@JsonIgnoreProperties(ignoreUnknown = false)
public record GuardianConsentTokenRequest(@NotBlank @Size(max = 512) String token) {}
