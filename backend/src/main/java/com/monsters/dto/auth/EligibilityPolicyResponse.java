package com.monsters.dto.auth;

public record EligibilityPolicyResponse(String serviceRegion, int minimumAge, int adultAge,
        Document minorNotice, Document guardianConsent, Document publicNicknameDisclosure) {
    public record Document(String version, String url) {}
}
