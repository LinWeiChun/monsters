package com.monsters.security.common;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.monsters.exception.common.UnauthorizedException;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.Signature;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.RSAPublicKeySpec;
import java.time.Clock;
import java.time.Instant;
import java.util.Base64;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class GoogleIdTokenVerifier {

    private static final Set<String> VALID_ISSUERS = Set.of(
            "accounts.google.com",
            "https://accounts.google.com"
    );
    private static final String EXPECTED_ALGORITHM = "RS256";
    private static final String EXPECTED_KEY_TYPE = "RSA";

    private final GoogleProperties googleProperties;
    private final GoogleJwkProvider googleJwkProvider;
    private final ObjectMapper objectMapper;
    private final Clock clock;

    @Autowired
    public GoogleIdTokenVerifier(
            GoogleProperties googleProperties,
            GoogleJwkProvider googleJwkProvider,
            ObjectMapper objectMapper
    ) {
        this(googleProperties, googleJwkProvider, objectMapper, Clock.systemUTC());
    }

    GoogleIdTokenVerifier(
            GoogleProperties googleProperties,
            GoogleJwkProvider googleJwkProvider,
            ObjectMapper objectMapper,
            Clock clock
    ) {
        this.googleProperties = googleProperties;
        this.googleJwkProvider = googleJwkProvider;
        this.objectMapper = objectMapper;
        this.clock = clock;
    }

    public GoogleUserInfo verify(String idToken) {
        try {
            String[] parts = idToken.split("\\.");
            if (parts.length != 3) {
                throw invalidToken();
            }

            Map<String, Object> header = decodeJson(parts[0]);
            Map<String, Object> payload = decodeJson(parts[1]);
            validateHeader(header);
            validatePayload(payload);

            Map<String, Object> jwk = googleJwkProvider.getKey(requiredString(header, "kid"));
            verifySignature(parts[0] + "." + parts[1], parts[2], jwk);

            return new GoogleUserInfo(
                    requiredString(payload, "sub"),
                    requiredString(payload, "email").trim().toLowerCase(Locale.ROOT),
                    stringOrNull(payload, "name"),
                    stringOrNull(payload, "picture")
            );
        } catch (UnauthorizedException exception) {
            throw exception;
        } catch (Exception exception) {
            throw invalidToken();
        }
    }

    private void validateHeader(Map<String, Object> header) {
        if (!EXPECTED_ALGORITHM.equals(requiredString(header, "alg"))) {
            throw invalidToken();
        }
        requiredString(header, "kid");
    }

    private void validatePayload(Map<String, Object> payload) {
        Set<String> clientIds = googleProperties.clientIdSet();
        if (clientIds.isEmpty()) {
            throw new IllegalStateException("Google client IDs are not configured");
        }
        if (!VALID_ISSUERS.contains(requiredString(payload, "iss"))) {
            throw invalidToken();
        }
        if (!clientIds.contains(requiredString(payload, "aud"))) {
            throw invalidToken();
        }
        if (epochSecond(payload, "exp") <= Instant.now(clock).getEpochSecond()) {
            throw invalidToken();
        }
        if (!Boolean.TRUE.equals(booleanValue(payload, "email_verified"))) {
            throw invalidToken();
        }
        requiredString(payload, "sub");
        requiredString(payload, "email");
    }

    private void verifySignature(String unsignedToken, String signature, Map<String, Object> jwk) throws Exception {
        if (!EXPECTED_KEY_TYPE.equals(requiredString(jwk, "kty"))) {
            throw invalidToken();
        }
        RSAPublicKey publicKey = publicKey(jwk);
        Signature verifier = Signature.getInstance("SHA256withRSA");
        verifier.initVerify(publicKey);
        verifier.update(unsignedToken.getBytes(StandardCharsets.UTF_8));
        if (!verifier.verify(base64UrlDecode(signature))) {
            throw invalidToken();
        }
    }

    private RSAPublicKey publicKey(Map<String, Object> jwk) throws Exception {
        BigInteger modulus = new BigInteger(1, base64UrlDecode(requiredString(jwk, "n")));
        BigInteger exponent = new BigInteger(1, base64UrlDecode(requiredString(jwk, "e")));
        RSAPublicKeySpec keySpec = new RSAPublicKeySpec(modulus, exponent);
        return (RSAPublicKey) KeyFactory.getInstance("RSA").generatePublic(keySpec);
    }

    private Map<String, Object> decodeJson(String value) throws Exception {
        return objectMapper.readValue(
                base64UrlDecode(value),
                new TypeReference<Map<String, Object>>() {
                }
        );
    }

    private byte[] base64UrlDecode(String value) {
        return Base64.getUrlDecoder().decode(value);
    }

    private String requiredString(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (!(value instanceof String stringValue) || stringValue.isBlank()) {
            throw invalidToken();
        }
        return stringValue;
    }

    private String stringOrNull(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value instanceof String stringValue && !stringValue.isBlank()) {
            return stringValue;
        }
        return null;
    }

    private Boolean booleanValue(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value instanceof Boolean booleanValue) {
            return booleanValue;
        }
        if (value instanceof String stringValue) {
            return Boolean.parseBoolean(stringValue);
        }
        return false;
    }

    private long epochSecond(Map<String, Object> map, String key) {
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
        return new UnauthorizedException("Invalid Google ID token");
    }
}
