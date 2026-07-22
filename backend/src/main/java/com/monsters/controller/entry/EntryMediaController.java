package com.monsters.controller.entry;

import com.monsters.entity.entry.EntryType;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.service.entry.EntryMediaDownloadResult;
import com.monsters.service.entry.EntryMediaDownloadService;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class EntryMediaController {

    private static final String ACCEPT_RANGES_VALUE = "bytes";

    private final EntryMediaDownloadService entryMediaDownloadService;

    public EntryMediaController(EntryMediaDownloadService entryMediaDownloadService) {
        this.entryMediaDownloadService = entryMediaDownloadService;
    }

    @GetMapping("/annoyances/{id}/media/{mediaId}")
    public ResponseEntity<InputStreamResource> downloadAnnoyanceMedia(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @PathVariable Long id,
            @PathVariable Long mediaId,
            @RequestHeader(value = HttpHeaders.RANGE, required = false) String rangeHeader
    ) {
        EntryMediaDownloadResult download = entryMediaDownloadService.download(
                currentUser.userId(),
                EntryType.ANNOYANCE,
                id,
                mediaId,
                rangeHeader
        );
        return toResponse(download);
    }

    @GetMapping("/diaries/{id}/media/{mediaId}")
    public ResponseEntity<InputStreamResource> downloadDiaryMedia(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @PathVariable Long id,
            @PathVariable Long mediaId,
            @RequestHeader(value = HttpHeaders.RANGE, required = false) String rangeHeader
    ) {
        EntryMediaDownloadResult download = entryMediaDownloadService.download(
                currentUser.userId(),
                EntryType.DIARY,
                id,
                mediaId,
                rangeHeader
        );
        return toResponse(download);
    }

    private ResponseEntity<InputStreamResource> toResponse(EntryMediaDownloadResult download) {
        HttpHeaders headers = new HttpHeaders();
        headers.set(HttpHeaders.CONTENT_TYPE, download.contentType());
        headers.setContentLength(download.contentLength());
        headers.set(HttpHeaders.ACCEPT_RANGES, ACCEPT_RANGES_VALUE);

        HttpStatus status = HttpStatus.OK;
        if (download.contentRange() != null) {
            headers.set(HttpHeaders.CONTENT_RANGE, download.contentRange());
            status = HttpStatus.PARTIAL_CONTENT;
        }

        return ResponseEntity
                .status(status)
                .headers(headers)
                .body(new InputStreamResource(download.content()));
    }
}
