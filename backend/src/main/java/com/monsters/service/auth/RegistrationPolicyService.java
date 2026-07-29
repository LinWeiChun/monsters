package com.monsters.service.auth;

import com.monsters.config.registration.RegistrationPolicyProperties;
import com.monsters.dto.auth.RegistrationPolicyResponse;
import com.monsters.exception.common.BusinessException;
import java.net.URI;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class RegistrationPolicyService {

    private final RegistrationPolicyProperties properties;

    public RegistrationPolicyService(RegistrationPolicyProperties properties) {
        this.properties = properties;
    }

    public RegistrationPolicyResponse currentPolicy() {
        String termsVersion = required(properties.getTerms().getVersion());
        String termsUrl = requiredHttpsUrl(properties.getTerms().getUrl());
        String privacyVersion = required(properties.getPrivacy().getVersion());
        String privacyUrl = requiredHttpsUrl(properties.getPrivacy().getUrl());
        return new RegistrationPolicyResponse(
                termsVersion,
                termsUrl,
                privacyVersion,
                privacyUrl
        );
    }

    private String required(String value) {
        if (value == null || value.isBlank()) {
            throw unavailable();
        }
        return value.trim();
    }

    private String requiredHttpsUrl(String value) {
        String url = required(value);
        try {
            URI uri = URI.create(url);
            if (!"https".equalsIgnoreCase(uri.getScheme()) || uri.getHost() == null) {
                throw unavailable();
            }
            return uri.toString();
        } catch (IllegalArgumentException exception) {
            throw unavailable();
        }
    }

    private BusinessException unavailable() {
        return new BusinessException(
                HttpStatus.SERVICE_UNAVAILABLE,
                "SERVICE_TEMPORARILY_UNAVAILABLE",
                "Registration is temporarily unavailable"
        );
    }
}
