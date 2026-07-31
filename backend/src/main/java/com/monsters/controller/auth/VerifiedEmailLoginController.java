package com.monsters.controller.auth;

import com.monsters.dto.auth.VerifiedEmailLoginRequest;
import com.monsters.dto.auth.VerifiedEmailLoginResponse;
import com.monsters.dto.common.ApiResponse;
import com.monsters.service.auth.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class VerifiedEmailLoginController {

    private final AuthService authService;

    public VerifiedEmailLoginController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<VerifiedEmailLoginResponse>> login(
            @Valid @RequestBody VerifiedEmailLoginRequest request
    ) {
        VerifiedEmailLoginResponse response = authService.loginVerifiedEmail(request);
        if (response.requiresContinuation()) {
            return ResponseEntity.ok(ApiResponse.success(
                    "AUTH_CONTINUATION_REQUIRED",
                    "Additional member verification is required",
                    response
            ));
        }
        return ResponseEntity.ok(ApiResponse.success(
                "AUTHENTICATED",
                "Login success",
                response
        ));
    }
}
