package com.monsters.dto.annoyance;

import jakarta.validation.constraints.NotNull;

public record SolveAnnoyanceRequest(
        @NotNull(message = "Solved state is required")
        Boolean isSolved
) {
}
