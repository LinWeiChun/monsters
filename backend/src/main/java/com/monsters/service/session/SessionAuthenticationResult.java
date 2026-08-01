package com.monsters.service.session;

import com.monsters.dto.auth.AuthenticatedMemberResponse;

public record SessionAuthenticationResult(
        String accessToken,
        String refreshCredential,
        String tokenType,
        long expiresIn,
        AuthenticatedMemberResponse user
) {
}
