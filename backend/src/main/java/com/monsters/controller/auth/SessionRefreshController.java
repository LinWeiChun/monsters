package com.monsters.controller.auth;

import com.monsters.dto.auth.SessionRefreshRequest;
import com.monsters.dto.auth.VerifiedEmailLoginResponse;
import com.monsters.dto.common.ApiResponse;
import com.monsters.service.session.SessionAuthenticationResult;
import com.monsters.service.session.SessionFamilyService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class SessionRefreshController {

    private final SessionFamilyService sessionFamilyService;

    public SessionRefreshController(SessionFamilyService sessionFamilyService) {
        this.sessionFamilyService = sessionFamilyService;
    }

    @PostMapping("/session-refreshes")
    public ResponseEntity<ApiResponse<VerifiedEmailLoginResponse>> refresh(
            @Valid @RequestBody SessionRefreshRequest request
    ) {
        SessionAuthenticationResult result = sessionFamilyService.refresh(
                request.refreshCredential()
        );
        return ResponseEntity.ok(ApiResponse.success(
                "AUTHENTICATED",
                "Session refresh success",
                VerifiedEmailLoginResponse.authenticated(
                        result.accessToken(),
                        result.refreshCredential(),
                        result.tokenType(),
                        result.expiresIn(),
                        result.user()
                )
        ));
    }
}
