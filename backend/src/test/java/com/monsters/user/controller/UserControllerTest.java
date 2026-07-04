package com.monsters.user.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import com.monsters.common.dto.ApiResponse;
import com.monsters.common.security.AuthenticatedUser;
import com.monsters.user.dto.UserProfileResponse;
import com.monsters.user.service.UserService;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.ResponseEntity;

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
}
