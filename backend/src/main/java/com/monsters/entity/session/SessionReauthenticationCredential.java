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
@Table(name = "session_reauthentication_credentials")
public class SessionReauthenticationCredential extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "session_id", nullable = false)
    private UserSession session;

    @Column(name = "token_hash", nullable = false, length = 64, unique = true, updatable = false)
    private String tokenHash;

    @Column(name = "purpose", nullable = false, length = 40, updatable = false)
    private String purpose;

    @Column(name = "issued_at", nullable = false, updatable = false)
    private LocalDateTime issuedAt;

    @Column(name = "expires_at", nullable = false, updatable = false)
    private LocalDateTime expiresAt;

    @Column(name = "revoked_at")
    private LocalDateTime revokedAt;

    protected SessionReauthenticationCredential() {
    }

    public SessionReauthenticationCredential(
            UserSession session,
            String tokenHash,
            String purpose,
            LocalDateTime issuedAt,
            LocalDateTime expiresAt
    ) {
        this.session = session;
        this.tokenHash = tokenHash;
        this.purpose = purpose;
        this.issuedAt = issuedAt;
        this.expiresAt = expiresAt;
    }

    public UserSession getSession() {
        return session;
    }

    public void revoke(LocalDateTime now) {
        if (revokedAt == null) {
            revokedAt = now;
        }
    }

    public boolean isUsableAt(LocalDateTime now) {
        return revokedAt == null && expiresAt.isAfter(now);
    }
}
