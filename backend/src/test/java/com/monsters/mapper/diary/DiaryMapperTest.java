package com.monsters.mapper.diary;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.monsters.dto.diary.DiaryRecordMethod;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.entity.entry.Mood;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

class DiaryMapperTest {

    private final DiaryMapper mapper = new DiaryMapper();

    @Test
    void shouldMapTextDiaryAndHideObjectKey() {
        Entry entry = entry("diary content");
        EntryMedia drawing = media(20L, EntryMediaType.DRAWING, "private/secret-drawing-key", 1);

        DiaryResponse response = mapper.toResponse(entry, mood(), List.of(drawing));

        assertThat(response.recordMethod()).isEqualTo(DiaryRecordMethod.TEXT);
        assertThat(response.score()).isEqualTo(4);
        assertThat(response.isShared()).isFalse();
        assertThat(response.occurredAt().toString()).isEqualTo("2026-07-19T09:00+08:00");
        assertThat(response.media()).singleElement().satisfies(item -> {
            assertThat(item.type()).isEqualTo("drawing");
            assertThat(item.downloadUrl()).isEqualTo("/api/diaries/10/media/20");
            assertThat(item.toString()).doesNotContain("private/secret-drawing-key");
        });
        assertThat(response.reward()).isNull();
    }

    @Test
    void shouldInferMediaRecordMethod() {
        Entry entry = entry(null);
        EntryMedia image = media(21L, EntryMediaType.IMAGE, "private/image-key", 0);

        DiaryResponse response = mapper.toResponse(entry, mood(), List.of(image));

        assertThat(response.recordMethod()).isEqualTo(DiaryRecordMethod.IMAGE);
        assertThat(response.content()).isNull();
    }

    @Test
    void shouldRejectPersistedStateWithTextAndPrimaryMedia() {
        Entry entry = entry("diary content");
        EntryMedia image = media(21L, EntryMediaType.IMAGE, "private/image-key", 0);

        assertThatThrownBy(() -> mapper.toResponse(entry, mood(), List.of(image)))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("Diary has an invalid primary record state");
    }

    private Entry entry(String content) {
        Entry entry = Entry.diary(
                1L,
                3L,
                content,
                false,
                LocalDateTime.of(2026, 7, 19, 9, 0)
        );
        ReflectionTestUtils.setField(entry, "id", 10L);
        return entry;
    }

    private EntryMedia media(Long id, EntryMediaType type, String objectKey, int displayOrder) {
        EntryMedia media = new EntryMedia(
                10L,
                type,
                objectKey,
                "image/png",
                1024,
                null,
                displayOrder
        );
        ReflectionTestUtils.setField(media, "id", id);
        return media;
    }

    private Mood mood() {
        return new Mood("SCORE_4", "4分", 4, null, 4);
    }
}
