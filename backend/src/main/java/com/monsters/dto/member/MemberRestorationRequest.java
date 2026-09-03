package com.monsters.dto.member;

import jakarta.validation.constraints.AssertTrue;

public record MemberRestorationRequest(
        @AssertTrue boolean confirmed
) {
}
