package com.monsters.entity.session;

import com.monsters.entity.common.BaseEntity;
import com.monsters.entity.user.User;
import com.monsters.security.session.SessionDeviceContext;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "user_sessions")
public class UserSession extends BaseEntity {

    @Column(name = "public_id", nullable = false, length = 36, unique = true, updatable = false)
    private String publicId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "session_type", nullable = false, length = 20)
    private String sessionType;

    @Column(name = "device_type", nullable = false, length = 16)
    private String deviceType;

    @Column(name = "device_summary", nullable = false, length = 120)
    private String deviceSummary;

    @Column(name = "last_activity_at", nullable = false)
    private LocalDateTime lastActivityAt;

    @Column(name = "idle_expires_at", nullable = false)
    private LocalDateTime idleExpiresAt;

    @Column(name = "absolute_expires_at", nullable = false)
    private LocalDateTime absoluteExpiresAt;

    @Column(name = "revoked_at")
    private LocalDateTime revokedAt;

    @Column(name = "revocation_reason", length = 80)
    private String revocationReason;

    protected UserSession() {
    }

    public UserSession(User user, LocalDateTime now, long idleSeconds, long absoluteSeconds) {
        this(user, now, idleSeconds, absoluteSeconds, SessionDeviceContext.unknown());
    }

    public UserSession(
            User user,
            LocalDateTime now,
            long idleSeconds,
            long absoluteSeconds,
            SessionDeviceContext deviceContext
    ) {
        this.publicId = UUID.randomUUID().toString();
        this.user = user;
        this.sessionType = "MEMBER";
        this.deviceType = deviceContext.type().name();
        this.deviceSummary = deviceContext.summary();
        this.lastActivityAt = now;
        this.idleExpiresAt = now.plusSeconds(idleSeconds);
        this.absoluteExpiresAt = now.plusSeconds(absoluteSeconds);
    }

    public void recordActivity(LocalDateTime now, long idleSeconds) {
        lastActivityAt = now;
        LocalDateTime candidate = now.plusSeconds(idleSeconds);
        idleExpiresAt = candidate.isBefore(absoluteExpiresAt) ? candidate : absoluteExpiresAt;
    }

    public boolean isExpired(LocalDateTime now) {
        return !idleExpiresAt.isAfter(now) || !absoluteExpiresAt.isAfter(now);
    }

    public boolean isRevoked() {
        return revokedAt != null;
    }

    public boolean isActiveAt(LocalDateTime now) {
        return !isRevoked() && !isExpired(now);
    }

    public void revoke(LocalDateTime now, String reason) {
        if (revokedAt == null) {
            revokedAt = now;
            revocationReason = reason;
        }
    }

    public String getPublicId() {
        return publicId;
    }

    public User getUser() {
        return user;
    }

    public String getDeviceType() {
        return deviceType;
    }

    public String getDeviceSummary() {
        return deviceSummary;
    }

    public LocalDateTime getLastActivityAt() {
        return lastActivityAt;
    }

    public LocalDateTime getIdleExpiresAt() {
        return idleExpiresAt;
    }

    public LocalDateTime getAbsoluteExpiresAt() {
        return absoluteExpiresAt;
    }

    public LocalDateTime getRevokedAt() {
        return revokedAt;
    }
}
