package com.monsters.dto.member;

public record BirthdayCorrectionResponse(
        String requestId,
        String status,
        boolean restricted,
        String memberState,
        long version
) {
}
