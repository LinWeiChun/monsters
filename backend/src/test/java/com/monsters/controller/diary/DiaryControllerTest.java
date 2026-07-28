package com.monsters.controller.diary;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.common.ApiResponse;
import com.monsters.dto.common.PageResponse;
import com.monsters.dto.diary.CreateDiaryRequest;
import com.monsters.dto.diary.DiaryRecordMethod;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.dto.diary.ShareDiaryRequest;
import com.monsters.dto.diary.UpdateDiaryRequest;
import com.monsters.dto.entry.EntryDraftEnvelope;
import com.monsters.dto.entry.SaveEntryDraftRequest;
import com.monsters.entity.entry.EntryDraftStep;
import com.monsters.entity.entry.EntryType;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.service.diary.DiaryService;
import com.monsters.service.entry.EntryDraftService;
import java.time.OffsetDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

class DiaryControllerTest {

    @Test
    void shouldProvideDiaryApiControllerSkeleton() {
        assertThat(DiaryController.class).hasAnnotation(RestController.class);
        assertThat(DiaryController.class.getAnnotation(RequestMapping.class).value())
                .containsExactly("/api/diaries");

        DiaryService service = org.mockito.Mockito.mock(DiaryService.class);
        DiaryController controller = new DiaryController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );

        assertThat(ReflectionTestUtils.getField(controller, "diaryService")).isSameAs(service);
    }

    @Test
    void createShouldReturnCreatedResponseForCurrentUser() {
        DiaryService service = org.mockito.Mockito.mock(DiaryService.class);
        DiaryController controller = new DiaryController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );
        CreateDiaryRequest request = new CreateDiaryRequest(
                DiaryRecordMethod.IMAGE,
                null,
                4,
                false,
                OffsetDateTime.parse("2026-07-19T12:00:00+08:00")
        );
        MockMultipartFile contentFile = new MockMultipartFile(
                "contentFile",
                "image.png",
                "image/png",
                new byte[]{1}
        );
        DiaryResponse diary = new DiaryResponse(
                10L,
                DiaryRecordMethod.IMAGE,
                null,
                4,
                false,
                OffsetDateTime.parse("2026-07-19T12:00:00+08:00"),
                List.of(),
                null
        );
        when(service.create(1L, request, contentFile, null)).thenReturn(diary);

        ResponseEntity<ApiResponse<DiaryResponse>> response = controller.create(
                new AuthenticatedUser(1L, "user@example.com"),
                request,
                contentFile,
                null
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().success()).isTrue();
        assertThat(response.getBody().message()).isEqualTo("Diary creation success");
        assertThat(response.getBody().data()).isSameAs(diary);
    }

    @Test
    void draftEndpointsShouldRestoreSaveDiscardAndSubmitForCurrentUser() {
        DiaryService diaryService = org.mockito.Mockito.mock(DiaryService.class);
        EntryDraftService draftService = org.mockito.Mockito.mock(EntryDraftService.class);
        DiaryController controller = new DiaryController(diaryService, draftService);
        AuthenticatedUser user = new AuthenticatedUser(1L, "user@example.com");
        EntryDraftEnvelope draft = new EntryDraftEnvelope(null);
        SaveEntryDraftRequest request = new SaveEntryDraftRequest(
                EntryDraftStep.INTRO,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null
        );
        DiaryResponse diary = new DiaryResponse(
                10L,
                DiaryRecordMethod.TEXT,
                "content",
                4,
                false,
                OffsetDateTime.parse("2026-07-28T12:00:00+08:00"),
                List.of(),
                null
        );
        when(draftService.find(1L, EntryType.DIARY)).thenReturn(draft);
        when(draftService.save(1L, EntryType.DIARY, request, null, null))
                .thenReturn(draft);
        when(draftService.submitDiary(1L)).thenReturn(diary);

        ResponseEntity<ApiResponse<EntryDraftEnvelope>> found =
                controller.findDraft(user);
        ResponseEntity<ApiResponse<EntryDraftEnvelope>> saved =
                controller.saveDraft(user, request, null, null);
        ResponseEntity<ApiResponse<Void>> discarded = controller.discardDraft(user);
        ResponseEntity<ApiResponse<DiaryResponse>> submitted =
                controller.submitDraft(user);

        assertThat(found.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(found.getBody().data()).isSameAs(draft);
        assertThat(saved.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(saved.getBody().data()).isSameAs(draft);
        assertThat(discarded.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(submitted.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(submitted.getBody().data()).isSameAs(diary);
        verify(draftService).discard(1L, EntryType.DIARY);
    }

    @Test
    void findAllShouldReturnPageForCurrentUser() {
        DiaryService service = org.mockito.Mockito.mock(DiaryService.class);
        DiaryController controller = new DiaryController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );
        PageResponse<DiaryResponse> page = new PageResponse<>(
                List.of(),
                0,
                20,
                0,
                0,
                true,
                true
        );
        when(service.findAll(1L, 0, 20, "occurredAt,desc", false)).thenReturn(page);

        ResponseEntity<ApiResponse<PageResponse<DiaryResponse>>> response = controller.findAll(
                new AuthenticatedUser(1L, "user@example.com"),
                0,
                20,
                "occurredAt,desc",
                false
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().message()).isEqualTo("Diary query success");
        assertThat(response.getBody().data()).isSameAs(page);
    }

    @Test
    void findOneShouldReturnOwnerDiary() {
        DiaryService service = org.mockito.Mockito.mock(DiaryService.class);
        DiaryController controller = new DiaryController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );
        DiaryResponse diary = new DiaryResponse(
                10L,
                DiaryRecordMethod.TEXT,
                "content",
                4,
                false,
                OffsetDateTime.parse("2026-07-19T12:00:00+08:00"),
                List.of(),
                null
        );
        when(service.findOne(1L, 10L)).thenReturn(diary);

        ResponseEntity<ApiResponse<DiaryResponse>> response = controller.findOne(
                new AuthenticatedUser(1L, "user@example.com"),
                10L
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().message()).isEqualTo("Diary query success");
        assertThat(response.getBody().data()).isSameAs(diary);
    }

    @Test
    void updateShouldReturnUpdatedDiaryForCurrentUser() {
        DiaryService service = org.mockito.Mockito.mock(DiaryService.class);
        DiaryController controller = new DiaryController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );
        UpdateDiaryRequest request = new UpdateDiaryRequest(
                DiaryRecordMethod.TEXT,
                "updated content",
                4,
                true,
                OffsetDateTime.parse("2026-07-22T12:00:00+08:00"),
                null,
                null
        );
        DiaryResponse diary = new DiaryResponse(
                10L,
                DiaryRecordMethod.TEXT,
                "updated content",
                4,
                true,
                OffsetDateTime.parse("2026-07-22T12:00:00+08:00"),
                List.of(),
                null
        );
        when(service.update(1L, 10L, request, null, null)).thenReturn(diary);

        ResponseEntity<ApiResponse<DiaryResponse>> response = controller.update(
                new AuthenticatedUser(1L, "user@example.com"),
                10L,
                request,
                null,
                null
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().success()).isTrue();
        assertThat(response.getBody().message()).isEqualTo("Diary update success");
        assertThat(response.getBody().data()).isSameAs(diary);
    }

    @Test
    void updateSharingShouldReturnUpdatedDiaryForCurrentUser() {
        DiaryService service = org.mockito.Mockito.mock(DiaryService.class);
        DiaryController controller = new DiaryController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );
        ShareDiaryRequest request = new ShareDiaryRequest(true);
        DiaryResponse diary = new DiaryResponse(
                10L,
                DiaryRecordMethod.TEXT,
                "content",
                4,
                true,
                OffsetDateTime.parse("2026-07-22T12:00:00+08:00"),
                List.of(),
                null
        );
        when(service.updateSharing(1L, 10L, true)).thenReturn(diary);

        ResponseEntity<ApiResponse<DiaryResponse>> response = controller.updateSharing(
                new AuthenticatedUser(1L, "user@example.com"),
                10L,
                request
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().success()).isTrue();
        assertThat(response.getBody().message()).isEqualTo("Diary sharing update success");
        assertThat(response.getBody().data()).isSameAs(diary);
    }
}
