package com.monsters.service.annoyance;

import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import java.util.List;

public record UpdatedAnnoyance(
        Entry entry,
        List<EntryMedia> media,
        List<String> removedObjectKeys
) {

    public UpdatedAnnoyance {
        media = List.copyOf(media);
        removedObjectKeys = List.copyOf(removedObjectKeys);
    }
}
