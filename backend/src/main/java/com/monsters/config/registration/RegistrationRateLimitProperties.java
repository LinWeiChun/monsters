package com.monsters.config.registration;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.registration.rate-limit")
public class RegistrationRateLimitProperties {

    private String hashKey;
    private long emailCooldownSeconds = 60;
    private int emailMaxAttempts = 5;
    private int ipMaxAttempts = 20;
    private long windowMinutes = 15;

    public String getHashKey() {
        return hashKey;
    }

    public void setHashKey(String hashKey) {
        this.hashKey = hashKey;
    }

    public long getEmailCooldownSeconds() {
        return emailCooldownSeconds;
    }

    public void setEmailCooldownSeconds(long emailCooldownSeconds) {
        this.emailCooldownSeconds = emailCooldownSeconds;
    }

    public int getEmailMaxAttempts() {
        return emailMaxAttempts;
    }

    public void setEmailMaxAttempts(int emailMaxAttempts) {
        this.emailMaxAttempts = emailMaxAttempts;
    }

    public int getIpMaxAttempts() {
        return ipMaxAttempts;
    }

    public void setIpMaxAttempts(int ipMaxAttempts) {
        this.ipMaxAttempts = ipMaxAttempts;
    }

    public long getWindowMinutes() {
        return windowMinutes;
    }

    public void setWindowMinutes(long windowMinutes) {
        this.windowMinutes = windowMinutes;
    }
}
