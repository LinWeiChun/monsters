package com.monsters.dto.user;

import java.time.LocalDate;

public record UserProfileResponse(
        Long userId,
        String account,
        String email,
        String userName,
        LocalDate birthday,
        String avatarUrl
) {
}
