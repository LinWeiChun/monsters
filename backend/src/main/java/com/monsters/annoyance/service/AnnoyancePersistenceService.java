package com.monsters.annoyance.service;

import com.monsters.entry.entity.Entry;
import com.monsters.entry.entity.EntryMedia;
import com.monsters.entry.repository.EntryMediaRepository;
import com.monsters.entry.repository.EntryRepository;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AnnoyancePersistenceService {

    private final EntryRepository entryRepository;
    private final EntryMediaRepository entryMediaRepository;

    public AnnoyancePersistenceService(
            EntryRepository entryRepository,
            EntryMediaRepository entryMediaRepository
    ) {
        this.entryRepository = entryRepository;
        this.entryMediaRepository = entryMediaRepository;
    }

    @Transactional
    public CreatedAnnoyance create(
            Long userId,
            Long annoyanceTypeId,
            Long moodId,
            String content,
            boolean shared,
            LocalDateTime occurredAt,
            List<NewEntryMedia> newMedia
    ) {
        Entry entry = entryRepository.saveAndFlush(Entry.annoyance(
                userId,
                annoyanceTypeId,
                moodId,
                content,
                shared,
                occurredAt
        ));
        List<EntryMedia> media = newMedia.stream()
                .map(item -> new EntryMedia(
                        entry.getId(),
                        item.mediaType(),
                        item.storedMedia().objectKey(),
                        item.storedMedia().contentType(),
                        item.storedMedia().sizeBytes(),
                        item.storedMedia().durationSeconds(),
                        item.displayOrder()
                ))
                .toList();
        List<EntryMedia> savedMedia = entryMediaRepository.saveAllAndFlush(media);
        return new CreatedAnnoyance(entry, savedMedia);
    }
}
