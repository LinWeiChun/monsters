package com.monsters.dto.member;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.PositiveOrZero;

public record MemberStateCommandRequest(
        @AssertTrue boolean confirmed,
        @PositiveOrZero long expectedVersion
) {
}
