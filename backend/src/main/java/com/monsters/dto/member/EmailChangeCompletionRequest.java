package com.monsters.dto.member;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record EmailChangeCompletionRequest(
        @NotBlank @Size(max = 512) String token
) {
}
