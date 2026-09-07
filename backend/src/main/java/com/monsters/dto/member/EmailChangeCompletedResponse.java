package com.monsters.dto.member;

public record EmailChangeCompletedResponse(
        String status,
        long version
) {
}
