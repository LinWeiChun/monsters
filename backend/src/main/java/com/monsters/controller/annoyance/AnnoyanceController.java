package com.monsters.controller.annoyance;

import com.monsters.dto.annoyance.AnnoyanceResponse;
import com.monsters.dto.annoyance.CreateAnnoyanceRequest;
import com.monsters.dto.annoyance.SolveAnnoyanceRequest;
import com.monsters.dto.annoyance.UpdateAnnoyanceRequest;
import com.monsters.dto.common.ApiResponse;
import com.monsters.dto.common.PageResponse;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.service.annoyance.AnnoyanceService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/annoyances")
public class AnnoyanceController {

    private final AnnoyanceService annoyanceService;

    public AnnoyanceController(AnnoyanceService annoyanceService) {
        this.annoyanceService = annoyanceService;
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
}
