package com.monsters.dto.annoyance;

import java.math.BigDecimal;

public record AnnoyanceMediaResponse(
        Long id,
        String type,
        String contentType,
        long sizeBytes,
        BigDecimal durationSeconds,
        String downloadUrl
) {
}
