package com.monsters.controller.annoyance;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import com.monsters.dto.annoyance.AnnoyanceRecordMethod;
import com.monsters.dto.annoyance.AnnoyanceResponse;
import com.monsters.dto.annoyance.CreateAnnoyanceRequest;
import com.monsters.dto.common.ApiResponse;
import com.monsters.dto.common.PageResponse;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.service.annoyance.AnnoyanceService;
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
        AnnoyanceController controller = new AnnoyanceController(service);

        assertThat(ReflectionTestUtils.getField(controller, "annoyanceService")).isSameAs(service);
    }

    @Test
    void createShouldReturnCreatedResponseForCurrentUser() {
        AnnoyanceService service = org.mockito.Mockito.mock(AnnoyanceService.class);
        AnnoyanceController controller = new AnnoyanceController(service);
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
    void findAllShouldReturnPageForCurrentUser() {
        AnnoyanceService service = org.mockito.Mockito.mock(AnnoyanceService.class);
        AnnoyanceController controller = new AnnoyanceController(service);
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
        AnnoyanceController controller = new AnnoyanceController(service);
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
}
