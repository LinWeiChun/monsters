package com.monsters.service.user;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.common.BusinessException;
import com.monsters.storage.common.AvatarStorageService;
import com.monsters.dto.user.PasswordLockRequest;
import com.monsters.dto.user.PasswordLockStatusResponse;
import com.monsters.dto.user.PasswordLockVerificationResponse;
import com.monsters.dto.user.UpdateUserProfileRequest;
import com.monsters.dto.user.UserProfileResponse;
import com.monsters.entity.user.User;
import com.monsters.entity.user.UserPasswordLock;
import com.monsters.repository.user.UserPasswordLockRepository;
import com.monsters.repository.user.UserRepository;
import java.time.LocalDate;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private UserPasswordLockRepository userPasswordLockRepository;

    @Mock
    private AvatarStorageService avatarStorageService;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Test
    void getProfileShouldReturnCurrentUserProfile() {
        UserService userService = userService();
        User user = new User("wei_account", "user@example.com", "Wei");
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
        UserService userService = userService();
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.getProfile(1L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("User not found");
    }

    @Test
    void updateProfileShouldRejectLegacyWritesWithoutChangingNicknameOrBirthday() {
        UserService userService = userService();
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        ReflectionTestUtils.setField(user, "account", "old-account");
        ReflectionTestUtils.setField(user, "birthday", LocalDate.of(2000, 1, 2));
        ReflectionTestUtils.setField(user, "avatarUrl", "https://example.com/avatar.png");
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> userService.updateProfile(
                1L,
                new UpdateUserProfileRequest("  Lin  ", LocalDate.of(2001, 3, 4))
        )).isInstanceOfSatisfying(BusinessException.class, exception -> {
            assertThat(exception.getCode()).isEqualTo("CLIENT_UPGRADE_REQUIRED");
            assertThat(exception.getStatus().value()).isEqualTo(409);
        });
        assertThat(user.getUserName()).isEqualTo("Wei");
        assertThat(user.getBirthday()).isEqualTo(LocalDate.of(2000, 1, 2));
    }

    @Test
    void updateProfileShouldRejectMissingUser() {
        UserService userService = userService();
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.updateProfile(
                1L,
                new UpdateUserProfileRequest("Lin", LocalDate.of(2001, 3, 4))
        ))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("User not found");
    }

    @Test
    void updateAvatarShouldUploadAndUpdateCurrentUserAvatar() {
        UserService userService = userService();
        User user = new User("wei_account", "user@example.com", "Wei");
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "avatar.png",
                "image/png",
                new byte[]{1, 2, 3}
        );
        ReflectionTestUtils.setField(user, "id", 1L);
        ReflectionTestUtils.setField(user, "account", "old-account");
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.of(user));
        when(avatarStorageService.uploadAvatar(1L, file))
                .thenReturn("https://cdn.example.com/users/avatars/1/avatar.png");

        UserProfileResponse response = userService.updateAvatar(1L, file);

        assertThat(response.userId()).isEqualTo(1L);
        assertThat(response.account()).isEqualTo("old-account");
        assertThat(response.email()).isEqualTo("user@example.com");
        assertThat(response.userName()).isEqualTo("Wei");
        assertThat(response.avatarUrl()).isEqualTo("https://cdn.example.com/users/avatars/1/avatar.png");
        assertThat(user.getAvatarUrl()).isEqualTo("https://cdn.example.com/users/avatars/1/avatar.png");
    }

    @Test
    void updateAvatarShouldRejectMissingUser() {
        UserService userService = userService();
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "avatar.png",
                "image/png",
                new byte[]{1, 2, 3}
        );
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.updateAvatar(1L, file))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("User not found");
    }

    @Test
    void setPasswordLockShouldCreateCurrentUserPasswordLock() {
        UserService userService = userService();
        User user = new User("wei_account", "user@example.com", "Wei");
        ReflectionTestUtils.setField(user, "id", 1L);
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.of(user));
        when(userPasswordLockRepository.findByUserId(1L)).thenReturn(Optional.empty());
        when(passwordEncoder.encode("1234")).thenReturn("encoded-lock");
        when(userPasswordLockRepository.save(any(UserPasswordLock.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        PasswordLockStatusResponse response = userService.setPasswordLock(
                1L,
                new PasswordLockRequest("1234")
        );

        assertThat(response.enabled()).isTrue();
        verify(userPasswordLockRepository).save(any(UserPasswordLock.class));
    }

    @Test
    void setPasswordLockShouldUpdateExistingCurrentUserPasswordLock() {
        UserService userService = userService();
        User user = new User("wei_account", "user@example.com", "Wei");
        UserPasswordLock passwordLock = new UserPasswordLock(user, "old-lock");
        ReflectionTestUtils.setField(user, "id", 1L);
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.of(user));
        when(userPasswordLockRepository.findByUserId(1L)).thenReturn(Optional.of(passwordLock));
        when(passwordEncoder.encode("5678")).thenReturn("new-lock");
        when(userPasswordLockRepository.save(passwordLock)).thenReturn(passwordLock);

        PasswordLockStatusResponse response = userService.setPasswordLock(
                1L,
                new PasswordLockRequest("5678")
        );

        assertThat(response.enabled()).isTrue();
        assertThat(passwordLock.getLockPasswordHash()).isEqualTo("new-lock");
        assertThat(passwordLock.isEnabled()).isTrue();
    }

    @Test
    void setPasswordLockShouldRejectMissingUser() {
        UserService userService = userService();
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.setPasswordLock(1L, new PasswordLockRequest("1234")))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("User not found");
    }

    @Test
    void verifyPasswordLockShouldReturnTrueForMatchedPasswordLock() {
        UserService userService = userService();
        User user = new User("wei_account", "user@example.com", "Wei");
        UserPasswordLock passwordLock = new UserPasswordLock(user, "encoded-lock");
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.of(user));
        when(userPasswordLockRepository.findByUserIdAndEnabledTrue(1L)).thenReturn(Optional.of(passwordLock));
        when(passwordEncoder.matches("1234", "encoded-lock")).thenReturn(true);

        PasswordLockVerificationResponse response = userService.verifyPasswordLock(
                1L,
                new PasswordLockRequest("1234")
        );

        assertThat(response.verified()).isTrue();
    }

    @Test
    void verifyPasswordLockShouldReturnFalseForMismatchedPasswordLock() {
        UserService userService = userService();
        User user = new User("wei_account", "user@example.com", "Wei");
        UserPasswordLock passwordLock = new UserPasswordLock(user, "encoded-lock");
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.of(user));
        when(userPasswordLockRepository.findByUserIdAndEnabledTrue(1L)).thenReturn(Optional.of(passwordLock));
        when(passwordEncoder.matches("9999", "encoded-lock")).thenReturn(false);

        PasswordLockVerificationResponse response = userService.verifyPasswordLock(
                1L,
                new PasswordLockRequest("9999")
        );

        assertThat(response.verified()).isFalse();
    }

    @Test
    void verifyPasswordLockShouldRejectMissingPasswordLock() {
        UserService userService = userService();
        User user = new User("wei_account", "user@example.com", "Wei");
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.of(user));
        when(userPasswordLockRepository.findByUserIdAndEnabledTrue(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.verifyPasswordLock(1L, new PasswordLockRequest("1234")))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Password lock not found");
    }

    @Test
    void verifyPasswordLockShouldRejectMissingUser() {
        UserService userService = userService();
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.verifyPasswordLock(1L, new PasswordLockRequest("1234")))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("User not found");
    }

    private UserService userService() {
        return new UserService(userRepository, userPasswordLockRepository, avatarStorageService, passwordEncoder);
    }
}
