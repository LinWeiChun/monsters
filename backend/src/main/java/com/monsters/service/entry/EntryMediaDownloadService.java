package com.monsters.service.entry;

import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import com.monsters.entity.entry.EntryType;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.repository.entry.EntryMediaRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.storage.entry.DownloadedEntryMedia;
import com.monsters.storage.entry.EntryMediaStorageService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EntryMediaDownloadService {

    private static final String MEDIA_NOT_FOUND = "Entry media not found";

    private final EntryRepository entryRepository;
    private final EntryMediaRepository entryMediaRepository;
    private final UserRepository userRepository;
    private final EntryMediaStorageService entryMediaStorageService;

    public EntryMediaDownloadService(
            EntryRepository entryRepository,
            EntryMediaRepository entryMediaRepository,
            UserRepository userRepository,
            EntryMediaStorageService entryMediaStorageService
    ) {
        this.entryRepository = entryRepository;
        this.entryMediaRepository = entryMediaRepository;
        this.userRepository = userRepository;
        this.entryMediaStorageService = entryMediaStorageService;
    }

    @Transactional(readOnly = true)
    public EntryMediaDownloadResult download(
            Long userId,
            EntryType entryType,
            Long entryId,
            Long mediaId,
            String rangeHeader
    ) {
        requireUser(userId);
        Entry entry = entryRepository.findByIdAndEntryTypeAndDeletedFalse(entryId, entryType)
                .filter(candidate -> candidate.getUserId().equals(userId) || candidate.isShared())
                .orElseThrow(() -> new ResourceNotFoundException(MEDIA_NOT_FOUND));
        EntryMedia media = entryMediaRepository.findByIdAndEntryIdAndDeletedFalse(
                mediaId,
                entry.getId()
        ).orElseThrow(() -> new ResourceNotFoundException(MEDIA_NOT_FOUND));

        DownloadedEntryMedia downloaded = entryMediaStorageService.download(
                media.getObjectKey(),
                rangeHeader
        );
        return new EntryMediaDownloadResult(
                downloaded.content(),
                media.getContentType(),
                downloaded.contentLength(),
                downloaded.contentRange()
        );
    }

    private void requireUser(Long userId) {
        userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
}
