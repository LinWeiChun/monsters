package com.monsters.config.registration;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.registration.documents")
public class RegistrationPolicyProperties {

    private final RequiredDocument terms = new RequiredDocument();
    private final RequiredDocument privacy = new RequiredDocument();

    public RequiredDocument getTerms() {
        return terms;
    }

    public RequiredDocument getPrivacy() {
        return privacy;
    }

    public static class RequiredDocument {

        private String version;
        private String url;

        public String getVersion() {
            return version;
        }

        public void setVersion(String version) {
            this.version = version;
        }

        public String getUrl() {
            return url;
        }

        public void setUrl(String url) {
            this.url = url;
        }
    }
}
