package com.monsters.service.entry;

import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryDraft;
import com.monsters.entity.entry.EntryDraftMedia;
import com.monsters.entity.entry.EntryDraftMediaRole;
import com.monsters.entity.entry.EntryDraftRecordMethod;
import com.monsters.entity.entry.EntryDraftStep;
import com.monsters.entity.entry.EntryMedia;
import com.monsters.entity.entry.EntryType;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.common.ValidationException;
import com.monsters.repository.entry.EntryDraftMediaRepository;
import com.monsters.repository.entry.EntryDraftRepository;
import com.monsters.repository.entry.EntryMediaRepository;
import com.monsters.repository.entry.EntryRepository;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EntryDraftPersistenceService {

    private static final String DRAFT_NOT_FOUND = "Entry draft not found";
    private static final String MEDIA_NOT_FOUND = "Entry draft media not found";

    private final EntryDraftRepository entryDraftRepository;
    private final EntryDraftMediaRepository entryDraftMediaRepository;
    private final EntryRepository entryRepository;
    private final EntryMediaRepository entryMediaRepository;

    public EntryDraftPersistenceService(
            EntryDraftRepository entryDraftRepository,
            EntryDraftMediaRepository entryDraftMediaRepository,
            EntryRepository entryRepository,
            EntryMediaRepository entryMediaRepository
    ) {
        this.entryDraftRepository = entryDraftRepository;
        this.entryDraftMediaRepository = entryDraftMediaRepository;
        this.entryRepository = entryRepository;
        this.entryMediaRepository = entryMediaRepository;
    }

    @Transactional
    public SavedEntryDraft save(
            Long userId,
            EntryType entryType,
            EntryDraftStep step,
            Long annoyanceTypeId,
            EntryDraftRecordMethod recordMethod,
            String content,
            Boolean wantsDrawing,
            Integer score,
            Boolean shared,
            LocalDateTime expiresAt,
            Long existingContentMediaId,
            Long existingDrawingMediaId,
            List<NewEntryDraftMedia> newMedia
    ) {
        EntryDraft draft = entryDraftRepository
                .findByUserIdAndEntryTypeForUpdate(userId, entryType)
                .orElseGet(() -> new EntryDraft(userId, entryType));
        draft.update(
                step,
                annoyanceTypeId,
                recordMethod,
                content,
                wantsDrawing,
                score,
                shared,
                expiresAt
        );
        EntryDraft savedDraft = entryDraftRepository.saveAndFlush(draft);
        List<EntryDraftMedia> currentMedia = entryDraftMediaRepository
                .findAllByEntryDraftIdOrderByMediaRoleAsc(savedDraft.getId());
        Map<EntryDraftMediaRole, EntryDraftMedia> currentByRole =
                new EnumMap<>(EntryDraftMediaRole.class);
        currentMedia.forEach(item -> currentByRole.put(item.getMediaRole(), item));
        Map<EntryDraftMediaRole, NewEntryDraftMedia> newByRole =
                new EnumMap<>(EntryDraftMediaRole.class);
        newMedia.forEach(item -> newByRole.put(item.role(), item));

        List<EntryDraftMedia> kept = new ArrayList<>();
        List<EntryDraftMedia> removed = new ArrayList<>();
        resolveRole(
                EntryDraftMediaRole.CONTENT,
                existingContentMediaId,
                currentByRole,
                newByRole,
                kept,
                removed
        );
        resolveRole(
                EntryDraftMediaRole.DRAWING,
                existingDrawingMediaId,
                currentByRole,
                newByRole,
                kept,
                removed
        );

        if (!removed.isEmpty()) {
            entryDraftMediaRepository.deleteAll(removed);
            entryDraftMediaRepository.flush();
        }
        List<EntryDraftMedia> added = newMedia.stream()
                .map(item -> new EntryDraftMedia(
                        savedDraft.getId(),
                        item.role(),
                        item.mediaType(),
                        item.storedMedia().objectKey(),
                        item.originalFilename(),
                        item.storedMedia().contentType(),
                        item.storedMedia().sizeBytes(),
                        item.storedMedia().durationSeconds()
                ))
                .toList();
        List<EntryDraftMedia> savedNewMedia = added.isEmpty()
                ? List.of()
                : entryDraftMediaRepository.saveAllAndFlush(added);
        List<EntryDraftMedia> active = new ArrayList<>(kept);
        active.addAll(savedNewMedia);
        active.sort(Comparator.comparing(EntryDraftMedia::getMediaRole));
        return new SavedEntryDraft(
                savedDraft,
                List.copyOf(active),
                removed.stream().map(EntryDraftMedia::getObjectKey).toList()
        );
    }

    @Transactional
    public SubmittedEntry submit(
            Long userId,
            EntryType entryType,
            Long annoyanceTypeId,
            Long moodId,
            String content,
            boolean shared,
            LocalDateTime occurredAt
    ) {
        EntryDraft draft = entryDraftRepository
                .findByUserIdAndEntryTypeForUpdate(userId, entryType)
                .orElseThrow(() -> new ResourceNotFoundException(DRAFT_NOT_FOUND));
        List<EntryDraftMedia> draftMedia = entryDraftMediaRepository
                .findAllByEntryDraftIdOrderByMediaRoleAsc(draft.getId());
        Entry entry = entryType == EntryType.DIARY
                ? Entry.diary(userId, moodId, content, shared, occurredAt)
                : Entry.annoyance(
                        userId,
                        annoyanceTypeId,
                        moodId,
                        content,
                        shared,
                        occurredAt
                );
        Entry savedEntry = entryRepository.saveAndFlush(entry);
        List<EntryMedia> media = draftMedia.stream()
                .map(item -> new EntryMedia(
                        savedEntry.getId(),
                        item.getMediaType(),
                        item.getObjectKey(),
                        item.getContentType(),
                        item.getFileSizeBytes(),
                        item.getDurationSeconds(),
                        item.getMediaRole() == EntryDraftMediaRole.CONTENT ? 0 : 1
                ))
                .toList();
        List<EntryMedia> savedMedia = media.isEmpty()
                ? List.of()
                : entryMediaRepository.saveAllAndFlush(media);
        entryDraftRepository.delete(draft);
        entryDraftRepository.flush();
        return new SubmittedEntry(savedEntry, savedMedia);
    }

    private void resolveRole(
            EntryDraftMediaRole role,
            Long existingMediaId,
            Map<EntryDraftMediaRole, EntryDraftMedia> currentByRole,
            Map<EntryDraftMediaRole, NewEntryDraftMedia> newByRole,
            List<EntryDraftMedia> kept,
            List<EntryDraftMedia> removed
    ) {
        EntryDraftMedia current = currentByRole.get(role);
        NewEntryDraftMedia replacement = newByRole.get(role);
        if (replacement != null && existingMediaId != null) {
            throw new ValidationException(
                    "New draft media and existing media id cannot be used together"
            );
        }
        if (replacement != null) {
            if (current != null) {
                removed.add(current);
            }
            return;
        }
        if (existingMediaId == null) {
            if (current != null) {
                removed.add(current);
            }
            return;
        }
        if (current == null || !current.getId().equals(existingMediaId)) {
            throw new ResourceNotFoundException(MEDIA_NOT_FOUND);
        }
        kept.add(current);
    }
}
