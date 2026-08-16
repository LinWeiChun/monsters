package com.monsters.service.session;

import com.monsters.dto.auth.DeviceSessionPageResponse;
import com.monsters.dto.auth.DeviceSessionResponse;
import com.monsters.exception.common.ValidationException;
import com.monsters.repository.session.UserSessionRepository;
import java.time.Clock;
import java.time.LocalDateTime;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DeviceSessionService {

    private static final int MAX_PAGE_SIZE = 5;

    private final UserSessionRepository sessionRepository;
    private final Clock clock;

    public DeviceSessionService(UserSessionRepository sessionRepository, Clock clock) {
        this.sessionRepository = sessionRepository;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public DeviceSessionPageResponse list(Long userId, String currentSessionId, int page, int size) {
        if (page < 0 || size < 1 || size > MAX_PAGE_SIZE) {
            throw new ValidationException("Invalid session page request");
        }
        LocalDateTime now = LocalDateTime.now(clock);
        var sessions = sessionRepository
                .findByUser_IdAndRevokedAtIsNullAndIdleExpiresAtAfterAndAbsoluteExpiresAtAfterOrderByIdDesc(
                        userId,
                        now,
                        now,
                        PageRequest.of(page, size)
                );
        return new DeviceSessionPageResponse(
                sessions.getContent().stream()
                        .map(session -> new DeviceSessionResponse(
                                session.getPublicId(),
                                session.getDeviceType(),
                                session.getDeviceSummary(),
                                session.getLastActivityAt(),
                                session.getPublicId().equals(currentSessionId)
                        ))
                        .toList(),
                sessions.getNumber(),
                sessions.getSize(),
                sessions.getTotalElements(),
                sessions.getTotalPages()
        );
    }
}
