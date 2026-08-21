package com.monsters.dto.auth;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record VerifiedEmailLoginResponse(
        String accessToken,
        String refreshToken,
        String tokenType,
        long expiresIn,
        AuthenticatedMemberResponse user,
        ContinuationNextAction nextAction,
        String continuationCredential
) {

    public static VerifiedEmailLoginResponse authenticated(
            String accessToken,
            String refreshToken,
            String tokenType,
            long expiresIn,
            AuthenticatedMemberResponse user
    ) {
        return new VerifiedEmailLoginResponse(
                accessToken,
                refreshToken,
                tokenType,
                expiresIn,
                user,
                null,
                null
        );
    }

    public static VerifiedEmailLoginResponse continuation(
            String credential,
            ContinuationNextAction nextAction,
            long expiresIn
    ) {
        return new VerifiedEmailLoginResponse(
                null,
                null,
                null,
                expiresIn,
                null,
                nextAction,
                credential
        );
    }

    public static VerifiedEmailLoginResponse googleAccountLinkRequired() {
        return new VerifiedEmailLoginResponse(
                null,
                null,
                null,
                0,
                null,
                ContinuationNextAction.LINK_GOOGLE_ACCOUNT,
                null
        );
    }

    @JsonIgnore
    public boolean requiresContinuation() {
        return continuationCredential != null;
    }

    @JsonIgnore
    public boolean requiresGoogleAccountLink() {
        return nextAction == ContinuationNextAction.LINK_GOOGLE_ACCOUNT;
    }

    public VerifiedEmailLoginResponse withoutRefreshCredential() {
        return new VerifiedEmailLoginResponse(
                accessToken,
                null,
                tokenType,
                expiresIn,
                user,
                nextAction,
                continuationCredential
        );
    }
}
