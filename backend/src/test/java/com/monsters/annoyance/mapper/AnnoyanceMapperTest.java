package com.monsters.annoyance.mapper;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.monsters.annoyance.dto.AnnoyanceRecordMethod;
import com.monsters.annoyance.dto.AnnoyanceResponse;
import com.monsters.annoyance.entity.AnnoyanceType;
import com.monsters.entry.entity.Entry;
import com.monsters.entry.entity.EntryMedia;
import com.monsters.entry.entity.EntryMediaType;
import com.monsters.entry.entity.Mood;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

class AnnoyanceMapperTest {

    private final AnnoyanceMapper mapper = new AnnoyanceMapper();

    @Test
    void shouldMapTextAnnoyanceAndHideObjectKey() {
        Entry entry = entry("content");
        EntryMedia drawing = new EntryMedia(
                10L,
                EntryMediaType.DRAWING,
                "private/secret-drawing-key",
                "image/png",
                1024,
                null,
                1
        );
        ReflectionTestUtils.setField(drawing, "id", 20L);

        AnnoyanceResponse response = mapper.toResponse(entry, category(), mood(), List.of(drawing));

        assertThat(response.recordMethod()).isEqualTo(AnnoyanceRecordMethod.TEXT);
        assertThat(response.category().code()).isEqualTo("ACADEMIC");
        assertThat(response.score()).isEqualTo(4);
        assertThat(response.occurredAt().toString()).isEqualTo("2026-07-11T12:00+08:00");
        assertThat(response.media()).singleElement().satisfies(media -> {
            assertThat(media.type()).isEqualTo("drawing");
            assertThat(media.downloadUrl()).isEqualTo("/api/annoyances/10/media/20");
            assertThat(media.toString()).doesNotContain("private/secret-drawing-key");
        });
        assertThat(response.reward()).isNull();
    }

    @Test
    void shouldInferMediaRecordMethod() {
        Entry entry = entry(null);
        EntryMedia image = new EntryMedia(
                10L,
                EntryMediaType.IMAGE,
                "private/image-key",
                "image/png",
                2048,
                null,
                0
        );
        ReflectionTestUtils.setField(image, "id", 21L);

        AnnoyanceResponse response = mapper.toResponse(entry, category(), mood(), List.of(image));

        assertThat(response.recordMethod()).isEqualTo(AnnoyanceRecordMethod.IMAGE);
        assertThat(response.content()).isNull();
    }

    @Test
    void shouldRejectPersistedStateWithTextAndPrimaryMedia() {
        Entry entry = entry("content");
        EntryMedia image = new EntryMedia(
                10L,
                EntryMediaType.IMAGE,
                "private/image-key",
                "image/png",
                2048,
                null,
                0
        );

        assertThatThrownBy(() -> mapper.toResponse(entry, category(), mood(), List.of(image)))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("Annoyance has an invalid primary record state");
    }

    private Entry entry(String content) {
        Entry entry = Entry.annoyance(
                1L,
                2L,
                3L,
                content,
                false,
                LocalDateTime.of(2026, 7, 11, 12, 0)
        );
        ReflectionTestUtils.setField(entry, "id", 10L);
        return entry;
    }

    private AnnoyanceType category() {
        return new AnnoyanceType("ACADEMIC", "課業", 1);
    }

    private Mood mood() {
        return new Mood("BAD", "不好", 4, null, 4);
    }
}
