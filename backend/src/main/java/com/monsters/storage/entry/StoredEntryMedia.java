package com.monsters.storage.entry;

import java.math.BigDecimal;

public record StoredEntryMedia(
        String objectKey,
        String contentType,
        long sizeBytes,
        BigDecimal durationSeconds
) {
}
