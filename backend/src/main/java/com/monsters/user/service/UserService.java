package com.monsters.user.service;

import com.monsters.common.exception.ResourceNotFoundException;
import com.monsters.user.dto.UserProfileResponse;
import com.monsters.user.entity.User;
import com.monsters.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public UserProfileResponse getProfile(Long userId) {
        User user = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
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
