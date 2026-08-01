package com.monsters.controller.auth;

import com.monsters.dto.auth.*;
import com.monsters.dto.common.ApiResponse;
import com.monsters.security.common.ContinuationAuthenticatedMember;
import com.monsters.service.eligibility.EligibilityService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
public class EligibilityController {
    private final EligibilityService service;
    public EligibilityController(EligibilityService service) { this.service = service; }

    @GetMapping("/eligibility-policy")
    public ResponseEntity<ApiResponse<EligibilityPolicyResponse>> policy() {
        return ResponseEntity.ok(ApiResponse.success("ELIGIBILITY_POLICY_AVAILABLE",
                "Eligibility policy available", service.currentPolicy()));
    }

    @PostMapping("/eligibility-completions")
    public ResponseEntity<ApiResponse<EligibilityCompletionResponse>> complete(
            @Valid @RequestBody EligibilityCompletionRequest request, Authentication authentication) {
        ContinuationAuthenticatedMember member = (ContinuationAuthenticatedMember) authentication.getPrincipal();
        String credential = (String) authentication.getDetails();
        return ResponseEntity.ok(ApiResponse.success("ELIGIBILITY_COMPLETED",
                "Eligibility step completed", service.complete(member.memberId(), credential, request)));
    }
}
