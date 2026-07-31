package com.monsters.security.password;

import java.text.Normalizer;
import org.springframework.stereotype.Component;

@Component
public class PasswordPolicy {

    public static final int MINIMUM_CODE_POINTS = 15;
    public static final int MAXIMUM_CODE_POINTS = 128;

    private final PasswordBlocklist passwordBlocklist;

    public PasswordPolicy(PasswordBlocklist passwordBlocklist) {
        this.passwordBlocklist = passwordBlocklist;
    }

    public String normalizeAndValidate(String password) {
        if (password == null || password.isEmpty()) {
            throw new PasswordPolicyException("PASSWORD_REQUIRED");
        }

        String normalizedPassword = Normalizer.normalize(password, Normalizer.Form.NFC);
        int codePointCount = normalizedPassword.codePointCount(0, normalizedPassword.length());
        if (codePointCount < MINIMUM_CODE_POINTS) {
            throw new PasswordPolicyException("PASSWORD_TOO_SHORT");
        }
        if (codePointCount > MAXIMUM_CODE_POINTS) {
            throw new PasswordPolicyException("PASSWORD_TOO_LONG");
        }
        if (passwordBlocklist.contains(normalizedPassword)) {
            throw new PasswordPolicyException("PASSWORD_TOO_WEAK");
        }
        return normalizedPassword;
    }
}
