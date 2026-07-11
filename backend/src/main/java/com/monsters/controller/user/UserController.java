package com.monsters.controller.user;

import com.monsters.dto.common.ApiResponse;
import com.monsters.security.common.AuthenticatedUser;
import com.monsters.dto.user.PasswordLockRequest;
import com.monsters.dto.user.PasswordLockStatusResponse;
import com.monsters.dto.user.PasswordLockVerificationResponse;
import com.monsters.dto.user.UpdateUserProfileRequest;
import com.monsters.dto.user.UserProfileResponse;
import com.monsters.service.user.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

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

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserProfileResponse>> updateMe(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @Valid @RequestBody UpdateUserProfileRequest request
    ) {
        UserProfileResponse response = userService.updateProfile(currentUser.userId(), request);
        return ResponseEntity.ok(ApiResponse.success("Profile update success", response));
    }

    @PutMapping(value = "/me/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<UserProfileResponse>> updateAvatar(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @RequestPart("file") MultipartFile file
    ) {
        UserProfileResponse response = userService.updateAvatar(currentUser.userId(), file);
        return ResponseEntity.ok(ApiResponse.success("Avatar update success", response));
    }

    @PutMapping("/me/password-lock")
    public ResponseEntity<ApiResponse<PasswordLockStatusResponse>> setPasswordLock(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @Valid @RequestBody PasswordLockRequest request
    ) {
        PasswordLockStatusResponse response = userService.setPasswordLock(currentUser.userId(), request);
        return ResponseEntity.ok(ApiResponse.success("Password lock update success", response));
    }

    @PostMapping("/me/password-lock/verify")
    public ResponseEntity<ApiResponse<PasswordLockVerificationResponse>> verifyPasswordLock(
            @AuthenticationPrincipal AuthenticatedUser currentUser,
            @Valid @RequestBody PasswordLockRequest request
    ) {
        PasswordLockVerificationResponse response = userService.verifyPasswordLock(currentUser.userId(), request);
        return ResponseEntity.ok(ApiResponse.success("Password lock verify success", response));
    }
}
