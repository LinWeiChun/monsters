package com.monsters.entry.entity;

import com.monsters.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "entries")
public class Entry extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "entry_type", nullable = false, length = 20)
    private EntryType entryType;

    @Column(name = "monster_id")
    private Long monsterId;

    @Column(name = "annoyance_type_id")
    private Long annoyanceTypeId;

    @Column(name = "mood_id", nullable = false)
    private Long moodId;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Column(name = "is_shared", nullable = false)
    private boolean shared;

    @Column(name = "is_solved", nullable = false)
    private boolean solved;

    @Column(name = "occurred_at", nullable = false)
    private LocalDateTime occurredAt;

    @Column(name = "is_deleted", nullable = false)
    private boolean deleted;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    protected Entry() {
    }

    public static Entry annoyance(
            Long userId,
            Long annoyanceTypeId,
            Long moodId,
            String content,
            boolean shared,
            LocalDateTime occurredAt
    ) {
        Entry entry = new Entry();
        entry.userId = userId;
        entry.entryType = EntryType.ANNOYANCE;
        entry.annoyanceTypeId = annoyanceTypeId;
        entry.moodId = moodId;
        entry.content = content;
        entry.shared = shared;
        entry.solved = false;
        entry.occurredAt = occurredAt;
        entry.deleted = false;
        return entry;
    }

    public void updateAnnoyance(
            Long annoyanceTypeId,
            Long moodId,
            String content,
            boolean shared,
            LocalDateTime occurredAt
    ) {
        requireAnnoyance();
        this.annoyanceTypeId = annoyanceTypeId;
        this.moodId = moodId;
        this.content = content;
        this.shared = shared;
        this.occurredAt = occurredAt;
    }

    public void solve() {
        requireAnnoyance();
        solved = true;
    }

    public void updateShared(boolean shared) {
        this.shared = shared;
    }

    public void markDeleted() {
        deleted = true;
        deletedAt = LocalDateTime.now();
    }

    private void requireAnnoyance() {
        if (entryType != EntryType.ANNOYANCE) {
            throw new IllegalStateException("Entry is not an annoyance");
        }
    }

    public Long getUserId() {
        return userId;
    }

    public EntryType getEntryType() {
        return entryType;
    }

    public Long getMonsterId() {
        return monsterId;
    }

    public Long getAnnoyanceTypeId() {
        return annoyanceTypeId;
    }

    public Long getMoodId() {
        return moodId;
    }

    public String getContent() {
        return content;
    }

    public boolean isShared() {
        return shared;
    }

    public boolean isSolved() {
        return solved;
    }

    public LocalDateTime getOccurredAt() {
        return occurredAt;
    }

    public boolean isDeleted() {
        return deleted;
    }

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }
}
