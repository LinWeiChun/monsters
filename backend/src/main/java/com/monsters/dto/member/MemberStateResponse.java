package com.monsters.dto.member;

public record MemberStateResponse(
        String memberState,
        long version,
        String nextAction
) {
}
