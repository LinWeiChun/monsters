package com.monsters.entity.user;

import com.monsters.entity.common.BaseEntity;
import com.monsters.entity.session.UserSession;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "member_email_change_requests")
public class MemberEmailChangeRequest extends BaseEntity {

    @Column(name = "public_id", nullable = false, length = 36, unique = true, updatable = false)
    private String publicId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "initiating_session_id", nullable = false)
    private UserSession initiatingSession;

    @Column(name = "original_email", nullable = false, length = 255)
    private String originalEmail;

    @Column(name = "new_email", nullable = false, length = 255)
    private String newEmail;

    @Column(name = "requested_for_version", nullable = false)
    private long requestedForVersion;

    @Column(name = "token_hash", length = 64, unique = true)
    private String tokenHash;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private MemberEmailChangeStatus status;

    @Column(name = "verified_at")
    private LocalDateTime verifiedAt;

    protected MemberEmailChangeRequest() {
    }

    public MemberEmailChangeRequest(
            User user,
            UserSession initiatingSession,
            String originalEmail,
            String newEmail,
            long requestedForVersion
    ) {
        this.publicId = UUID.randomUUID().toString();
        this.user = user;
        this.initiatingSession = initiatingSession;
        this.originalEmail = originalEmail;
        this.newEmail = newEmail;
        this.requestedForVersion = requestedForVersion;
        this.status = MemberEmailChangeStatus.PENDING_DELIVERY;
    }

    public void awaitVerification(String tokenHash, LocalDateTime expiresAt) {
        if (status != MemberEmailChangeStatus.PENDING_DELIVERY) {
            throw new IllegalStateException("Email change request cannot receive a token");
        }
        this.tokenHash = tokenHash;
        this.expiresAt = expiresAt;
        this.status = MemberEmailChangeStatus.PENDING_VERIFICATION;
    }

    public void supersede() {
        if (status == MemberEmailChangeStatus.PENDING_DELIVERY
                || status == MemberEmailChangeStatus.PENDING_VERIFICATION) {
            status = MemberEmailChangeStatus.SUPERSEDED;
            tokenHash = null;
        }
    }

    public void resetDelivery() {
        if (status == MemberEmailChangeStatus.PENDING_VERIFICATION) {
            status = MemberEmailChangeStatus.PENDING_DELIVERY;
            tokenHash = null;
            expiresAt = null;
        }
    }

    public void expire() {
        if (status == MemberEmailChangeStatus.PENDING_VERIFICATION) {
            status = MemberEmailChangeStatus.EXPIRED;
        }
    }

    public void complete(LocalDateTime now) {
        if (status != MemberEmailChangeStatus.PENDING_VERIFICATION) {
            throw new IllegalStateException("Email change request is not awaiting verification");
        }
        status = MemberEmailChangeStatus.COMPLETED;
        verifiedAt = now;
    }

    public boolean isPending() {
        return status == MemberEmailChangeStatus.PENDING_DELIVERY
                || status == MemberEmailChangeStatus.PENDING_VERIFICATION;
    }

    public String getPublicId() { return publicId; }
    public User getUser() { return user; }
    public UserSession getInitiatingSession() { return initiatingSession; }
    public String getOriginalEmail() { return originalEmail; }
    public String getNewEmail() { return newEmail; }
    public long getRequestedForVersion() { return requestedForVersion; }
    public String getTokenHash() { return tokenHash; }
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public MemberEmailChangeStatus getStatus() { return status; }
    public LocalDateTime getVerifiedAt() { return verifiedAt; }
}
