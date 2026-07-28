package com.monsters.dto.annoyance;

import com.fasterxml.jackson.annotation.JsonInclude;
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
        @JsonInclude(JsonInclude.Include.ALWAYS)
        Object reward
) {
    public AnnoyanceResponse {
        media = List.copyOf(media);
        if (reward != null) {
            throw new IllegalArgumentException(
                    "Annoyance reward must remain null until Phase 6"
            );
        }
    }
}
