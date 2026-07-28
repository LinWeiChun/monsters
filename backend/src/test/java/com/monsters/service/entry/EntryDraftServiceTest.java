package com.monsters.service.entry;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.diary.DiaryResponse;
import com.monsters.dto.entry.EntryDraftEnvelope;
import com.monsters.dto.entry.SaveEntryDraftRequest;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryDraft;
import com.monsters.entity.entry.EntryDraftMedia;
import com.monsters.entity.entry.EntryDraftMediaRole;
import com.monsters.entity.entry.EntryDraftRecordMethod;
import com.monsters.entity.entry.EntryDraftStep;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.entity.entry.EntryType;
import com.monsters.entity.entry.Mood;
import com.monsters.entity.user.User;
import com.monsters.exception.common.ValidationException;
import com.monsters.mapper.annoyance.AnnoyanceMapper;
import com.monsters.mapper.diary.DiaryMapper;
import com.monsters.repository.annoyance.AnnoyanceTypeRepository;
import com.monsters.repository.entry.EntryDraftMediaRepository;
import com.monsters.repository.entry.EntryDraftRepository;
import com.monsters.repository.entry.MoodRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.storage.entry.EntryMediaStorageService;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Pageable;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class EntryDraftServiceTest {

    @Mock private EntryDraftRepository entryDraftRepository;
    @Mock private EntryDraftMediaRepository entryDraftMediaRepository;
    @Mock private AnnoyanceTypeRepository annoyanceTypeRepository;
    @Mock private MoodRepository moodRepository;
    @Mock private UserRepository userRepository;
    @Mock private EntryMediaStorageService entryMediaStorageService;
    @Mock private EntryDraftPersistenceService persistenceService;
    @Mock private EntryDraftDeletionService deletionService;
    @Mock private DiaryMapper diaryMapper;
    @Mock private AnnoyanceMapper annoyanceMapper;

    @Test
    void findShouldReturnNullEnvelopeWhenNoActiveDraftExists() {
        prepareUser();
        when(entryDraftRepository.findByUserIdAndEntryTypeAndExpiresAtAfter(
                eq(1L),
                eq(EntryType.DIARY),
                any(LocalDateTime.class)
        )).thenReturn(Optional.empty());

        EntryDraftEnvelope result = service().find(1L, EntryType.DIARY);

        assertThat(result.draft()).isNull();
    }

    @Test
    void saveTextDraftShouldPersistPartialStateWithThirtyDayExpiry() {
        prepareUser();
        EntryDraft draft = draft(EntryType.DIARY, EntryDraftStep.CONTENT);
        draft.update(
                EntryDraftStep.CONTENT,
                null,
                EntryDraftRecordMethod.TEXT,
                "draft content",
                null,
                null,
                null,
                LocalDateTime.now().plusDays(30)
        );
        when(persistenceService.save(
                eq(1L),
                eq(EntryType.DIARY),
                eq(EntryDraftStep.CONTENT),
                eq(null),
                eq(EntryDraftRecordMethod.TEXT),
                eq("draft content"),
                eq(null),
                eq(null),
                eq(null),
                any(LocalDateTime.class),
                eq(null),
                eq(null),
                anyList()
        )).thenReturn(new SavedEntryDraft(draft, List.of(), List.of()));
        SaveEntryDraftRequest request = new SaveEntryDraftRequest(
                EntryDraftStep.CONTENT,
                null,
                EntryDraftRecordMethod.TEXT,
                "draft content",
                null,
                null,
                null,
                null,
                null
        );

        EntryDraftEnvelope result = service().save(
                1L,
                EntryType.DIARY,
                request,
                null,
                null
        );

        assertThat(result.draft()).isNotNull();
        assertThat(result.draft().content()).isEqualTo("draft content");
        assertThat(result.draft().expiresAt())
                .isAfter(LocalDateTime.now().plusDays(29).atZone(
                        java.time.ZoneId.of("Asia/Taipei")
                ).toOffsetDateTime());
    }

    @Test
    void saveDiaryDraftShouldRejectAnnoyanceCategory() {
        prepareUser();
        SaveEntryDraftRequest request = new SaveEntryDraftRequest(
                EntryDraftStep.CONTENT,
                "ACADEMIC",
                EntryDraftRecordMethod.TEXT,
                "draft content",
                null,
                null,
                null,
                null,
                null
        );

        assertThatThrownBy(() -> service().save(
                1L,
                EntryType.DIARY,
                request,
                null,
                null
        )).isInstanceOf(ValidationException.class);
        verify(persistenceService, never()).save(
                anyLong(),
                any(),
                any(),
                any(),
                any(),
                any(),
                any(),
                any(),
                any(),
                any(),
                any(),
                any(),
                anyList()
        );
    }

    @Test
    void saveDiaryDraftShouldRejectAnnoyanceOnlyStep() {
        prepareUser();
        SaveEntryDraftRequest request = new SaveEntryDraftRequest(
                EntryDraftStep.CATEGORY,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null
        );

        assertThatThrownBy(() -> service().save(
                1L,
                EntryType.DIARY,
                request,
                null,
                null
        )).isInstanceOf(ValidationException.class);
    }

    @Test
    void submitDiaryShouldRequireCompletedDrawingDecision() {
        prepareUser();
        EntryDraft draft = draft(EntryType.DIARY, EntryDraftStep.REVIEW);
        draft.update(
                EntryDraftStep.REVIEW,
                null,
                EntryDraftRecordMethod.TEXT,
                "complete diary",
                null,
                4,
                false,
                LocalDateTime.now().plusDays(30)
        );
        when(entryDraftRepository.findActiveByUserIdAndEntryTypeForUpdate(
                eq(1L),
                eq(EntryType.DIARY),
                any(LocalDateTime.class)
        )).thenReturn(Optional.of(draft));
        when(entryDraftMediaRepository.findAllByEntryDraftIdOrderByMediaRoleAsc(
                draft.getId()
        )).thenReturn(List.of());

        assertThatThrownBy(() -> service().submitDiary(1L))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Drawing choice is required");
        verify(persistenceService, never()).submit(
                anyLong(),
                any(),
                any(),
                any(),
                any(),
                anyBoolean(),
                any(LocalDateTime.class)
        );
    }

    @Test
    void discardShouldDelegateOwnerScopedDeletion() {
        prepareUser();

        service().discard(1L, EntryType.DIARY);

        verify(deletionService).discard(1L, EntryType.DIARY);
    }

    @Test
    void submitDiaryShouldPromoteCompleteDraftAndReturnExistingContract() {
        prepareUser();
        EntryDraft draft = draft(EntryType.DIARY, EntryDraftStep.REVIEW);
        draft.update(
                EntryDraftStep.REVIEW,
                null,
                EntryDraftRecordMethod.TEXT,
                "complete diary",
                false,
                4,
                false,
                LocalDateTime.now().plusDays(30)
        );
        Mood mood = new Mood("SCORE_4", "4分", 4, null, 4);
        ReflectionTestUtils.setField(mood, "id", 4L);
        Entry entry = Entry.diary(
                1L,
                4L,
                "complete diary",
                false,
                LocalDateTime.now()
        );
        ReflectionTestUtils.setField(entry, "id", 301L);
        DiaryResponse expected = new DiaryResponse(
                301L,
                com.monsters.dto.diary.DiaryRecordMethod.TEXT,
                "complete diary",
                4,
                false,
                java.time.OffsetDateTime.now(),
                List.of(),
                null
        );
        when(entryDraftRepository.findActiveByUserIdAndEntryTypeForUpdate(
                eq(1L),
                eq(EntryType.DIARY),
                any(LocalDateTime.class)
        )).thenReturn(Optional.of(draft));
        when(entryDraftMediaRepository.findAllByEntryDraftIdOrderByMediaRoleAsc(
                draft.getId()
        )).thenReturn(List.of());
        when(moodRepository.findByScore(4)).thenReturn(Optional.of(mood));
        when(persistenceService.submit(
                eq(1L),
                eq(EntryType.DIARY),
                eq(null),
                eq(4L),
                eq("complete diary"),
                eq(false),
                any(LocalDateTime.class)
        )).thenReturn(new SubmittedEntry(entry, List.of()));
        when(diaryMapper.toResponse(entry, mood, List.of())).thenReturn(expected);

        DiaryResponse actual = service().submitDiary(1L);

        assertThat(actual).isSameAs(expected);
    }

    @Test
    void cleanupExpiredShouldAdvanceCursorAfterEachBatch() {
        EntryDraft expired = draft(EntryType.DIARY, EntryDraftStep.CONTENT);
        LocalDateTime expiresAt = LocalDateTime.now().minusDays(1);
        expired.update(
                EntryDraftStep.CONTENT,
                null,
                null,
                null,
                null,
                null,
                null,
                expiresAt
        );
        when(entryDraftRepository
                .findTop100ByExpiresAtLessThanEqualOrderByExpiresAtAscIdAsc(
                        any(LocalDateTime.class)
                )).thenReturn(List.of(expired));
        when(entryDraftRepository.findExpiredAfter(
                any(LocalDateTime.class),
                eq(expiresAt),
                eq(expired.getId()),
                any(Pageable.class)
        )).thenReturn(List.of());

        service().cleanupExpired();

        verify(deletionService).discardExpired(
                eq(expired.getId()),
                any(LocalDateTime.class)
        );
        verify(entryDraftRepository).findExpiredAfter(
                any(LocalDateTime.class),
                eq(expiresAt),
                eq(expired.getId()),
                any(Pageable.class)
        );
    }

    private EntryDraftService service() {
        return new EntryDraftService(
                entryDraftRepository,
                entryDraftMediaRepository,
                annoyanceTypeRepository,
                moodRepository,
                userRepository,
                entryMediaStorageService,
                persistenceService,
                deletionService,
                diaryMapper,
                annoyanceMapper,
                30
        );
    }

    private void prepareUser() {
        when(userRepository.findByIdAndDeletedFalse(1L))
                .thenReturn(Optional.of(new User("user", "user@example.com", "User")));
    }

    private EntryDraft draft(EntryType entryType, EntryDraftStep step) {
        EntryDraft draft = new EntryDraft(1L, entryType);
        ReflectionTestUtils.setField(draft, "id", 501L);
        draft.update(
                step,
                null,
                null,
                null,
                null,
                null,
                null,
                LocalDateTime.now().plusDays(30)
        );
        return draft;
    }
}
