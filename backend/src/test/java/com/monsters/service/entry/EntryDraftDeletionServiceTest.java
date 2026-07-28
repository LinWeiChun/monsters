package com.monsters.service.entry;

import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.entity.entry.EntryDraft;
import com.monsters.entity.entry.EntryDraftMedia;
import com.monsters.entity.entry.EntryDraftMediaRole;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.entity.entry.EntryType;
import com.monsters.repository.entry.EntryDraftMediaRepository;
import com.monsters.repository.entry.EntryDraftRepository;
import com.monsters.storage.entry.EntryMediaStorageService;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class EntryDraftDeletionServiceTest {

    @Mock private EntryDraftRepository entryDraftRepository;
    @Mock private EntryDraftMediaRepository entryDraftMediaRepository;
    @Mock private EntryMediaStorageService entryMediaStorageService;

    @Test
    void discardShouldDeletePrivateObjectsBeforeMetadata() {
        EntryDraft draft = draft();
        EntryDraftMedia media = new EntryDraftMedia(
                draft.getId(),
                EntryDraftMediaRole.CONTENT,
                EntryMediaType.IMAGE,
                "entries/media/1/image/key.png",
                "photo.png",
                "image/png",
                3,
                null
        );
        when(entryDraftRepository.findByUserIdAndEntryTypeForUpdate(
                1L,
                EntryType.DIARY
        )).thenReturn(Optional.of(draft));
        when(entryDraftMediaRepository.findAllByEntryDraftIdOrderByMediaRoleAsc(
                draft.getId()
        )).thenReturn(List.of(media));

        service().discard(1L, EntryType.DIARY);

        verify(entryMediaStorageService).delete(media.getObjectKey());
        verify(entryDraftRepository).delete(draft);
        verify(entryDraftRepository).flush();
    }

    @Test
    void discardExpiredShouldKeepRenewedDraft() {
        LocalDateTime cutoff = LocalDateTime.now();
        when(entryDraftRepository.findExpiredByIdForUpdate(501L, cutoff))
                .thenReturn(Optional.empty());

        service().discardExpired(501L, cutoff);

        verify(entryMediaStorageService, never()).delete(
                org.mockito.ArgumentMatchers.anyString()
        );
        verify(entryDraftRepository, never()).delete(
                org.mockito.ArgumentMatchers.any(EntryDraft.class)
        );
    }

    private EntryDraftDeletionService service() {
        return new EntryDraftDeletionService(
                entryDraftRepository,
                entryDraftMediaRepository,
                entryMediaStorageService
        );
    }

    private EntryDraft draft() {
        EntryDraft draft = new EntryDraft(1L, EntryType.DIARY);
        ReflectionTestUtils.setField(draft, "id", 501L);
        return draft;
    }
}
