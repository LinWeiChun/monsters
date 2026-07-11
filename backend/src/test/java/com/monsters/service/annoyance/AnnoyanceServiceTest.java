package com.monsters.service.annoyance;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.annoyance.AnnoyanceRecordMethod;
import com.monsters.dto.annoyance.AnnoyanceResponse;
import com.monsters.dto.annoyance.CreateAnnoyanceRequest;
import com.monsters.dto.annoyance.UpdateAnnoyanceRequest;
import com.monsters.dto.common.PageResponse;
import com.monsters.entity.annoyance.AnnoyanceType;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.entity.entry.EntryType;
import com.monsters.entity.entry.Mood;
import com.monsters.entity.user.User;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.common.ValidationException;
import com.monsters.mapper.annoyance.AnnoyanceMapper;
import com.monsters.repository.annoyance.AnnoyanceTypeRepository;
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
import java.util.ArrayList;
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
    void findAllShouldApplyOwnerFiltersSortAndBatchMap() {
        prepareUser();
        Entry first = entry(10L, "first");
        Entry second = entry(11L, "second");
        AnnoyanceType category = category();
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
        AnnoyanceResponse firstResponse = response(first);
        AnnoyanceResponse secondResponse = response(second);
        PageRequest pageable = PageRequest.of(2, 2);
        when(entryRepository.findAnnoyancePage(
                1L,
                EntryType.ANNOYANCE,
                true,
                false,
                "score",
                "asc",
                pageable
        )).thenReturn(new PageImpl<>(List.of(first, second), pageable, 6));
        when(annoyanceTypeRepository.findAllById(any())).thenReturn(List.of(category));
        when(moodRepository.findAllById(any())).thenReturn(List.of(mood));
        when(entryMediaRepository.findAllByEntryIdInAndDeletedFalseOrderByEntryIdAscDisplayOrderAsc(
                List.of(10L, 11L)
        )).thenReturn(List.of(drawing));
        when(annoyanceMapper.toResponse(first, category, mood, List.of(drawing)))
                .thenReturn(firstResponse);
        when(annoyanceMapper.toResponse(second, category, mood, List.of()))
                .thenReturn(secondResponse);

        PageResponse<AnnoyanceResponse> result = service().findAll(
                1L,
                2,
                2,
                "score,ASC",
                true,
                false
        );

        assertThat(result.content()).containsExactly(firstResponse, secondResponse);
        assertThat(result.page()).isEqualTo(2);
        assertThat(result.size()).isEqualTo(2);
        assertThat(result.totalElements()).isEqualTo(6);
        assertThat(result.totalPages()).isEqualTo(3);
        assertThat(result.first()).isFalse();
        assertThat(result.last()).isTrue();
        verify(entryRepository).findAnnoyancePage(
                1L,
                EntryType.ANNOYANCE,
                true,
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
        when(entryRepository.findAnnoyancePage(
                1L,
                EntryType.ANNOYANCE,
                null,
                null,
                "occurredAt",
                "desc",
                pageable
        )).thenReturn(new PageImpl<>(List.of(), pageable, 0));

        PageResponse<AnnoyanceResponse> result = service().findAll(1L, 0, 20, " ", null, null);

        assertThat(result.content()).isEmpty();
        assertThat(result.totalElements()).isZero();
        assertThat(result.totalPages()).isZero();
        assertThat(result.first()).isTrue();
        assertThat(result.last()).isTrue();
        verify(annoyanceTypeRepository, never()).findAllById(any());
        verify(moodRepository, never()).findAllById(any());
        verify(entryMediaRepository, never())
                .findAllByEntryIdInAndDeletedFalseOrderByEntryIdAscDisplayOrderAsc(anyList());
    }

    @Test
    void findAllShouldRejectInvalidPaginationAndSort() {
        prepareUser();
        AnnoyanceService service = service();

        assertThatThrownBy(() -> service.findAll(1L, -1, 20, null, null, null))
                .isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.findAll(1L, 0, 0, null, null, null))
                .isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.findAll(1L, 0, 101, null, null, null))
                .isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.findAll(1L, 0, 20, "id,asc", null, null))
                .isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.findAll(1L, 0, 20, "score,sideways", null, null))
                .isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.findAll(1L, 0, 20, "score,asc,extra", null, null))
                .isInstanceOf(ValidationException.class);
        verify(entryRepository, never()).findAnnoyancePage(
                anyLong(), any(), any(), any(), anyString(), anyString(), any()
        );
    }

    @Test
    void findOneShouldReturnOwnerResponse() {
        prepareUser();
        Entry entry = entry();
        AnnoyanceType category = category();
        Mood mood = mood();
        AnnoyanceResponse expected = response(entry);
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.ANNOYANCE
        )).thenReturn(Optional.of(entry));
        when(annoyanceTypeRepository.findById(2L)).thenReturn(Optional.of(category));
        when(moodRepository.findById(3L)).thenReturn(Optional.of(mood));
        when(entryMediaRepository.findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(10L))
                .thenReturn(List.of());
        when(annoyanceMapper.toResponse(entry, category, mood, List.of())).thenReturn(expected);

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
    void updateShouldReplacePrimaryMediaAndRetainDrawing() {
        Entry entry = entry(10L, null);
        EntryMedia oldImage = media(21L, EntryMediaType.IMAGE, "old-image.png", 0);
        EntryMedia drawing = media(22L, EntryMediaType.DRAWING, "drawing.webp", 1);
        EntryMedia newImage = media(23L, EntryMediaType.IMAGE, "new-image.png", 0);
        List<EntryMedia> activeMedia = List.of(oldImage, drawing);
        MockMultipartFile contentFile = file("new-image.png", "image/png");
        StoredEntryMedia storedImage = stored("new-image.png", "image/png");
        UpdateAnnoyanceRequest request = updateRequest(
                AnnoyanceRecordMethod.IMAGE,
                null,
                true,
                null,
                22L
        );
        AnnoyanceResponse expected = response(entry);
        prepareUpdateLookups(entry, activeMedia);
        when(entryMediaStorageService.upload(1L, EntryMediaType.IMAGE, contentFile))
                .thenReturn(storedImage);
        when(persistenceService.update(
                eq(entry),
                eq(2L),
                eq(3L),
                org.mockito.ArgumentMatchers.isNull(),
                eq(true),
                eq(LocalDateTime.of(2026, 7, 12, 12, 0)),
                eq(activeMedia),
                eq(Set.of(22L)),
                anyList()
        )).thenReturn(new UpdatedAnnoyance(
                entry,
                List.of(newImage, drawing),
                List.of("old-image.png")
        ));
        when(annoyanceMapper.toResponse(
                eq(entry),
                any(AnnoyanceType.class),
                any(Mood.class),
                eq(List.of(newImage, drawing))
        ))
                .thenReturn(expected);

        AnnoyanceResponse actual = service().update(1L, 10L, request, contentFile, null);

        assertThat(actual).isSameAs(expected);
        verify(persistenceService).update(
                entry,
                2L,
                3L,
                null,
                true,
                LocalDateTime.of(2026, 7, 12, 12, 0),
                activeMedia,
                Set.of(22L),
                List.of(new NewEntryMedia(EntryMediaType.IMAGE, storedImage, 0))
        );
        verify(entryMediaStorageService).delete("old-image.png");
        verify(entryMediaStorageService, never()).delete("drawing.webp");
    }

    @Test
    void updateShouldConvertMediaToTextAndRemoveAllOldMedia() {
        Entry entry = entry(10L, null);
        EntryMedia image = media(21L, EntryMediaType.IMAGE, "old-image.png", 0);
        EntryMedia drawing = media(22L, EntryMediaType.DRAWING, "drawing.webp", 1);
        List<EntryMedia> activeMedia = List.of(image, drawing);
        UpdateAnnoyanceRequest request = updateRequest(
                AnnoyanceRecordMethod.TEXT,
                "  updated content  ",
                false,
                null,
                null
        );
        AnnoyanceResponse expected = response(entry);
        prepareUpdateLookups(entry, activeMedia);
        when(persistenceService.update(
                entry,
                2L,
                3L,
                "updated content",
                false,
                LocalDateTime.of(2026, 7, 12, 12, 0),
                activeMedia,
                Set.of(),
                List.of()
        )).thenReturn(new UpdatedAnnoyance(
                entry,
                List.of(),
                List.of("old-image.png", "drawing.webp")
        ));
        when(annoyanceMapper.toResponse(
                eq(entry),
                any(AnnoyanceType.class),
                any(Mood.class),
                eq(List.of())
        ))
                .thenReturn(expected);

        assertThat(service().update(1L, 10L, request, null, null)).isSameAs(expected);

        verify(entryMediaStorageService, never()).upload(anyLong(), any(), any());
        verify(entryMediaStorageService).delete("old-image.png");
        verify(entryMediaStorageService).delete("drawing.webp");
    }

    @Test
    void updateShouldKeepExistingContentAndDrawingWithoutStorageChanges() {
        Entry entry = entry(10L, null);
        EntryMedia image = media(21L, EntryMediaType.IMAGE, "image.png", 0);
        EntryMedia drawing = media(22L, EntryMediaType.DRAWING, "drawing.webp", 1);
        List<EntryMedia> activeMedia = List.of(image, drawing);
        UpdateAnnoyanceRequest request = updateRequest(
                AnnoyanceRecordMethod.IMAGE,
                null,
                false,
                21L,
                22L
        );
        AnnoyanceResponse expected = response(entry);
        prepareUpdateLookups(entry, activeMedia);
        when(persistenceService.update(
                entry,
                2L,
                3L,
                null,
                false,
                LocalDateTime.of(2026, 7, 12, 12, 0),
                activeMedia,
                Set.of(21L, 22L),
                List.of()
        )).thenReturn(new UpdatedAnnoyance(entry, activeMedia, List.of()));
        when(annoyanceMapper.toResponse(
                eq(entry),
                any(AnnoyanceType.class),
                any(Mood.class),
                eq(activeMedia)
        ))
                .thenReturn(expected);

        assertThat(service().update(1L, 10L, request, null, null)).isSameAs(expected);

        verify(entryMediaStorageService, never()).upload(anyLong(), any(), any());
        verify(entryMediaStorageService, never()).delete(anyString());
    }

    @Test
    void updateShouldRejectInvalidMediaCombinationsBeforeOwnerLookup() {
        AnnoyanceService service = service();

        assertThatThrownBy(() -> service.update(
                1L,
                10L,
                updateRequest(AnnoyanceRecordMethod.TEXT, "content", false, 21L, null),
                null,
                null
        )).isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.update(
                1L,
                10L,
                updateRequest(AnnoyanceRecordMethod.IMAGE, null, false, null, null),
                null,
                null
        )).isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.update(
                1L,
                10L,
                updateRequest(AnnoyanceRecordMethod.IMAGE, null, false, 21L, null),
                file(),
                null
        )).isInstanceOf(ValidationException.class);
        assertThatThrownBy(() -> service.update(
                1L,
                10L,
                updateRequest(AnnoyanceRecordMethod.IMAGE, null, false, 21L, 22L),
                null,
                file("drawing.webp", "image/webp")
        )).isInstanceOf(ValidationException.class);

        verify(userRepository, never()).findByIdAndDeletedFalse(anyLong());
        verify(persistenceService, never()).update(
                any(), anyLong(), anyLong(), any(), anyBoolean(), any(), anyList(), any(), anyList()
        );
    }

    @Test
    void updateShouldRejectExistingMediaWithWrongType() {
        Entry entry = entry(10L, null);
        EntryMedia image = media(21L, EntryMediaType.IMAGE, "image.png", 0);
        prepareUpdateLookups(entry, List.of(image));
        UpdateAnnoyanceRequest request = updateRequest(
                AnnoyanceRecordMethod.AUDIO,
                null,
                false,
                21L,
                null
        );

        assertThatThrownBy(() -> service().update(1L, 10L, request, null, null))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Existing content media is invalid");

        verify(entryMediaStorageService, never()).upload(anyLong(), any(), any());
        verify(persistenceService, never()).update(
                any(), anyLong(), anyLong(), any(), anyBoolean(), any(), anyList(), any(), anyList()
        );
    }

    @Test
    void updateShouldCleanNewUploadsWhenDatabaseTransactionFails() {
        Entry entry = entry(10L, null);
        EntryMedia oldImage = media(21L, EntryMediaType.IMAGE, "old-image.png", 0);
        MockMultipartFile contentFile = file("new-image.png", "image/png");
        StoredEntryMedia storedImage = stored("new-image.png", "image/png");
        prepareUpdateLookups(entry, List.of(oldImage));
        when(entryMediaStorageService.upload(1L, EntryMediaType.IMAGE, contentFile))
                .thenReturn(storedImage);
        when(persistenceService.update(
                any(), anyLong(), anyLong(), any(), anyBoolean(), any(), anyList(), any(), anyList()
        )).thenThrow(new IllegalStateException("database failed"));

        assertThatThrownBy(() -> service().update(
                1L,
                10L,
                updateRequest(AnnoyanceRecordMethod.IMAGE, null, false, null, null),
                contentFile,
                null
        )).isInstanceOf(IllegalStateException.class).hasMessage("database failed");

        verify(entryMediaStorageService).delete("new-image.png");
        verify(entryMediaStorageService, never()).delete("old-image.png");
    }

    @Test
    void updateShouldPreserveSuccessWhenOldObjectCleanupFails() {
        Entry entry = entry(10L, "old");
        UpdateAnnoyanceRequest request = updateRequest(
                AnnoyanceRecordMethod.TEXT,
                "updated",
                false,
                null,
                null
        );
        AnnoyanceResponse expected = response(entry);
        prepareUpdateLookups(entry, List.of());
        when(persistenceService.update(
                entry,
                2L,
                3L,
                "updated",
                false,
                LocalDateTime.of(2026, 7, 12, 12, 0),
                List.of(),
                Set.of(),
                List.of()
        )).thenReturn(new UpdatedAnnoyance(entry, List.of(), List.of("stale-object")));
        when(annoyanceMapper.toResponse(
                eq(entry),
                any(AnnoyanceType.class),
                any(Mood.class),
                eq(List.of())
        )).thenReturn(expected);
        doThrow(new IllegalStateException("R2 unavailable"))
                .when(entryMediaStorageService)
                .delete("stale-object");

        assertThat(service().update(1L, 10L, request, null, null)).isSameAs(expected);

        verify(entryMediaStorageService).delete("stale-object");
    }

    @Test
    void updateShouldRejectOwnershipMismatchBeforeUploading() {
        prepareUser();
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.ANNOYANCE
        )).thenReturn(Optional.empty());
        MockMultipartFile contentFile = file();

        assertThatThrownBy(() -> service().update(
                1L,
                10L,
                updateRequest(AnnoyanceRecordMethod.IMAGE, null, false, null, null),
                contentFile,
                null
        )).isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Annoyance not found");

        verify(entryMediaStorageService, never()).upload(anyLong(), any(), any());
        verify(persistenceService, never()).update(
                any(), anyLong(), anyLong(), any(), anyBoolean(), any(), anyList(), any(), anyList()
        );
    }

    @Test
    void solveShouldTransitionOwnedAnnoyanceToSolved() {
        Entry entry = entry();
        AnnoyanceType category = category();
        Mood mood = mood();
        AnnoyanceResponse expected = response(entry);
        prepareUser();
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.ANNOYANCE
        )).thenReturn(Optional.of(entry));
        when(entryRepository.saveAndFlush(entry)).thenReturn(entry);
        when(annoyanceTypeRepository.findById(2L)).thenReturn(Optional.of(category));
        when(moodRepository.findById(3L)).thenReturn(Optional.of(mood));
        when(entryMediaRepository.findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(10L))
                .thenReturn(List.of());
        when(annoyanceMapper.toResponse(entry, category, mood, List.of())).thenReturn(expected);

        assertThat(service().solve(1L, 10L, true)).isSameAs(expected);

        assertThat(entry.isSolved()).isTrue();
        verify(entryRepository).saveAndFlush(entry);
    }

    @Test
    void solveShouldBeIdempotentWhenAlreadySolved() {
        Entry entry = entry();
        entry.solve();
        AnnoyanceType category = category();
        Mood mood = mood();
        AnnoyanceResponse expected = response(entry);
        prepareUser();
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.ANNOYANCE
        )).thenReturn(Optional.of(entry));
        when(annoyanceTypeRepository.findById(2L)).thenReturn(Optional.of(category));
        when(moodRepository.findById(3L)).thenReturn(Optional.of(mood));
        when(entryMediaRepository.findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(10L))
                .thenReturn(List.of());
        when(annoyanceMapper.toResponse(entry, category, mood, List.of())).thenReturn(expected);

        assertThat(service().solve(1L, 10L, true)).isSameAs(expected);

        verify(entryRepository, never()).saveAndFlush(any());
    }

    @Test
    void solveShouldRejectFalseBeforeOwnerLookup() {
        assertThatThrownBy(() -> service().solve(1L, 10L, false))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Solved state must be true");
        assertThatThrownBy(() -> service().solve(1L, 10L, null))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Solved state must be true");

        verify(userRepository, never()).findByIdAndDeletedFalse(anyLong());
        verify(entryRepository, never()).findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                anyLong(), anyLong(), any()
        );
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
        return entry(10L, "content");
    }

    private Entry entry(Long id, String content) {
        Entry entry = Entry.annoyance(
                1L,
                2L,
                3L,
                content,
                false,
                LocalDateTime.of(2026, 7, 11, 12, 0)
        );
        ReflectionTestUtils.setField(entry, "id", id);
        return entry;
    }

    private EntryMedia media(
            Long id,
            EntryMediaType mediaType,
            String objectKey,
            int displayOrder
    ) {
        EntryMedia media = new EntryMedia(
                10L,
                mediaType,
                objectKey,
                mediaType == EntryMediaType.DRAWING ? "image/webp" : "image/png",
                1,
                null,
                displayOrder
        );
        ReflectionTestUtils.setField(media, "id", id);
        return media;
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
        prepareUser();
        when(annoyanceTypeRepository.findByCode("ACADEMIC")).thenReturn(Optional.of(category));
        when(moodRepository.findByScore(4)).thenReturn(Optional.of(mood));
    }

    private void prepareUser() {
        when(userRepository.findByIdAndDeletedFalse(1L))
                .thenReturn(Optional.of(new User("account", "user@example.com", "User")));
    }

    private void prepareUpdateLookups(Entry entry, List<EntryMedia> activeMedia) {
        prepareLookups(category(), mood());
        when(entryRepository.findByIdAndUserIdAndEntryTypeAndDeletedFalse(
                10L,
                1L,
                EntryType.ANNOYANCE
        )).thenReturn(Optional.of(entry));
        when(entryMediaRepository.findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(10L))
                .thenReturn(activeMedia);
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

    private UpdateAnnoyanceRequest updateRequest(
            AnnoyanceRecordMethod recordMethod,
            String content,
            boolean shared,
            Long existingContentMediaId,
            Long existingDrawingMediaId
    ) {
        return new UpdateAnnoyanceRequest(
                "ACADEMIC",
                recordMethod,
                content,
                4,
                shared,
                OffsetDateTime.parse("2026-07-12T12:00:00+08:00"),
                existingContentMediaId,
                existingDrawingMediaId
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
