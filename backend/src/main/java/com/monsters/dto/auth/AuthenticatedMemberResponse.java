package com.monsters.dto.auth;

public record AuthenticatedMemberResponse(
        String publicId,
        String email,
        String userName
) {
}
