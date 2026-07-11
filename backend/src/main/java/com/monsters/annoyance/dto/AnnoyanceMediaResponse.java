package com.monsters.annoyance.dto;

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
