package com.monsters.entry.storage;

import java.math.BigDecimal;

public record StoredEntryMedia(
        String objectKey,
        String contentType,
        long sizeBytes,
        BigDecimal durationSeconds
) {
}
