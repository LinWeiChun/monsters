package com.monsters.dto.annoyance;

import jakarta.validation.constraints.NotNull;

public record ShareAnnoyanceRequest(
        @NotNull(message = "Shared state is required")
        Boolean isShared
) {
}
