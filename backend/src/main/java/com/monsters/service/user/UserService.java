package com.monsters.service.user;

import com.monsters.exception.common.ResourceNotFoundException;
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
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final UserPasswordLockRepository userPasswordLockRepository;
    private final AvatarStorageService avatarStorageService;
    private final PasswordEncoder passwordEncoder;

    public UserService(
            UserRepository userRepository,
            UserPasswordLockRepository userPasswordLockRepository,
            AvatarStorageService avatarStorageService,
            PasswordEncoder passwordEncoder
    ) {
        this.userRepository = userRepository;
        this.userPasswordLockRepository = userPasswordLockRepository;
        this.avatarStorageService = avatarStorageService;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public UserProfileResponse getProfile(Long userId) {
        User user = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return toProfileResponse(user);
    }

    @Transactional
    public UserProfileResponse updateProfile(Long userId, UpdateUserProfileRequest request) {
        User user = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.updateProfile(request.userName().trim(), request.birthday());
        return toProfileResponse(user);
    }

    @Transactional
    public UserProfileResponse updateAvatar(Long userId, MultipartFile file) {
        User user = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        String avatarUrl = avatarStorageService.uploadAvatar(userId, file);
        user.updateAvatarUrl(avatarUrl);
        return toProfileResponse(user);
    }

    @Transactional
    public PasswordLockStatusResponse setPasswordLock(Long userId, PasswordLockRequest request) {
        User user = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        String passwordHash = passwordEncoder.encode(request.lockPassword());
        UserPasswordLock passwordLock = userPasswordLockRepository.findByUserId(userId)
                .orElseGet(() -> new UserPasswordLock(user, passwordHash));
        passwordLock.updateLockPasswordHash(passwordHash);
        userPasswordLockRepository.save(passwordLock);
        return new PasswordLockStatusResponse(true);
    }

    @Transactional(readOnly = true)
    public PasswordLockVerificationResponse verifyPasswordLock(Long userId, PasswordLockRequest request) {
        userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        UserPasswordLock passwordLock = userPasswordLockRepository.findByUserIdAndEnabledTrue(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Password lock not found"));
        boolean verified = passwordEncoder.matches(request.lockPassword(), passwordLock.getLockPasswordHash());
        return new PasswordLockVerificationResponse(verified);
    }

    private UserProfileResponse toProfileResponse(User user) {
        return new UserProfileResponse(
                user.getId(),
                user.getAccount(),
                user.getEmail(),
                user.getUserName(),
                user.getBirthday(),
                user.getAvatarUrl()
        );
    }
}
