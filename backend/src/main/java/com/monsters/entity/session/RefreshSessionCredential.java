package com.monsters.entity.session;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "refresh_session_credentials")
public class RefreshSessionCredential extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "session_id", nullable = false)
    private UserSession session;

    @Column(name = "token_hash", nullable = false, length = 64, unique = true, updatable = false)
    private String tokenHash;

    @Column(name = "sequence_number", nullable = false, updatable = false)
    private long sequenceNumber;

    @Column(name = "issued_at", nullable = false, updatable = false)
    private LocalDateTime issuedAt;

    @Column(name = "rotated_at")
    private LocalDateTime rotatedAt;

    @Column(name = "grace_expires_at")
    private LocalDateTime graceExpiresAt;

    @Column(name = "reuse_detected_at")
    private LocalDateTime reuseDetectedAt;

    protected RefreshSessionCredential() {
    }

    public RefreshSessionCredential(
            UserSession session,
            String tokenHash,
            long sequenceNumber,
            LocalDateTime issuedAt
    ) {
        this.session = session;
        this.tokenHash = tokenHash;
        this.sequenceNumber = sequenceNumber;
        this.issuedAt = issuedAt;
    }

    public void markRotated(LocalDateTime now, long graceSeconds) {
        rotatedAt = now;
        graceExpiresAt = now.plusSeconds(graceSeconds);
    }

    public boolean isRotated() {
        return rotatedAt != null;
    }

    public boolean isWithinGrace(LocalDateTime now) {
        return graceExpiresAt != null && !now.isAfter(graceExpiresAt);
    }

    public void markReuseDetected(LocalDateTime now) {
        reuseDetectedAt = now;
    }

    public UserSession getSession() {
        return session;
    }

    public String getTokenHash() {
        return tokenHash;
    }

    public long getSequenceNumber() {
        return sequenceNumber;
    }

    public LocalDateTime getRotatedAt() {
        return rotatedAt;
    }
}
