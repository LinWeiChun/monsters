package com.monsters.dto.auth;

public record GoogleAccountLinkResponse(
        boolean linked,
        boolean currentSessionPreserved,
        boolean otherSessionsRevoked
) {
}
