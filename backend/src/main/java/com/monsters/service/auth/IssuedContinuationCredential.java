package com.monsters.service.auth;

import com.monsters.dto.auth.ContinuationNextAction;

public record IssuedContinuationCredential(
        String credential,
        ContinuationNextAction nextAction,
        long expiresIn
) {
}
