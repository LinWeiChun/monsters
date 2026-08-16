package com.monsters.dto.auth;

import java.util.List;

public record DeviceSessionPageResponse(
        List<DeviceSessionResponse> items,
        int page,
        int size,
        long totalItems,
        int totalPages
) {
}
