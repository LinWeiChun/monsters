package com.monsters.entity.user;

import com.monsters.entity.common.BaseEntity;
import com.monsters.service.eligibility.EligibilityAgeBand;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "birthday_correction_requests")
public class BirthdayCorrectionRequest extends BaseEntity {

    @Column(name = "public_id", nullable = false, length = 36, unique = true, updatable = false)
    private String publicId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "current_birthday", nullable = false)
    private LocalDate currentBirthday;

    @Column(name = "requested_birthday", nullable = false)
    private LocalDate requestedBirthday;

    @Enumerated(EnumType.STRING)
    @Column(name = "reason_code", nullable = false, length = 40)
    private BirthdayCorrectionReason reason;

    @Column(name = "requested_for_version", nullable = false)
    private long requestedForVersion;

    @Enumerated(EnumType.STRING)
    @Column(name = "from_age_band", nullable = false, length = 20)
    private EligibilityAgeBand fromAgeBand;

    @Enumerated(EnumType.STRING)
    @Column(name = "to_age_band", nullable = false, length = 20)
    private EligibilityAgeBand toAgeBand;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private BirthdayCorrectionStatus status;

    @Column(name = "restricted_at")
    private LocalDateTime restrictedAt;

    @Column(name = "decided_at")
    private LocalDateTime decidedAt;

    protected BirthdayCorrectionRequest() {
    }

    public BirthdayCorrectionRequest(
            User user,
            LocalDate currentBirthday,
            LocalDate requestedBirthday,
            BirthdayCorrectionReason reason,
            long requestedForVersion,
            EligibilityAgeBand fromAgeBand,
            EligibilityAgeBand toAgeBand,
            BirthdayCorrectionStatus status,
            LocalDateTime now
    ) {
        this.publicId = UUID.randomUUID().toString();
        this.user = user;
        this.currentBirthday = currentBirthday;
        this.requestedBirthday = requestedBirthday;
        this.reason = reason;
        this.requestedForVersion = requestedForVersion;
        this.fromAgeBand = fromAgeBand;
        this.toAgeBand = toAgeBand;
        this.status = status;
        if (status == BirthdayCorrectionStatus.AUTO_APPROVED) {
            this.decidedAt = now;
        }
    }

    public void markRestricted(LocalDateTime now) {
        restrictedAt = now;
    }

    public String getPublicId() { return publicId; }
    public User getUser() { return user; }
    public LocalDate getCurrentBirthday() { return currentBirthday; }
    public LocalDate getRequestedBirthday() { return requestedBirthday; }
    public BirthdayCorrectionReason getReason() { return reason; }
    public long getRequestedForVersion() { return requestedForVersion; }
    public EligibilityAgeBand getFromAgeBand() { return fromAgeBand; }
    public EligibilityAgeBand getToAgeBand() { return toAgeBand; }
    public BirthdayCorrectionStatus getStatus() { return status; }
    public LocalDateTime getRestrictedAt() { return restrictedAt; }
    public LocalDateTime getDecidedAt() { return decidedAt; }
}
