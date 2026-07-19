package com.monsters.dto.diary;

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
        Void reward
) {
    public DiaryResponse {
        media = List.copyOf(media);
    }
}
