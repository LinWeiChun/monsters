package com.monsters.entity.audit;

import com.monsters.entity.common.BaseEntity;
import com.monsters.entity.session.UserSession;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "session_security_audits")
public class SessionSecurityAudit extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "session_id", nullable = false)
    private UserSession session;

    @Column(name = "event_id", nullable = false, length = 36, unique = true, updatable = false)
    private String eventId;

    @Column(name = "event_type", nullable = false, length = 80, updatable = false)
    private String eventType;

    @Column(name = "occurred_at", nullable = false, updatable = false)
    private LocalDateTime occurredAt;

    protected SessionSecurityAudit() {
    }

    public SessionSecurityAudit(
            UserSession session,
            String eventId,
            String eventType,
            LocalDateTime occurredAt
    ) {
        this.session = session;
        this.eventId = eventId;
        this.eventType = eventType;
        this.occurredAt = occurredAt;
    }
}
