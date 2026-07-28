package com.monsters.entity.entry;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "entry_drafts")
public class EntryDraft extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "entry_type", nullable = false, length = 20)
    private EntryType entryType;

    @Enumerated(EnumType.STRING)
    @Column(name = "current_step", nullable = false, length = 30)
    private EntryDraftStep currentStep;

    @Column(name = "annoyance_type_id")
    private Long annoyanceTypeId;

    @Enumerated(EnumType.STRING)
    @Column(name = "record_method", length = 20)
    private EntryDraftRecordMethod recordMethod;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Column(name = "wants_drawing")
    private Boolean wantsDrawing;

    @Column(name = "score")
    private Integer score;

    @Column(name = "is_shared")
    private Boolean shared;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    protected EntryDraft() {
    }

    public EntryDraft(Long userId, EntryType entryType) {
        this.userId = userId;
        this.entryType = entryType;
        this.currentStep = EntryDraftStep.INTRO;
    }

    public void update(
            EntryDraftStep currentStep,
            Long annoyanceTypeId,
            EntryDraftRecordMethod recordMethod,
            String content,
            Boolean wantsDrawing,
            Integer score,
            Boolean shared,
            LocalDateTime expiresAt
    ) {
        this.currentStep = currentStep;
        this.annoyanceTypeId = annoyanceTypeId;
        this.recordMethod = recordMethod;
        this.content = content;
        this.wantsDrawing = wantsDrawing;
        this.score = score;
        this.shared = shared;
        this.expiresAt = expiresAt;
    }

    public Long getUserId() {
        return userId;
    }

    public EntryType getEntryType() {
        return entryType;
    }

    public EntryDraftStep getCurrentStep() {
        return currentStep;
    }

    public Long getAnnoyanceTypeId() {
        return annoyanceTypeId;
    }

    public EntryDraftRecordMethod getRecordMethod() {
        return recordMethod;
    }

    public String getContent() {
        return content;
    }

    public Boolean getWantsDrawing() {
        return wantsDrawing;
    }

    public Integer getScore() {
        return score;
    }

    public Boolean getShared() {
        return shared;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }
}
