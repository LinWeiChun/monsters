package com.monsters.dto.auth;

public record RegistrationPolicyResponse(
        String termsVersion,
        String termsUrl,
        String privacyVersion,
        String privacyUrl
) {
}
