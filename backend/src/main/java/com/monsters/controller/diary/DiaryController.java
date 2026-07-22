package com.monsters.controller.diary;

import com.monsters.dto.common.ApiResponse;
import com.monsters.dto.common.PageResponse;
import com.monsters.dto.diary.CreateDiaryRequest;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.dto.diary.ShareDiaryRequest;
import com.monsters.dto.diary.UpdateDiaryRequest;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.service.diary.DiaryService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/diaries")
public class DiaryController {

    private final DiaryService diaryService;

    public DiaryController(DiaryService diaryService) {
        this.diaryService = diaryService;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<DiaryResponse>> create(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @Valid @RequestPart("request") CreateDiaryRequest request,
            @RequestPart(value = "contentFile", required = false) MultipartFile contentFile,
            @RequestPart(value = "drawingFile", required = false) MultipartFile drawingFile
    ) {
        DiaryResponse response = diaryService.create(
                currentUser.userId(),
                request,
                contentFile,
                drawingFile
        );
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Diary creation success", response));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<DiaryResponse>>> findAll(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "occurredAt,desc") String sort,
            @RequestParam(required = false) Boolean isShared
    ) {
        PageResponse<DiaryResponse> response = diaryService.findAll(
                currentUser.userId(),
                page,
                size,
                sort,
                isShared
        );
        return ResponseEntity.ok(ApiResponse.success("Diary query success", response));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<DiaryResponse>> findOne(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @PathVariable Long id
    ) {
        DiaryResponse response = diaryService.findOne(currentUser.userId(), id);
        return ResponseEntity.ok(ApiResponse.success("Diary query success", response));
    }

    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<DiaryResponse>> update(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @PathVariable Long id,
            @Valid @RequestPart("request") UpdateDiaryRequest request,
            @RequestPart(value = "contentFile", required = false) MultipartFile contentFile,
            @RequestPart(value = "drawingFile", required = false) MultipartFile drawingFile
    ) {
        DiaryResponse response = diaryService.update(
                currentUser.userId(),
                id,
                request,
                contentFile,
                drawingFile
        );
        return ResponseEntity.ok(ApiResponse.success("Diary update success", response));
    }

    @PatchMapping("/{id}/share")
    public ResponseEntity<ApiResponse<DiaryResponse>> updateSharing(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @PathVariable Long id,
            @Valid @RequestBody ShareDiaryRequest request
    ) {
        DiaryResponse response = diaryService.updateSharing(
                currentUser.userId(),
                id,
                request.isShared()
        );
        return ResponseEntity.ok(ApiResponse.success(
                "Diary sharing update success",
                response
        ));
    }
}
