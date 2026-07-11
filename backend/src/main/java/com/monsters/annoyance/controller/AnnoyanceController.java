package com.monsters.annoyance.controller;

import com.monsters.annoyance.dto.AnnoyanceResponse;
import com.monsters.annoyance.dto.CreateAnnoyanceRequest;
import com.monsters.annoyance.service.AnnoyanceService;
import com.monsters.common.dto.ApiResponse;
import com.monsters.common.security.AuthenticatedUser;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
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
}
