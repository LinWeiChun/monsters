package com.monsters.service.entry;

import com.monsters.entity.entry.EntryDraft;
import com.monsters.entity.entry.EntryDraftMedia;
import java.util.List;

public record SavedEntryDraft(
        EntryDraft draft,
        List<EntryDraftMedia> media,
        List<String> removedObjectKeys
) {
}
