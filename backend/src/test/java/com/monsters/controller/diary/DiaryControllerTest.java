package com.monsters.controller.diary;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import com.monsters.dto.common.ApiResponse;
import com.monsters.dto.diary.CreateDiaryRequest;
import com.monsters.dto.diary.DiaryRecordMethod;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.service.diary.DiaryService;
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
        DiaryController controller = new DiaryController(service);

        assertThat(ReflectionTestUtils.getField(controller, "diaryService")).isSameAs(service);
    }

    @Test
    void createShouldReturnCreatedResponseForCurrentUser() {
        DiaryService service = org.mockito.Mockito.mock(DiaryService.class);
        DiaryController controller = new DiaryController(service);
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
}
