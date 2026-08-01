package com.monsters.entity.user;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "guardian_consents")
public class GuardianConsent extends BaseEntity {
    @Column(name = "public_id", nullable = false, length = 36, unique = true, updatable = false)
    private String publicId;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    @Column(name = "guardian_email", nullable = false, length = 255)
    private String guardianEmail;
    @Column(name = "document_version", nullable = false, length = 80)
    private String documentVersion;
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private GuardianConsentStatus status;
    @Column(name = "requested_at", nullable = false)
    private LocalDateTime requestedAt;
    @Column(name = "granted_at") private LocalDateTime grantedAt;
    @Column(name = "withdrawn_at") private LocalDateTime withdrawnAt;
    protected GuardianConsent() {}
    public GuardianConsent(User user, String guardianEmail, String documentVersion, LocalDateTime now) {
        this.publicId = UUID.randomUUID().toString();
        this.user = user;
        this.guardianEmail = guardianEmail;
        this.documentVersion = documentVersion;
        this.status = GuardianConsentStatus.PENDING;
        this.requestedAt = now;
    }
    public void grant(LocalDateTime now) {
        if (status != GuardianConsentStatus.PENDING) throw new IllegalStateException("Consent is not pending");
        status = GuardianConsentStatus.GRANTED; grantedAt = now;
    }
    public void withdraw(LocalDateTime now) {
        if (status != GuardianConsentStatus.GRANTED) throw new IllegalStateException("Consent is not granted");
        status = GuardianConsentStatus.WITHDRAWN; withdrawnAt = now;
    }
    public String getPublicId() { return publicId; }
    public User getUser() { return user; }
    public String getGuardianEmail() { return guardianEmail; }
    public String getDocumentVersion() { return documentVersion; }
    public GuardianConsentStatus getStatus() { return status; }
}
