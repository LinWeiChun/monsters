package com.monsters.dto.auth;

import java.time.LocalDateTime;

public record DeviceSessionResponse(
        String sessionId,
        String deviceType,
        String deviceSummary,
        LocalDateTime lastActivityAt,
        boolean current
) {
}
