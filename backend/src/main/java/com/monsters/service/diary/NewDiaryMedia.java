package com.monsters.service.diary;

import com.monsters.entity.entry.EntryMediaType;
import com.monsters.storage.entry.StoredEntryMedia;

public record NewDiaryMedia(
        EntryMediaType mediaType,
        StoredEntryMedia storedMedia,
        int displayOrder
) {
}
