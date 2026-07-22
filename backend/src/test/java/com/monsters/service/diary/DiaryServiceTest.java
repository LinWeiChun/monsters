package com.monsters.service.diary;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.common.PageResponse;
import com.monsters.dto.diary.CreateDiaryRequest;
import com.monsters.dto.diary.DiaryRecordMethod;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.dto.diary.UpdateDiaryRequest;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
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
import java.util.Set;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
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
    void updateShouldRetainContentMediaAndRemoveDrawingAfterTransaction() {
        Entry entry = entry(10L, null);
        Mood mood = mood();
        EntryMedia image = media(21L, EntryMediaType.IMAGE, "entries/media/1/image/old.png", 0);
        EntryMedia drawing = media(22L, EntryMediaType.DRAWING, "entries/media/1/drawing/old.webp", 1);
        UpdateDiaryRequest request = updateRequest(
                DiaryRecordMethod.IMAGE,
                null,
                false,
                21L,
                null
        );
        DiaryResponse expected = response(entry);
        prepareLookups(mood);
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.DIARY
        )).thenReturn(Optional.of(entry));
        when(entryMediaRepository.findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(10L))
                .thenReturn(List.of(image, drawing));
        when(persistenceService.update(
                any(), anyLong(), any(), anyBoolean(), any(), anyList(), any(), anyList()
        )).thenReturn(new UpdatedDiary(
                entry,
                List.of(image),
                List.of("entries/media/1/drawing/old.webp")
        ));
        when(diaryMapper.toResponse(entry, mood, List.of(image))).thenReturn(expected);

        assertThat(service().update(1L, 10L, request, null, null)).isSameAs(expected);

        verify(persistenceService).update(
                entry,
                3L,
                null,
                false,
                LocalDateTime.of(2026, 7, 22, 12, 0),
                List.of(image, drawing),
                Set.of(21L),
                List.of()
        );
        verify(entryMediaStorageService).delete("entries/media/1/drawing/old.webp");
    }

    @Test
    void updateShouldCleanNewMediaWhenDatabaseTransactionFails() {
        Entry entry = entry(10L, null);
        Mood mood = mood();
        MockMultipartFile contentFile = file("new-image.png", "image/png");
        UpdateDiaryRequest request = updateRequest(
                DiaryRecordMethod.IMAGE,
                null,
                false,
                null,
                null
        );
        prepareLookups(mood);
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.DIARY
        )).thenReturn(Optional.of(entry));
        when(entryMediaRepository.findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(10L))
                .thenReturn(List.of());
        when(entryMediaStorageService.upload(1L, EntryMediaType.IMAGE, contentFile))
                .thenReturn(stored("entries/media/1/image/new.png", "image/png"));
        when(persistenceService.update(
                any(), anyLong(), any(), anyBoolean(), any(), anyList(), any(), anyList()
        )).thenThrow(new IllegalStateException("database failed"));

        assertThatThrownBy(() -> service().update(1L, 10L, request, contentFile, null))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("database failed");

        verify(entryMediaStorageService).delete("entries/media/1/image/new.png");
    }

    @Test
    void updateShouldRejectInvalidRetainedMedia() {
        Entry entry = entry(10L, null);
        Mood mood = mood();
        EntryMedia image = media(21L, EntryMediaType.IMAGE, "entries/media/1/image/old.png", 0);
        UpdateDiaryRequest request = updateRequest(
                DiaryRecordMethod.IMAGE,
                null,
                false,
                99L,
                null
        );
        prepareLookups(mood);
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.DIARY
        )).thenReturn(Optional.of(entry));
        when(entryMediaRepository.findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(10L))
                .thenReturn(List.of(image));

        assertThatThrownBy(() -> service().update(1L, 10L, request, null, null))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Existing content media is invalid");
        verify(entryMediaStorageService, never()).upload(anyLong(), any(), any());
    }

    @Test
    void findAllShouldApplyOwnerFilterSortAndBatchMap() {
        prepareUser();
        Entry first = entry(10L, "first");
        Entry second = entry(11L, "second");
        Mood mood = mood();
        EntryMedia drawing = new EntryMedia(
                10L,
                EntryMediaType.DRAWING,
                "entries/media/1/drawing/key.webp",
                "image/webp",
                1,
                null,
                1
        );
        DiaryResponse firstResponse = response(first);
        DiaryResponse secondResponse = response(second);
        PageRequest pageable = PageRequest.of(2, 2);
        when(entryRepository.findEntryPage(
                1L,
                EntryType.DIARY,
                null,
                false,
                "score",
                "asc",
                pageable
        )).thenReturn(new PageImpl<>(List.of(first, second), pageable, 6));
        when(moodRepository.findAllById(any())).thenReturn(List.of(mood));
        when(entryMediaRepository.findAllByEntryIdInAndDeletedFalseOrderByEntryIdAscDisplayOrderAsc(
                List.of(10L, 11L)
        )).thenReturn(List.of(drawing));
        when(diaryMapper.toResponse(first, mood, List.of(drawing))).thenReturn(firstResponse);
        when(diaryMapper.toResponse(second, mood, List.of())).thenReturn(secondResponse);

        PageResponse<DiaryResponse> result = service().findAll(
                1L,
                2,
                2,
                "score,ASC",
                false
        );

        assertThat(result.content()).containsExactly(firstResponse, secondResponse);
        assertThat(result.page()).isEqualTo(2);
        assertThat(result.size()).isEqualTo(2);
        assertThat(result.totalElements()).isEqualTo(6);
        assertThat(result.totalPages()).isEqualTo(3);
        assertThat(result.first()).isFalse();
        assertThat(result.last()).isTrue();
        verify(entryRepository).findEntryPage(
                1L,
                EntryType.DIARY,
                null,
                false,
                "score",
                "asc",
                pageable
        );
    }

    @Test
    void findAllShouldReturnEmptyPageWithoutLookupQueries() {
        prepareUser();
        PageRequest pageable = PageRequest.of(0, 20);
        when(entryRepository.findEntryPage(
                1L,
                EntryType.DIARY,
                null,
                null,
                "occurredAt",
                "desc",
                pageable
        )).thenReturn(new PageImpl<>(List.of(), pageable, 0));

        PageResponse<DiaryResponse> result = service().findAll(1L, 0, 20, " ", null);

        assertThat(result.content()).isEmpty();
        assertThat(result.totalElements()).isZero();
        assertThat(result.totalPages()).isZero();
        assertThat(result.first()).isTrue();
        assertThat(result.last()).isTrue();
        verify(moodRepository, never()).findAllById(any());
        verify(entryMediaRepository, never())
                .findAllByEntryIdInAndDeletedFalseOrderByEntryIdAscDisplayOrderAsc(anyList());
    }

    @Test
    void findAllShouldRejectInvalidPaginationAndSort() {
        prepareUser();
        DiaryService service = service();

        assertThatThrownBy(() -> service.findAll(1L, -1, 20, null, null))
                .isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.findAll(1L, 0, 0, null, null))
                .isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.findAll(1L, 0, 101, null, null))
                .isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.findAll(1L, 0, 20, "id,asc", null))
                .isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.findAll(1L, 0, 20, "score,sideways", null))
                .isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.findAll(1L, 0, 20, "score,asc,extra", null))
                .isInstanceOf(ValidationException.class);
        verify(entryRepository, never()).findEntryPage(
                anyLong(), any(), any(), any(), anyString(), anyString(), any()
        );
    }

    @Test
    void findOneShouldReturnOwnerDiaryResponse() {
        prepareUser();
        Entry entry = entry();
        Mood mood = mood();
        DiaryResponse expected = response(entry);
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.DIARY
        )).thenReturn(Optional.of(entry));
        when(moodRepository.findById(3L)).thenReturn(Optional.of(mood));
        when(entryMediaRepository.findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(10L))
                .thenReturn(List.of());
        when(diaryMapper.toResponse(entry, mood, List.of())).thenReturn(expected);

        assertThat(service().findOne(1L, 10L)).isSameAs(expected);
    }

    @Test
    void findOneShouldRejectDeletedUserBeforeEntryQuery() {
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service().findOne(1L, 10L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("User not found");
        verify(entryRepository, never()).findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                anyLong(), anyLong(), any()
        );
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
        return entry(10L, "diary content");
    }

    private Entry entry(Long id, String content) {
        Entry entry = Entry.diary(
                1L,
                3L,
                content,
                false,
                LocalDateTime.of(2026, 7, 19, 9, 0)
        );
        ReflectionTestUtils.setField(entry, "id", id);
        return entry;
    }

    private DiaryResponse response(Entry entry) {
        return new DiaryResponse(
                entry.getId(),
                DiaryRecordMethod.TEXT,
                entry.getContent(),
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
        prepareUser();
        when(moodRepository.findByScore(4)).thenReturn(Optional.of(mood));
    }

    private void prepareUser() {
        when(userRepository.findByIdAndDeletedFalse(1L))
                .thenReturn(Optional.of(new User("account", "user@example.com", "User")));
    }

    private StoredEntryMedia stored(String objectKey, String contentType) {
        return new StoredEntryMedia(objectKey, contentType, 1, (BigDecimal) null);
    }

    private EntryMedia media(Long id, EntryMediaType type, String objectKey, int displayOrder) {
        EntryMedia media = new EntryMedia(
                10L,
                type,
                objectKey,
                type == EntryMediaType.IMAGE ? "image/png" : "image/webp",
                1,
                null,
                displayOrder
        );
        ReflectionTestUtils.setField(media, "id", id);
        return media;
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

    private UpdateDiaryRequest updateRequest(
            DiaryRecordMethod recordMethod,
            String content,
            Boolean shared,
            Long existingContentMediaId,
            Long existingDrawingMediaId
    ) {
        return new UpdateDiaryRequest(
                recordMethod,
                content,
                4,
                shared,
                OffsetDateTime.parse("2026-07-22T12:00:00+08:00"),
                existingContentMediaId,
                existingDrawingMediaId
        );
    }
}
