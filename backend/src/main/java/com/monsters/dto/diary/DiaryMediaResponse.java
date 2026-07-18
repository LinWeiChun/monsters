package com.monsters.dto.diary;

import java.math.BigDecimal;

public record DiaryMediaResponse(
        Long id,
        String type,
        String contentType,
        long sizeBytes,
        BigDecimal durationSeconds,
        String downloadUrl
) {
}
