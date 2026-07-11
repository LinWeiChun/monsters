package com.monsters.entity.entry;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "entry_media")
public class EntryMedia extends BaseEntity {

    @Column(name = "entry_id", nullable = false)
    private Long entryId;

    @Convert(converter = EntryMediaTypeConverter.class)
    @Column(name = "media_type", nullable = false, length = 30)
    private EntryMediaType mediaType;

    @Column(name = "object_key", nullable = false, length = 500, unique = true)
    private String objectKey;

    @Column(name = "content_type", nullable = false, length = 100)
    private String contentType;

    @Column(name = "file_size_bytes", nullable = false)
    private long fileSizeBytes;

    @Column(name = "duration_seconds", precision = 10, scale = 3)
    private BigDecimal durationSeconds;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    @Column(name = "is_deleted", nullable = false)
    private boolean deleted;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    protected EntryMedia() {
    }

    public EntryMedia(
            Long entryId,
            EntryMediaType mediaType,
            String objectKey,
            String contentType,
            long fileSizeBytes,
            BigDecimal durationSeconds,
            int displayOrder
    ) {
        this.entryId = entryId;
        this.mediaType = mediaType;
        this.objectKey = objectKey;
        this.contentType = contentType;
        this.fileSizeBytes = fileSizeBytes;
        this.durationSeconds = durationSeconds;
        this.displayOrder = displayOrder;
        this.deleted = false;
    }

    public void markDeleted() {
        deleted = true;
        deletedAt = LocalDateTime.now();
    }

    public Long getEntryId() {
        return entryId;
    }

    public EntryMediaType getMediaType() {
        return mediaType;
    }

    public String getObjectKey() {
        return objectKey;
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

    public int getDisplayOrder() {
        return displayOrder;
    }

    public boolean isDeleted() {
        return deleted;
    }

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }
}
