package com.monsters.controller.auth;

import com.monsters.dto.auth.DeviceSessionPageResponse;
import com.monsters.dto.common.ApiResponse;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.service.session.DeviceSessionService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth/sessions")
public class DeviceSessionController {

    private final DeviceSessionService deviceSessionService;

    public DeviceSessionController(DeviceSessionService deviceSessionService) {
        this.deviceSessionService = deviceSessionService;
    }

    @GetMapping
    public ApiResponse<DeviceSessionPageResponse> list(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "3") int size
    ) {
        return ApiResponse.success(
                "DEVICE_SESSIONS_RETRIEVED",
                "Device sessions retrieved",
                deviceSessionService.list(
                        currentUser.userId(),
                        currentUser.sessionId(),
                        page,
                        size
                )
        );
    }
}
