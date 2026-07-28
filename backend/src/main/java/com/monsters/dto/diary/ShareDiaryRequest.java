package com.monsters.dto.diary;

import jakarta.validation.constraints.NotNull;

public record ShareDiaryRequest(
        @NotNull(message = "Shared state is required")
        Boolean isShared
) {
}
