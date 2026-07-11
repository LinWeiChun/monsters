package com.monsters.entry.entity;

import static org.assertj.core.api.Assertions.assertThat;

import com.monsters.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;

class EntryMediaTest {

    @Test
    void shouldMapPrivateR2MetadataToEntryMediaTable() throws NoSuchFieldException {
        assertThat(EntryMedia.class).hasAnnotation(Entity.class);
        assertThat(EntryMedia.class.getAnnotation(Table.class).name()).isEqualTo("entry_media");
        assertThat(EntryMedia.class.getSuperclass()).isEqualTo(BaseEntity.class);

        assertColumn("entryId", "entry_id", false);
        assertColumn("objectKey", "object_key", false);
        assertColumn("contentType", "content_type", false);
        assertColumn("fileSizeBytes", "file_size_bytes", false);
        assertColumn("durationSeconds", "duration_seconds", true);
    }

    @Test
    void mediaTypeShouldUseLowercaseDatabaseConverter() throws NoSuchFieldException {
        Convert convert = EntryMedia.class.getDeclaredField("mediaType").getAnnotation(Convert.class);

        assertThat(convert.converter()).isEqualTo(EntryMediaTypeConverter.class);
    }

    @Test
    void shouldExposeStoredMetadataWithoutPublicUrl() {
        EntryMedia media = new EntryMedia(
                10L,
                EntryMediaType.AUDIO,
                "entries/media/1/audio/key.m4a",
                "audio/mp4",
                1024,
                new BigDecimal("12.500"),
                0
        );

        assertThat(media.getEntryId()).isEqualTo(10L);
        assertThat(media.getMediaType()).isEqualTo(EntryMediaType.AUDIO);
        assertThat(media.getObjectKey()).isEqualTo("entries/media/1/audio/key.m4a");
        assertThat(media.getContentType()).isEqualTo("audio/mp4");
        assertThat(media.getFileSizeBytes()).isEqualTo(1024);
        assertThat(media.getDurationSeconds()).isEqualByComparingTo("12.500");
        assertThat(media.isDeleted()).isFalse();
    }

    @Test
    void markDeletedShouldSetSoftDeleteState() {
        EntryMedia media = new EntryMedia(
                10L,
                EntryMediaType.IMAGE,
                "entries/media/1/image/key.png",
                "image/png",
                1024,
                null,
                0
        );

        media.markDeleted();

        assertThat(media.isDeleted()).isTrue();
        assertThat(media.getDeletedAt()).isNotNull();
    }

    private void assertColumn(
            String fieldName,
            String columnName,
            boolean nullable
    ) throws NoSuchFieldException {
        Column column = EntryMedia.class.getDeclaredField(fieldName).getAnnotation(Column.class);
        assertThat(column.name()).isEqualTo(columnName);
        assertThat(column.nullable()).isEqualTo(nullable);
    }
}
