package com.monsters.service.entry;

import com.monsters.entity.entry.EntryDraftMediaRole;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.storage.entry.StoredEntryMedia;

public record NewEntryDraftMedia(
        EntryDraftMediaRole role,
        EntryMediaType mediaType,
        String originalFilename,
        StoredEntryMedia storedMedia
) {
}
