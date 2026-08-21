package com.monsters.controller.auth;

import com.monsters.dto.auth.SessionReauthenticationRequest;
import com.monsters.dto.auth.SessionReauthenticationResponse;
import com.monsters.dto.common.ApiResponse;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.security.session.WebSessionCookieService;
import com.monsters.service.session.DeviceSessionCommandService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class DeviceSessionCommandController {

    private final DeviceSessionCommandService commandService;
    private final WebSessionCookieService webSessionCookieService;

    public DeviceSessionCommandController(
            DeviceSessionCommandService commandService,
            WebSessionCookieService webSessionCookieService
    ) {
        this.commandService = commandService;
        this.webSessionCookieService = webSessionCookieService;
    }

    @PostMapping("/reauthentications/password")
    public ApiResponse<SessionReauthenticationResponse> reauthenticate(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @Valid @RequestBody SessionReauthenticationRequest request,
            HttpServletRequest httpRequest
    ) {
        requireTrustedCookieRequest(httpRequest);
        return ApiResponse.success(
                "SESSION_REAUTHENTICATED",
                "Purpose-limited password reauthentication succeeded",
                commandService.reauthenticate(
                        currentUser.userId(),
                        currentUser.sessionId(),
                        request.password(),
                        request.effectivePurpose()
                )
        );
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logoutCurrent(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            HttpServletRequest httpRequest
    ) {
        boolean cookieTransport = requireTrustedCookieRequest(httpRequest);
        commandService.revokeCurrent(currentUser.userId(), currentUser.sessionId());
        return response(
                "CURRENT_SESSION_REVOKED",
                "Current session revoked",
                cookieTransport
        );
    }

    @PostMapping("/sessions/{sessionId}/revocations")
    public ApiResponse<Void> revokeOne(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @PathVariable String sessionId,
            @RequestHeader(
                    value = DeviceSessionCommandService.REAUTHENTICATION_HEADER,
                    required = false
            ) String reauthenticationCredential,
            HttpServletRequest httpRequest
    ) {
        requireTrustedCookieRequest(httpRequest);
        commandService.revokeOne(
                currentUser.userId(),
                currentUser.sessionId(),
                sessionId,
                reauthenticationCredential
        );
        return ApiResponse.success("DEVICE_SESSION_REVOKED", "Device session revoked", null);
    }

    @PostMapping("/session-revocations/others")
    public ApiResponse<Void> revokeOthers(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @RequestHeader(
                    value = DeviceSessionCommandService.REAUTHENTICATION_HEADER,
                    required = false
            ) String reauthenticationCredential,
            HttpServletRequest httpRequest
    ) {
        requireTrustedCookieRequest(httpRequest);
        commandService.revokeOthers(
                currentUser.userId(),
                currentUser.sessionId(),
                reauthenticationCredential
        );
        return ApiResponse.success("OTHER_SESSIONS_REVOKED", "Other sessions revoked", null);
    }

    @PostMapping("/session-revocations/all")
    public ResponseEntity<ApiResponse<Void>> revokeAll(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @RequestHeader(
                    value = DeviceSessionCommandService.REAUTHENTICATION_HEADER,
                    required = false
            ) String reauthenticationCredential,
            HttpServletRequest httpRequest
    ) {
        boolean cookieTransport = requireTrustedCookieRequest(httpRequest);
        commandService.revokeAll(
                currentUser.userId(),
                currentUser.sessionId(),
                reauthenticationCredential
        );
        return response("ALL_SESSIONS_REVOKED", "All sessions revoked", cookieTransport);
    }

    private boolean requireTrustedCookieRequest(HttpServletRequest request) {
        boolean cookieTransport = webSessionCookieService.usesCookieTransport(request);
        if (cookieTransport) {
            webSessionCookieService.requireTrustedRequest(request);
        }
        return cookieTransport;
    }

    private ResponseEntity<ApiResponse<Void>> response(
            String code,
            String message,
            boolean expireCookie
    ) {
        ResponseEntity.BodyBuilder builder = ResponseEntity.ok();
        if (expireCookie) {
            builder.header(HttpHeaders.SET_COOKIE, webSessionCookieService.expire().toString());
        }
        return builder.body(ApiResponse.success(code, message, null));
    }
}
