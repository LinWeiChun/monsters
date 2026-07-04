package com.monsters.user.controller;

import com.monsters.common.dto.ApiResponse;
import com.monsters.common.security.AuthenticatedUser;
import com.monsters.user.dto.UserProfileResponse;
import com.monsters.user.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserProfileResponse>> me(
            @AuthenticationPrincipal AuthenticatedUser currentUser
    ) {
        UserProfileResponse response = userService.getProfile(currentUser.userId());
        return ResponseEntity.ok(ApiResponse.success("Profile query success", response));
    }
}
