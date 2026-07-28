package com.monsters.dto.entry;

import com.monsters.entity.entry.EntryDraftRecordMethod;
import com.monsters.entity.entry.EntryDraftStep;
import com.monsters.entity.entry.EntryType;
import java.time.OffsetDateTime;

public record EntryDraftResponse(
        Long id,
        EntryType entryType,
        EntryDraftStep step,
        EntryDraftCategoryResponse category,
        EntryDraftRecordMethod recordMethod,
        String content,
        Boolean wantsDrawing,
        Integer score,
        Boolean isShared,
        OffsetDateTime expiresAt,
        EntryDraftMediaResponse contentMedia,
        EntryDraftMediaResponse drawingMedia
) {
}
