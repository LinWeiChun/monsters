package com.monsters.annoyance.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.annoyance.dto.AnnoyanceRecordMethod;
import com.monsters.annoyance.dto.AnnoyanceResponse;
import com.monsters.annoyance.entity.AnnoyanceType;
import com.monsters.annoyance.mapper.AnnoyanceMapper;
import com.monsters.annoyance.repository.AnnoyanceTypeRepository;
import com.monsters.common.exception.ResourceNotFoundException;
import com.monsters.common.exception.ValidationException;
import com.monsters.entry.entity.Entry;
import com.monsters.entry.entity.EntryType;
import com.monsters.entry.entity.Mood;
import com.monsters.entry.repository.EntryMediaRepository;
import com.monsters.entry.repository.EntryRepository;
import com.monsters.entry.repository.MoodRepository;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class AnnoyanceServiceTest {

    @Mock private EntryRepository entryRepository;
    @Mock private EntryMediaRepository entryMediaRepository;
    @Mock private AnnoyanceTypeRepository annoyanceTypeRepository;
    @Mock private MoodRepository moodRepository;
    @Mock private AnnoyanceMapper annoyanceMapper;

    @Test
    void shouldRequireOwnerScopedAnnoyance() {
        Entry entry = entry();
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.ANNOYANCE
        )).thenReturn(Optional.of(entry));

        assertThat(service().requireOwnedEntry(1L, 10L)).isSameAs(entry);
    }

    @Test
    void shouldHideOwnershipMismatchAsNotFound() {
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.ANNOYANCE
        )).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service().requireOwnedEntry(1L, 10L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Annoyance not found");
    }

    @Test
    void shouldResolveCategoryAndMoodLookups() {
        AnnoyanceType category = new AnnoyanceType("ACADEMIC", "課業", 1);
        Mood mood = new Mood("BAD", "不好", 4, null, 4);
        when(annoyanceTypeRepository.findByCode("ACADEMIC")).thenReturn(Optional.of(category));
        when(moodRepository.findByScore(4)).thenReturn(Optional.of(mood));

        assertThat(service().requireCategory("ACADEMIC")).isSameAs(category);
        assertThat(service().requireMood(4)).isSameAs(mood);
    }

    @Test
    void shouldBuildResponseFromLookupsAndActiveMedia() {
        Entry entry = entry();
        AnnoyanceType category = new AnnoyanceType("ACADEMIC", "課業", 1);
        Mood mood = new Mood("BAD", "不好", 4, null, 4);
        AnnoyanceResponse expected = new AnnoyanceResponse(
                10L,
                null,
                AnnoyanceRecordMethod.TEXT,
                "content",
                4,
                false,
                false,
                entry.getOccurredAt().atZone(ZoneId.of("Asia/Taipei")).toOffsetDateTime(),
                List.of(),
                null
        );
        when(annoyanceTypeRepository.findById(2L)).thenReturn(Optional.of(category));
        when(moodRepository.findById(3L)).thenReturn(Optional.of(mood));
        when(entryMediaRepository.findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(10L))
                .thenReturn(List.of());
        when(annoyanceMapper.toResponse(entry, category, mood, List.of())).thenReturn(expected);

        assertThat(service().toResponse(entry)).isSameAs(expected);
        verify(annoyanceMapper).toResponse(entry, category, mood, List.of());
    }

    @Test
    void shouldValidateTextAndMediaRecordCombinations() {
        AnnoyanceService service = service();
        MockMultipartFile file = file();

        service.validatePrimaryRecord(AnnoyanceRecordMethod.TEXT, "content", null);
        service.validatePrimaryRecord(AnnoyanceRecordMethod.IMAGE, null, file);

        assertThatThrownBy(() -> service.validatePrimaryRecord(null, "content", null))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Record method is required");
        assertThatThrownBy(() -> service.validatePrimaryRecord(
                AnnoyanceRecordMethod.TEXT,
                "content",
                file
        )).isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.validatePrimaryRecord(
                AnnoyanceRecordMethod.VIDEO,
                "content",
                file
        )).isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.validatePrimaryRecord(
                AnnoyanceRecordMethod.IMAGE,
                " ",
                file
        )).isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.validatePrimaryRecord(
                AnnoyanceRecordMethod.AUDIO,
                null,
                null
        )).isInstanceOf(ValidationException.class);
    }

    private AnnoyanceService service() {
        return new AnnoyanceService(
                entryRepository,
                entryMediaRepository,
                annoyanceTypeRepository,
                moodRepository,
                annoyanceMapper
        );
    }

    private Entry entry() {
        Entry entry = Entry.annoyance(
                1L,
                2L,
                3L,
                "content",
                false,
                LocalDateTime.of(2026, 7, 11, 12, 0)
        );
        ReflectionTestUtils.setField(entry, "id", 10L);
        return entry;
    }

    private MockMultipartFile file() {
        return new MockMultipartFile("contentFile", "image.png", "image/png", new byte[]{1});
    }
}
