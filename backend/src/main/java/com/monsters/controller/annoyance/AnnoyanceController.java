package com.monsters.controller.annoyance;

import com.monsters.dto.annoyance.AnnoyanceResponse;
import com.monsters.dto.annoyance.CreateAnnoyanceRequest;
import com.monsters.dto.annoyance.ShareAnnoyanceRequest;
import com.monsters.dto.annoyance.SolveAnnoyanceRequest;
import com.monsters.dto.annoyance.UpdateAnnoyanceRequest;
import com.monsters.dto.common.ApiResponse;
import com.monsters.dto.common.PageResponse;
import com.monsters.dto.entry.EntryDraftEnvelope;
import com.monsters.dto.entry.SaveEntryDraftRequest;
import com.monsters.entity.entry.EntryType;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.service.annoyance.AnnoyanceService;
import com.monsters.service.entry.EntryDraftService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/annoyances")
public class AnnoyanceController {

    private final AnnoyanceService annoyanceService;
    private final EntryDraftService entryDraftService;

    public AnnoyanceController(
            AnnoyanceService annoyanceService,
            EntryDraftService entryDraftService
    ) {
        this.annoyanceService = annoyanceService;
        this.entryDraftService = entryDraftService;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<AnnoyanceResponse>> create(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @Valid @RequestPart("request") CreateAnnoyanceRequest request,
            @RequestPart(value = "contentFile", required = false) MultipartFile contentFile,
            @RequestPart(value = "drawingFile", required = false) MultipartFile drawingFile
    ) {
        AnnoyanceResponse response = annoyanceService.create(
                currentUser.userId(),
                request,
                contentFile,
                drawingFile
        );
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Annoyance creation success", response));
    }

    @GetMapping("/draft")
    public ResponseEntity<ApiResponse<EntryDraftEnvelope>> findDraft(
            @AuthenticationPrincipal AuthenticatedUser currentUser
    ) {
        EntryDraftEnvelope response = entryDraftService.find(
                currentUser.userId(),
                EntryType.ANNOYANCE
        );
        return ResponseEntity.ok(ApiResponse.success(
                "Annoyance draft query success",
                response
        ));
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
                EntryType.ANNOYANCE,
                request,
                contentFile,
                drawingFile
        );
        return ResponseEntity.ok(ApiResponse.success(
                "Annoyance draft save success",
                response
        ));
    }

    @DeleteMapping("/draft")
    public ResponseEntity<ApiResponse<Void>> discardDraft(
            @AuthenticationPrincipal AuthenticatedUser currentUser
    ) {
        entryDraftService.discard(currentUser.userId(), EntryType.ANNOYANCE);
        return ResponseEntity.ok(ApiResponse.success(
                "Annoyance draft discard success",
                null
        ));
    }

    @PostMapping("/draft/submit")
    public ResponseEntity<ApiResponse<AnnoyanceResponse>> submitDraft(
            @AuthenticationPrincipal AuthenticatedUser currentUser
    ) {
        AnnoyanceResponse response = entryDraftService.submitAnnoyance(
                currentUser.userId()
        );
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Annoyance creation success", response));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<AnnoyanceResponse>>> findAll(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "occurredAt,desc") String sort,
            @RequestParam(required = false) Boolean isSolved,
            @RequestParam(required = false) Boolean isShared
    ) {
        PageResponse<AnnoyanceResponse> response = annoyanceService.findAll(
                currentUser.userId(),
                page,
                size,
                sort,
                isSolved,
                isShared
        );
        return ResponseEntity.ok(ApiResponse.success("Annoyance query success", response));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<AnnoyanceResponse>> findOne(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @PathVariable Long id
    ) {
        AnnoyanceResponse response = annoyanceService.findOne(currentUser.userId(), id);
        return ResponseEntity.ok(ApiResponse.success("Annoyance query success", response));
    }

    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<AnnoyanceResponse>> update(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @PathVariable Long id,
            @Valid @RequestPart("request") UpdateAnnoyanceRequest request,
            @RequestPart(value = "contentFile", required = false) MultipartFile contentFile,
            @RequestPart(value = "drawingFile", required = false) MultipartFile drawingFile
    ) {
        AnnoyanceResponse response = annoyanceService.update(
                currentUser.userId(),
                id,
                request,
                contentFile,
                drawingFile
        );
        return ResponseEntity.ok(ApiResponse.success("Annoyance update success", response));
    }

    @PatchMapping("/{id}/solve")
    public ResponseEntity<ApiResponse<AnnoyanceResponse>> solve(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @PathVariable Long id,
            @Valid @RequestBody SolveAnnoyanceRequest request
    ) {
        AnnoyanceResponse response = annoyanceService.solve(
                currentUser.userId(),
                id,
                request.isSolved()
        );
        return ResponseEntity.ok(ApiResponse.success("Annoyance solve success", response));
    }

    @PatchMapping("/{id}/share")
    public ResponseEntity<ApiResponse<AnnoyanceResponse>> updateSharing(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @PathVariable Long id,
            @Valid @RequestBody ShareAnnoyanceRequest request
    ) {
        AnnoyanceResponse response = annoyanceService.updateSharing(
                currentUser.userId(),
                id,
                request.isShared()
        );
        return ResponseEntity.ok(ApiResponse.success(
                "Annoyance sharing update success",
                response
        ));
    }
}
