package com.monsters.security.password;

import java.text.Normalizer;
import java.util.Objects;
import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class PasswordHashService {

    private static final int SALT_LENGTH_BYTES = 16;
    private static final int HASH_LENGTH_BYTES = 32;
    private static final int PARALLELISM = 1;
    private static final int MEMORY_KIB = 19_456;
    private static final int ITERATIONS = 2;

    private final Argon2PasswordEncoder argon2PasswordEncoder;
    private final BCryptPasswordEncoder bcryptPasswordEncoder;

    public PasswordHashService() {
        this.argon2PasswordEncoder = new Argon2PasswordEncoder(
                SALT_LENGTH_BYTES,
                HASH_LENGTH_BYTES,
                PARALLELISM,
                MEMORY_KIB,
                ITERATIONS
        );
        this.bcryptPasswordEncoder = new BCryptPasswordEncoder();
    }

    public String encode(CharSequence rawPassword) {
        return argon2PasswordEncoder.encode(normalize(rawPassword));
    }

    public boolean matches(CharSequence rawPassword, String passwordHash) {
        if (rawPassword == null || passwordHash == null) {
            return false;
        }
        if (isBcrypt(passwordHash)) {
            return bcryptPasswordEncoder.matches(rawPassword, passwordHash)
                    || bcryptPasswordEncoder.matches(normalize(rawPassword), passwordHash);
        }
        if (passwordHash.startsWith("$argon2id$")) {
            return argon2PasswordEncoder.matches(normalize(rawPassword), passwordHash);
        }
        return false;
    }

    public boolean needsRehash(String passwordHash) {
        return isBcrypt(passwordHash)
                || (passwordHash != null
                && passwordHash.startsWith("$argon2id$")
                && argon2PasswordEncoder.upgradeEncoding(passwordHash));
    }

    private boolean isBcrypt(String passwordHash) {
        return passwordHash != null && passwordHash.matches("^\\$2[aby]\\$.*");
    }

    private String normalize(CharSequence rawPassword) {
        return Normalizer.normalize(
                Objects.requireNonNull(rawPassword, "rawPassword").toString(),
                Normalizer.Form.NFC
        );
    }
}
