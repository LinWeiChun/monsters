package com.monsters.common.security;

public record GoogleUserInfo(
        String providerUserId,
        String email,
        String name,
        String picture
) {
}
