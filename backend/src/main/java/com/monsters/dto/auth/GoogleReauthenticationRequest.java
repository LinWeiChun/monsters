package com.monsters.dto.auth;

import com.monsters.entity.session.ReauthenticationPurpose;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record GoogleReauthenticationRequest(
        @NotBlank @Size(max = 8192) String idToken,
        @NotNull ReauthenticationPurpose purpose
) {
}
