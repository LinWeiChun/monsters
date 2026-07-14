package com.monsters.service.annoyance;

import com.monsters.dto.annoyance.AnnoyanceRecordMethod;
import com.monsters.dto.annoyance.AnnoyanceResponse;
import com.monsters.dto.annoyance.CreateAnnoyanceRequest;
import com.monsters.dto.annoyance.UpdateAnnoyanceRequest;
import com.monsters.dto.common.PageResponse;
import com.monsters.entity.annoyance.AnnoyanceType;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.entity.entry.EntryType;
import com.monsters.entity.entry.Mood;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.common.ValidationException;
import com.monsters.mapper.annoyance.AnnoyanceMapper;
import com.monsters.repository.annoyance.AnnoyanceTypeRepository;
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
public class AnnoyanceService {

    private static final Logger log = LoggerFactory.getLogger(AnnoyanceService.class);
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
    private final AnnoyanceTypeRepository annoyanceTypeRepository;
    private final MoodRepository moodRepository;
    private final AnnoyanceMapper annoyanceMapper;
    private final UserRepository userRepository;
    private final EntryMediaStorageService entryMediaStorageService;
    private final AnnoyancePersistenceService persistenceService;

    public AnnoyanceService(
            EntryRepository entryRepository,
            EntryMediaRepository entryMediaRepository,
            AnnoyanceTypeRepository annoyanceTypeRepository,
            MoodRepository moodRepository,
            AnnoyanceMapper annoyanceMapper,
            UserRepository userRepository,
            EntryMediaStorageService entryMediaStorageService,
            AnnoyancePersistenceService persistenceService
    ) {
        this.entryRepository = entryRepository;
        this.entryMediaRepository = entryMediaRepository;
        this.annoyanceTypeRepository = annoyanceTypeRepository;
        this.moodRepository = moodRepository;
        this.annoyanceMapper = annoyanceMapper;
        this.userRepository = userRepository;
        this.entryMediaStorageService = entryMediaStorageService;
        this.persistenceService = persistenceService;
    }

    public AnnoyanceResponse create(
            Long userId,
            CreateAnnoyanceRequest request,
            MultipartFile contentFile,
            MultipartFile drawingFile
    ) {
        validatePrimaryRecord(request.recordMethod(), request.content(), contentFile);
        requireUser(userId);
        AnnoyanceType category = requireCategory(normalizeCategoryCode(request.categoryCode()));
        Mood mood = requireMood(request.score());
        LocalDateTime occurredAt = resolveOccurredAt(request);
        List<NewEntryMedia> newMedia = new ArrayList<>();

        CreatedAnnoyance created;
        try {
            uploadPrimaryMedia(userId, request.recordMethod(), contentFile, newMedia);
            uploadDrawing(userId, drawingFile, newMedia);
            created = persistenceService.create(
                    userId,
                    category.getId(),
                    mood.getId(),
                    normalizedContent(request),
                    request.sharedOrDefault(),
                    occurredAt,
                    newMedia
            );
        } catch (RuntimeException exception) {
            cleanupUploadedMedia(newMedia);
            throw exception;
        }

        return annoyanceMapper.toResponse(created.entry(), category, mood, created.media());
    }

    @Transactional(readOnly = true)
    public PageResponse<AnnoyanceResponse> findAll(
            Long userId,
            int page,
            int size,
            String sort,
            Boolean solved,
            Boolean shared
    ) {
        requireUser(userId);
        validatePage(page, size);
        AnnoyanceSort annoyanceSort = parseSort(sort);
        Page<Entry> entries = entryRepository.findAnnoyancePage(
                userId,
                EntryType.ANNOYANCE,
                solved,
                shared,
                annoyanceSort.field(),
                annoyanceSort.direction(),
                PageRequest.of(page, size)
        );
        List<AnnoyanceResponse> content = mapEntries(entries.getContent());
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

    public AnnoyanceResponse update(
            Long userId,
            Long entryId,
            UpdateAnnoyanceRequest request,
            MultipartFile contentFile,
            MultipartFile drawingFile
    ) {
        validateUpdateRecord(request, contentFile, drawingFile);
        requireUser(userId);
        Entry entry = requireOwnedEntry(userId, entryId);
        AnnoyanceType category = requireCategory(normalizeCategoryCode(request.categoryCode()));
        Mood mood = requireMood(request.score());
        List<EntryMedia> activeMedia = entryMediaRepository
                .findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(entryId);
        Set<Long> retainedMediaIds = retainedMediaIds(request, activeMedia);
        List<NewEntryMedia> newMedia = new ArrayList<>();

        UpdatedAnnoyance updated;
        try {
            if (hasFile(contentFile)) {
                uploadPrimaryMedia(userId, request.recordMethod(), contentFile, newMedia);
            }
            if (hasFile(drawingFile)) {
                uploadDrawing(userId, drawingFile, newMedia);
            }
            updated = persistenceService.update(
                    entry,
                    category.getId(),
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
        return annoyanceMapper.toResponse(
                updated.entry(),
                category,
                mood,
                updated.media()
        );
    }

    @Transactional
    public AnnoyanceResponse solve(Long userId, Long entryId, Boolean solved) {
        if (!Boolean.TRUE.equals(solved)) {
            throw new ValidationException("Solved state must be true");
        }
        requireUser(userId);
        Entry entry = requireOwnedEntry(userId, entryId);
        if (!entry.isSolved()) {
            entry.solve();
            entryRepository.saveAndFlush(entry);
        }
        return toResponse(entry);
    }

    @Transactional
    public AnnoyanceResponse updateSharing(Long userId, Long entryId, Boolean shared) {
        if (shared == null) {
            throw new ValidationException("Shared state is required");
        }
        requireUser(userId);
        Entry entry = requireOwnedEntry(userId, entryId);
        if (entry.isShared() != shared) {
            entry.updateShared(shared);
            entryRepository.saveAndFlush(entry);
        }
        return toResponse(entry);
    }

    @Transactional(readOnly = true)
    public AnnoyanceResponse findOne(Long userId, Long entryId) {
        requireUser(userId);
        return toResponse(requireOwnedEntry(userId, entryId));
    }

    @Transactional(readOnly = true)
    public Entry requireOwnedEntry(Long userId, Long entryId) {
        return entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                entryId,
                userId,
                EntryType.ANNOYANCE
        ).orElseThrow(() -> new ResourceNotFoundException("Annoyance not found"));
    }

    @Transactional(readOnly = true)
    public AnnoyanceType requireCategory(String categoryCode) {
        return annoyanceTypeRepository.findByCode(categoryCode)
                .orElseThrow(() -> new ResourceNotFoundException("Annoyance category not found"));
    }

    @Transactional(readOnly = true)
    public Mood requireMood(int score) {
        return moodRepository.findByScore(score)
                .orElseThrow(() -> new ResourceNotFoundException("Mood not found"));
    }

    @Transactional(readOnly = true)
    public AnnoyanceResponse toResponse(Entry entry) {
        AnnoyanceType category = annoyanceTypeRepository.findById(entry.getAnnoyanceTypeId())
                .orElseThrow(() -> new ResourceNotFoundException("Annoyance category not found"));
        Mood mood = moodRepository.findById(entry.getMoodId())
                .orElseThrow(() -> new ResourceNotFoundException("Mood not found"));
        List<EntryMedia> media = entryMediaRepository
                .findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(entry.getId());
        return annoyanceMapper.toResponse(entry, category, mood, media);
    }

    public void validatePrimaryRecord(
            AnnoyanceRecordMethod recordMethod,
            String content,
            MultipartFile contentFile
    ) {
        if (recordMethod == null) {
            throw new ValidationException("Record method is required");
        }

        boolean hasTextContent = content != null && !content.isBlank();
        boolean hasAnyContentValue = content != null;
        boolean hasFile = contentFile != null && !contentFile.isEmpty();
        if (recordMethod == AnnoyanceRecordMethod.TEXT) {
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

    private String normalizeCategoryCode(String categoryCode) {
        return categoryCode.trim().toUpperCase(Locale.ROOT);
    }

    private LocalDateTime resolveOccurredAt(CreateAnnoyanceRequest request) {
        if (request.occurredAt() == null) {
            return LocalDateTime.now(APPLICATION_ZONE);
        }
        return request.occurredAt()
                .atZoneSameInstant(APPLICATION_ZONE)
                .toLocalDateTime();
    }

    private LocalDateTime resolveOccurredAt(UpdateAnnoyanceRequest request) {
        if (request.occurredAt() == null) {
            return LocalDateTime.now(APPLICATION_ZONE);
        }
        return request.occurredAt()
                .atZoneSameInstant(APPLICATION_ZONE)
                .toLocalDateTime();
    }

    private String normalizedContent(CreateAnnoyanceRequest request) {
        return request.recordMethod() == AnnoyanceRecordMethod.TEXT
                ? request.content().trim()
                : null;
    }

    private String normalizedContent(UpdateAnnoyanceRequest request) {
        return request.recordMethod() == AnnoyanceRecordMethod.TEXT
                ? request.content().trim()
                : null;
    }

    private void uploadPrimaryMedia(
            Long userId,
            AnnoyanceRecordMethod recordMethod,
            MultipartFile contentFile,
            List<NewEntryMedia> newMedia
    ) {
        if (recordMethod == AnnoyanceRecordMethod.TEXT) {
            return;
        }
        EntryMediaType mediaType = switch (recordMethod) {
            case IMAGE -> EntryMediaType.IMAGE;
            case AUDIO -> EntryMediaType.AUDIO;
            case VIDEO -> EntryMediaType.VIDEO;
            case TEXT -> throw new IllegalStateException("TEXT does not use content media");
        };
        StoredEntryMedia stored = entryMediaStorageService.upload(userId, mediaType, contentFile);
        newMedia.add(new NewEntryMedia(mediaType, stored, 0));
    }

    private void uploadDrawing(
            Long userId,
            MultipartFile drawingFile,
            List<NewEntryMedia> newMedia
    ) {
        if (!hasFile(drawingFile)) {
            return;
        }
        StoredEntryMedia stored = entryMediaStorageService.upload(
                userId,
                EntryMediaType.DRAWING,
                drawingFile
        );
        newMedia.add(new NewEntryMedia(EntryMediaType.DRAWING, stored, 1));
    }

    private void cleanupUploadedMedia(List<NewEntryMedia> newMedia) {
        for (NewEntryMedia media : newMedia) {
            try {
                entryMediaStorageService.delete(media.storedMedia().objectKey());
            } catch (RuntimeException cleanupException) {
                log.warn("Failed to clean up newly uploaded entry media after persistence failure");
            }
        }
    }

    private void cleanupStoredObjects(List<String> objectKeys) {
        for (String objectKey : objectKeys) {
            try {
                entryMediaStorageService.delete(objectKey);
            } catch (RuntimeException cleanupException) {
                log.warn("Failed to clean up replaced entry media after annoyance update");
            }
        }
    }

    private void validateUpdateRecord(
            UpdateAnnoyanceRequest request,
            MultipartFile contentFile,
            MultipartFile drawingFile
    ) {
        AnnoyanceRecordMethod recordMethod = request.recordMethod();
        if (recordMethod == null) {
            throw new ValidationException("Record method is required");
        }
        boolean hasContentFile = hasFile(contentFile);
        boolean keepsContentMedia = request.existingContentMediaId() != null;
        if (recordMethod == AnnoyanceRecordMethod.TEXT) {
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
            UpdateAnnoyanceRequest request,
            List<EntryMedia> activeMedia
    ) {
        Set<Long> retainedIds = new HashSet<>();
        if (request.existingContentMediaId() != null) {
            EntryMediaType expectedType = primaryMediaType(request.recordMethod());
            requireRetainedMedia(
                    activeMedia,
                    request.existingContentMediaId(),
                    expectedType,
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

    private EntryMediaType primaryMediaType(AnnoyanceRecordMethod recordMethod) {
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

    private AnnoyanceSort parseSort(String sort) {
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
        return new AnnoyanceSort(field, direction);
    }

    private List<AnnoyanceResponse> mapEntries(List<Entry> entries) {
        if (entries.isEmpty()) {
            return List.of();
        }
        Map<Long, AnnoyanceType> categories = annoyanceTypeRepository
                .findAllById(distinctIds(entries.stream().map(Entry::getAnnoyanceTypeId).toList()))
                .stream()
                .collect(Collectors.toMap(AnnoyanceType::getId, Function.identity()));
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
                .map(entry -> annoyanceMapper.toResponse(
                        entry,
                        requiredCategory(categories, entry.getAnnoyanceTypeId()),
                        requiredMood(moods, entry.getMoodId()),
                        mediaByEntryId.getOrDefault(entry.getId(), List.of())
                ))
                .toList();
    }

    private List<Long> distinctIds(Collection<Long> ids) {
        return ids.stream().distinct().toList();
    }

    private AnnoyanceType requiredCategory(Map<Long, AnnoyanceType> categories, Long categoryId) {
        AnnoyanceType category = categories.get(categoryId);
        if (category == null) {
            throw new ResourceNotFoundException("Annoyance category not found");
        }
        return category;
    }

    private Mood requiredMood(Map<Long, Mood> moods, Long moodId) {
        Mood mood = moods.get(moodId);
        if (mood == null) {
            throw new ResourceNotFoundException("Mood not found");
        }
        return mood;
    }

    private record AnnoyanceSort(String field, String direction) {
    }
}
