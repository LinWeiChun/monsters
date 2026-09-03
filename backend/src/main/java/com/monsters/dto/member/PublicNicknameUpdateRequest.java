package com.monsters.dto.member;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

public record PublicNicknameUpdateRequest(
        @NotBlank @Size(max = 120) String publicNickname,
        @AssertTrue boolean confirmExistingCommunityUpdate,
        @PositiveOrZero long expectedVersion
) {
}
