package com.monsters.service.registration;

import com.monsters.config.registration.RegistrationRateLimitProperties;
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
public class RegistrationRateLimitService {

    private static final String HMAC_ALGORITHM = "HmacSHA256";

    private final RegistrationRateLimitBucketRepository bucketRepository;
    private final RegistrationRateLimitProperties properties;
    private final Clock clock;

    public RegistrationRateLimitService(
            RegistrationRateLimitBucketRepository bucketRepository,
            RegistrationRateLimitProperties properties,
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
                hash("EMAIL:" + email.trim().toLowerCase(Locale.ROOT)),
                now
        );
        RegistrationRateLimitBucket ipBucket = lockBucket(
                RegistrationRateLimitScope.IP,
                hash("IP:" + normalizedAddress(remoteAddress)),
                now
        );

        long emailRetryAfter = emailBucket.retryAfter(
                now,
                properties.getWindowMinutes(),
                properties.getEmailMaxAttempts(),
                properties.getEmailCooldownSeconds()
        );
        long ipRetryAfter = ipBucket.retryAfter(
                now,
                properties.getWindowMinutes(),
                properties.getIpMaxAttempts(),
                0
        );
        long retryAfter = Math.max(emailRetryAfter, ipRetryAfter);
        if (retryAfter > 0) {
            throw new RateLimitException(retryAfter);
        }

        emailBucket.record(now, properties.getWindowMinutes());
        ipBucket.record(now, properties.getWindowMinutes());
    }

    private RegistrationRateLimitBucket lockBucket(
            RegistrationRateLimitScope scope,
            String keyHash,
            LocalDateTime now
    ) {
        bucketRepository.insertIfMissing(scope.name(), keyHash, now);
        return bucketRepository.findByScopeAndKeyHash(scope, keyHash)
                .orElseThrow(() -> new IllegalStateException("Rate limit bucket missing"));
    }

    private String hash(String value) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            mac.init(new SecretKeySpec(
                    properties.getHashKey().getBytes(StandardCharsets.UTF_8),
                    HMAC_ALGORITHM
            ));
            return HexFormat.of().formatHex(mac.doFinal(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException | InvalidKeyException exception) {
            throw new IllegalStateException("Registration rate limit hashing failed", exception);
        }
    }

    private String normalizedAddress(String remoteAddress) {
        return StringUtils.hasText(remoteAddress) ? remoteAddress : "unknown";
    }

    private void validateConfiguration() {
        if (!StringUtils.hasText(properties.getHashKey())
                || properties.getEmailCooldownSeconds() <= 0
                || properties.getEmailMaxAttempts() <= 0
                || properties.getIpMaxAttempts() <= 0
                || properties.getWindowMinutes() <= 0) {
            throw new BusinessException(
                    HttpStatus.SERVICE_UNAVAILABLE,
                    "SERVICE_TEMPORARILY_UNAVAILABLE",
                    "Registration service is temporarily unavailable"
            );
        }
    }
}
