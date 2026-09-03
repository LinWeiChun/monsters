package com.monsters.dto.member;

public record MemberWorkflowSummary(
        String requestId,
        String status,
        String target
) {
}
