package com.monsters.security.session;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.stereotype.Component;

@Component
public class RefreshCredentialGenerator {

    private static final String HMAC_SHA256 = "HmacSHA256";
    private final SecureRandom secureRandom = new SecureRandom();

    public String initialCredential() {
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        return encode(bytes);
    }

    public String deriveSuccessor(
            String currentCredential,
            String sessionPublicId,
            long nextSequence,
            String derivationKey
    ) {
        requireDerivationKey(derivationKey);
        String input = currentCredential + "\n" + sessionPublicId + "\n" + nextSequence;
        try {
            Mac mac = Mac.getInstance(HMAC_SHA256);
            mac.init(new SecretKeySpec(
                    derivationKey.getBytes(StandardCharsets.UTF_8),
                    HMAC_SHA256
            ));
            return encode(mac.doFinal(input.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception exception) {
            throw new IllegalStateException("Refresh credential derivation failed", exception);
        }
    }

    public String hash(String credential) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest(credential.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(digest.length * 2);
            for (byte value : digest) {
                hex.append(String.format("%02x", value));
            }
            return hex.toString();
        } catch (Exception exception) {
            throw new IllegalStateException("Refresh credential hashing failed", exception);
        }
    }

    public void requireDerivationKey(String derivationKey) {
        if (derivationKey == null
                || derivationKey.isBlank()
                || derivationKey.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalStateException("Refresh credential derivation key is not configured");
        }
    }

    private String encode(byte[] value) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value);
    }
}
