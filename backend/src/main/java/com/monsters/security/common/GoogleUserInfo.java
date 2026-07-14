package com.monsters.security.common;

public record GoogleUserInfo(
        String providerUserId,
        String email,
        String name,
        String picture
) {
}
