package com.monsters.controller.annoyance;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.annoyance.AnnoyanceRecordMethod;
import com.monsters.dto.annoyance.AnnoyanceResponse;
import com.monsters.dto.annoyance.CreateAnnoyanceRequest;
import com.monsters.dto.annoyance.ShareAnnoyanceRequest;
import com.monsters.dto.annoyance.SolveAnnoyanceRequest;
import com.monsters.dto.annoyance.UpdateAnnoyanceRequest;
import com.monsters.dto.common.ApiResponse;
import com.monsters.dto.common.PageResponse;
import com.monsters.dto.entry.EntryDraftEnvelope;
import com.monsters.dto.entry.SaveEntryDraftRequest;
import com.monsters.entity.entry.EntryDraftStep;
import com.monsters.entity.entry.EntryType;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.service.annoyance.AnnoyanceService;
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

class AnnoyanceControllerTest {

    @Test
    void shouldProvideAnnoyanceApiControllerSkeleton() {
        assertThat(AnnoyanceController.class).hasAnnotation(RestController.class);
        assertThat(AnnoyanceController.class.getAnnotation(RequestMapping.class).value())
                .containsExactly("/api/annoyances");

        AnnoyanceService service = org.mockito.Mockito.mock(AnnoyanceService.class);
        AnnoyanceController controller = new AnnoyanceController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );

        assertThat(ReflectionTestUtils.getField(controller, "annoyanceService")).isSameAs(service);
    }

    @Test
    void createShouldReturnCreatedResponseForCurrentUser() {
        AnnoyanceService service = org.mockito.Mockito.mock(AnnoyanceService.class);
        AnnoyanceController controller = new AnnoyanceController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );
        CreateAnnoyanceRequest request = new CreateAnnoyanceRequest(
                "ACADEMIC",
                AnnoyanceRecordMethod.IMAGE,
                null,
                4,
                false,
                OffsetDateTime.parse("2026-07-11T12:00:00+08:00")
        );
        MockMultipartFile contentFile = new MockMultipartFile(
                "contentFile",
                "image.png",
                "image/png",
                new byte[]{1}
        );
        AnnoyanceResponse annoyance = new AnnoyanceResponse(
                10L,
                null,
                AnnoyanceRecordMethod.IMAGE,
                null,
                4,
                false,
                false,
                OffsetDateTime.parse("2026-07-11T12:00:00+08:00"),
                List.of(),
                null
        );
        when(service.create(1L, request, contentFile, null)).thenReturn(annoyance);

        ResponseEntity<ApiResponse<AnnoyanceResponse>> response = controller.create(
                new AuthenticatedUser(1L, "user@example.com"),
                request,
                contentFile,
                null
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().success()).isTrue();
        assertThat(response.getBody().message()).isEqualTo("Annoyance creation success");
        assertThat(response.getBody().data()).isSameAs(annoyance);
    }

    @Test
    void draftEndpointsShouldRestoreSaveDiscardAndSubmitForCurrentUser() {
        AnnoyanceService annoyanceService =
                org.mockito.Mockito.mock(AnnoyanceService.class);
        EntryDraftService draftService = org.mockito.Mockito.mock(EntryDraftService.class);
        AnnoyanceController controller = new AnnoyanceController(
                annoyanceService,
                draftService
        );
        AuthenticatedUser user = new AuthenticatedUser(1L, "user@example.com");
        EntryDraftEnvelope draft = new EntryDraftEnvelope(null);
        SaveEntryDraftRequest request = new SaveEntryDraftRequest(
                EntryDraftStep.INTRO,
                "ACADEMIC",
                null,
                null,
                null,
                null,
                null,
                null,
                null
        );
        AnnoyanceResponse annoyance = new AnnoyanceResponse(
                10L,
                null,
                AnnoyanceRecordMethod.TEXT,
                "content",
                4,
                false,
                false,
                OffsetDateTime.parse("2026-07-28T12:00:00+08:00"),
                List.of(),
                null
        );
        when(draftService.find(1L, EntryType.ANNOYANCE)).thenReturn(draft);
        when(draftService.save(1L, EntryType.ANNOYANCE, request, null, null))
                .thenReturn(draft);
        when(draftService.submitAnnoyance(1L)).thenReturn(annoyance);

        ResponseEntity<ApiResponse<EntryDraftEnvelope>> found =
                controller.findDraft(user);
        ResponseEntity<ApiResponse<EntryDraftEnvelope>> saved =
                controller.saveDraft(user, request, null, null);
        ResponseEntity<ApiResponse<Void>> discarded = controller.discardDraft(user);
        ResponseEntity<ApiResponse<AnnoyanceResponse>> submitted =
                controller.submitDraft(user);

        assertThat(found.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(found.getBody().data()).isSameAs(draft);
        assertThat(saved.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(saved.getBody().data()).isSameAs(draft);
        assertThat(discarded.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(submitted.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(submitted.getBody().data()).isSameAs(annoyance);
        verify(draftService).discard(1L, EntryType.ANNOYANCE);
    }

    @Test
    void findAllShouldReturnPageForCurrentUser() {
        AnnoyanceService service = org.mockito.Mockito.mock(AnnoyanceService.class);
        AnnoyanceController controller = new AnnoyanceController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );
        PageResponse<AnnoyanceResponse> page = new PageResponse<>(
                List.of(),
                0,
                20,
                0,
                0,
                true,
                true
        );
        when(service.findAll(1L, 0, 20, "occurredAt,desc", true, false)).thenReturn(page);

        ResponseEntity<ApiResponse<PageResponse<AnnoyanceResponse>>> response = controller.findAll(
                new AuthenticatedUser(1L, "user@example.com"),
                0,
                20,
                "occurredAt,desc",
                true,
                false
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().message()).isEqualTo("Annoyance query success");
        assertThat(response.getBody().data()).isSameAs(page);
    }

    @Test
    void findOneShouldReturnOwnerAnnoyance() {
        AnnoyanceService service = org.mockito.Mockito.mock(AnnoyanceService.class);
        AnnoyanceController controller = new AnnoyanceController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );
        AnnoyanceResponse annoyance = new AnnoyanceResponse(
                10L,
                null,
                AnnoyanceRecordMethod.TEXT,
                "content",
                4,
                false,
                false,
                OffsetDateTime.parse("2026-07-11T12:00:00+08:00"),
                List.of(),
                null
        );
        when(service.findOne(1L, 10L)).thenReturn(annoyance);

        ResponseEntity<ApiResponse<AnnoyanceResponse>> response = controller.findOne(
                new AuthenticatedUser(1L, "user@example.com"),
                10L
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().message()).isEqualTo("Annoyance query success");
        assertThat(response.getBody().data()).isSameAs(annoyance);
    }

    @Test
    void updateShouldReturnUpdatedAnnoyanceForCurrentUser() {
        AnnoyanceService service = org.mockito.Mockito.mock(AnnoyanceService.class);
        AnnoyanceController controller = new AnnoyanceController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );
        UpdateAnnoyanceRequest request = new UpdateAnnoyanceRequest(
                "ACADEMIC",
                AnnoyanceRecordMethod.TEXT,
                "updated",
                3,
                true,
                OffsetDateTime.parse("2026-07-12T12:00:00+08:00"),
                null,
                null
        );
        AnnoyanceResponse annoyance = new AnnoyanceResponse(
                10L,
                null,
                AnnoyanceRecordMethod.TEXT,
                "updated",
                3,
                true,
                false,
                OffsetDateTime.parse("2026-07-12T12:00:00+08:00"),
                List.of(),
                null
        );
        when(service.update(1L, 10L, request, null, null)).thenReturn(annoyance);

        ResponseEntity<ApiResponse<AnnoyanceResponse>> response = controller.update(
                new AuthenticatedUser(1L, "user@example.com"),
                10L,
                request,
                null,
                null
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().message()).isEqualTo("Annoyance update success");
        assertThat(response.getBody().data()).isSameAs(annoyance);
    }

    @Test
    void solveShouldReturnSolvedAnnoyanceForCurrentUser() {
        AnnoyanceService service = org.mockito.Mockito.mock(AnnoyanceService.class);
        AnnoyanceController controller = new AnnoyanceController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );
        SolveAnnoyanceRequest request = new SolveAnnoyanceRequest(true);
        AnnoyanceResponse annoyance = new AnnoyanceResponse(
                10L,
                null,
                AnnoyanceRecordMethod.TEXT,
                "content",
                4,
                false,
                true,
                OffsetDateTime.parse("2026-07-12T12:00:00+08:00"),
                List.of(),
                null
        );
        when(service.solve(1L, 10L, true)).thenReturn(annoyance);

        ResponseEntity<ApiResponse<AnnoyanceResponse>> response = controller.solve(
                new AuthenticatedUser(1L, "user@example.com"),
                10L,
                request
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().message()).isEqualTo("Annoyance solve success");
        assertThat(response.getBody().data()).isSameAs(annoyance);
    }

    @Test
    void updateSharingShouldReturnUpdatedAnnoyanceForCurrentUser() {
        AnnoyanceService service = org.mockito.Mockito.mock(AnnoyanceService.class);
        AnnoyanceController controller = new AnnoyanceController(
                service,
                org.mockito.Mockito.mock(EntryDraftService.class)
        );
        ShareAnnoyanceRequest request = new ShareAnnoyanceRequest(true);
        AnnoyanceResponse annoyance = new AnnoyanceResponse(
                10L,
                null,
                AnnoyanceRecordMethod.TEXT,
                "content",
                4,
                true,
                false,
                OffsetDateTime.parse("2026-07-12T12:00:00+08:00"),
                List.of(),
                null
        );
        when(service.updateSharing(1L, 10L, true)).thenReturn(annoyance);

        ResponseEntity<ApiResponse<AnnoyanceResponse>> response = controller.updateSharing(
                new AuthenticatedUser(1L, "user@example.com"),
                10L,
                request
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().message()).isEqualTo("Annoyance sharing update success");
        assertThat(response.getBody().data()).isSameAs(annoyance);
    }
}
