package com.monsters.controller.auth;

import com.monsters.dto.auth.SessionRefreshRequest;
import com.monsters.dto.auth.VerifiedEmailLoginResponse;
import com.monsters.dto.common.ApiResponse;
import com.monsters.exception.common.BusinessException;
import com.monsters.security.session.WebSessionCookieService;
import com.monsters.service.session.SessionAuthenticationResult;
import com.monsters.service.session.SessionFamilyService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class SessionRefreshController {

    private final SessionFamilyService sessionFamilyService;
    private final WebSessionCookieService webSessionCookieService;

    public SessionRefreshController(
            SessionFamilyService sessionFamilyService,
            WebSessionCookieService webSessionCookieService
    ) {
        this.sessionFamilyService = sessionFamilyService;
        this.webSessionCookieService = webSessionCookieService;
    }

    @PostMapping("/session-refreshes")
    public ResponseEntity<ApiResponse<VerifiedEmailLoginResponse>> refresh(
            @Valid @RequestBody(required = false) SessionRefreshRequest request,
            HttpServletRequest httpRequest,
            HttpServletResponse httpResponse
    ) {
        boolean cookieTransport = webSessionCookieService.usesCookieTransport(httpRequest);
        String refreshCredential;
        if (cookieTransport) {
            webSessionCookieService.requireTrustedRequest(httpRequest);
            refreshCredential = webSessionCookieService.refreshCredential(httpRequest);
        } else {
            if (request == null) {
                throw new BusinessException(
                        HttpStatus.BAD_REQUEST,
                        "VALIDATION_FAILED",
                        "Refresh credential is required"
                );
            }
            refreshCredential = request.refreshCredential();
        }
        SessionAuthenticationResult result;
        try {
            result = sessionFamilyService.refresh(refreshCredential);
        } catch (BusinessException exception) {
            if (cookieTransport && exception.getStatus() == HttpStatus.UNAUTHORIZED) {
                httpResponse.addHeader(
                        HttpHeaders.SET_COOKIE,
                        webSessionCookieService.expire().toString()
                );
            }
            throw exception;
        }
        VerifiedEmailLoginResponse response = VerifiedEmailLoginResponse.authenticated(
                result.accessToken(),
                result.refreshCredential(),
                result.tokenType(),
                result.expiresIn(),
                result.user()
        );
        ResponseEntity.BodyBuilder responseBuilder = ResponseEntity.ok();
        if (cookieTransport) {
            responseBuilder.header(
                    HttpHeaders.SET_COOKIE,
                    webSessionCookieService.issue(result.refreshCredential()).toString()
            );
            response = response.withoutRefreshCredential();
        }
        return responseBuilder.body(ApiResponse.success(
                "AUTHENTICATED",
                "Session refresh success",
                response
        ));
    }
}
