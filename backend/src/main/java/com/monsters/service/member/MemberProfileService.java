package com.monsters.service.member;

import com.monsters.dto.member.MemberProfileResponse;
import com.monsters.dto.member.MemberWorkflowSummary;
import com.monsters.dto.member.PublicNicknameUpdateRequest;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.user.BirthdayCorrectionStatus;
import com.monsters.entity.user.MemberEmailChangeStatus;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.member.MemberStateConflictException;
import com.monsters.exception.member.VersionConflictException;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.BirthdayCorrectionRequestRepository;
import com.monsters.repository.user.MemberEmailChangeRequestRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.service.eligibility.EligibilityRules;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MemberProfileService {

    public static final String PUBLIC_NICKNAME_UPDATED = "PUBLIC_NICKNAME_UPDATED";
    private static final List<MemberEmailChangeStatus> PENDING_EMAIL_STATUSES = List.of(
            MemberEmailChangeStatus.PENDING_DELIVERY,
            MemberEmailChangeStatus.PENDING_VERIFICATION
    );
    private static final List<BirthdayCorrectionStatus> PENDING_BIRTHDAY_STATUSES = List.of(
            BirthdayCorrectionStatus.PENDING_REVIEW,
            BirthdayCorrectionStatus.APPEALED
    );

    private final UserRepository userRepository;
    private final MemberEmailChangeRequestRepository emailChangeRepository;
    private final BirthdayCorrectionRequestRepository birthdayCorrectionRepository;
    private final OutboxEventRepository outboxRepository;
    private final EligibilityRules eligibilityRules;
    private final Clock clock;

    public MemberProfileService(
            UserRepository userRepository,
            MemberEmailChangeRequestRepository emailChangeRepository,
            BirthdayCorrectionRequestRepository birthdayCorrectionRepository,
            OutboxEventRepository outboxRepository,
            EligibilityRules eligibilityRules,
            Clock clock
    ) {
        this.userRepository = userRepository;
        this.emailChangeRepository = emailChangeRepository;
        this.birthdayCorrectionRepository = birthdayCorrectionRepository;
        this.outboxRepository = outboxRepository;
        this.eligibilityRules = eligibilityRules;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public MemberProfileResponse getProfile(Long userId) {
        return toResponse(activeMember(userId));
    }

    @Transactional
    public MemberProfileResponse updatePublicNickname(
            Long userId,
            PublicNicknameUpdateRequest request
    ) {
        User user = userRepository.findForUpdateByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Member not found"));
        requireActive(user);
        requireVersion(user, request.expectedVersion());
        String nickname = eligibilityRules.normalizePublicNickname(request.publicNickname());
        user.updatePublicNickname(nickname);
        userRepository.saveAndFlush(user);
        LocalDateTime now = LocalDateTime.now(clock);
        outboxRepository.save(new OutboxEvent(
                UUID.randomUUID().toString(),
                "MEMBER",
                user.getPublicId(),
                PUBLIC_NICKNAME_UPDATED,
                versionPayload(user),
                now
        ));
        return toResponse(user);
    }

    MemberProfileResponse toResponse(User user) {
        MemberWorkflowSummary pendingEmail = emailChangeRepository
                .findFirstByUser_IdAndStatusInOrderByIdDesc(user.getId(), PENDING_EMAIL_STATUSES)
                .map(value -> new MemberWorkflowSummary(
                        value.getPublicId(),
                        value.getStatus().name(),
                        value.getNewEmail()
                ))
                .orElse(null);
        MemberWorkflowSummary pendingBirthday = birthdayCorrectionRepository
                .findFirstByUser_IdAndStatusInOrderByIdDesc(user.getId(), PENDING_BIRTHDAY_STATUSES)
                .map(value -> new MemberWorkflowSummary(
                        value.getPublicId(),
                        value.getStatus().name(),
                        value.getRequestedBirthday().toString()
                ))
                .orElse(null);
        return new MemberProfileResponse(
                user.getPublicId(),
                user.getEmail(),
                user.getUserName(),
                user.getBirthday(),
                user.getServiceRegion(),
                user.getEligibilityStatus().name(),
                user.getCommunityEligibilityStatus().name(),
                user.getMemberState().name(),
                user.getVersion(),
                pendingEmail,
                pendingBirthday
        );
    }

    private User activeMember(Long userId) {
        User user = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Member not found"));
        requireActive(user);
        return user;
    }

    private void requireActive(User user) {
        if (user.getMemberState() != MemberState.ACTIVE) {
            throw new MemberStateConflictException("Member data cannot be changed in the current state");
        }
    }

    private void requireVersion(User user, long expectedVersion) {
        if (user.getVersion() != expectedVersion) {
            throw new VersionConflictException("Member version is stale");
        }
    }

    private String versionPayload(User user) {
        return "{\"version\":%d}".formatted(user.getVersion());
    }
}
