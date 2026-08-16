package com.monsters.controller.auth;

import com.monsters.dto.auth.VerifiedEmailLoginRequest;
import com.monsters.dto.auth.VerifiedEmailLoginResponse;
import com.monsters.dto.common.ApiResponse;
import com.monsters.security.session.WebSessionCookieService;
import com.monsters.security.session.SessionDeviceContext;
import com.monsters.service.auth.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class VerifiedEmailLoginController {

    private final AuthService authService;
    private final WebSessionCookieService webSessionCookieService;

    public VerifiedEmailLoginController(
            AuthService authService,
            WebSessionCookieService webSessionCookieService
    ) {
        this.authService = authService;
        this.webSessionCookieService = webSessionCookieService;
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<VerifiedEmailLoginResponse>> login(
            @Valid @RequestBody VerifiedEmailLoginRequest request,
            HttpServletRequest httpRequest
    ) {
        boolean cookieTransport = webSessionCookieService.usesCookieTransport(httpRequest);
        if (cookieTransport) {
            webSessionCookieService.requireTrustedRequest(httpRequest);
        }
        String clientPlatform = httpRequest.getHeader("X-Client-Platform");
        VerifiedEmailLoginResponse response = clientPlatform == null
                ? authService.loginVerifiedEmail(request)
                : authService.loginVerifiedEmail(
                        request,
                        SessionDeviceContext.resolve(
                                clientPlatform,
                                httpRequest.getHeader(HttpHeaders.USER_AGENT)
                        )
                );
        if (response.requiresContinuation()) {
            ResponseEntity.BodyBuilder responseBuilder = ResponseEntity.ok();
            if (cookieTransport) {
                responseBuilder.header(
                        HttpHeaders.SET_COOKIE,
                        webSessionCookieService.expire().toString()
                );
            }
            return responseBuilder.body(ApiResponse.success(
                    "AUTH_CONTINUATION_REQUIRED",
                    "Additional member verification is required",
                    response
            ));
        }
        ResponseEntity.BodyBuilder responseBuilder = ResponseEntity.ok();
        if (cookieTransport) {
            responseBuilder.header(
                    HttpHeaders.SET_COOKIE,
                    webSessionCookieService.issue(response.refreshToken()).toString()
            );
            response = response.withoutRefreshCredential();
        }
        return responseBuilder.body(ApiResponse.success("AUTHENTICATED", "Login success", response));
    }
}
