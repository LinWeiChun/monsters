package com.monsters.mapper.diary;

import com.monsters.dto.diary.DiaryMediaResponse;
import com.monsters.dto.diary.DiaryRecordMethod;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.entity.entry.Mood;
import java.time.ZoneId;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class DiaryMapper {

    private static final ZoneId APPLICATION_ZONE = ZoneId.of("Asia/Taipei");

    public DiaryResponse toResponse(Entry entry, Mood mood, List<EntryMedia> media) {
        return new DiaryResponse(
                entry.getId(),
                resolveRecordMethod(entry, media),
                entry.getContent(),
                mood.getScore(),
                entry.isShared(),
                entry.getOccurredAt().atZone(APPLICATION_ZONE).toOffsetDateTime(),
                media.stream().map(item -> toMediaResponse(entry.getId(), item)).toList(),
                null
        );
    }

    private DiaryMediaResponse toMediaResponse(Long entryId, EntryMedia media) {
        return new DiaryMediaResponse(
                media.getId(),
                media.getMediaType().databaseValue(),
                media.getContentType(),
                media.getFileSizeBytes(),
                media.getDurationSeconds(),
                "/api/diaries/" + entryId + "/media/" + media.getId()
        );
    }

    private DiaryRecordMethod resolveRecordMethod(Entry entry, List<EntryMedia> media) {
        List<EntryMediaType> primaryTypes = media.stream()
                .map(EntryMedia::getMediaType)
                .filter(type -> type != EntryMediaType.DRAWING)
                .toList();

        if (entry.getContent() != null && !entry.getContent().isBlank() && primaryTypes.isEmpty()) {
            return DiaryRecordMethod.TEXT;
        }
        if (entry.getContent() == null && primaryTypes.size() == 1) {
            return switch (primaryTypes.get(0)) {
                case IMAGE -> DiaryRecordMethod.IMAGE;
                case AUDIO -> DiaryRecordMethod.AUDIO;
                case VIDEO -> DiaryRecordMethod.VIDEO;
                case DRAWING -> throw invalidRecordState();
            };
        }
        throw invalidRecordState();
    }

    private IllegalStateException invalidRecordState() {
        return new IllegalStateException("Diary has an invalid primary record state");
    }
}
