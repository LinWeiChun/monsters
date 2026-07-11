package com.monsters.service.annoyance;

import com.monsters.dto.annoyance.AnnoyanceRecordMethod;
import com.monsters.dto.annoyance.AnnoyanceResponse;
import com.monsters.dto.annoyance.CreateAnnoyanceRequest;
import com.monsters.entity.annoyance.AnnoyanceType;
import com.monsters.mapper.annoyance.AnnoyanceMapper;
import com.monsters.repository.annoyance.AnnoyanceTypeRepository;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.common.ValidationException;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.entity.entry.EntryType;
import com.monsters.entity.entry.Mood;
import com.monsters.repository.entry.EntryMediaRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.entry.MoodRepository;
import com.monsters.storage.entry.EntryMediaStorageService;
import com.monsters.storage.entry.StoredEntryMedia;
import com.monsters.repository.user.UserRepository;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class AnnoyanceService {

    private static final Logger log = LoggerFactory.getLogger(AnnoyanceService.class);
    private static final ZoneId APPLICATION_ZONE = ZoneId.of("Asia/Taipei");

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

    private String normalizedContent(CreateAnnoyanceRequest request) {
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
        if (drawingFile == null) {
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
                log.warn("Failed to clean up entry media after annoyance creation failure");
            }
        }
    }
}
