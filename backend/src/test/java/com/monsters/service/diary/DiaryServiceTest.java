package com.monsters.service.diary;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.diary.CreateDiaryRequest;
import com.monsters.dto.diary.DiaryRecordMethod;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.entity.entry.EntryType;
import com.monsters.entity.entry.Mood;
import com.monsters.entity.user.User;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.common.ValidationException;
import com.monsters.mapper.diary.DiaryMapper;
import com.monsters.repository.entry.EntryMediaRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.entry.MoodRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.storage.entry.EntryMediaStorageService;
import com.monsters.storage.entry.StoredEntryMedia;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
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
    @Mock private UserRepository userRepository;
    @Mock private EntryMediaStorageService entryMediaStorageService;
    @Mock private DiaryPersistenceService persistenceService;

    @Test
    void createTextShouldNormalizeInputAndReturnMappedResponse() {
        Entry entry = entry();
        Mood mood = mood();
        CreatedDiary created = new CreatedDiary(entry, List.of());
        DiaryResponse expected = response(entry);
        CreateDiaryRequest request = new CreateDiaryRequest(
                DiaryRecordMethod.TEXT,
                "  diary content  ",
                4,
                null,
                OffsetDateTime.parse("2026-07-19T04:00:00Z")
        );
        prepareLookups(mood);
        when(persistenceService.create(
                anyLong(),
                anyLong(),
                any(),
                anyBoolean(),
                any(LocalDateTime.class),
                anyList()
        )).thenReturn(created);
        when(diaryMapper.toResponse(entry, mood, List.of())).thenReturn(expected);

        DiaryResponse actual = service().create(1L, request, null, null);

        assertThat(actual).isSameAs(expected);
        verify(persistenceService).create(
                1L,
                3L,
                "diary content",
                false,
                LocalDateTime.of(2026, 7, 19, 12, 0),
                List.of()
        );
        verify(entryMediaStorageService, never()).upload(anyLong(), any(), any());
    }

    @Test
    void createMediaShouldUploadPrimaryAndOptionalDrawingBeforePersistence() {
        Mood mood = mood();
        Entry entry = Entry.diary(
                1L,
                3L,
                null,
                true,
                LocalDateTime.of(2026, 7, 19, 12, 0)
        );
        ReflectionTestUtils.setField(entry, "id", 10L);
        MockMultipartFile contentFile = file("image.png", "image/png");
        MockMultipartFile drawingFile = file("drawing.webp", "image/webp");
        when(entryMediaStorageService.upload(1L, EntryMediaType.IMAGE, contentFile))
                .thenReturn(stored("entries/media/1/image/key.png", "image/png"));
        when(entryMediaStorageService.upload(1L, EntryMediaType.DRAWING, drawingFile))
                .thenReturn(stored("entries/media/1/drawing/key.webp", "image/webp"));
        prepareLookups(mood);
        when(persistenceService.create(
                anyLong(), anyLong(), any(), anyBoolean(), any(), anyList()
        )).thenReturn(new CreatedDiary(entry, List.of()));
        when(diaryMapper.toResponse(entry, mood, List.of())).thenReturn(response(entry));

        service().create(1L, mediaRequest(), contentFile, drawingFile);

        @SuppressWarnings("unchecked")
        org.mockito.ArgumentCaptor<List<NewDiaryMedia>> captor =
                org.mockito.ArgumentCaptor.forClass(List.class);
        verify(persistenceService).create(
                org.mockito.ArgumentMatchers.eq(1L),
                org.mockito.ArgumentMatchers.eq(3L),
                org.mockito.ArgumentMatchers.isNull(),
                org.mockito.ArgumentMatchers.eq(false),
                org.mockito.ArgumentMatchers.eq(LocalDateTime.of(2026, 7, 19, 12, 0)),
                captor.capture()
        );
        assertThat(captor.getValue())
                .extracting(NewDiaryMedia::mediaType)
                .containsExactly(EntryMediaType.IMAGE, EntryMediaType.DRAWING);
        assertThat(captor.getValue())
                .extracting(NewDiaryMedia::displayOrder)
                .containsExactly(0, 1);
    }

    @Test
    void createShouldCleanUploadedMediaWhenDatabaseTransactionFails() {
        prepareLookups(mood());
        MockMultipartFile contentFile = file("image.png", "image/png");
        when(entryMediaStorageService.upload(1L, EntryMediaType.IMAGE, contentFile))
                .thenReturn(stored("entries/media/1/image/key.png", "image/png"));
        when(persistenceService.create(
                anyLong(), anyLong(), any(), anyBoolean(), any(), anyList()
        )).thenThrow(new IllegalStateException("database failed"));

        assertThatThrownBy(() -> service().create(1L, mediaRequest(), contentFile, null))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("database failed");

        verify(entryMediaStorageService).delete("entries/media/1/image/key.png");
    }

    @Test
    void createShouldRejectDeletedUserBeforeUploading() {
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service().create(
                1L,
                mediaRequest(),
                file("image.png", "image/png"),
                null
        )).isInstanceOf(ResourceNotFoundException.class).hasMessage("User not found");

        verify(entryMediaStorageService, never()).upload(anyLong(), any(), any());
    }

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
                diaryMapper,
                userRepository,
                entryMediaStorageService,
                persistenceService
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
        Mood mood = new Mood("SCORE_4", "4分", 4, null, 4);
        ReflectionTestUtils.setField(mood, "id", 3L);
        return mood;
    }

    private MockMultipartFile file() {
        return file("image.png", "image/png");
    }

    private MockMultipartFile file(String filename, String contentType) {
        return new MockMultipartFile("file", filename, contentType, new byte[]{1});
    }

    private void prepareLookups(Mood mood) {
        when(userRepository.findByIdAndDeletedFalse(1L))
                .thenReturn(Optional.of(new User("account", "user@example.com", "User")));
        when(moodRepository.findByScore(4)).thenReturn(Optional.of(mood));
    }

    private StoredEntryMedia stored(String objectKey, String contentType) {
        return new StoredEntryMedia(objectKey, contentType, 1, (BigDecimal) null);
    }

    private CreateDiaryRequest mediaRequest() {
        return new CreateDiaryRequest(
                DiaryRecordMethod.IMAGE,
                null,
                4,
                false,
                OffsetDateTime.parse("2026-07-19T12:00:00+08:00")
        );
    }
}
