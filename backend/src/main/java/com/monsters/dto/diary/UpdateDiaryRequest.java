package com.monsters.dto.diary;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;

public record UpdateDiaryRequest(
        @NotNull(message = "Record method is required")
        DiaryRecordMethod recordMethod,
        String content,
        @NotNull(message = "Score is required")
        @Min(value = 1, message = "Score must be between 1 and 5")
        @Max(value = 5, message = "Score must be between 1 and 5")
        Integer score,
        Boolean isShared,
        OffsetDateTime occurredAt,
        Long existingContentMediaId,
        Long existingDrawingMediaId
) {

    public boolean sharedOrDefault() {
        return Boolean.TRUE.equals(isShared);
    }
}
