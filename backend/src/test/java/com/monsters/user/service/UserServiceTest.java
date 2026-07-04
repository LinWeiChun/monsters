package com.monsters.user.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

import com.monsters.common.exception.ResourceNotFoundException;
import com.monsters.user.dto.UserProfileResponse;
import com.monsters.user.entity.User;
import com.monsters.user.repository.UserRepository;
import java.time.LocalDate;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Test
    void getProfileShouldReturnCurrentUserProfile() {
        UserService userService = new UserService(userRepository);
        User user = new User("user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        ReflectionTestUtils.setField(user, "account", "old-account");
        ReflectionTestUtils.setField(user, "birthday", LocalDate.of(2000, 1, 2));
        ReflectionTestUtils.setField(user, "avatarUrl", "https://example.com/avatar.png");
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.of(user));

        UserProfileResponse response = userService.getProfile(1L);

        assertThat(response.userId()).isEqualTo(1L);
        assertThat(response.account()).isEqualTo("old-account");
        assertThat(response.email()).isEqualTo("user@example.com");
        assertThat(response.userName()).isEqualTo("Wei");
        assertThat(response.birthday()).isEqualTo(LocalDate.of(2000, 1, 2));
        assertThat(response.avatarUrl()).isEqualTo("https://example.com/avatar.png");
    }

    @Test
    void getProfileShouldRejectMissingUser() {
        UserService userService = new UserService(userRepository);
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.getProfile(1L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("User not found");
    }
}
