package com.monsters.annoyance.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.annoyance.dto.AnnoyanceRecordMethod;
import com.monsters.annoyance.dto.AnnoyanceResponse;
import com.monsters.annoyance.dto.CreateAnnoyanceRequest;
import com.monsters.annoyance.entity.AnnoyanceType;
import com.monsters.annoyance.mapper.AnnoyanceMapper;
import com.monsters.annoyance.repository.AnnoyanceTypeRepository;
import com.monsters.common.exception.ResourceNotFoundException;
import com.monsters.common.exception.ValidationException;
import com.monsters.entry.entity.Entry;
import com.monsters.entry.entity.EntryMediaType;
import com.monsters.entry.entity.EntryType;
import com.monsters.entry.entity.Mood;
import com.monsters.entry.repository.EntryMediaRepository;
import com.monsters.entry.repository.EntryRepository;
import com.monsters.entry.repository.MoodRepository;
import com.monsters.entry.storage.EntryMediaStorageService;
import com.monsters.entry.storage.StoredEntryMedia;
import com.monsters.user.entity.User;
import com.monsters.user.repository.UserRepository;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
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
    @Mock private UserRepository userRepository;
    @Mock private EntryMediaStorageService entryMediaStorageService;
    @Mock private AnnoyancePersistenceService persistenceService;

    @Test
    void createTextShouldNormalizeInputAndReturnMappedResponse() {
        AnnoyanceType category = category();
        Mood mood = mood();
        Entry entry = entry();
        CreatedAnnoyance created = new CreatedAnnoyance(entry, List.of());
        AnnoyanceResponse expected = response(entry);
        CreateAnnoyanceRequest request = new CreateAnnoyanceRequest(
                " academic ",
                AnnoyanceRecordMethod.TEXT,
                "  content  ",
                4,
                null,
                OffsetDateTime.parse("2026-07-11T04:00:00Z")
        );
        prepareLookups(category, mood);
        when(persistenceService.create(
                anyLong(),
                anyLong(),
                anyLong(),
                anyString(),
                anyBoolean(),
                any(LocalDateTime.class),
                anyList()
        )).thenReturn(created);
        when(annoyanceMapper.toResponse(entry, category, mood, List.of())).thenReturn(expected);

        AnnoyanceResponse actual = service().create(1L, request, null, null);

        assertThat(actual).isSameAs(expected);
        verify(annoyanceTypeRepository).findByCode("ACADEMIC");
        verify(persistenceService).create(
                1L,
                2L,
                3L,
                "content",
                false,
                LocalDateTime.of(2026, 7, 11, 12, 0),
                List.of()
        );
        verify(entryMediaStorageService, never()).upload(anyLong(), any(), any());
    }

    @Test
    void createMediaShouldUploadPrimaryAndDrawingBeforePersistence() {
        AnnoyanceType category = category();
        Mood mood = mood();
        Entry entry = Entry.annoyance(
                1L,
                2L,
                3L,
                null,
                true,
                LocalDateTime.of(2026, 7, 11, 12, 0)
        );
        ReflectionTestUtils.setField(entry, "id", 10L);
        MockMultipartFile contentFile = file("image.png", "image/png");
        MockMultipartFile drawingFile = file("drawing.webp", "image/webp");
        StoredEntryMedia storedImage = stored("entries/media/1/image/key.png", "image/png");
        StoredEntryMedia storedDrawing = stored("entries/media/1/drawing/key.webp", "image/webp");
        CreatedAnnoyance created = new CreatedAnnoyance(entry, List.of());
        AnnoyanceResponse expected = response(entry);
        CreateAnnoyanceRequest request = new CreateAnnoyanceRequest(
                "ACADEMIC",
                AnnoyanceRecordMethod.IMAGE,
                null,
                4,
                true,
                OffsetDateTime.parse("2026-07-11T12:00:00+08:00")
        );
        prepareLookups(category, mood);
        when(entryMediaStorageService.upload(1L, EntryMediaType.IMAGE, contentFile))
                .thenReturn(storedImage);
        when(entryMediaStorageService.upload(1L, EntryMediaType.DRAWING, drawingFile))
                .thenReturn(storedDrawing);
        when(persistenceService.create(
                anyLong(),
                anyLong(),
                anyLong(),
                org.mockito.ArgumentMatchers.isNull(),
                anyBoolean(),
                any(LocalDateTime.class),
                anyList()
        )).thenReturn(created);
        when(annoyanceMapper.toResponse(entry, category, mood, List.of())).thenReturn(expected);

        AnnoyanceResponse actual = service().create(1L, request, contentFile, drawingFile);

        assertThat(actual).isSameAs(expected);
        @SuppressWarnings("unchecked")
        org.mockito.ArgumentCaptor<List<NewEntryMedia>> captor = org.mockito.ArgumentCaptor.forClass(List.class);
        verify(persistenceService).create(
                org.mockito.ArgumentMatchers.eq(1L),
                org.mockito.ArgumentMatchers.eq(2L),
                org.mockito.ArgumentMatchers.eq(3L),
                org.mockito.ArgumentMatchers.isNull(),
                org.mockito.ArgumentMatchers.eq(true),
                org.mockito.ArgumentMatchers.eq(LocalDateTime.of(2026, 7, 11, 12, 0)),
                captor.capture()
        );
        assertThat(captor.getValue())
                .extracting(NewEntryMedia::mediaType)
                .containsExactly(EntryMediaType.IMAGE, EntryMediaType.DRAWING);
        assertThat(captor.getValue())
                .extracting(NewEntryMedia::displayOrder)
                .containsExactly(0, 1);
    }

    @Test
    void createShouldCleanUploadedPrimaryWhenDrawingUploadFails() {
        prepareLookups(category(), mood());
        MockMultipartFile contentFile = file("image.png", "image/png");
        MockMultipartFile drawingFile = file("drawing.webp", "image/webp");
        StoredEntryMedia storedImage = stored("entries/media/1/image/key.png", "image/png");
        when(entryMediaStorageService.upload(1L, EntryMediaType.IMAGE, contentFile))
                .thenReturn(storedImage);
        when(entryMediaStorageService.upload(1L, EntryMediaType.DRAWING, drawingFile))
                .thenThrow(new ValidationException("drawing failed"));

        assertThatThrownBy(() -> service().create(
                1L,
                mediaRequest(),
                contentFile,
                drawingFile
        )).isInstanceOf(ValidationException.class).hasMessage("drawing failed");

        verify(entryMediaStorageService).delete("entries/media/1/image/key.png");
        verify(persistenceService, never()).create(
                anyLong(), anyLong(), anyLong(), any(), anyBoolean(), any(), anyList()
        );
    }

    @Test
    void createShouldCleanAllUploadsWhenDatabaseTransactionFails() {
        prepareLookups(category(), mood());
        MockMultipartFile contentFile = file("image.png", "image/png");
        MockMultipartFile drawingFile = file("drawing.webp", "image/webp");
        when(entryMediaStorageService.upload(1L, EntryMediaType.IMAGE, contentFile))
                .thenReturn(stored("entries/media/1/image/key.png", "image/png"));
        when(entryMediaStorageService.upload(1L, EntryMediaType.DRAWING, drawingFile))
                .thenReturn(stored("entries/media/1/drawing/key.webp", "image/webp"));
        when(persistenceService.create(
                anyLong(), anyLong(), anyLong(), any(), anyBoolean(), any(), anyList()
        )).thenThrow(new IllegalStateException("database failed"));

        assertThatThrownBy(() -> service().create(
                1L,
                mediaRequest(),
                contentFile,
                drawingFile
        )).isInstanceOf(IllegalStateException.class).hasMessage("database failed");

        verify(entryMediaStorageService).delete("entries/media/1/image/key.png");
        verify(entryMediaStorageService).delete("entries/media/1/drawing/key.webp");
    }

    @Test
    void createShouldPreserveOriginalFailureWhenCleanupAlsoFails() {
        prepareLookups(category(), mood());
        MockMultipartFile contentFile = file("image.png", "image/png");
        when(entryMediaStorageService.upload(1L, EntryMediaType.IMAGE, contentFile))
                .thenReturn(stored("entries/media/1/image/key.png", "image/png"));
        when(persistenceService.create(
                anyLong(), anyLong(), anyLong(), any(), anyBoolean(), any(), anyList()
        )).thenThrow(new IllegalStateException("database failed"));
        doThrow(new IllegalStateException("cleanup failed"))
                .when(entryMediaStorageService)
                .delete("entries/media/1/image/key.png");

        assertThatThrownBy(() -> service().create(
                1L,
                mediaRequest(),
                contentFile,
                null
        )).isInstanceOf(IllegalStateException.class).hasMessage("database failed");
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
                annoyanceMapper,
                userRepository,
                entryMediaStorageService,
                persistenceService
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
        return file("image.png", "image/png");
    }

    private MockMultipartFile file(String filename, String contentType) {
        return new MockMultipartFile("file", filename, contentType, new byte[]{1});
    }

    private AnnoyanceType category() {
        AnnoyanceType category = new AnnoyanceType("ACADEMIC", "課業", 1);
        ReflectionTestUtils.setField(category, "id", 2L);
        return category;
    }

    private Mood mood() {
        Mood mood = new Mood("SCORE_4", "4分", 4, null, 4);
        ReflectionTestUtils.setField(mood, "id", 3L);
        return mood;
    }

    private void prepareLookups(AnnoyanceType category, Mood mood) {
        when(userRepository.findByIdAndDeletedFalse(1L))
                .thenReturn(Optional.of(new User("account", "user@example.com", "User")));
        when(annoyanceTypeRepository.findByCode("ACADEMIC")).thenReturn(Optional.of(category));
        when(moodRepository.findByScore(4)).thenReturn(Optional.of(mood));
    }

    private StoredEntryMedia stored(String objectKey, String contentType) {
        return new StoredEntryMedia(objectKey, contentType, 1, (BigDecimal) null);
    }

    private CreateAnnoyanceRequest mediaRequest() {
        return new CreateAnnoyanceRequest(
                "ACADEMIC",
                AnnoyanceRecordMethod.IMAGE,
                null,
                4,
                false,
                OffsetDateTime.parse("2026-07-11T12:00:00+08:00")
        );
    }

    private AnnoyanceResponse response(Entry entry) {
        return new AnnoyanceResponse(
                entry.getId(),
                null,
                entry.getContent() == null ? AnnoyanceRecordMethod.IMAGE : AnnoyanceRecordMethod.TEXT,
                entry.getContent(),
                4,
                entry.isShared(),
                entry.isSolved(),
                entry.getOccurredAt().atZone(ZoneId.of("Asia/Taipei")).toOffsetDateTime(),
                new ArrayList<>(),
                null
        );
    }
}
