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

@RestController
@RequestMapping("/api/v1/auth")
public class PasswordResetController {

    private final PasswordResetService passwordResetService;

    public PasswordResetController(PasswordResetService passwordResetService) {
        this.passwordResetService = passwordResetService;
    }

    @PostMapping("/password-reset-requests")
    public ResponseEntity<ApiResponse<Void>> request(
            @Valid @RequestBody PasswordResetEmailRequest request,
            HttpServletRequest httpRequest
    ) {
        passwordResetService.request(request, httpRequest.getRemoteAddr());
        return accepted();
    }

    @PostMapping("/password-resets")
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

    private ResponseEntity<ApiResponse<Void>> accepted() {
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(ApiResponse.success(
                "PASSWORD_RESET_REQUEST_ACCEPTED",
                "Password reset request accepted",
                null
        ));
    }
}
