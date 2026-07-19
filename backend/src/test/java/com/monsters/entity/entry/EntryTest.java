package com.monsters.entity.entry;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;

class EntryTest {

    @Test
    void shouldMapSharedEntryAggregateToEntriesTable() {
        assertThat(Entry.class).hasAnnotation(Entity.class);
        assertThat(Entry.class.getAnnotation(Table.class).name()).isEqualTo("entries");
        assertThat(Entry.class.getSuperclass()).isEqualTo(BaseEntity.class);
    }

    @Test
    void shouldCreateAnnoyanceWithSafeDefaults() {
        LocalDateTime occurredAt = LocalDateTime.of(2026, 7, 11, 12, 0);

        Entry entry = Entry.annoyance(1L, 2L, 3L, "content", true, occurredAt);

        assertThat(entry.getUserId()).isEqualTo(1L);
        assertThat(entry.getEntryType()).isEqualTo(EntryType.ANNOYANCE);
        assertThat(entry.getAnnoyanceTypeId()).isEqualTo(2L);
        assertThat(entry.getMoodId()).isEqualTo(3L);
        assertThat(entry.getContent()).isEqualTo("content");
        assertThat(entry.isShared()).isTrue();
        assertThat(entry.isSolved()).isFalse();
        assertThat(entry.isDeleted()).isFalse();
        assertThat(entry.getOccurredAt()).isEqualTo(occurredAt);
    }

    @Test
    void shouldSupportAnnoyanceLifecycleChanges() {
        Entry entry = Entry.annoyance(
                1L,
                2L,
                3L,
                "old",
                false,
                LocalDateTime.of(2026, 7, 11, 12, 0)
        );
        LocalDateTime updatedOccurredAt = LocalDateTime.of(2026, 7, 12, 13, 0);

        entry.updateAnnoyance(4L, 5L, "new", true, updatedOccurredAt);
        entry.solve();
        entry.updateShared(false);
        entry.markDeleted();

        assertThat(entry.getAnnoyanceTypeId()).isEqualTo(4L);
        assertThat(entry.getMoodId()).isEqualTo(5L);
        assertThat(entry.getContent()).isEqualTo("new");
        assertThat(entry.isSolved()).isTrue();
        assertThat(entry.isShared()).isFalse();
        assertThat(entry.isDeleted()).isTrue();
        assertThat(entry.getDeletedAt()).isNotNull();
    }

    @Test
    void shouldCreateDiaryWithSafeDefaults() {
        LocalDateTime occurredAt = LocalDateTime.of(2026, 7, 19, 9, 0);

        Entry entry = Entry.diary(1L, 3L, "diary content", true, occurredAt);

        assertThat(entry.getUserId()).isEqualTo(1L);
        assertThat(entry.getEntryType()).isEqualTo(EntryType.DIARY);
        assertThat(entry.getMonsterId()).isNull();
        assertThat(entry.getAnnoyanceTypeId()).isNull();
        assertThat(entry.getMoodId()).isEqualTo(3L);
        assertThat(entry.getContent()).isEqualTo("diary content");
        assertThat(entry.isShared()).isTrue();
        assertThat(entry.isSolved()).isFalse();
        assertThat(entry.isDeleted()).isFalse();
        assertThat(entry.getOccurredAt()).isEqualTo(occurredAt);
    }

    @Test
    void shouldSupportDiaryUpdatesAndProtectEntryTypeInvariants() {
        Entry diary = Entry.diary(
                1L,
                3L,
                "old",
                false,
                LocalDateTime.of(2026, 7, 19, 9, 0)
        );
        LocalDateTime updatedOccurredAt = LocalDateTime.of(2026, 7, 19, 10, 0);

        diary.updateDiary(4L, "new", true, updatedOccurredAt);

        assertThat(diary.getAnnoyanceTypeId()).isNull();
        assertThat(diary.getMoodId()).isEqualTo(4L);
        assertThat(diary.getContent()).isEqualTo("new");
        assertThat(diary.isShared()).isTrue();
        assertThat(diary.isSolved()).isFalse();
        assertThat(diary.getOccurredAt()).isEqualTo(updatedOccurredAt);
        assertThatThrownBy(() -> diary.updateAnnoyance(2L, 4L, "invalid", false, updatedOccurredAt))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("Entry is not an annoyance");

        Entry annoyance = Entry.annoyance(1L, 2L, 3L, "content", false, updatedOccurredAt);
        assertThatThrownBy(() -> annoyance.updateDiary(4L, "invalid", false, updatedOccurredAt))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("Entry is not a diary");
    }
}
