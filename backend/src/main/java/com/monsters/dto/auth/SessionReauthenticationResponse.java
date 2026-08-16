package com.monsters.dto.auth;

public record SessionReauthenticationResponse(
        String credential,
        String purpose,
        long expiresIn
) {
}
