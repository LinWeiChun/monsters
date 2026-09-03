package com.monsters.entity.user;

import com.monsters.dto.auth.ContinuationNextAction;
import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "member_continuation_credentials")
public class MemberContinuationCredential extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "token_hash", nullable = false, length = 64, unique = true)
    private String tokenHash;

    @Enumerated(EnumType.STRING)
    @Column(name = "next_action", nullable = false, length = 40)
    private ContinuationNextAction nextAction;

    @Enumerated(EnumType.STRING)
    @Column(name = "issued_for_state", nullable = false, length = 40)
    private MemberState issuedForState;

    @Column(name = "issued_for_version", nullable = false)
    private long issuedForVersion;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "revoked_at")
    private LocalDateTime revokedAt;

    protected MemberContinuationCredential() {
    }

    public MemberContinuationCredential(
            User user,
            String tokenHash,
            ContinuationNextAction nextAction,
            long issuedForVersion,
            LocalDateTime expiresAt
    ) {
        this.user = user;
        this.tokenHash = tokenHash;
        this.nextAction = nextAction;
        this.issuedForState = user.getMemberState();
        this.issuedForVersion = issuedForVersion;
        this.expiresAt = expiresAt;
    }

    public User getUser() {
        return user;
    }

    public String getTokenHash() {
        return tokenHash;
    }

    public ContinuationNextAction getNextAction() {
        return nextAction;
    }

    public MemberState getIssuedForState() {
        return issuedForState;
    }

    public long getIssuedForVersion() {
        return issuedForVersion;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public LocalDateTime getRevokedAt() {
        return revokedAt;
    }

    public boolean isUsableAt(LocalDateTime now) {
        return revokedAt == null && expiresAt.isAfter(now)
                && user.getMemberState() == issuedForState
                && user.getVersion() == issuedForVersion;
    }

    public void consume(LocalDateTime now) {
        if (!isUsableAt(now)) throw new IllegalStateException("Continuation credential unavailable");
        revokedAt = now;
    }
}
