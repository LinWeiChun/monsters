package com.monsters.common.security;

import com.monsters.user.entity.User;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.stereotype.Service;

@Service
public class JwtTokenService {

    private static final String HMAC_SHA256 = "HmacSHA256";
    private static final String TOKEN_TYPE_ACCESS = "access";
    private static final String TOKEN_TYPE_REFRESH = "refresh";

    private final JwtProperties jwtProperties;

    public JwtTokenService(JwtProperties jwtProperties) {
        this.jwtProperties = jwtProperties;
    }

    public String createAccessToken(User user) {
        return createToken(user, TOKEN_TYPE_ACCESS, jwtProperties.accessTokenExpirationSeconds());
    }

    public String createRefreshToken(User user) {
        return createToken(user, TOKEN_TYPE_REFRESH, jwtProperties.refreshTokenExpirationSeconds());
    }

    private String createToken(User user, String tokenType, long expirationSeconds) {
        if (jwtProperties.secret() == null || jwtProperties.secret().isBlank()) {
            throw new IllegalStateException("JWT secret is not configured");
        }

        Instant issuedAt = Instant.now();
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

        String header = base64Url(headerJson.getBytes(StandardCharsets.UTF_8));
        String payload = base64Url(payloadJson.getBytes(StandardCharsets.UTF_8));
        String unsignedToken = header + "." + payload;
        String signature = base64Url(sign(unsignedToken));
        return unsignedToken + "." + signature;
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

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
