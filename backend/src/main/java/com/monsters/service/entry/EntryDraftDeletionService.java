package com.monsters.service.entry;

import com.monsters.entity.entry.EntryDraft;
import com.monsters.entity.entry.EntryDraftMedia;
import com.monsters.entity.entry.EntryType;
import com.monsters.repository.entry.EntryDraftMediaRepository;
import com.monsters.repository.entry.EntryDraftRepository;
import com.monsters.storage.entry.EntryMediaStorageService;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EntryDraftDeletionService {

    private final EntryDraftRepository entryDraftRepository;
    private final EntryDraftMediaRepository entryDraftMediaRepository;
    private final EntryMediaStorageService entryMediaStorageService;

    public EntryDraftDeletionService(
            EntryDraftRepository entryDraftRepository,
            EntryDraftMediaRepository entryDraftMediaRepository,
            EntryMediaStorageService entryMediaStorageService
    ) {
        this.entryDraftRepository = entryDraftRepository;
        this.entryDraftMediaRepository = entryDraftMediaRepository;
        this.entryMediaStorageService = entryMediaStorageService;
    }

    @Transactional
    public void discard(Long userId, EntryType entryType) {
        entryDraftRepository.findByUserIdAndEntryTypeForUpdate(userId, entryType)
                .ifPresent(this::deleteDraftAndMedia);
    }

    @Transactional
    public void discardExpired(Long draftId, LocalDateTime cutoff) {
        entryDraftRepository.findExpiredByIdForUpdate(draftId, cutoff)
                .ifPresent(this::deleteDraftAndMedia);
    }

    private void deleteDraftAndMedia(EntryDraft draft) {
        List<EntryDraftMedia> media = entryDraftMediaRepository
                .findAllByEntryDraftIdOrderByMediaRoleAsc(draft.getId());
        for (EntryDraftMedia item : media) {
            entryMediaStorageService.delete(item.getObjectKey());
        }
        entryDraftRepository.delete(draft);
        entryDraftRepository.flush();
    }
}
