package com.monsters.annoyance.service;

import com.monsters.annoyance.dto.AnnoyanceRecordMethod;
import com.monsters.annoyance.dto.AnnoyanceResponse;
import com.monsters.annoyance.entity.AnnoyanceType;
import com.monsters.annoyance.mapper.AnnoyanceMapper;
import com.monsters.annoyance.repository.AnnoyanceTypeRepository;
import com.monsters.common.exception.ResourceNotFoundException;
import com.monsters.common.exception.ValidationException;
import com.monsters.entry.entity.Entry;
import com.monsters.entry.entity.EntryMedia;
import com.monsters.entry.entity.EntryType;
import com.monsters.entry.entity.Mood;
import com.monsters.entry.repository.EntryMediaRepository;
import com.monsters.entry.repository.EntryRepository;
import com.monsters.entry.repository.MoodRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class AnnoyanceService {

    private final EntryRepository entryRepository;
    private final EntryMediaRepository entryMediaRepository;
    private final AnnoyanceTypeRepository annoyanceTypeRepository;
    private final MoodRepository moodRepository;
    private final AnnoyanceMapper annoyanceMapper;

    public AnnoyanceService(
            EntryRepository entryRepository,
            EntryMediaRepository entryMediaRepository,
            AnnoyanceTypeRepository annoyanceTypeRepository,
            MoodRepository moodRepository,
            AnnoyanceMapper annoyanceMapper
    ) {
        this.entryRepository = entryRepository;
        this.entryMediaRepository = entryMediaRepository;
        this.annoyanceTypeRepository = annoyanceTypeRepository;
        this.moodRepository = moodRepository;
        this.annoyanceMapper = annoyanceMapper;
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
}
