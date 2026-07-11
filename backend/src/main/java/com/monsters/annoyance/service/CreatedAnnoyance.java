package com.monsters.annoyance.service;

import com.monsters.entry.entity.Entry;
import com.monsters.entry.entity.EntryMedia;
import java.util.List;

public record CreatedAnnoyance(Entry entry, List<EntryMedia> media) {

    public CreatedAnnoyance {
        media = List.copyOf(media);
    }
}
