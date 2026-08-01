package com.monsters.config.registration;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.registration.eligibility")
public class EligibilityPolicyProperties {
    private String serviceRegion = "TW";
    private String minorNoticeVersion;
    private String guardianConsentVersion;
    private String publicNicknameDisclosureVersion;
    private String minorNoticeUrl;
    private String guardianConsentUrl;
    private String publicNicknameDisclosureUrl;
    private String guardianActionPublicUrl;
    private int grantTokenTtlHours = 24;
    private int withdrawalTokenTtlMinutes = 15;
    public String getServiceRegion() { return serviceRegion; }
    public void setServiceRegion(String value) { serviceRegion = value; }
    public String getMinorNoticeVersion() { return minorNoticeVersion; }
    public void setMinorNoticeVersion(String value) { minorNoticeVersion = value; }
    public String getGuardianConsentVersion() { return guardianConsentVersion; }
    public void setGuardianConsentVersion(String value) { guardianConsentVersion = value; }
    public String getPublicNicknameDisclosureVersion() { return publicNicknameDisclosureVersion; }
    public void setPublicNicknameDisclosureVersion(String value) { publicNicknameDisclosureVersion = value; }
    public String getMinorNoticeUrl() { return minorNoticeUrl; }
    public void setMinorNoticeUrl(String value) { minorNoticeUrl = value; }
    public String getGuardianConsentUrl() { return guardianConsentUrl; }
    public void setGuardianConsentUrl(String value) { guardianConsentUrl = value; }
    public String getPublicNicknameDisclosureUrl() { return publicNicknameDisclosureUrl; }
    public void setPublicNicknameDisclosureUrl(String value) { publicNicknameDisclosureUrl = value; }
    public String getGuardianActionPublicUrl() { return guardianActionPublicUrl; }
    public void setGuardianActionPublicUrl(String value) { guardianActionPublicUrl = value; }
    public int getGrantTokenTtlHours() { return grantTokenTtlHours; }
    public void setGrantTokenTtlHours(int value) { grantTokenTtlHours = value; }
    public int getWithdrawalTokenTtlMinutes() { return withdrawalTokenTtlMinutes; }
    public void setWithdrawalTokenTtlMinutes(int value) { withdrawalTokenTtlMinutes = value; }
}
