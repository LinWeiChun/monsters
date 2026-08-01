package com.monsters.security.session;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.security.session")
public class SessionProperties {

    private long idleExpirationSeconds;
    private long absoluteExpirationSeconds;
    private long refreshConcurrencyGraceSeconds;
    private String refreshDerivationKey;

    public long idleExpirationSeconds() {
        return idleExpirationSeconds;
    }

    public void setIdleExpirationSeconds(long idleExpirationSeconds) {
        this.idleExpirationSeconds = idleExpirationSeconds;
    }

    public long absoluteExpirationSeconds() {
        return absoluteExpirationSeconds;
    }

    public void setAbsoluteExpirationSeconds(long absoluteExpirationSeconds) {
        this.absoluteExpirationSeconds = absoluteExpirationSeconds;
    }

    public long refreshConcurrencyGraceSeconds() {
        return refreshConcurrencyGraceSeconds;
    }

    public void setRefreshConcurrencyGraceSeconds(long refreshConcurrencyGraceSeconds) {
        this.refreshConcurrencyGraceSeconds = refreshConcurrencyGraceSeconds;
    }

    public String refreshDerivationKey() {
        return refreshDerivationKey;
    }

    public void setRefreshDerivationKey(String refreshDerivationKey) {
        this.refreshDerivationKey = refreshDerivationKey;
    }
}
