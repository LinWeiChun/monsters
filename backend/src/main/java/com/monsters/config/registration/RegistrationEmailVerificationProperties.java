package com.monsters.config.registration;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.registration.email-verification")
public class RegistrationEmailVerificationProperties {

    private String publicUrl;
    private long tokenTtlHours = 24;
    private int maxDeliveryAttempts = 5;
    private long unverifiedRetentionDays = 7;
    private int cleanupBatchSize = 100;

    public String getPublicUrl() {
        return publicUrl;
    }

    public void setPublicUrl(String publicUrl) {
        this.publicUrl = publicUrl;
    }

    public long getTokenTtlHours() {
        return tokenTtlHours;
    }

    public void setTokenTtlHours(long tokenTtlHours) {
        this.tokenTtlHours = tokenTtlHours;
    }

    public int getMaxDeliveryAttempts() {
        return maxDeliveryAttempts;
    }

    public void setMaxDeliveryAttempts(int maxDeliveryAttempts) {
        this.maxDeliveryAttempts = maxDeliveryAttempts;
    }

    public long getUnverifiedRetentionDays() {
        return unverifiedRetentionDays;
    }

    public void setUnverifiedRetentionDays(long unverifiedRetentionDays) {
        this.unverifiedRetentionDays = unverifiedRetentionDays;
    }

    public int getCleanupBatchSize() {
        return cleanupBatchSize;
    }

    public void setCleanupBatchSize(int cleanupBatchSize) {
        this.cleanupBatchSize = cleanupBatchSize;
    }
}
