package com.monsters.service.diary;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.diary.DiaryRecordMethod;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryType;
import com.monsters.entity.entry.Mood;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.common.ValidationException;
import com.monsters.mapper.diary.DiaryMapper;
import com.monsters.repository.entry.EntryMediaRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.entry.MoodRepository;
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
class DiaryServiceTest {

    @Mock private EntryRepository entryRepository;
    @Mock private EntryMediaRepository entryMediaRepository;
    @Mock private MoodRepository moodRepository;
    @Mock private DiaryMapper diaryMapper;

    @Test
    void shouldRequireOwnerScopedDiary() {
        Entry entry = entry();
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.DIARY
        )).thenReturn(Optional.of(entry));

        assertThat(service().requireOwnedEntry(1L, 10L)).isSameAs(entry);
    }

    @Test
    void shouldHideOwnershipMismatchAsNotFound() {
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.DIARY
        )).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service().requireOwnedEntry(1L, 10L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Diary not found");
    }

    @Test
    void shouldResolveMoodAndBuildResponseFromActiveMedia() {
        Entry entry = entry();
        Mood mood = mood();
        DiaryResponse expected = response(entry);
        when(moodRepository.findByScore(4)).thenReturn(Optional.of(mood));
        when(moodRepository.findById(3L)).thenReturn(Optional.of(mood));
        when(entryMediaRepository.findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(10L))
                .thenReturn(List.of());
        when(diaryMapper.toResponse(entry, mood, List.of())).thenReturn(expected);

        assertThat(service().requireMood(4)).isSameAs(mood);
        assertThat(service().toResponse(entry)).isSameAs(expected);
        verify(diaryMapper).toResponse(entry, mood, List.of());
    }

    @Test
    void shouldRejectUnknownMood() {
        when(moodRepository.findByScore(4)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service().requireMood(4))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Mood not found");
    }

    @Test
    void shouldValidateTextAndMediaRecordCombinations() {
        DiaryService service = service();
        MockMultipartFile file = file();

        service.validatePrimaryRecord(DiaryRecordMethod.TEXT, "content", null);
        service.validatePrimaryRecord(DiaryRecordMethod.IMAGE, null, file);

        assertThatThrownBy(() -> service.validatePrimaryRecord(null, "content", null))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Record method is required");
        assertThatThrownBy(() -> service.validatePrimaryRecord(
                DiaryRecordMethod.TEXT,
                "content",
                file
        )).isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.validatePrimaryRecord(
                DiaryRecordMethod.VIDEO,
                "content",
                file
        )).isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.validatePrimaryRecord(
                DiaryRecordMethod.IMAGE,
                " ",
                file
        )).isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.validatePrimaryRecord(
                DiaryRecordMethod.AUDIO,
                null,
                null
        )).isInstanceOf(ValidationException.class);
    }

    private DiaryService service() {
        return new DiaryService(
                entryRepository,
                entryMediaRepository,
                moodRepository,
                diaryMapper
        );
    }

    private Entry entry() {
        Entry entry = Entry.diary(
                1L,
                3L,
                "diary content",
                false,
                LocalDateTime.of(2026, 7, 19, 9, 0)
        );
        ReflectionTestUtils.setField(entry, "id", 10L);
        return entry;
    }

    private DiaryResponse response(Entry entry) {
        return new DiaryResponse(
                10L,
                DiaryRecordMethod.TEXT,
                "diary content",
                4,
                false,
                entry.getOccurredAt().atZone(ZoneId.of("Asia/Taipei")).toOffsetDateTime(),
                List.of(),
                null
        );
    }

    private Mood mood() {
        return new Mood("SCORE_4", "4分", 4, null, 4);
    }

    private MockMultipartFile file() {
        return new MockMultipartFile("contentFile", "image.png", "image/png", new byte[]{1});
    }
}
