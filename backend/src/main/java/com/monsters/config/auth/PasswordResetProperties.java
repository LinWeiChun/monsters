package com.monsters.config.auth;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.password-reset")
public class PasswordResetProperties {

    private String publicUrl;
    private long tokenTtlMinutes = 15;
    private int maxDeliveryAttempts = 5;
    private String rateLimitHashKey;
    private long rateLimitEmailCooldownSeconds = 60;
    private int rateLimitEmailMaxAttempts = 5;
    private int rateLimitIpMaxAttempts = 20;
    private long rateLimitWindowMinutes = 15;

    public String getPublicUrl() {
        return publicUrl;
    }

    public void setPublicUrl(String publicUrl) {
        this.publicUrl = publicUrl;
    }

    public long getTokenTtlMinutes() {
        return tokenTtlMinutes;
    }

    public void setTokenTtlMinutes(long tokenTtlMinutes) {
        this.tokenTtlMinutes = tokenTtlMinutes;
    }

    public int getMaxDeliveryAttempts() {
        return maxDeliveryAttempts;
    }

    public void setMaxDeliveryAttempts(int maxDeliveryAttempts) {
        this.maxDeliveryAttempts = maxDeliveryAttempts;
    }

    public String getRateLimitHashKey() {
        return rateLimitHashKey;
    }

    public void setRateLimitHashKey(String rateLimitHashKey) {
        this.rateLimitHashKey = rateLimitHashKey;
    }

    public long getRateLimitEmailCooldownSeconds() {
        return rateLimitEmailCooldownSeconds;
    }

    public void setRateLimitEmailCooldownSeconds(long value) {
        rateLimitEmailCooldownSeconds = value;
    }

    public int getRateLimitEmailMaxAttempts() {
        return rateLimitEmailMaxAttempts;
    }

    public void setRateLimitEmailMaxAttempts(int value) {
        rateLimitEmailMaxAttempts = value;
    }

    public int getRateLimitIpMaxAttempts() {
        return rateLimitIpMaxAttempts;
    }

    public void setRateLimitIpMaxAttempts(int value) {
        rateLimitIpMaxAttempts = value;
    }

    public long getRateLimitWindowMinutes() {
        return rateLimitWindowMinutes;
    }

    public void setRateLimitWindowMinutes(long value) {
        rateLimitWindowMinutes = value;
    }
}
