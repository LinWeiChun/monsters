package com.monsters.dto.diary;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.OffsetDateTime;
import java.util.List;

public record DiaryResponse(
        Long id,
        DiaryRecordMethod recordMethod,
        String content,
        int score,
        boolean isShared,
        OffsetDateTime occurredAt,
        List<DiaryMediaResponse> media,
        @JsonInclude(JsonInclude.Include.ALWAYS)
        Object reward
) {
    public DiaryResponse {
        media = List.copyOf(media);
        if (reward != null) {
            throw new IllegalArgumentException(
                    "Diary reward must remain null until Phase 6"
            );
        }
    }
}
