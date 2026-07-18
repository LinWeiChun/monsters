package com.monsters.service.diary;

import com.monsters.dto.diary.DiaryRecordMethod;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import com.monsters.entity.entry.EntryType;
import com.monsters.entity.entry.Mood;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.common.ValidationException;
import com.monsters.mapper.diary.DiaryMapper;
import com.monsters.repository.entry.EntryMediaRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.entry.MoodRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class DiaryService {

    private final EntryRepository entryRepository;
    private final EntryMediaRepository entryMediaRepository;
    private final MoodRepository moodRepository;
    private final DiaryMapper diaryMapper;

    public DiaryService(
            EntryRepository entryRepository,
            EntryMediaRepository entryMediaRepository,
            MoodRepository moodRepository,
            DiaryMapper diaryMapper
    ) {
        this.entryRepository = entryRepository;
        this.entryMediaRepository = entryMediaRepository;
        this.moodRepository = moodRepository;
        this.diaryMapper = diaryMapper;
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
}
