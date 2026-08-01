package com.monsters.entity.user;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "guardian_consent_tokens")
public class GuardianConsentToken extends BaseEntity {
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "guardian_consent_id", nullable = false)
    private GuardianConsent consent;
    @Enumerated(EnumType.STRING)
    @Column(name = "purpose", nullable = false, length = 20)
    private GuardianConsentTokenPurpose purpose;
    @Column(name = "token_hash", nullable = false, length = 64, unique = true)
    private String tokenHash;
    @Column(name = "expires_at", nullable = false) private LocalDateTime expiresAt;
    @Column(name = "used_at") private LocalDateTime usedAt;
    @Column(name = "revoked_at") private LocalDateTime revokedAt;
    protected GuardianConsentToken() {}
    public GuardianConsentToken(GuardianConsent consent, GuardianConsentTokenPurpose purpose,
            String tokenHash, LocalDateTime expiresAt) {
        this.consent = consent; this.purpose = purpose; this.tokenHash = tokenHash; this.expiresAt = expiresAt;
    }
    public boolean isUsableAt(LocalDateTime now) {
        return usedAt == null && revokedAt == null && expiresAt.isAfter(now);
    }
    public boolean isExpiredAt(LocalDateTime now) { return !expiresAt.isAfter(now); }
    public void consume(LocalDateTime now) { if (!isUsableAt(now)) throw new IllegalStateException("Token unavailable"); usedAt = now; }
    public void revoke(LocalDateTime now) { if (usedAt == null) revokedAt = now; }
    public GuardianConsent getConsent() { return consent; }
    public GuardianConsentTokenPurpose getPurpose() { return purpose; }
    public LocalDateTime getExpiresAt() { return expiresAt; }
}
