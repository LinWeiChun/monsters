package com.monsters.dto.auth;

public record EligibilityCompletionResponse(String eligibilityStatus, String communityEligibilityStatus,
        String nextAction, String consentReference) {}
