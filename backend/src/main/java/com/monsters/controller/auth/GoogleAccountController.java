package com.monsters.controller.auth;

import com.monsters.dto.auth.GoogleAccountLinkRequest;
import com.monsters.dto.auth.GoogleAccountLinkResponse;
import com.monsters.dto.auth.GoogleLoginRequest;
import com.monsters.dto.auth.VerifiedEmailLoginResponse;
import com.monsters.dto.common.ApiResponse;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.security.session.SessionDeviceContext;
import com.monsters.security.session.WebSessionCookieService;
import com.monsters.service.auth.GoogleAccountService;
import com.monsters.service.session.DeviceSessionCommandService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class GoogleAccountController {

    private final GoogleAccountService googleAccountService;
    private final WebSessionCookieService webSessionCookieService;

    public GoogleAccountController(
            GoogleAccountService googleAccountService,
            WebSessionCookieService webSessionCookieService
    ) {
        this.googleAccountService = googleAccountService;
        this.webSessionCookieService = webSessionCookieService;
    }

    @PostMapping("/google-logins")
    public ResponseEntity<ApiResponse<VerifiedEmailLoginResponse>> login(
            @Valid @RequestBody GoogleLoginRequest request,
            HttpServletRequest httpRequest
    ) {
        boolean cookieTransport = requireTrustedCookieRequest(httpRequest);
        VerifiedEmailLoginResponse response = googleAccountService.login(
                request,
                SessionDeviceContext.resolve(
                        httpRequest.getHeader("X-Client-Platform"),
                        httpRequest.getHeader(HttpHeaders.USER_AGENT)
                )
        );
        if (response.requiresGoogleAccountLink()) {
            return clearCookieResponse(
                    "GOOGLE_ACCOUNT_LINK_REQUIRED",
                    "Sign in with the existing account before linking Google",
                    response,
                    cookieTransport
            );
        }
        if (response.requiresContinuation()) {
            return clearCookieResponse(
                    "AUTH_CONTINUATION_REQUIRED",
                    "Additional member verification is required",
                    response,
                    cookieTransport
            );
        }

        ResponseEntity.BodyBuilder builder = ResponseEntity.ok();
        if (cookieTransport) {
            builder.header(
                    HttpHeaders.SET_COOKIE,
                    webSessionCookieService.issue(response.refreshToken()).toString()
            );
            response = response.withoutRefreshCredential();
        }
        return builder.body(ApiResponse.success(
                "AUTHENTICATED",
                "Google login success",
                response
        ));
    }

    @PostMapping("/google-account-links")
    public ApiResponse<GoogleAccountLinkResponse> link(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @RequestHeader(
                    value = DeviceSessionCommandService.REAUTHENTICATION_HEADER,
                    required = false
            ) String reauthenticationCredential,
            @Valid @RequestBody GoogleAccountLinkRequest request,
            HttpServletRequest httpRequest
    ) {
        requireTrustedCookieRequest(httpRequest);
        GoogleAccountLinkResponse response = googleAccountService.link(
                currentUser.userId(),
                currentUser.sessionId(),
                reauthenticationCredential,
                request
        );
        return ApiResponse.success(
                "GOOGLE_ACCOUNT_LINKED",
                "Google account linked",
                response
        );
    }

    private boolean requireTrustedCookieRequest(HttpServletRequest request) {
        boolean cookieTransport = webSessionCookieService.usesCookieTransport(request);
        if (cookieTransport) {
            webSessionCookieService.requireTrustedRequest(request);
        }
        return cookieTransport;
    }

    private ResponseEntity<ApiResponse<VerifiedEmailLoginResponse>> clearCookieResponse(
            String code,
            String message,
            VerifiedEmailLoginResponse response,
            boolean cookieTransport
    ) {
        ResponseEntity.BodyBuilder builder = ResponseEntity.ok();
        if (cookieTransport) {
            builder.header(HttpHeaders.SET_COOKIE, webSessionCookieService.expire().toString());
        }
        return builder.body(ApiResponse.success(code, message, response));
    }
}
