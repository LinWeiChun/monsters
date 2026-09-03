package com.monsters.controller.auth;

import com.monsters.dto.auth.GoogleReauthenticationRequest;
import com.monsters.dto.auth.SessionReauthenticationResponse;
import com.monsters.dto.common.ApiResponse;
import com.monsters.dto.member.EmailChangeCompletedResponse;
import com.monsters.dto.member.EmailChangeCompletionRequest;
import com.monsters.dto.member.MemberStateResponse;
import com.monsters.dto.member.MemberRestorationRequest;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.security.common.ContinuationAuthenticatedMember;
import com.monsters.security.session.WebSessionCookieService;
import com.monsters.service.auth.GoogleReauthenticationService;
import com.monsters.service.member.MemberAccountLifecycleService;
import com.monsters.service.member.MemberEmailChangeService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class MemberDataAuthController {

    private final GoogleReauthenticationService googleReauthenticationService;
    private final MemberEmailChangeService emailChangeService;
    private final MemberAccountLifecycleService accountLifecycleService;
    private final WebSessionCookieService webSessionCookieService;

    public MemberDataAuthController(
            GoogleReauthenticationService googleReauthenticationService,
            MemberEmailChangeService emailChangeService,
            MemberAccountLifecycleService accountLifecycleService,
            WebSessionCookieService webSessionCookieService
    ) {
        this.googleReauthenticationService = googleReauthenticationService;
        this.emailChangeService = emailChangeService;
        this.accountLifecycleService = accountLifecycleService;
        this.webSessionCookieService = webSessionCookieService;
    }

    @PostMapping("/reauthentications/google")
    public ApiResponse<SessionReauthenticationResponse> reauthenticateWithGoogle(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @Valid @RequestBody GoogleReauthenticationRequest request,
            HttpServletRequest httpRequest
    ) {
        requireTrustedCookieRequest(httpRequest);
        return ApiResponse.success(
                "SESSION_REAUTHENTICATED",
                "Purpose-limited Google reauthentication succeeded",
                googleReauthenticationService.reauthenticate(
                        currentUser.userId(),
                        currentUser.sessionId(),
                        request
                )
        );
    }

    @PostMapping("/email-changes")
    public ApiResponse<EmailChangeCompletedResponse> completeEmailChange(
            @Valid @RequestBody EmailChangeCompletionRequest request
    ) {
        return ApiResponse.success(
                "EMAIL_CHANGE_COMPLETED",
                "Email change completed",
                emailChangeService.complete(request.token())
        );
    }

    @PostMapping("/member-restorations")
    public ApiResponse<MemberStateResponse> restore(
            @AuthenticationPrincipal ContinuationAuthenticatedMember currentMember,
            Authentication authentication,
            @Valid @RequestBody MemberRestorationRequest request
    ) {
        String rawCredential = authentication.getDetails() instanceof String value ? value : null;
        return ApiResponse.success(
                "MEMBER_RESTORED",
                "Member account restored",
                accountLifecycleService.restore(currentMember.memberId(), rawCredential, request)
        );
    }

    private void requireTrustedCookieRequest(HttpServletRequest request) {
        if (webSessionCookieService.usesCookieTransport(request)) {
            webSessionCookieService.requireTrustedRequest(request);
        }
    }
}
