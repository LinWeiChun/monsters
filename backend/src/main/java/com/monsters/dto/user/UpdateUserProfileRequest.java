package com.monsters.dto.user;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

public record UpdateUserProfileRequest(
        @NotBlank
        @Size(max = 80)
        String userName,
        LocalDate birthday
) {
}
