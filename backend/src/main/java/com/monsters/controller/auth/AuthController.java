package com.monsters.controller.auth;

import com.monsters.dto.auth.GoogleLoginRequest;
import com.monsters.dto.auth.LoginRequest;
import com.monsters.dto.auth.LoginResponse;
import com.monsters.dto.auth.RegisterRequest;
import com.monsters.dto.auth.RegisterResponse;
import com.monsters.dto.auth.RefreshTokenRequest;
import com.monsters.service.auth.AuthService;
import com.monsters.service.auth.TokenRevocationService;
import com.monsters.dto.common.ApiResponse;
import com.monsters.exception.common.UnauthorizedException;
import jakarta.validation.Valid;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final TokenRevocationService tokenRevocationService;

    public AuthController(AuthService authService, TokenRevocationService tokenRevocationService) {
        this.authService = authService;
        this.tokenRevocationService = tokenRevocationService;
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<RegisterResponse>> register(
            @Valid @RequestBody RegisterRequest request
    ) {
        RegisterResponse response = authService.register(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Register success", response));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(
            @Valid @RequestBody LoginRequest request
    ) {
        LoginResponse response = authService.login(request);
        return ResponseEntity.ok(loginApiResponse(response, "Login success"));
    }

    @PostMapping("/google-login")
    public ResponseEntity<ApiResponse<LoginResponse>> googleLogin(
            @Valid @RequestBody GoogleLoginRequest request
    ) {
        LoginResponse response = authService.googleLogin(request);
        return ResponseEntity.ok(loginApiResponse(response, "Google login success"));
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<LoginResponse>> refresh(
            @Valid @RequestBody RefreshTokenRequest request
    ) {
        LoginResponse response = authService.refresh(request);
        return ResponseEntity.ok(ApiResponse.success(
                "AUTHENTICATED",
                "Token refresh success",
                response
        ));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(
            HttpServletRequest request,
            @RequestBody(required = false) RefreshTokenRequest refreshRequest
    ) {
        tokenRevocationService.revokeAccessToken(requiredBearerToken(request));
        if (refreshRequest != null
                && refreshRequest.refreshToken() != null
                && !refreshRequest.refreshToken().isBlank()) {
            tokenRevocationService.revokeRefreshToken(refreshRequest.refreshToken());
        }
        return ResponseEntity.ok(ApiResponse.success("Logout success", null));
    }

    private String requiredBearerToken(HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            throw new UnauthorizedException("尚未登入或 Token 無效");
        }
        String token = authorization.substring("Bearer ".length()).trim();
        if (token.isBlank()) {
            throw new UnauthorizedException("尚未登入或 Token 無效");
        }
        return token;
    }

    private ApiResponse<LoginResponse> loginApiResponse(LoginResponse response, String successMessage) {
        if (response.requiresContinuation()) {
            return ApiResponse.success(
                    "AUTH_CONTINUATION_REQUIRED",
                    "Additional member verification is required",
                    response
            );
        }
        return ApiResponse.success("AUTHENTICATED", successMessage, response);
    }
}
