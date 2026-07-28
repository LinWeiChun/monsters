package com.monsters.controller.diary;

import com.monsters.dto.common.ApiResponse;
import com.monsters.dto.common.PageResponse;
import com.monsters.dto.diary.CreateDiaryRequest;
import com.monsters.dto.diary.DiaryResponse;
import com.monsters.dto.diary.ShareDiaryRequest;
import com.monsters.dto.diary.UpdateDiaryRequest;
import com.monsters.dto.entry.EntryDraftEnvelope;
import com.monsters.dto.entry.SaveEntryDraftRequest;
import com.monsters.entity.entry.EntryType;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.service.diary.DiaryService;
import com.monsters.service.entry.EntryDraftService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
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
    private final EntryDraftService entryDraftService;

    public DiaryController(
            DiaryService diaryService,
            EntryDraftService entryDraftService
    ) {
        this.diaryService = diaryService;
        this.entryDraftService = entryDraftService;
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

    @GetMapping("/draft")
    public ResponseEntity<ApiResponse<EntryDraftEnvelope>> findDraft(
            @AuthenticationPrincipal AuthenticatedUser currentUser
    ) {
        EntryDraftEnvelope response = entryDraftService.find(
                currentUser.userId(),
                EntryType.DIARY
        );
        return ResponseEntity.ok(ApiResponse.success("Diary draft query success", response));
    }

    @PutMapping(value = "/draft", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<EntryDraftEnvelope>> saveDraft(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @Valid @RequestPart("request") SaveEntryDraftRequest request,
            @RequestPart(value = "contentFile", required = false) MultipartFile contentFile,
            @RequestPart(value = "drawingFile", required = false) MultipartFile drawingFile
    ) {
        EntryDraftEnvelope response = entryDraftService.save(
                currentUser.userId(),
                EntryType.DIARY,
                request,
                contentFile,
                drawingFile
        );
        return ResponseEntity.ok(ApiResponse.success("Diary draft save success", response));
    }

    @DeleteMapping("/draft")
    public ResponseEntity<ApiResponse<Void>> discardDraft(
            @AuthenticationPrincipal AuthenticatedUser currentUser
    ) {
        entryDraftService.discard(currentUser.userId(), EntryType.DIARY);
        return ResponseEntity.ok(ApiResponse.success("Diary draft discard success", null));
    }

    @PostMapping("/draft/submit")
    public ResponseEntity<ApiResponse<DiaryResponse>> submitDraft(
            @AuthenticationPrincipal AuthenticatedUser currentUser
    ) {
        DiaryResponse response = entryDraftService.submitDiary(currentUser.userId());
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
