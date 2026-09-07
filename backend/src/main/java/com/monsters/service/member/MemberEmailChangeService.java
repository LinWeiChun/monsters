package com.monsters.service.member;

import com.monsters.dto.member.EmailChangeCompletedResponse;
import com.monsters.dto.member.EmailChangePendingResponse;
import com.monsters.dto.member.EmailChangeRequest;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.session.ReauthenticationPurpose;
import com.monsters.entity.session.UserSession;
import com.monsters.entity.user.MemberEmailChangeRequest;
import com.monsters.entity.user.MemberEmailChangeStatus;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
import com.monsters.exception.common.BusinessException;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.member.MemberStateConflictException;
import com.monsters.exception.member.VersionConflictException;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.MemberEmailChangeRequestRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.security.common.MemberEmailChangeTokenService;
import com.monsters.service.session.DeviceSessionCommandService;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MemberEmailChangeService {

    public static final String REQUESTED_EVENT = "MEMBER_EMAIL_CHANGE_REQUESTED";
    public static final String OLD_EMAIL_NOTIFICATION_EVENT = "MEMBER_EMAIL_CHANGED_OLD_NOTIFICATION";
    public static final String NEW_EMAIL_NOTIFICATION_EVENT = "MEMBER_EMAIL_CHANGED_NEW_NOTIFICATION";
    private static final List<MemberEmailChangeStatus> PENDING_STATUSES = List.of(
            MemberEmailChangeStatus.PENDING_DELIVERY,
            MemberEmailChangeStatus.PENDING_VERIFICATION
    );

    private final UserRepository userRepository;
    private final MemberEmailChangeRequestRepository requestRepository;
    private final OutboxEventRepository outboxRepository;
    private final DeviceSessionCommandService sessionCommandService;
    private final MemberEmailChangeTokenService tokenService;
    private final Clock clock;

    public MemberEmailChangeService(
            UserRepository userRepository,
            MemberEmailChangeRequestRepository requestRepository,
            OutboxEventRepository outboxRepository,
            DeviceSessionCommandService sessionCommandService,
            MemberEmailChangeTokenService tokenService,
            Clock clock
    ) {
        this.userRepository = userRepository;
        this.requestRepository = requestRepository;
        this.outboxRepository = outboxRepository;
        this.sessionCommandService = sessionCommandService;
        this.tokenService = tokenService;
        this.clock = clock;
    }

    @Transactional
    public EmailChangePendingResponse requestChange(
            Long userId,
            String currentSessionId,
            String reauthenticationCredential,
            EmailChangeRequest request
    ) {
        User user = userRepository.findForUpdateByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Member not found"));
        requireActive(user);
        requireVersion(user, request.expectedVersion());
        String newEmail = normalizeEmail(request.newEmail());
        if (newEmail.equals(user.getEmail()) || userRepository.existsByEmailAndDeletedFalse(newEmail)) {
            throw emailConflict();
        }
        UserSession session = sessionCommandService.consumeReauthentication(
                userId,
                currentSessionId,
                reauthenticationCredential,
                ReauthenticationPurpose.EMAIL_CHANGE
        );
        requestRepository.findAllByUser_IdAndStatusIn(userId, PENDING_STATUSES)
                .forEach(MemberEmailChangeRequest::supersede);
        MemberEmailChangeRequest emailChange = requestRepository.save(new MemberEmailChangeRequest(
                user,
                session,
                user.getEmail(),
                newEmail,
                user.getVersion()
        ));
        LocalDateTime now = now();
        outboxRepository.save(new OutboxEvent(
                UUID.randomUUID().toString(),
                "MEMBER_EMAIL_CHANGE",
                emailChange.getPublicId(),
                REQUESTED_EVENT,
                "{}",
                now
        ));
        return new EmailChangePendingResponse(
                emailChange.getPublicId(),
                emailChange.getStatus().name()
        );
    }

    @Transactional
    public EmailChangeCompletedResponse complete(String rawToken) {
        MemberEmailChangeRequest request = requestRepository
                .findForUpdateByTokenHash(tokenService.hashToken(rawToken))
                .orElseThrow(this::invalidToken);
        LocalDateTime now = now();
        if (request.getStatus() == MemberEmailChangeStatus.COMPLETED) {
            throw usedToken();
        }
        if (request.getStatus() != MemberEmailChangeStatus.PENDING_VERIFICATION) {
            throw invalidToken();
        }
        if (request.getExpiresAt() == null || !request.getExpiresAt().isAfter(now)) {
            throw expiredToken();
        }
        User user = userRepository.findForUpdateByIdAndDeletedFalse(request.getUser().getId())
                .orElseThrow(this::invalidToken);
        requireActive(user);
        requireVersion(user, request.getRequestedForVersion());
        if (!user.getEmail().equals(request.getOriginalEmail())
                || userRepository.existsByEmailAndDeletedFalse(request.getNewEmail())) {
            throw emailConflict();
        }
        user.changeEmail(request.getNewEmail());
        userRepository.saveAndFlush(user);
        request.complete(now);
        sessionCommandService.revokeOthersAfterEmailChange(
                user.getId(),
                request.getInitiatingSession().getPublicId()
        );
        enqueueNotification(request, OLD_EMAIL_NOTIFICATION_EVENT, now);
        enqueueNotification(request, NEW_EMAIL_NOTIFICATION_EVENT, now);
        return new EmailChangeCompletedResponse(
                request.getStatus().name(),
                user.getVersion()
        );
    }

    private void enqueueNotification(
            MemberEmailChangeRequest request,
            String eventType,
            LocalDateTime now
    ) {
        outboxRepository.save(new OutboxEvent(
                UUID.randomUUID().toString(),
                "MEMBER_EMAIL_CHANGE",
                request.getPublicId(),
                eventType,
                "{}",
                now
        ));
    }

    private void requireActive(User user) {
        if (user.getMemberState() != MemberState.ACTIVE) {
            throw new MemberStateConflictException("Member cannot change Email in the current state");
        }
    }

    private void requireVersion(User user, long expectedVersion) {
        if (user.getVersion() != expectedVersion) {
            throw new VersionConflictException("Member version is stale");
        }
    }

    private String normalizeEmail(String value) {
        return value.trim().toLowerCase(Locale.ROOT);
    }

    private BusinessException emailConflict() {
        return new BusinessException(
                HttpStatus.CONFLICT,
                "EMAIL_CHANGE_CONFLICT",
                "Email cannot be changed"
        );
    }

    private BusinessException invalidToken() {
        return new BusinessException(
                HttpStatus.BAD_REQUEST,
                "EMAIL_CHANGE_TOKEN_INVALID",
                "Email change token is invalid"
        );
    }

    private BusinessException usedToken() {
        return new BusinessException(
                HttpStatus.BAD_REQUEST,
                "EMAIL_CHANGE_TOKEN_USED",
                "Email change token was already used"
        );
    }

    private BusinessException expiredToken() {
        return new BusinessException(
                HttpStatus.BAD_REQUEST,
                "EMAIL_CHANGE_TOKEN_EXPIRED",
                "Email change token has expired"
        );
    }

    private LocalDateTime now() {
        return LocalDateTime.now(clock);
    }
}
