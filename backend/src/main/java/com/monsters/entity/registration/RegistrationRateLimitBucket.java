package com.monsters.entity.registration;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.time.Duration;
import java.time.LocalDateTime;

@Entity
@Table(name = "registration_rate_limit_buckets")
public class RegistrationRateLimitBucket extends BaseEntity {

    @Enumerated(EnumType.STRING)
    @Column(name = "bucket_scope", nullable = false, length = 20)
    private RegistrationRateLimitScope scope;

    @Column(name = "key_hash", nullable = false, length = 64)
    private String keyHash;

    @Column(name = "window_started_at", nullable = false)
    private LocalDateTime windowStartedAt;

    @Column(name = "attempts", nullable = false)
    private int attempts;

    @Column(name = "last_attempt_at")
    private LocalDateTime lastAttemptAt;

    protected RegistrationRateLimitBucket() {
    }

    public long retryAfter(
            LocalDateTime now,
            long windowMinutes,
            int maxAttempts,
            long cooldownSeconds
    ) {
        resetExpiredWindow(now, windowMinutes);
        long cooldownRemaining = remainingSeconds(lastAttemptAt, cooldownSeconds, now);
        if (cooldownRemaining > 0) {
            return cooldownRemaining;
        }
        if (attempts >= maxAttempts) {
            return remainingSeconds(windowStartedAt, windowMinutes * 60, now);
        }
        return 0;
    }

    public void record(LocalDateTime now, long windowMinutes) {
        resetExpiredWindow(now, windowMinutes);
        attempts++;
        lastAttemptAt = now;
    }

    private void resetExpiredWindow(LocalDateTime now, long windowMinutes) {
        if (!windowStartedAt.plusMinutes(windowMinutes).isAfter(now)) {
            windowStartedAt = now;
            attempts = 0;
            lastAttemptAt = null;
        }
    }

    private long remainingSeconds(
            LocalDateTime start,
            long durationSeconds,
            LocalDateTime now
    ) {
        if (start == null || durationSeconds <= 0) {
            return 0;
        }
        LocalDateTime allowedAt = start.plusSeconds(durationSeconds);
        if (!allowedAt.isAfter(now)) {
            return 0;
        }
        long remainingMillis = Duration.between(now, allowedAt).toMillis();
        return Math.max(1, (remainingMillis + 999) / 1000);
    }
}
