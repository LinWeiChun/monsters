package com.monsters.controller.auth;

import com.monsters.dto.auth.EmailVerificationRequest;
import com.monsters.dto.auth.EmailVerificationResendRequest;
import com.monsters.dto.auth.LoginResponse;
import com.monsters.dto.auth.RegistrationPolicyResponse;
import com.monsters.dto.auth.RegistrationRequest;
import com.monsters.dto.common.ApiResponse;
import com.monsters.service.auth.RegistrationPolicyService;
import com.monsters.service.auth.RegistrationService;
import com.monsters.service.registration.EmailVerificationService;
import com.monsters.service.registration.EmailVerificationResendService;
import jakarta.validation.Valid;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class RegistrationController {

    private final RegistrationPolicyService registrationPolicyService;
    private final RegistrationService registrationService;
    private final EmailVerificationService emailVerificationService;
    private final EmailVerificationResendService emailVerificationResendService;

    public RegistrationController(
            RegistrationPolicyService registrationPolicyService,
            RegistrationService registrationService,
            EmailVerificationService emailVerificationService,
            EmailVerificationResendService emailVerificationResendService
    ) {
        this.registrationPolicyService = registrationPolicyService;
        this.registrationService = registrationService;
        this.emailVerificationService = emailVerificationService;
        this.emailVerificationResendService = emailVerificationResendService;
    }

    @GetMapping("/registration-policy")
    public ResponseEntity<ApiResponse<RegistrationPolicyResponse>> registrationPolicy() {
        return ResponseEntity.ok(ApiResponse.success(
                "REGISTRATION_POLICY_AVAILABLE",
                "Registration policy available",
                registrationPolicyService.currentPolicy()
        ));
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<Void>> register(
            @Valid @RequestBody RegistrationRequest request,
            HttpServletRequest httpRequest
    ) {
        registrationService.register(request, httpRequest.getRemoteAddr());
        return ResponseEntity
                .status(HttpStatus.ACCEPTED)
                .body(ApiResponse.success(
                        "REGISTRATION_ACCEPTED",
                        "Registration request accepted",
                        null
                ));
    }

    @PostMapping("/email-verifications")
    public ResponseEntity<ApiResponse<LoginResponse>> verifyEmail(
            @Valid @RequestBody EmailVerificationRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                "EMAIL_VERIFIED",
                "Email verified",
                emailVerificationService.verify(request)
        ));
    }

    @PostMapping("/email-verification-requests")
    public ResponseEntity<ApiResponse<Void>> requestVerificationEmail(
            @Valid @RequestBody EmailVerificationResendRequest request,
            HttpServletRequest httpRequest
    ) {
        emailVerificationResendService.request(request, httpRequest.getRemoteAddr());
        return ResponseEntity
                .status(HttpStatus.ACCEPTED)
                .body(ApiResponse.success(
                        "EMAIL_VERIFICATION_REQUEST_ACCEPTED",
                        "Email verification request accepted",
                        null
                ));
    }
}
