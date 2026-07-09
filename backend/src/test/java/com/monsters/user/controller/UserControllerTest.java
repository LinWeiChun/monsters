package com.monsters.user.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import com.monsters.common.dto.ApiResponse;
import com.monsters.common.security.AuthenticatedUser;
import com.monsters.user.dto.PasswordLockRequest;
import com.monsters.user.dto.PasswordLockStatusResponse;
import com.monsters.user.dto.PasswordLockVerificationResponse;
import com.monsters.user.dto.UpdateUserProfileRequest;
import com.monsters.user.dto.UserProfileResponse;
import com.monsters.user.service.UserService;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.ResponseEntity;
import org.springframework.mock.web.MockMultipartFile;

@ExtendWith(MockitoExtension.class)
class UserControllerTest {

    @Mock
    private UserService userService;

    @Test
    void meShouldReturnCurrentUserProfile() {
        UserController controller = new UserController(userService);
        UserProfileResponse profile = new UserProfileResponse(
                1L,
                "old-account",
                "user@example.com",
                "Wei",
                LocalDate.of(2000, 1, 2),
                "https://example.com/avatar.png"
        );
        when(userService.getProfile(1L)).thenReturn(profile);

        ResponseEntity<ApiResponse<UserProfileResponse>> response = controller.me(
                new AuthenticatedUser(1L, "user@example.com")
        );

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().success()).isTrue();
        assertThat(response.getBody().message()).isEqualTo("Profile query success");
        assertThat(response.getBody().data()).isEqualTo(profile);
    }

    @Test
    void updateMeShouldReturnUpdatedProfile() {
        UserController controller = new UserController(userService);
        UpdateUserProfileRequest request = new UpdateUserProfileRequest(
                "Lin",
                LocalDate.of(2001, 3, 4)
        );
        UserProfileResponse profile = new UserProfileResponse(
                1L,
                "old-account",
                "user@example.com",
                "Lin",
                LocalDate.of(2001, 3, 4),
                "https://example.com/avatar.png"
        );
        when(userService.updateProfile(1L, request)).thenReturn(profile);

        ResponseEntity<ApiResponse<UserProfileResponse>> response = controller.updateMe(
                new AuthenticatedUser(1L, "user@example.com"),
                request
        );

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().success()).isTrue();
        assertThat(response.getBody().message()).isEqualTo("Profile update success");
        assertThat(response.getBody().data()).isEqualTo(profile);
    }

    @Test
    void updateAvatarShouldReturnUpdatedProfile() {
        UserController controller = new UserController(userService);
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "avatar.png",
                "image/png",
                new byte[]{1, 2, 3}
        );
        UserProfileResponse profile = new UserProfileResponse(
                1L,
                "old-account",
                "user@example.com",
                "Wei",
                LocalDate.of(2000, 1, 2),
                "https://cdn.example.com/users/avatars/1/avatar.png"
        );
        when(userService.updateAvatar(1L, file)).thenReturn(profile);

        ResponseEntity<ApiResponse<UserProfileResponse>> response = controller.updateAvatar(
                new AuthenticatedUser(1L, "user@example.com"),
                file
        );

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().success()).isTrue();
        assertThat(response.getBody().message()).isEqualTo("Avatar update success");
        assertThat(response.getBody().data()).isEqualTo(profile);
    }

    @Test
    void setPasswordLockShouldReturnEnabledStatus() {
        UserController controller = new UserController(userService);
        PasswordLockRequest request = new PasswordLockRequest("1234");
        PasswordLockStatusResponse status = new PasswordLockStatusResponse(true);
        when(userService.setPasswordLock(1L, request)).thenReturn(status);

        ResponseEntity<ApiResponse<PasswordLockStatusResponse>> response = controller.setPasswordLock(
                new AuthenticatedUser(1L, "user@example.com"),
                request
        );

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().success()).isTrue();
        assertThat(response.getBody().message()).isEqualTo("Password lock update success");
        assertThat(response.getBody().data()).isEqualTo(status);
    }

    @Test
    void verifyPasswordLockShouldReturnVerificationResult() {
        UserController controller = new UserController(userService);
        PasswordLockRequest request = new PasswordLockRequest("1234");
        PasswordLockVerificationResponse verification = new PasswordLockVerificationResponse(true);
        when(userService.verifyPasswordLock(1L, request)).thenReturn(verification);

        ResponseEntity<ApiResponse<PasswordLockVerificationResponse>> response = controller.verifyPasswordLock(
                new AuthenticatedUser(1L, "user@example.com"),
                request
        );

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().success()).isTrue();
        assertThat(response.getBody().message()).isEqualTo("Password lock verify success");
        assertThat(response.getBody().data()).isEqualTo(verification);
    }
}
