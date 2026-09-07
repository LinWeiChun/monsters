package com.monsters.controller.member;

import com.monsters.dto.common.ApiResponse;
import com.monsters.dto.member.BirthdayCorrectionCommand;
import com.monsters.dto.member.BirthdayCorrectionResponse;
import com.monsters.dto.member.EmailChangePendingResponse;
import com.monsters.dto.member.EmailChangeRequest;
import com.monsters.dto.member.MemberProfileResponse;
import com.monsters.dto.member.MemberStateCommandRequest;
import com.monsters.dto.member.MemberStateResponse;
import com.monsters.dto.member.PublicNicknameUpdateRequest;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.security.session.WebSessionCookieService;
import com.monsters.service.member.MemberAccountLifecycleService;
import com.monsters.service.member.MemberBirthdayCorrectionService;
import com.monsters.service.member.MemberEmailChangeService;
import com.monsters.service.member.MemberProfileService;
import com.monsters.service.session.DeviceSessionCommandService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/members")
public class MemberController {

    private final MemberProfileService profileService;
    private final MemberEmailChangeService emailChangeService;
    private final MemberBirthdayCorrectionService birthdayCorrectionService;
    private final MemberAccountLifecycleService accountLifecycleService;
    private final WebSessionCookieService webSessionCookieService;

    public MemberController(
            MemberProfileService profileService,
            MemberEmailChangeService emailChangeService,
            MemberBirthdayCorrectionService birthdayCorrectionService,
            MemberAccountLifecycleService accountLifecycleService,
            WebSessionCookieService webSessionCookieService
    ) {
        this.profileService = profileService;
        this.emailChangeService = emailChangeService;
        this.birthdayCorrectionService = birthdayCorrectionService;
        this.accountLifecycleService = accountLifecycleService;
        this.webSessionCookieService = webSessionCookieService;
    }

    @GetMapping("/me")
    public ApiResponse<MemberProfileResponse> getProfile(
            @AuthenticationPrincipal AuthenticatedUser currentUser
    ) {
        return ApiResponse.success(
                "MEMBER_PROFILE_RETRIEVED",
                "Member profile retrieved",
                profileService.getProfile(currentUser.userId())
        );
    }

    @PutMapping("/me/public-nickname")
    public ApiResponse<MemberProfileResponse> updatePublicNickname(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @Valid @RequestBody PublicNicknameUpdateRequest request
    ) {
        return ApiResponse.success(
                "PUBLIC_NICKNAME_UPDATED",
                "Public nickname updated",
                profileService.updatePublicNickname(currentUser.userId(), request)
        );
    }

    @PostMapping("/me/email-change-requests")
    public ResponseEntity<ApiResponse<EmailChangePendingResponse>> requestEmailChange(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @RequestHeader(
                    value = DeviceSessionCommandService.REAUTHENTICATION_HEADER,
                    required = false
            ) String reauthenticationCredential,
            @Valid @RequestBody EmailChangeRequest request,
            HttpServletRequest httpRequest
    ) {
        requireTrustedCookieRequest(httpRequest);
        EmailChangePendingResponse response = emailChangeService.requestChange(
                currentUser.userId(),
                currentUser.sessionId(),
                reauthenticationCredential,
                request
        );
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(ApiResponse.success(
                "EMAIL_CHANGE_VERIFICATION_PENDING",
                "Email change verification is pending",
                response
        ));
    }

    @PostMapping("/me/birthday-correction-requests")
    public ResponseEntity<ApiResponse<BirthdayCorrectionResponse>> requestBirthdayCorrection(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @RequestHeader(
                    value = DeviceSessionCommandService.REAUTHENTICATION_HEADER,
                    required = false
            ) String reauthenticationCredential,
            @Valid @RequestBody BirthdayCorrectionCommand command,
            HttpServletRequest httpRequest
    ) {
        requireTrustedCookieRequest(httpRequest);
        BirthdayCorrectionResponse response = birthdayCorrectionService.requestCorrection(
                currentUser.userId(),
                currentUser.sessionId(),
                reauthenticationCredential,
                command
        );
        boolean pending = "PENDING_REVIEW".equals(response.status());
        return ResponseEntity.status(pending ? HttpStatus.ACCEPTED : HttpStatus.OK)
                .body(ApiResponse.success(
                        pending
                                ? "BIRTHDAY_CORRECTION_REVIEW_PENDING"
                                : "BIRTHDAY_CORRECTION_APPROVED",
                        pending
                                ? "Birthday correction is pending review"
                                : "Birthday correction was approved",
                        response
                ));
    }

    @PostMapping("/me/deactivations")
    public ResponseEntity<ApiResponse<MemberStateResponse>> deactivate(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @Valid @RequestBody MemberStateCommandRequest request,
            HttpServletRequest httpRequest
    ) {
        boolean cookieTransport = requireTrustedCookieRequest(httpRequest);
        MemberStateResponse response = accountLifecycleService.deactivate(
                currentUser.userId(),
                request
        );
        ResponseEntity.BodyBuilder builder = ResponseEntity.ok();
        if (cookieTransport) {
            builder.header(HttpHeaders.SET_COOKIE, webSessionCookieService.expire().toString());
        }
        return builder.body(ApiResponse.success(
                "MEMBER_DEACTIVATED",
                "Member account deactivated",
                response
        ));
    }

    private boolean requireTrustedCookieRequest(HttpServletRequest request) {
        boolean cookieTransport = webSessionCookieService.usesCookieTransport(request);
        if (cookieTransport) {
            webSessionCookieService.requireTrustedRequest(request);
        }
        return cookieTransport;
    }
}
