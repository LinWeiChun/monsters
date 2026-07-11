package com.monsters.dto.annoyance;

import java.time.OffsetDateTime;
import java.util.List;

public record AnnoyanceResponse(
        Long id,
        AnnoyanceCategoryResponse category,
        AnnoyanceRecordMethod recordMethod,
        String content,
        int score,
        boolean isShared,
        boolean isSolved,
        OffsetDateTime occurredAt,
        List<AnnoyanceMediaResponse> media,
        Void reward
) {
    public AnnoyanceResponse {
        media = List.copyOf(media);
    }
}
