package com.monsters.security.common;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import org.springframework.stereotype.Service;

@Service
public class PasswordResetTokenService {

    private static final int TOKEN_BYTE_LENGTH = 32;

    private final SecureRandom secureRandom;

    public PasswordResetTokenService() {
        this(new SecureRandom());
    }

    PasswordResetTokenService(SecureRandom secureRandom) {
        this.secureRandom = secureRandom;
    }

    public String createToken() {
        byte[] tokenBytes = new byte[TOKEN_BYTE_LENGTH];
        secureRandom.nextBytes(tokenBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(tokenBytes);
    }

    public String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(hash);
        } catch (Exception exception) {
            throw new IllegalStateException("Password reset token hashing failed", exception);
        }
    }
}
