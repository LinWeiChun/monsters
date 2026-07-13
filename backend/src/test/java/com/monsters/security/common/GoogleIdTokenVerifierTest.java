package com.monsters.security.common;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.monsters.exception.common.UnauthorizedException;
import java.nio.charset.StandardCharsets;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.Signature;
import java.security.interfaces.RSAPublicKey;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Base64;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class GoogleIdTokenVerifierTest {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private KeyPair keyPair;
    private GoogleIdTokenVerifier verifier;

    @BeforeEach
    void setUp() throws Exception {
        KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("RSA");
        keyPairGenerator.initialize(2048);
        keyPair = keyPairGenerator.generateKeyPair();

        GoogleProperties googleProperties = new GoogleProperties();
        googleProperties.setClientIds("web-client-id,android-client-id");

        GoogleJwkProvider jwkProvider = keyId -> jwk();
        verifier = new GoogleIdTokenVerifier(
                googleProperties,
                jwkProvider,
                objectMapper,
                Clock.fixed(Instant.ofEpochSecond(1000), ZoneOffset.UTC)
        );
    }

    @Test
    void verifyShouldReturnGoogleUserInfo() throws Exception {
        String token = idToken("web-client-id", true, 2000);

        GoogleUserInfo userInfo = verifier.verify(token);

        assertThat(userInfo.providerUserId()).isEqualTo("google-sub");
        assertThat(userInfo.email()).isEqualTo("user@example.com");
        assertThat(userInfo.name()).isEqualTo("Wei");
        assertThat(userInfo.picture()).isEqualTo("https://example.com/avatar.png");
    }

    @Test
    void verifyShouldRejectInvalidAudience() throws Exception {
        String token = idToken("other-client-id", true, 2000);

        assertThatThrownBy(() -> verifier.verify(token))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessage("Invalid Google ID token");
    }

    @Test
    void verifyShouldRejectUnverifiedEmail() throws Exception {
        String token = idToken("web-client-id", false, 2000);

        assertThatThrownBy(() -> verifier.verify(token))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessage("Invalid Google ID token");
    }

    @Test
    void verifyShouldRejectExpiredToken() throws Exception {
        String token = idToken("web-client-id", true, 999);

        assertThatThrownBy(() -> verifier.verify(token))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessage("Invalid Google ID token");
    }

    private String idToken(String audience, boolean emailVerified, long expiresAt) throws Exception {
        String header = base64Json(Map.of(
                "alg", "RS256",
                "typ", "JWT",
                "kid", "test-key"
        ));
        String payload = base64Json(Map.of(
                "iss", "https://accounts.google.com",
                "aud", audience,
                "sub", "google-sub",
                "email", "USER@example.COM",
                "email_verified", emailVerified,
                "name", "Wei",
                "picture", "https://example.com/avatar.png",
                "exp", expiresAt
        ));
        String unsignedToken = header + "." + payload;
        return unsignedToken + "." + sign(unsignedToken);
    }

    private Map<String, Object> jwk() {
        RSAPublicKey publicKey = (RSAPublicKey) keyPair.getPublic();
        return Map.of(
                "kid", "test-key",
                "kty", "RSA",
                "n", base64Url(publicKey.getModulus().toByteArray()),
                "e", base64Url(publicKey.getPublicExponent().toByteArray())
        );
    }

    private String sign(String unsignedToken) throws Exception {
        Signature signature = Signature.getInstance("SHA256withRSA");
        signature.initSign(keyPair.getPrivate());
        signature.update(unsignedToken.getBytes(StandardCharsets.UTF_8));
        return base64Url(signature.sign());
    }

    private String base64Json(Map<String, Object> value) throws Exception {
        return base64Url(objectMapper.writeValueAsBytes(value));
    }

    private String base64Url(byte[] value) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value);
    }
}
