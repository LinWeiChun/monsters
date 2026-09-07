package com.monsters.config.member;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.member.email-change")
public class MemberEmailChangeProperties {

    private String publicUrl;
    private long tokenTtlHours = 24;
    private int maxDeliveryAttempts = 5;

    public String getPublicUrl() { return publicUrl; }
    public void setPublicUrl(String publicUrl) { this.publicUrl = publicUrl; }
    public long getTokenTtlHours() { return tokenTtlHours; }
    public void setTokenTtlHours(long tokenTtlHours) { this.tokenTtlHours = tokenTtlHours; }
    public int getMaxDeliveryAttempts() { return maxDeliveryAttempts; }
    public void setMaxDeliveryAttempts(int maxDeliveryAttempts) {
        this.maxDeliveryAttempts = maxDeliveryAttempts;
    }
}
