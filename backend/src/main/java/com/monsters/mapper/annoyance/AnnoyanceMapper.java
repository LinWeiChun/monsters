package com.monsters.mapper.annoyance;

import com.monsters.dto.annoyance.AnnoyanceCategoryResponse;
import com.monsters.dto.annoyance.AnnoyanceMediaResponse;
import com.monsters.dto.annoyance.AnnoyanceRecordMethod;
import com.monsters.dto.annoyance.AnnoyanceResponse;
import com.monsters.entity.annoyance.AnnoyanceType;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.entity.entry.Mood;
import java.time.ZoneId;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class AnnoyanceMapper {

    private static final ZoneId APPLICATION_ZONE = ZoneId.of("Asia/Taipei");

    public AnnoyanceResponse toResponse(
            Entry entry,
            AnnoyanceType annoyanceType,
            Mood mood,
            List<EntryMedia> media
    ) {
        return new AnnoyanceResponse(
                entry.getId(),
                new AnnoyanceCategoryResponse(annoyanceType.getCode(), annoyanceType.getTypeName()),
                resolveRecordMethod(entry, media),
                entry.getContent(),
                mood.getScore(),
                entry.isShared(),
                entry.isSolved(),
                entry.getOccurredAt().atZone(APPLICATION_ZONE).toOffsetDateTime(),
                media.stream().map(item -> toMediaResponse(entry.getId(), item)).toList(),
                null
        );
    }

    private AnnoyanceMediaResponse toMediaResponse(Long entryId, EntryMedia media) {
        return new AnnoyanceMediaResponse(
                media.getId(),
                media.getMediaType().databaseValue(),
                media.getContentType(),
                media.getFileSizeBytes(),
                media.getDurationSeconds(),
                "/api/annoyances/" + entryId + "/media/" + media.getId()
        );
    }

    private AnnoyanceRecordMethod resolveRecordMethod(Entry entry, List<EntryMedia> media) {
        List<EntryMediaType> primaryTypes = media.stream()
                .map(EntryMedia::getMediaType)
                .filter(type -> type != EntryMediaType.DRAWING)
                .toList();

        if (entry.getContent() != null && !entry.getContent().isBlank() && primaryTypes.isEmpty()) {
            return AnnoyanceRecordMethod.TEXT;
        }
        if (entry.getContent() == null && primaryTypes.size() == 1) {
            return switch (primaryTypes.get(0)) {
                case IMAGE -> AnnoyanceRecordMethod.IMAGE;
                case AUDIO -> AnnoyanceRecordMethod.AUDIO;
                case VIDEO -> AnnoyanceRecordMethod.VIDEO;
                case DRAWING -> throw invalidRecordState();
            };
        }
        throw invalidRecordState();
    }

    private IllegalStateException invalidRecordState() {
        return new IllegalStateException("Annoyance has an invalid primary record state");
    }
}
