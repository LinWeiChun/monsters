package com.monsters.controller.auth;

import com.monsters.dto.auth.*;
import com.monsters.dto.common.ApiResponse;
import com.monsters.service.eligibility.GuardianConsentService;
import jakarta.validation.Valid;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
public class GuardianConsentController {
    private final GuardianConsentService service;
    public GuardianConsentController(GuardianConsentService service) { this.service = service; }
    @PostMapping("/guardian-consent-actions")
    public ApiResponse<GuardianConsentActionResponse> inspect(@Valid @RequestBody GuardianConsentTokenRequest request) {
        return ApiResponse.success("GUARDIAN_CONSENT_ACTION_AVAILABLE", "Guardian action available", service.inspect(request.token()));
    }
    @PostMapping("/guardian-consents")
    public ApiResponse<GuardianConsentActionResponse> grant(@Valid @RequestBody GuardianConsentTokenRequest request) {
        return ApiResponse.success("GUARDIAN_CONSENT_GRANTED", "Guardian consent granted", service.grant(request.token()));
    }
    @PostMapping("/guardian-consent-withdrawal-requests")
    public ResponseEntity<ApiResponse<Void>> requestWithdrawal(@Valid @RequestBody GuardianWithdrawalRequest request) {
        service.requestWithdrawal(request);
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(ApiResponse.success(
                "GUARDIAN_WITHDRAWAL_REQUEST_ACCEPTED", "Guardian withdrawal request accepted", null));
    }
    @PostMapping("/guardian-consent-withdrawals")
    public ApiResponse<GuardianConsentActionResponse> withdraw(@Valid @RequestBody GuardianConsentTokenRequest request) {
        return ApiResponse.success("GUARDIAN_CONSENT_WITHDRAWN", "Guardian consent withdrawn", service.withdraw(request.token()));
    }
}
