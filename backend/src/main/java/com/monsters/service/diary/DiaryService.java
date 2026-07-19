package com.monsters.service.diary;

import com.monsters.dto.diary.CreateDiaryRequest;
import com.monsters.dto.diary.DiaryRecordMethod;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.entity.entry.EntryType;
import com.monsters.entity.entry.Mood;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.common.ValidationException;
import com.monsters.mapper.diary.DiaryMapper;
import com.monsters.repository.entry.EntryMediaRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.entry.MoodRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.storage.entry.EntryMediaStorageService;
import com.monsters.storage.entry.StoredEntryMedia;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class DiaryService {

    private static final Logger log = LoggerFactory.getLogger(DiaryService.class);
    private static final ZoneId APPLICATION_ZONE = ZoneId.of("Asia/Taipei");

    private final EntryRepository entryRepository;
    private final EntryMediaRepository entryMediaRepository;
    private final MoodRepository moodRepository;
    private final DiaryMapper diaryMapper;
    private final UserRepository userRepository;
    private final EntryMediaStorageService entryMediaStorageService;
    private final DiaryPersistenceService persistenceService;

    public DiaryService(
            EntryRepository entryRepository,
            EntryMediaRepository entryMediaRepository,
            MoodRepository moodRepository,
            DiaryMapper diaryMapper,
            UserRepository userRepository,
            EntryMediaStorageService entryMediaStorageService,
            DiaryPersistenceService persistenceService
    ) {
        this.entryRepository = entryRepository;
        this.entryMediaRepository = entryMediaRepository;
        this.moodRepository = moodRepository;
        this.diaryMapper = diaryMapper;
        this.userRepository = userRepository;
        this.entryMediaStorageService = entryMediaStorageService;
        this.persistenceService = persistenceService;
    }

    public DiaryResponse create(
            Long userId,
            CreateDiaryRequest request,
            MultipartFile contentFile,
            MultipartFile drawingFile
    ) {
        validatePrimaryRecord(request.recordMethod(), request.content(), contentFile);
        requireUser(userId);
        Mood mood = requireMood(request.score());
        List<NewDiaryMedia> newMedia = new ArrayList<>();

        CreatedDiary created;
        try {
            uploadPrimaryMedia(userId, request.recordMethod(), contentFile, newMedia);
            uploadDrawing(userId, drawingFile, newMedia);
            created = persistenceService.create(
                    userId,
                    mood.getId(),
                    normalizedContent(request),
                    request.sharedOrDefault(),
                    resolveOccurredAt(request),
                    newMedia
            );
        } catch (RuntimeException exception) {
            cleanupUploadedMedia(newMedia);
            throw exception;
        }

        return diaryMapper.toResponse(created.entry(), mood, created.media());
    }

    @Transactional(readOnly = true)
    public Entry requireOwnedEntry(Long userId, Long entryId) {
        return entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                entryId,
                userId,
                EntryType.DIARY
        ).orElseThrow(() -> new ResourceNotFoundException("Diary not found"));
    }

    @Transactional(readOnly = true)
    public Mood requireMood(int score) {
        return moodRepository.findByScore(score)
                .orElseThrow(() -> new ResourceNotFoundException("Mood not found"));
    }

    @Transactional(readOnly = true)
    public DiaryResponse toResponse(Entry entry) {
        Mood mood = moodRepository.findById(entry.getMoodId())
                .orElseThrow(() -> new ResourceNotFoundException("Mood not found"));
        List<EntryMedia> media = entryMediaRepository
                .findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(entry.getId());
        return diaryMapper.toResponse(entry, mood, media);
    }

    public void validatePrimaryRecord(
            DiaryRecordMethod recordMethod,
            String content,
            MultipartFile contentFile
    ) {
        if (recordMethod == null) {
            throw new ValidationException("Record method is required");
        }

        boolean hasTextContent = content != null && !content.isBlank();
        boolean hasAnyContentValue = content != null;
        boolean hasFile = contentFile != null && !contentFile.isEmpty();
        if (recordMethod == DiaryRecordMethod.TEXT) {
            if (!hasTextContent || hasFile) {
                throw new ValidationException("TEXT requires content and must not include contentFile");
            }
            return;
        }

        if (hasAnyContentValue || !hasFile) {
            throw new ValidationException(recordMethod + " requires contentFile and must not include content");
        }
    }

    private void requireUser(Long userId) {
        userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    private LocalDateTime resolveOccurredAt(CreateDiaryRequest request) {
        if (request.occurredAt() == null) {
            return LocalDateTime.now(APPLICATION_ZONE);
        }
        return request.occurredAt()
                .atZoneSameInstant(APPLICATION_ZONE)
                .toLocalDateTime();
    }

    private String normalizedContent(CreateDiaryRequest request) {
        return request.recordMethod() == DiaryRecordMethod.TEXT
                ? request.content().trim()
                : null;
    }

    private void uploadPrimaryMedia(
            Long userId,
            DiaryRecordMethod recordMethod,
            MultipartFile contentFile,
            List<NewDiaryMedia> newMedia
    ) {
        if (recordMethod == DiaryRecordMethod.TEXT) {
            return;
        }
        EntryMediaType mediaType = switch (recordMethod) {
            case IMAGE -> EntryMediaType.IMAGE;
            case AUDIO -> EntryMediaType.AUDIO;
            case VIDEO -> EntryMediaType.VIDEO;
            case TEXT -> throw new IllegalStateException("TEXT does not use content media");
        };
        StoredEntryMedia stored = entryMediaStorageService.upload(userId, mediaType, contentFile);
        newMedia.add(new NewDiaryMedia(mediaType, stored, 0));
    }

    private void uploadDrawing(
            Long userId,
            MultipartFile drawingFile,
            List<NewDiaryMedia> newMedia
    ) {
        if (drawingFile == null || drawingFile.isEmpty()) {
            return;
        }
        StoredEntryMedia stored = entryMediaStorageService.upload(
                userId,
                EntryMediaType.DRAWING,
                drawingFile
        );
        newMedia.add(new NewDiaryMedia(EntryMediaType.DRAWING, stored, 1));
    }

    private void cleanupUploadedMedia(List<NewDiaryMedia> newMedia) {
        for (NewDiaryMedia media : newMedia) {
            try {
                entryMediaStorageService.delete(media.storedMedia().objectKey());
            } catch (RuntimeException cleanupException) {
                log.warn("Failed to clean up newly uploaded diary media after persistence failure");
            }
        }
    }
}
