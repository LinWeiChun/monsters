package com.monsters.dto.auth;

import com.monsters.entity.session.ReauthenticationPurpose;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SessionReauthenticationRequest(
        @NotBlank @Size(max = 1024) String password,
        ReauthenticationPurpose purpose
) {

    public ReauthenticationPurpose effectivePurpose() {
        return purpose == null ? ReauthenticationPurpose.SESSION_MANAGEMENT : purpose;
    }
}
