package com.monsters.security.common;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.monsters.exception.common.UnauthorizedException;
import com.monsters.entity.user.User;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Clock;
import java.time.Instant;
import java.util.Base64;
import java.util.Map;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;

@Service
public class JwtTokenService {

    private static final String HMAC_SHA256 = "HmacSHA256";
    private static final String TOKEN_TYPE_ACCESS = "access";
    private static final String TOKEN_TYPE_REFRESH = "refresh";

    private final JwtProperties jwtProperties;
    private final ObjectMapper objectMapper;
    private final Clock clock;

    public JwtTokenService(JwtProperties jwtProperties, ObjectMapper objectMapper) {
        this.jwtProperties = jwtProperties;
        this.objectMapper = objectMapper;
        this.clock = Clock.systemUTC();
    }

    @Autowired
    public JwtTokenService(
            JwtProperties jwtProperties,
            ObjectMapper objectMapper,
            ObjectProvider<Clock> clockProvider
    ) {
        this.jwtProperties = jwtProperties;
        this.objectMapper = objectMapper;
        this.clock = clockProvider.getIfAvailable(Clock::systemUTC);
    }

    public String createAccessToken(User user) {
        return createToken(user, TOKEN_TYPE_ACCESS, jwtProperties.accessTokenExpirationSeconds());
    }

    public String createAccessToken(User user, String sessionId, Instant issuedAt) {
        requireSecret();
        Instant expiresAt = issuedAt.plusSeconds(jwtProperties.accessTokenExpirationSeconds());
        String headerJson = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
        String payloadJson = "{"
                + "\"iss\":\"" + escapeJson(jwtProperties.issuer()) + "\","
                + "\"sub\":\"" + user.getId() + "\","
                + "\"sid\":\"" + escapeJson(sessionId) + "\","
                + "\"iat\":" + issuedAt.getEpochSecond() + ","
                + "\"exp\":" + expiresAt.getEpochSecond()
                + "}";
        return signToken(headerJson, payloadJson);
    }

    public String createRefreshToken(User user) {
        return createToken(user, TOKEN_TYPE_REFRESH, jwtProperties.refreshTokenExpirationSeconds());
    }

    public JwtTokenPayload verifyAccessToken(String token) {
        JwtTokenPayload payload = verify(token);
        if (payload.sessionId() == null && !TOKEN_TYPE_ACCESS.equals(payload.tokenType())) {
            throw invalidToken();
        }
        return payload;
    }

    public JwtTokenPayload verifyRefreshToken(String token) {
        JwtTokenPayload payload = verify(token);
        if (!TOKEN_TYPE_REFRESH.equals(payload.tokenType())) {
            throw invalidToken();
        }
        return payload;
    }

    public String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            return base64Url(hash);
        } catch (Exception exception) {
            throw new IllegalStateException("JWT token hashing failed", exception);
        }
    }

    private String createToken(User user, String tokenType, long expirationSeconds) {
        requireSecret();

        Instant issuedAt = clock.instant();
        Instant expiresAt = issuedAt.plusSeconds(expirationSeconds);
        String headerJson = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
        String payloadJson = "{"
                + "\"iss\":\"" + escapeJson(jwtProperties.issuer()) + "\","
                + "\"sub\":\"" + user.getId() + "\","
                + "\"email\":\"" + escapeJson(user.getEmail()) + "\","
                + "\"type\":\"" + tokenType + "\","
                + "\"iat\":" + issuedAt.getEpochSecond() + ","
                + "\"exp\":" + expiresAt.getEpochSecond()
                + "}";

        return signToken(headerJson, payloadJson);
    }

    private String signToken(String headerJson, String payloadJson) {
        String header = base64Url(headerJson.getBytes(StandardCharsets.UTF_8));
        String payload = base64Url(payloadJson.getBytes(StandardCharsets.UTF_8));
        String unsignedToken = header + "." + payload;
        String signature = base64Url(sign(unsignedToken));
        return unsignedToken + "." + signature;
    }

    private JwtTokenPayload verify(String token) {
        try {
            requireSecret();
            String[] parts = token.split("\\.");
            if (parts.length != 3) {
                throw invalidToken();
            }

            String unsignedToken = parts[0] + "." + parts[1];
            String expectedSignature = base64Url(sign(unsignedToken));
            if (!MessageDigest.isEqual(
                    expectedSignature.getBytes(StandardCharsets.UTF_8),
                    parts[2].getBytes(StandardCharsets.UTF_8)
            )) {
                throw invalidToken();
            }

            Map<String, Object> payload = objectMapper.readValue(
                    Base64.getUrlDecoder().decode(parts[1]),
                    new TypeReference<Map<String, Object>>() {
                    }
            );
            if (!jwtProperties.issuer().equals(requiredString(payload, "iss"))) {
                throw invalidToken();
            }

            Instant expiresAt = Instant.ofEpochSecond(numberValue(payload, "exp"));
            if (!expiresAt.isAfter(clock.instant())) {
                throw invalidToken();
            }

            return new JwtTokenPayload(
                    Long.parseLong(requiredString(payload, "sub")),
                    optionalString(payload, "email"),
                    optionalString(payload, "type"),
                    optionalString(payload, "sid"),
                    Instant.ofEpochSecond(numberValue(payload, "iat")),
                    expiresAt
            );
        } catch (UnauthorizedException exception) {
            throw exception;
        } catch (Exception exception) {
            throw invalidToken();
        }
    }

    private byte[] sign(String unsignedToken) {
        try {
            Mac mac = Mac.getInstance(HMAC_SHA256);
            SecretKeySpec keySpec = new SecretKeySpec(
                    jwtProperties.secret().getBytes(StandardCharsets.UTF_8),
                    HMAC_SHA256
            );
            mac.init(keySpec);
            return mac.doFinal(unsignedToken.getBytes(StandardCharsets.UTF_8));
        } catch (Exception exception) {
            throw new IllegalStateException("JWT token signing failed", exception);
        }
    }

    private String base64Url(byte[] value) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value);
    }

    private void requireSecret() {
        if (jwtProperties.secret() == null || jwtProperties.secret().isBlank()) {
            throw new IllegalStateException("JWT secret is not configured");
        }
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private String requiredString(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (!(value instanceof String stringValue) || stringValue.isBlank()) {
            throw invalidToken();
        }
        return stringValue;
    }

    private String optionalString(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value == null) {
            return null;
        }
        if (!(value instanceof String stringValue) || stringValue.isBlank()) {
            throw invalidToken();
        }
        return stringValue;
    }

    private long numberValue(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value instanceof Number numberValue) {
            return numberValue.longValue();
        }
        if (value instanceof String stringValue) {
            return Long.parseLong(stringValue);
        }
        throw invalidToken();
    }

    private UnauthorizedException invalidToken() {
        return new UnauthorizedException("Invalid JWT token");
    }
}
