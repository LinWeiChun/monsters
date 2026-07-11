package com.monsters.service.annoyance;

import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import java.util.List;

public record CreatedAnnoyance(Entry entry, List<EntryMedia> media) {

    public CreatedAnnoyance {
        media = List.copyOf(media);
    }
}
