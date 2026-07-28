package com.monsters.dto.entry;

import java.math.BigDecimal;

public record EntryDraftMediaResponse(
        Long id,
        String role,
        String type,
        String fileName,
        String contentType,
        long sizeBytes,
        BigDecimal durationSeconds,
        String downloadUrl
) {
}
