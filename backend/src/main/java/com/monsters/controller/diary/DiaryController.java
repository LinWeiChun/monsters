package com.monsters.controller.diary;

import com.monsters.dto.common.ApiResponse;
import com.monsters.dto.diary.CreateDiaryRequest;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.service.diary.DiaryService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
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
}
