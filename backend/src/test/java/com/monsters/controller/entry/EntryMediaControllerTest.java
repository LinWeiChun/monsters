package com.monsters.controller.entry;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.entity.entry.EntryType;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.service.entry.EntryMediaDownloadResult;
import com.monsters.service.entry.EntryMediaDownloadService;
import java.io.ByteArrayInputStream;
import java.lang.reflect.Method;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

class EntryMediaControllerTest {

    @Test
    void shouldExposeAnnoyanceAndDiaryMediaRoutes() throws NoSuchMethodException {
        assertThat(EntryMediaController.class.getAnnotation(RequestMapping.class).value())
                .containsExactly("/api");

        Method annoyanceMethod = EntryMediaController.class.getMethod(
                "downloadAnnoyanceMedia",
                AuthenticatedUser.class,
                Long.class,
                Long.class,
                String.class
        );
        Method diaryMethod = EntryMediaController.class.getMethod(
                "downloadDiaryMedia",
                AuthenticatedUser.class,
                Long.class,
                Long.class,
                String.class
        );

        assertThat(annoyanceMethod.getAnnotation(GetMapping.class).value())
                .containsExactly("/annoyances/{id}/media/{mediaId}");
        assertThat(diaryMethod.getAnnotation(GetMapping.class).value())
                .containsExactly("/diaries/{id}/media/{mediaId}");
    }

    @Test
    void annoyanceFullDownloadShouldReturnOkAndStreamingHeaders() throws Exception {
        EntryMediaDownloadService service = org.mockito.Mockito.mock(
                EntryMediaDownloadService.class
        );
        EntryMediaController controller = new EntryMediaController(service);
        EntryMediaDownloadResult download = download(3, null);
        when(service.download(1L, EntryType.ANNOYANCE, 10L, 20L, null))
                .thenReturn(download);

        ResponseEntity<InputStreamResource> response = controller.downloadAnnoyanceMedia(
                new AuthenticatedUser(1L, "user@example.com"),
                10L,
                20L,
                null
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getHeaders().getFirst(HttpHeaders.CONTENT_TYPE))
                .isEqualTo("video/mp4");
        assertThat(response.getHeaders().getContentLength()).isEqualTo(3);
        assertThat(response.getHeaders().getFirst(HttpHeaders.ACCEPT_RANGES)).isEqualTo("bytes");
        assertThat(response.getHeaders().containsKey(HttpHeaders.CONTENT_RANGE)).isFalse();
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getInputStream().readAllBytes()).containsExactly(1, 2, 3);
        verify(service).download(1L, EntryType.ANNOYANCE, 10L, 20L, null);
    }

    @Test
    void diaryRangeDownloadShouldReturnPartialContentHeaders() {
        EntryMediaDownloadService service = org.mockito.Mockito.mock(
                EntryMediaDownloadService.class
        );
        EntryMediaController controller = new EntryMediaController(service);
        EntryMediaDownloadResult download = download(2, "bytes 0-1/3");
        when(service.download(1L, EntryType.DIARY, 10L, 20L, "bytes=0-1"))
                .thenReturn(download);

        ResponseEntity<InputStreamResource> response = controller.downloadDiaryMedia(
                new AuthenticatedUser(1L, "user@example.com"),
                10L,
                20L,
                "bytes=0-1"
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.PARTIAL_CONTENT);
        assertThat(response.getHeaders().getContentLength()).isEqualTo(2);
        assertThat(response.getHeaders().getFirst(HttpHeaders.ACCEPT_RANGES)).isEqualTo("bytes");
        assertThat(response.getHeaders().getFirst(HttpHeaders.CONTENT_RANGE))
                .isEqualTo("bytes 0-1/3");
        verify(service).download(1L, EntryType.DIARY, 10L, 20L, "bytes=0-1");
    }

    private EntryMediaDownloadResult download(long contentLength, String contentRange) {
        return new EntryMediaDownloadResult(
                new ByteArrayInputStream(new byte[]{1, 2, 3}),
                "video/mp4",
                contentLength,
                contentRange
        );
    }
}
