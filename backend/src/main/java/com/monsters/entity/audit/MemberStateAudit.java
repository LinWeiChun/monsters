package com.monsters.entity.audit;

import com.monsters.entity.common.BaseEntity;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
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
@Table(name = "member_state_audits")
public class MemberStateAudit extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "event_id", nullable = false, length = 36, unique = true, updatable = false)
    private String eventId;

    @Enumerated(EnumType.STRING)
    @Column(name = "from_state", nullable = false, length = 40)
    private MemberState fromState;

    @Enumerated(EnumType.STRING)
    @Column(name = "to_state", nullable = false, length = 40)
    private MemberState toState;

    @Column(name = "reason_code", nullable = false, length = 80)
    private String reasonCode;

    @Enumerated(EnumType.STRING)
    @Column(name = "actor_type", nullable = false, length = 20)
    private MemberStateActorType actorType;

    @Column(name = "occurred_at", nullable = false)
    private LocalDateTime occurredAt;

    protected MemberStateAudit() {
    }

    public MemberStateAudit(
            User user,
            String eventId,
            MemberState fromState,
            MemberState toState,
            String reasonCode,
            MemberStateActorType actorType,
            LocalDateTime occurredAt
    ) {
        this.user = user;
        this.eventId = eventId;
        this.fromState = fromState;
        this.toState = toState;
        this.reasonCode = reasonCode;
        this.actorType = actorType;
        this.occurredAt = occurredAt;
    }
}
