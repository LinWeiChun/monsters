package com.monsters.service.entry;

import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import java.util.List;

public record SubmittedEntry(
        Entry entry,
        List<EntryMedia> media
) {
}
