package com.monsters.entity.entry;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.math.BigDecimal;

@Entity
@Table(name = "entry_draft_media")
public class EntryDraftMedia extends BaseEntity {

    @Column(name = "entry_draft_id", nullable = false)
    private Long entryDraftId;

    @Enumerated(EnumType.STRING)
    @Column(name = "media_role", nullable = false, length = 20)
    private EntryDraftMediaRole mediaRole;

    @Convert(converter = EntryMediaTypeConverter.class)
    @Column(name = "media_type", nullable = false, length = 30)
    private EntryMediaType mediaType;

    @Column(name = "object_key", nullable = false, length = 500, unique = true)
    private String objectKey;

    @Column(name = "original_filename", nullable = false, length = 255)
    private String originalFilename;

    @Column(name = "content_type", nullable = false, length = 100)
    private String contentType;

    @Column(name = "file_size_bytes", nullable = false)
    private long fileSizeBytes;

    @Column(name = "duration_seconds", precision = 10, scale = 3)
    private BigDecimal durationSeconds;

    protected EntryDraftMedia() {
    }

    public EntryDraftMedia(
            Long entryDraftId,
            EntryDraftMediaRole mediaRole,
            EntryMediaType mediaType,
            String objectKey,
            String originalFilename,
            String contentType,
            long fileSizeBytes,
            BigDecimal durationSeconds
    ) {
        this.entryDraftId = entryDraftId;
        this.mediaRole = mediaRole;
        this.mediaType = mediaType;
        this.objectKey = objectKey;
        this.originalFilename = originalFilename;
        this.contentType = contentType;
        this.fileSizeBytes = fileSizeBytes;
        this.durationSeconds = durationSeconds;
    }

    public Long getEntryDraftId() {
        return entryDraftId;
    }

    public EntryDraftMediaRole getMediaRole() {
        return mediaRole;
    }

    public EntryMediaType getMediaType() {
        return mediaType;
    }

    public String getObjectKey() {
        return objectKey;
    }

    public String getOriginalFilename() {
        return originalFilename;
    }

    public String getContentType() {
        return contentType;
    }

    public long getFileSizeBytes() {
        return fileSizeBytes;
    }

    public BigDecimal getDurationSeconds() {
        return durationSeconds;
    }
}
