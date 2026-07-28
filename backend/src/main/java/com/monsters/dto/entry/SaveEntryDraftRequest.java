package com.monsters.dto.entry;

import com.monsters.entity.entry.EntryDraftRecordMethod;
import com.monsters.entity.entry.EntryDraftStep;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record SaveEntryDraftRequest(
        @NotNull(message = "Draft step is required")
        EntryDraftStep step,
        @Size(max = 50, message = "Category code must not exceed 50 characters")
        String categoryCode,
        EntryDraftRecordMethod recordMethod,
        @Size(max = 2000, message = "Content must not exceed 2000 characters")
        String content,
        Boolean wantsDrawing,
        Integer score,
        Boolean isShared,
        Long existingContentMediaId,
        Long existingDrawingMediaId
) {
}
