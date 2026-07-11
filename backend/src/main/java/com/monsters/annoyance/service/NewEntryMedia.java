package com.monsters.annoyance.service;

import com.monsters.entry.entity.EntryMediaType;
import com.monsters.entry.storage.StoredEntryMedia;

public record NewEntryMedia(
        EntryMediaType mediaType,
        StoredEntryMedia storedMedia,
        int displayOrder
) {
}
