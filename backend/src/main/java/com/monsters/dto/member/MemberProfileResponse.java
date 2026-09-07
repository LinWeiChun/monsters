package com.monsters.dto.member;

import java.time.LocalDate;

public record MemberProfileResponse(
        String publicId,
        String email,
        String publicNickname,
        LocalDate birthday,
        String serviceRegion,
        String eligibilityStatus,
        String communityEligibilityStatus,
        String memberState,
        long version,
        MemberWorkflowSummary pendingEmailChange,
        MemberWorkflowSummary pendingBirthdayCorrection
) {
}
