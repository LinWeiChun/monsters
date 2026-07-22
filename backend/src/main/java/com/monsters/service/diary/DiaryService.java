package com.monsters.service.diary;

import com.monsters.dto.common.PageResponse;
import com.monsters.dto.diary.CreateDiaryRequest;
import com.monsters.dto.diary.DiaryRecordMethod;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.dto.diary.UpdateDiaryRequest;
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
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class DiaryService {

    private static final Logger log = LoggerFactory.getLogger(DiaryService.class);
    private static final ZoneId APPLICATION_ZONE = ZoneId.of("Asia/Taipei");
    private static final String DEFAULT_SORT = "occurredAt,desc";
    private static final Set<String> ALLOWED_SORT_FIELDS = Set.of(
            "occurredAt",
            "createdAt",
            "score"
    );
    private static final Set<String> ALLOWED_SORT_DIRECTIONS = Set.of("asc", "desc");

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

    public DiaryResponse update(
            Long userId,
            Long entryId,
            UpdateDiaryRequest request,
            MultipartFile contentFile,
            MultipartFile drawingFile
    ) {
        validateUpdateRecord(request, contentFile, drawingFile);
        requireUser(userId);
        Entry entry = requireOwnedEntry(userId, entryId);
        Mood mood = requireMood(request.score());
        List<EntryMedia> activeMedia = entryMediaRepository
                .findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(entryId);
        Set<Long> retainedMediaIds = retainedMediaIds(request, activeMedia);
        List<NewDiaryMedia> newMedia = new ArrayList<>();

        UpdatedDiary updated;
        try {
            if (hasFile(contentFile)) {
                uploadPrimaryMedia(userId, request.recordMethod(), contentFile, newMedia);
            }
            if (hasFile(drawingFile)) {
                uploadDrawing(userId, drawingFile, newMedia);
            }
            updated = persistenceService.update(
                    entry,
                    mood.getId(),
                    normalizedContent(request),
                    request.sharedOrDefault(),
                    resolveOccurredAt(request),
                    activeMedia,
                    retainedMediaIds,
                    newMedia
            );
        } catch (RuntimeException exception) {
            cleanupUploadedMedia(newMedia);
            throw exception;
        }

        cleanupStoredObjects(updated.removedObjectKeys());
        return diaryMapper.toResponse(updated.entry(), mood, updated.media());
    }

    @Transactional(readOnly = true)
    public PageResponse<DiaryResponse> findAll(
            Long userId,
            int page,
            int size,
            String sort,
            Boolean shared
    ) {
        requireUser(userId);
        validatePage(page, size);
        DiarySort diarySort = parseSort(sort);
        Page<Entry> entries = entryRepository.findEntryPage(
                userId,
                EntryType.DIARY,
                null,
                shared,
                diarySort.field(),
                diarySort.direction(),
                PageRequest.of(page, size)
        );
        List<DiaryResponse> content = mapEntries(entries.getContent());
        return new PageResponse<>(
                content,
                entries.getNumber(),
                entries.getSize(),
                entries.getTotalElements(),
                entries.getTotalPages(),
                entries.isFirst(),
                entries.isLast()
        );
    }

    @Transactional(readOnly = true)
    public DiaryResponse findOne(Long userId, Long entryId) {
        requireUser(userId);
        return toResponse(requireOwnedEntry(userId, entryId));
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

    private LocalDateTime resolveOccurredAt(UpdateDiaryRequest request) {
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

    private String normalizedContent(UpdateDiaryRequest request) {
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

    private void cleanupStoredObjects(List<String> objectKeys) {
        for (String objectKey : objectKeys) {
            try {
                entryMediaStorageService.delete(objectKey);
            } catch (RuntimeException cleanupException) {
                log.warn("Failed to clean up replaced entry media after diary update");
            }
        }
    }

    private void validateUpdateRecord(
            UpdateDiaryRequest request,
            MultipartFile contentFile,
            MultipartFile drawingFile
    ) {
        DiaryRecordMethod recordMethod = request.recordMethod();
        if (recordMethod == null) {
            throw new ValidationException("Record method is required");
        }
        boolean hasContentFile = hasFile(contentFile);
        boolean keepsContentMedia = request.existingContentMediaId() != null;
        if (recordMethod == DiaryRecordMethod.TEXT) {
            if (request.content() == null
                    || request.content().isBlank()
                    || hasContentFile
                    || keepsContentMedia) {
                throw new ValidationException(
                        "TEXT requires content and must not include content media"
                );
            }
        } else if (request.content() != null || hasContentFile == keepsContentMedia) {
            throw new ValidationException(
                    recordMethod + " requires exactly one new or existing content media"
            );
        }

        if (hasFile(drawingFile) && request.existingDrawingMediaId() != null) {
            throw new ValidationException(
                    "Drawing requires either a new file or an existing media id, not both"
            );
        }
    }

    private Set<Long> retainedMediaIds(
            UpdateDiaryRequest request,
            List<EntryMedia> activeMedia
    ) {
        Set<Long> retainedIds = new HashSet<>();
        if (request.existingContentMediaId() != null) {
            requireRetainedMedia(
                    activeMedia,
                    request.existingContentMediaId(),
                    primaryMediaType(request.recordMethod()),
                    "content"
            );
            retainedIds.add(request.existingContentMediaId());
        }
        if (request.existingDrawingMediaId() != null) {
            requireRetainedMedia(
                    activeMedia,
                    request.existingDrawingMediaId(),
                    EntryMediaType.DRAWING,
                    "drawing"
            );
            retainedIds.add(request.existingDrawingMediaId());
        }
        return Set.copyOf(retainedIds);
    }

    private void requireRetainedMedia(
            List<EntryMedia> activeMedia,
            Long mediaId,
            EntryMediaType expectedType,
            String purpose
    ) {
        boolean matches = activeMedia.stream().anyMatch(media -> mediaId.equals(media.getId())
                && media.getMediaType() == expectedType);
        if (!matches) {
            throw new ValidationException("Existing " + purpose + " media is invalid");
        }
    }

    private EntryMediaType primaryMediaType(DiaryRecordMethod recordMethod) {
        return switch (recordMethod) {
            case IMAGE -> EntryMediaType.IMAGE;
            case AUDIO -> EntryMediaType.AUDIO;
            case VIDEO -> EntryMediaType.VIDEO;
            case TEXT -> throw new ValidationException("TEXT does not use content media");
        };
    }

    private boolean hasFile(MultipartFile file) {
        return file != null && !file.isEmpty();
    }

    private void validatePage(int page, int size) {
        if (page < 0) {
            throw new ValidationException("Page must be zero or greater");
        }
        if (size < 1 || size > 100) {
            throw new ValidationException("Size must be between 1 and 100");
        }
    }

    private DiarySort parseSort(String sort) {
        String normalizedSort = sort == null || sort.isBlank() ? DEFAULT_SORT : sort.trim();
        String[] parts = normalizedSort.split(",", -1);
        if (parts.length != 2) {
            throw new ValidationException("Sort must contain one field and one direction");
        }
        String field = parts[0].trim();
        String direction = parts[1].trim().toLowerCase(Locale.ROOT);
        if (!ALLOWED_SORT_FIELDS.contains(field)
                || !ALLOWED_SORT_DIRECTIONS.contains(direction)) {
            throw new ValidationException("Sort field or direction is invalid");
        }
        return new DiarySort(field, direction);
    }

    private List<DiaryResponse> mapEntries(List<Entry> entries) {
        if (entries.isEmpty()) {
            return List.of();
        }
        Map<Long, Mood> moods = moodRepository
                .findAllById(distinctIds(entries.stream().map(Entry::getMoodId).toList()))
                .stream()
                .collect(Collectors.toMap(Mood::getId, Function.identity()));
        Map<Long, List<EntryMedia>> mediaByEntryId = entryMediaRepository
                .findAllByEntryIdInAndDeletedFalseOrderByEntryIdAscDisplayOrderAsc(
                        entries.stream().map(Entry::getId).toList()
                )
                .stream()
                .collect(Collectors.groupingBy(EntryMedia::getEntryId));

        return entries.stream()
                .map(entry -> diaryMapper.toResponse(
                        entry,
                        requiredMood(moods, entry.getMoodId()),
                        mediaByEntryId.getOrDefault(entry.getId(), List.of())
                ))
                .toList();
    }

    private List<Long> distinctIds(Collection<Long> ids) {
        return ids.stream().distinct().toList();
    }

    private Mood requiredMood(Map<Long, Mood> moods, Long moodId) {
        Mood mood = moods.get(moodId);
        if (mood == null) {
            throw new ResourceNotFoundException("Mood not found");
        }
        return mood;
    }

    private record DiarySort(String field, String direction) {
    }
}
