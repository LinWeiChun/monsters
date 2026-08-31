package com.monsters.controller.auth;

import com.monsters.dto.auth.PasswordResetCompletionRequest;
import com.monsters.dto.auth.PasswordResetEmailRequest;
import com.monsters.dto.common.ApiResponse;
import com.monsters.service.auth.PasswordResetService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Deprecated(forRemoval = true)
@RestController
@RequestMapping("/api/auth")
public class LegacyPasswordResetController {

    private final PasswordResetService passwordResetService;

    public LegacyPasswordResetController(PasswordResetService passwordResetService) {
        this.passwordResetService = passwordResetService;
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Void>> request(
            @Valid @RequestBody PasswordResetEmailRequest request,
            HttpServletRequest httpRequest
    ) {
        passwordResetService.request(request, httpRequest.getRemoteAddr());
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(ApiResponse.success(
                "PASSWORD_RESET_REQUEST_ACCEPTED",
                "Password reset request accepted",
                null
        ));
    }

    @PostMapping("/reset-password")
    public ApiResponse<Void> complete(
            @Valid @RequestBody PasswordResetCompletionRequest request
    ) {
        passwordResetService.complete(request);
        return ApiResponse.success(
                "PASSWORD_RESET_COMPLETED",
                "Password reset completed",
                null
        );
    }
}
