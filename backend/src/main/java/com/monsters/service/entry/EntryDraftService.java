package com.monsters.service.entry;

import com.monsters.dto.annoyance.AnnoyanceResponse;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.dto.entry.EntryDraftCategoryResponse;
import com.monsters.dto.entry.EntryDraftEnvelope;
import com.monsters.dto.entry.EntryDraftMediaResponse;
import com.monsters.dto.entry.EntryDraftResponse;
import com.monsters.dto.entry.SaveEntryDraftRequest;
import com.monsters.entity.annoyance.AnnoyanceType;
import com.monsters.entity.entry.EntryDraft;
import com.monsters.entity.entry.EntryDraftMedia;
import com.monsters.entity.entry.EntryDraftMediaRole;
import com.monsters.entity.entry.EntryDraftRecordMethod;
import com.monsters.entity.entry.EntryDraftStep;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.entity.entry.EntryType;
import com.monsters.entity.entry.Mood;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.common.ValidationException;
import com.monsters.mapper.annoyance.AnnoyanceMapper;
import com.monsters.mapper.diary.DiaryMapper;
import com.monsters.repository.annoyance.AnnoyanceTypeRepository;
import com.monsters.repository.entry.EntryDraftMediaRepository;
import com.monsters.repository.entry.EntryDraftRepository;
import com.monsters.repository.entry.MoodRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.storage.entry.DownloadedEntryMedia;
import com.monsters.storage.entry.EntryMediaStorageService;
import com.monsters.storage.entry.StoredEntryMedia;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class EntryDraftService {

    private static final Logger log = LoggerFactory.getLogger(EntryDraftService.class);
    private static final ZoneId APPLICATION_ZONE = ZoneId.of("Asia/Taipei");
    private static final String DRAFT_NOT_FOUND = "Entry draft not found";
    private static final String MEDIA_NOT_FOUND = "Entry draft media not found";

    private final EntryDraftRepository entryDraftRepository;
    private final EntryDraftMediaRepository entryDraftMediaRepository;
    private final AnnoyanceTypeRepository annoyanceTypeRepository;
    private final MoodRepository moodRepository;
    private final UserRepository userRepository;
    private final EntryMediaStorageService entryMediaStorageService;
    private final EntryDraftPersistenceService persistenceService;
    private final EntryDraftDeletionService deletionService;
    private final DiaryMapper diaryMapper;
    private final AnnoyanceMapper annoyanceMapper;
    private final long retentionDays;

    public EntryDraftService(
            EntryDraftRepository entryDraftRepository,
            EntryDraftMediaRepository entryDraftMediaRepository,
            AnnoyanceTypeRepository annoyanceTypeRepository,
            MoodRepository moodRepository,
            UserRepository userRepository,
            EntryMediaStorageService entryMediaStorageService,
            EntryDraftPersistenceService persistenceService,
            EntryDraftDeletionService deletionService,
            DiaryMapper diaryMapper,
            AnnoyanceMapper annoyanceMapper,
            @Value("${app.entry-draft.retention-days:30}") long retentionDays
    ) {
        this.entryDraftRepository = entryDraftRepository;
        this.entryDraftMediaRepository = entryDraftMediaRepository;
        this.annoyanceTypeRepository = annoyanceTypeRepository;
        this.moodRepository = moodRepository;
        this.userRepository = userRepository;
        this.entryMediaStorageService = entryMediaStorageService;
        this.persistenceService = persistenceService;
        this.deletionService = deletionService;
        this.diaryMapper = diaryMapper;
        this.annoyanceMapper = annoyanceMapper;
        if (retentionDays < 1) {
            throw new IllegalArgumentException("Entry draft retention days must be positive");
        }
        this.retentionDays = retentionDays;
    }

    @Transactional(readOnly = true)
    public EntryDraftEnvelope find(Long userId, EntryType entryType) {
        requireUser(userId);
        return entryDraftRepository.findByUserIdAndEntryTypeAndExpiresAtAfter(
                        userId,
                        entryType,
                        LocalDateTime.now(APPLICATION_ZONE)
                )
                .map(draft -> toEnvelope(
                        draft,
                        entryDraftMediaRepository
                                .findAllByEntryDraftIdOrderByMediaRoleAsc(draft.getId())
                ))
                .orElseGet(() -> new EntryDraftEnvelope(null));
    }

    public EntryDraftEnvelope save(
            Long userId,
            EntryType entryType,
            SaveEntryDraftRequest request,
            MultipartFile contentFile,
            MultipartFile drawingFile
    ) {
        requireUser(userId);
        AnnoyanceType category = resolveCategory(entryType, request.categoryCode());
        validatePartial(entryType, request, contentFile, drawingFile);
        List<NewEntryDraftMedia> newMedia = new ArrayList<>();
        SavedEntryDraft saved;
        try {
            if (hasFile(contentFile)) {
                EntryMediaType mediaType = request.recordMethod().mediaType();
                newMedia.add(upload(
                        userId,
                        EntryDraftMediaRole.CONTENT,
                        mediaType,
                        contentFile
                ));
            }
            if (hasFile(drawingFile)) {
                newMedia.add(upload(
                        userId,
                        EntryDraftMediaRole.DRAWING,
                        EntryMediaType.DRAWING,
                        drawingFile
                ));
            }
            saved = persistenceService.save(
                    userId,
                    entryType,
                    request.step(),
                    category == null ? null : category.getId(),
                    request.recordMethod(),
                    normalizedContent(request),
                    request.wantsDrawing(),
                    request.score(),
                    request.isShared(),
                    LocalDateTime.now(APPLICATION_ZONE).plusDays(retentionDays),
                    request.existingContentMediaId(),
                    request.existingDrawingMediaId(),
                    newMedia
            );
        } catch (RuntimeException exception) {
            cleanupUploadedMedia(newMedia);
            throw exception;
        }
        cleanupStoredObjects(saved.removedObjectKeys());
        return toEnvelope(saved.draft(), saved.media());
    }

    public void discard(Long userId, EntryType entryType) {
        requireUser(userId);
        deletionService.discard(userId, entryType);
    }

    @Transactional
    public DiaryResponse submitDiary(Long userId) {
        DraftSubmission submission = requireSubmission(userId, EntryType.DIARY);
        SubmittedEntry submitted = persistenceService.submit(
                userId,
                EntryType.DIARY,
                null,
                submission.mood().getId(),
                submission.content(),
                submission.shared(),
                LocalDateTime.now(APPLICATION_ZONE)
        );
        return diaryMapper.toResponse(
                submitted.entry(),
                submission.mood(),
                submitted.media()
        );
    }

    @Transactional
    public AnnoyanceResponse submitAnnoyance(Long userId) {
        DraftSubmission submission = requireSubmission(userId, EntryType.ANNOYANCE);
        SubmittedEntry submitted = persistenceService.submit(
                userId,
                EntryType.ANNOYANCE,
                submission.category().getId(),
                submission.mood().getId(),
                submission.content(),
                submission.shared(),
                LocalDateTime.now(APPLICATION_ZONE)
        );
        return annoyanceMapper.toResponse(
                submitted.entry(),
                submission.category(),
                submission.mood(),
                submitted.media()
        );
    }

    @Transactional(readOnly = true)
    public EntryMediaDownloadResult download(
            Long userId,
            EntryType entryType,
            Long mediaId,
            String rangeHeader
    ) {
        requireUser(userId);
        EntryDraft draft = entryDraftRepository
                .findByUserIdAndEntryTypeAndExpiresAtAfter(
                        userId,
                        entryType,
                        LocalDateTime.now(APPLICATION_ZONE)
                )
                .orElseThrow(() -> new ResourceNotFoundException(MEDIA_NOT_FOUND));
        EntryDraftMedia media = entryDraftMediaRepository
                .findByIdAndEntryDraftId(mediaId, draft.getId())
                .orElseThrow(() -> new ResourceNotFoundException(MEDIA_NOT_FOUND));
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

    public void cleanupExpired() {
        LocalDateTime now = LocalDateTime.now(APPLICATION_ZONE);
        List<EntryDraft> drafts = entryDraftRepository
                .findTop100ByExpiresAtLessThanEqualOrderByExpiresAtAscIdAsc(now);
        while (!drafts.isEmpty()) {
            for (EntryDraft draft : drafts) {
                try {
                    deletionService.discardExpired(draft.getId(), now);
                } catch (RuntimeException exception) {
                    log.warn("Entry draft cleanup failed for draft id {}", draft.getId());
                }
            }
            EntryDraft last = drafts.get(drafts.size() - 1);
            drafts = entryDraftRepository.findExpiredAfter(
                    now,
                    last.getExpiresAt(),
                    last.getId(),
                    PageRequest.of(0, 100)
            );
        }
    }

    private DraftSubmission requireSubmission(Long userId, EntryType entryType) {
        requireUser(userId);
        EntryDraft draft = entryDraftRepository
                .findActiveByUserIdAndEntryTypeForUpdate(
                        userId,
                        entryType,
                        LocalDateTime.now(APPLICATION_ZONE)
                )
                .orElseThrow(() -> new ResourceNotFoundException(DRAFT_NOT_FOUND));
        if (draft.getCurrentStep() != EntryDraftStep.REVIEW) {
            throw new ValidationException("Entry draft is not ready for submission");
        }
        if (draft.getRecordMethod() == null) {
            throw new ValidationException("Record method is required");
        }
        if (draft.getScore() == null || draft.getScore() < 1 || draft.getScore() > 5) {
            throw new ValidationException("Score must be between 1 and 5");
        }
        if (draft.getShared() == null) {
            throw new ValidationException("Shared state is required");
        }
        List<EntryDraftMedia> media = entryDraftMediaRepository
                .findAllByEntryDraftIdOrderByMediaRoleAsc(draft.getId());
        EntryDraftMedia contentMedia = mediaByRole(media, EntryDraftMediaRole.CONTENT);
        EntryDraftMedia drawingMedia = mediaByRole(media, EntryDraftMediaRole.DRAWING);
        validateCompleteContent(draft, contentMedia);
        if (draft.getWantsDrawing() == null) {
            throw new ValidationException("Drawing choice is required");
        }
        if (Boolean.TRUE.equals(draft.getWantsDrawing()) && drawingMedia == null) {
            throw new ValidationException("Drawing choice requires drawing media");
        }
        if (Boolean.FALSE.equals(draft.getWantsDrawing()) && drawingMedia != null) {
            throw new ValidationException("Drawing media requires wantsDrawing");
        }
        Mood mood = moodRepository.findByScore(draft.getScore())
                .orElseThrow(() -> new ResourceNotFoundException("Mood not found"));
        AnnoyanceType category = null;
        if (entryType == EntryType.ANNOYANCE) {
            if (draft.getAnnoyanceTypeId() == null) {
                throw new ValidationException("Annoyance category is required");
            }
            category = annoyanceTypeRepository.findById(draft.getAnnoyanceTypeId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Annoyance category not found"
                    ));
        }
        return new DraftSubmission(
                mood,
                category,
                draft.getRecordMethod() == EntryDraftRecordMethod.TEXT
                        ? draft.getContent().trim()
                        : null,
                draft.getShared()
        );
    }

    private void validateCompleteContent(EntryDraft draft, EntryDraftMedia contentMedia) {
        if (draft.getRecordMethod() == EntryDraftRecordMethod.TEXT) {
            if (draft.getContent() == null
                    || draft.getContent().isBlank()
                    || contentMedia != null) {
                throw new ValidationException(
                        "TEXT requires content and must not include content media"
                );
            }
            return;
        }
        if (draft.getContent() != null
                || contentMedia == null
                || contentMedia.getMediaType() != draft.getRecordMethod().mediaType()) {
            throw new ValidationException(
                    draft.getRecordMethod() + " requires matching content media"
            );
        }
    }

    private void validatePartial(
            EntryType entryType,
            SaveEntryDraftRequest request,
            MultipartFile contentFile,
            MultipartFile drawingFile
    ) {
        if (request.score() != null && (request.score() < 1 || request.score() > 5)) {
            throw new ValidationException("Score must be between 1 and 5");
        }
        if (entryType == EntryType.DIARY
                && request.categoryCode() != null
                && !request.categoryCode().isBlank()) {
            throw new ValidationException("Diary draft must not include categoryCode");
        }
        if (entryType == EntryType.DIARY
                && request.step() == EntryDraftStep.CATEGORY) {
            throw new ValidationException("Diary draft must not use CATEGORY step");
        }
        boolean hasContentFile = hasFile(contentFile);
        if (request.recordMethod() == null) {
            if ((request.content() != null && !request.content().isBlank())
                    || hasContentFile
                    || request.existingContentMediaId() != null) {
                throw new ValidationException(
                        "Content requires a selected record method"
                );
            }
        } else if (request.recordMethod() == EntryDraftRecordMethod.TEXT) {
            if (hasContentFile || request.existingContentMediaId() != null) {
                throw new ValidationException("TEXT must not include content media");
            }
        } else if (request.content() != null) {
            throw new ValidationException(
                    request.recordMethod() + " must not include text content"
            );
        }
        if (hasContentFile && request.existingContentMediaId() != null) {
            throw new ValidationException(
                    "New content media and existing media id cannot be used together"
            );
        }
        if (hasFile(drawingFile) && request.existingDrawingMediaId() != null) {
            throw new ValidationException(
                    "New drawing media and existing media id cannot be used together"
            );
        }
        if (Boolean.FALSE.equals(request.wantsDrawing())
                && (hasFile(drawingFile) || request.existingDrawingMediaId() != null)) {
            throw new ValidationException("Drawing media requires wantsDrawing");
        }
    }

    private AnnoyanceType resolveCategory(EntryType entryType, String categoryCode) {
        if (entryType == EntryType.DIARY || categoryCode == null || categoryCode.isBlank()) {
            return null;
        }
        return annoyanceTypeRepository.findByCode(categoryCode.trim())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Annoyance category not found"
                ));
    }

    private NewEntryDraftMedia upload(
            Long userId,
            EntryDraftMediaRole role,
            EntryMediaType mediaType,
            MultipartFile file
    ) {
        String fileName = file.getOriginalFilename();
        if (fileName == null || fileName.isBlank() || fileName.length() > 255) {
            throw new ValidationException("Draft media filename is invalid");
        }
        StoredEntryMedia stored = entryMediaStorageService.upload(userId, mediaType, file);
        return new NewEntryDraftMedia(role, mediaType, fileName, stored);
    }

    private String normalizedContent(SaveEntryDraftRequest request) {
        if (request.recordMethod() != EntryDraftRecordMethod.TEXT) {
            return null;
        }
        return request.content();
    }

    private EntryDraftEnvelope toEnvelope(
            EntryDraft draft,
            List<EntryDraftMedia> media
    ) {
        AnnoyanceType category = draft.getAnnoyanceTypeId() == null
                ? null
                : annoyanceTypeRepository.findById(draft.getAnnoyanceTypeId()).orElse(null);
        EntryDraftCategoryResponse categoryResponse = category == null
                ? null
                : new EntryDraftCategoryResponse(category.getCode(), category.getTypeName());
        return new EntryDraftEnvelope(new EntryDraftResponse(
                draft.getId(),
                draft.getEntryType(),
                draft.getCurrentStep(),
                categoryResponse,
                draft.getRecordMethod(),
                draft.getContent(),
                draft.getWantsDrawing(),
                draft.getScore(),
                draft.getShared(),
                draft.getExpiresAt().atZone(APPLICATION_ZONE).toOffsetDateTime(),
                toMediaResponse(
                        draft.getEntryType(),
                        mediaByRole(media, EntryDraftMediaRole.CONTENT)
                ),
                toMediaResponse(
                        draft.getEntryType(),
                        mediaByRole(media, EntryDraftMediaRole.DRAWING)
                )
        ));
    }

    private EntryDraftMediaResponse toMediaResponse(
            EntryType entryType,
            EntryDraftMedia media
    ) {
        if (media == null) {
            return null;
        }
        String resource = entryType == EntryType.DIARY ? "diaries" : "annoyances";
        return new EntryDraftMediaResponse(
                media.getId(),
                media.getMediaRole().name(),
                media.getMediaType().databaseValue(),
                media.getOriginalFilename(),
                media.getContentType(),
                media.getFileSizeBytes(),
                media.getDurationSeconds(),
                "/api/" + resource + "/draft/media/" + media.getId()
        );
    }

    private EntryDraftMedia mediaByRole(
            List<EntryDraftMedia> media,
            EntryDraftMediaRole role
    ) {
        return media.stream()
                .filter(item -> item.getMediaRole() == role)
                .findFirst()
                .orElse(null);
    }

    private void cleanupUploadedMedia(List<NewEntryDraftMedia> media) {
        cleanupStoredObjects(media.stream()
                .map(item -> item.storedMedia().objectKey())
                .toList());
    }

    private void cleanupStoredObjects(List<String> objectKeys) {
        for (String objectKey : objectKeys) {
            try {
                entryMediaStorageService.delete(objectKey);
            } catch (RuntimeException exception) {
                log.warn("Entry draft media cleanup failed");
            }
        }
    }

    private void requireUser(Long userId) {
        userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    private boolean hasFile(MultipartFile file) {
        return file != null && !file.isEmpty();
    }

    private record DraftSubmission(
            Mood mood,
            AnnoyanceType category,
            String content,
            boolean shared
    ) {
    }
}
