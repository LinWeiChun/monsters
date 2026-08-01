package com.monsters.dto.auth;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.*;
import java.time.LocalDate;

@JsonIgnoreProperties(ignoreUnknown = false)
public record EligibilityCompletionRequest(
        @NotBlank @Pattern(regexp = "[A-Za-z]{2}") String serviceRegion,
        @NotNull LocalDate birthday,
        @Size(max = 120) String publicNickname,
        @Email @Size(max = 255) String guardianEmail,
        @Size(max = 80) String acceptedMinorNoticeVersion,
        @Size(max = 80) String guardianConsentVersion,
        boolean confirmPublicNicknameDisclosure,
        @Size(max = 80) String publicNicknameDisclosureVersion
) {}
