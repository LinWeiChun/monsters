package com.monsters.annoyance.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.OffsetDateTime;

public record CreateAnnoyanceRequest(
        @NotBlank(message = "Category code is required")
        @Size(max = 50, message = "Category code must not exceed 50 characters")
        String categoryCode,
        @NotNull(message = "Record method is required")
        AnnoyanceRecordMethod recordMethod,
        String content,
        @NotNull(message = "Score is required")
        @Min(value = 1, message = "Score must be between 1 and 5")
        @Max(value = 5, message = "Score must be between 1 and 5")
        Integer score,
        Boolean isShared,
        OffsetDateTime occurredAt
) {

    public boolean sharedOrDefault() {
        return Boolean.TRUE.equals(isShared);
    }
}
