package com.monsters.service.auth;

import com.monsters.config.auth.PasswordResetProperties;
import com.monsters.entity.registration.RegistrationRateLimitBucket;
import com.monsters.entity.registration.RegistrationRateLimitScope;
import com.monsters.exception.common.BusinessException;
import com.monsters.exception.common.RateLimitException;
import com.monsters.repository.registration.RegistrationRateLimitBucketRepository;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.Locale;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class PasswordResetRateLimitService {

    private static final String HMAC_ALGORITHM = "HmacSHA256";

    private final RegistrationRateLimitBucketRepository bucketRepository;
    private final PasswordResetProperties properties;
    private final Clock clock;

    public PasswordResetRateLimitService(
            RegistrationRateLimitBucketRepository bucketRepository,
            PasswordResetProperties properties,
            Clock clock
    ) {
        this.bucketRepository = bucketRepository;
        this.properties = properties;
        this.clock = clock;
    }

    @Transactional
    public void accept(String email, String remoteAddress) {
        validateConfiguration();
        LocalDateTime now = LocalDateTime.now(clock);
        RegistrationRateLimitBucket emailBucket = lockBucket(
                RegistrationRateLimitScope.EMAIL,
                hash("PASSWORD_RESET_EMAIL:" + email.trim().toLowerCase(Locale.ROOT)),
                now
        );
        RegistrationRateLimitBucket ipBucket = lockBucket(
                RegistrationRateLimitScope.IP,
                hash("PASSWORD_RESET_IP:" + normalizedAddress(remoteAddress)),
                now
        );
        long retryAfter = Math.max(
                emailBucket.retryAfter(
                        now,
                        properties.getRateLimitWindowMinutes(),
                        properties.getRateLimitEmailMaxAttempts(),
                        properties.getRateLimitEmailCooldownSeconds()
                ),
                ipBucket.retryAfter(
                        now,
                        properties.getRateLimitWindowMinutes(),
                        properties.getRateLimitIpMaxAttempts(),
                        0
                )
        );
        if (retryAfter > 0) {
            throw new RateLimitException(retryAfter);
        }
        emailBucket.record(now, properties.getRateLimitWindowMinutes());
        ipBucket.record(now, properties.getRateLimitWindowMinutes());
    }

    private RegistrationRateLimitBucket lockBucket(
            RegistrationRateLimitScope scope,
            String keyHash,
            LocalDateTime now
    ) {
        bucketRepository.insertIfMissing(scope.name(), keyHash, now);
        return bucketRepository.findByScopeAndKeyHash(scope, keyHash)
                .orElseThrow(() -> new IllegalStateException("Password reset rate limit bucket missing"));
    }

    private String hash(String value) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            mac.init(new SecretKeySpec(
                    properties.getRateLimitHashKey().getBytes(StandardCharsets.UTF_8),
                    HMAC_ALGORITHM
            ));
            return HexFormat.of().formatHex(mac.doFinal(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException | InvalidKeyException exception) {
            throw new IllegalStateException("Password reset rate limit hashing failed", exception);
        }
    }

    private String normalizedAddress(String remoteAddress) {
        return StringUtils.hasText(remoteAddress) ? remoteAddress : "unknown";
    }

    private void validateConfiguration() {
        if (!StringUtils.hasText(properties.getRateLimitHashKey())
                || properties.getRateLimitEmailCooldownSeconds() <= 0
                || properties.getRateLimitEmailMaxAttempts() <= 0
                || properties.getRateLimitIpMaxAttempts() <= 0
                || properties.getRateLimitWindowMinutes() <= 0) {
            throw new BusinessException(
                    HttpStatus.SERVICE_UNAVAILABLE,
                    "SERVICE_TEMPORARILY_UNAVAILABLE",
                    "Password reset service is temporarily unavailable"
            );
        }
    }
}
