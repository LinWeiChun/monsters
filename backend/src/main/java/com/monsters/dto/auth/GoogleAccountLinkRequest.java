package com.monsters.dto.auth;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record GoogleAccountLinkRequest(
        @NotBlank @Size(max = 8192) String idToken,
        @AssertTrue(message = "Google account linking must be explicitly confirmed") boolean confirmed
) {
}
