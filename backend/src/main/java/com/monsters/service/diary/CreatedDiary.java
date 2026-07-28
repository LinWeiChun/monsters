package com.monsters.service.diary;

import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import java.util.List;

public record CreatedDiary(Entry entry, List<EntryMedia> media) {

    public CreatedDiary {
        media = List.copyOf(media);
    }
}
