package com.monsters.security.password;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

@Component
public class PasswordBlocklist {

    private static final String SHA_256 = "SHA-256";

    private final Set<String> passwordHashes;

    public PasswordBlocklist(
            @Value("classpath:security/password-blocklist-v1.sha256") Resource resource
    ) {
        this.passwordHashes = load(resource);
    }

    public boolean contains(String normalizedPassword) {
        return passwordHashes.contains(sha256(normalizedPassword));
    }

    static String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance(SHA_256);
            return HexFormat.of().formatHex(digest.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is not available", exception);
        }
    }

    private Set<String> load(Resource resource) {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(
                resource.getInputStream(),
                StandardCharsets.UTF_8
        ))) {
            Set<String> hashes = reader.lines()
                    .map(String::trim)
                    .filter(line -> !line.isEmpty() && !line.startsWith("#"))
                    .peek(this::requireSha256)
                    .collect(Collectors.toUnmodifiableSet());
            if (hashes.isEmpty()) {
                throw new IllegalStateException("Password blocklist must not be empty");
            }
            return hashes;
        } catch (IOException exception) {
            throw new IllegalStateException("Password blocklist could not be loaded", exception);
        }
    }

    private void requireSha256(String hash) {
        if (!hash.matches("[0-9a-f]{64}")) {
            throw new IllegalStateException("Password blocklist contains an invalid hash");
        }
    }
}
