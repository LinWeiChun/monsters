package com.monsters.service.annoyance;

import com.monsters.entity.entry.EntryMediaType;
import com.monsters.storage.entry.StoredEntryMedia;

public record NewEntryMedia(
        EntryMediaType mediaType,
        StoredEntryMedia storedMedia,
        int displayOrder
) {
}
