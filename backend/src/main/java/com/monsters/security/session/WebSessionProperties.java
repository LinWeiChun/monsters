package com.monsters.security.session;

import java.util.ArrayList;
import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.security.web-session")
public class WebSessionProperties {

    private List<String> trustedOriginPatterns = new ArrayList<>();
    private long cookieMaxAgeSeconds = 7776000;

    public List<String> trustedOriginPatterns() {
        return trustedOriginPatterns;
    }

    public void setTrustedOriginPatterns(List<String> trustedOriginPatterns) {
        this.trustedOriginPatterns = trustedOriginPatterns;
    }

    public long cookieMaxAgeSeconds() {
        return cookieMaxAgeSeconds;
    }

    public void setCookieMaxAgeSeconds(long cookieMaxAgeSeconds) {
        this.cookieMaxAgeSeconds = cookieMaxAgeSeconds;
    }
}
