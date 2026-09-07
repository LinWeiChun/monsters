package com.monsters.dto.member;

public record EmailChangePendingResponse(
        String requestId,
        String status
) {
}
