package com.monsters.dto.auth;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record LoginResponse(
        String accessToken,
        String refreshToken,
        String tokenType,
        long expiresIn,
        AuthUserResponse user,
        ContinuationNextAction nextAction,
        String continuationCredential
) {

    public static LoginResponse authenticated(
            String accessToken,
            String refreshToken,
            String tokenType,
            long expiresIn,
            AuthUserResponse user
    ) {
        return new LoginResponse(
                accessToken,
                refreshToken,
                tokenType,
                expiresIn,
                user,
                null,
                null
        );
    }

    public static LoginResponse continuation(
            String credential,
            ContinuationNextAction nextAction,
            long expiresIn
    ) {
        return new LoginResponse(
                null,
                null,
                null,
                expiresIn,
                null,
                nextAction,
                credential
        );
    }

    @JsonIgnore
    public boolean requiresContinuation() {
        return continuationCredential != null;
    }
}
