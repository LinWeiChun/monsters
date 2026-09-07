package com.monsters.dto.member;

import com.monsters.entity.user.BirthdayCorrectionReason;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.PositiveOrZero;
import java.time.LocalDate;

public record BirthdayCorrectionCommand(
        @NotNull @PastOrPresent LocalDate birthday,
        @NotNull BirthdayCorrectionReason reason,
        @PositiveOrZero long expectedVersion
) {
}
