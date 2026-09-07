package com.monsters.service.member;

import com.monsters.dto.member.BirthdayCorrectionCommand;
import com.monsters.dto.member.BirthdayCorrectionResponse;
import com.monsters.entity.audit.MemberStateActorType;
import com.monsters.entity.audit.MemberStateAudit;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.session.ReauthenticationPurpose;
import com.monsters.entity.user.BirthdayCorrectionRequest;
import com.monsters.entity.user.BirthdayCorrectionStatus;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
import com.monsters.exception.common.BusinessException;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.member.MemberStateConflictException;
import com.monsters.exception.member.VersionConflictException;
import com.monsters.repository.audit.MemberStateAuditRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.BirthdayCorrectionRequestRepository;
import com.monsters.repository.user.MemberContinuationCredentialRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.service.eligibility.EligibilityAgeBand;
import com.monsters.service.eligibility.EligibilityRules;
import com.monsters.service.session.DeviceSessionCommandService;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MemberBirthdayCorrectionService {

    public static final String REQUESTED_EVENT = "BIRTHDAY_CORRECTION_REQUESTED";
    public static final String AUTO_APPROVED_EVENT = "BIRTHDAY_CORRECTION_AUTO_APPROVED";
    private static final String RESTRICTION_REASON = "BIRTHDAY_CORRECTION_RESTRICTION";
    private static final List<BirthdayCorrectionStatus> PENDING_STATUSES = List.of(
            BirthdayCorrectionStatus.PENDING_REVIEW,
            BirthdayCorrectionStatus.APPEALED
    );

    private final UserRepository userRepository;
    private final BirthdayCorrectionRequestRepository requestRepository;
    private final MemberContinuationCredentialRepository continuationRepository;
    private final MemberStateAuditRepository auditRepository;
    private final OutboxEventRepository outboxRepository;
    private final EntryRepository entryRepository;
    private final DeviceSessionCommandService sessionCommandService;
    private final EligibilityRules eligibilityRules;
    private final Clock clock;

    public MemberBirthdayCorrectionService(
            UserRepository userRepository,
            BirthdayCorrectionRequestRepository requestRepository,
            MemberContinuationCredentialRepository continuationRepository,
            MemberStateAuditRepository auditRepository,
            OutboxEventRepository outboxRepository,
            EntryRepository entryRepository,
            DeviceSessionCommandService sessionCommandService,
            EligibilityRules eligibilityRules,
            Clock clock
    ) {
        this.userRepository = userRepository;
        this.requestRepository = requestRepository;
        this.continuationRepository = continuationRepository;
        this.auditRepository = auditRepository;
        this.outboxRepository = outboxRepository;
        this.entryRepository = entryRepository;
        this.sessionCommandService = sessionCommandService;
        this.eligibilityRules = eligibilityRules;
        this.clock = clock;
    }

    @Transactional
    public BirthdayCorrectionResponse requestCorrection(
            Long userId,
            String currentSessionId,
            String reauthenticationCredential,
            BirthdayCorrectionCommand command
    ) {
        User user = userRepository.findForUpdateByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Member not found"));
        requireActive(user);
        requireVersion(user, command.expectedVersion());
        if (user.getBirthday() == null) {
            throw new MemberStateConflictException("Member birthday is not available for correction");
        }
        if (user.getBirthday().equals(command.birthday())) {
            throw new BusinessException(
                    HttpStatus.BAD_REQUEST,
                    "BIRTHDAY_CORRECTION_UNCHANGED",
                    "Corrected birthday must be different"
            );
        }
        if (requestRepository.existsByUser_IdAndStatusIn(userId, PENDING_STATUSES)) {
            throw new BusinessException(
                    HttpStatus.CONFLICT,
                    "BIRTHDAY_CORRECTION_ALREADY_PENDING",
                    "A birthday correction is already pending"
            );
        }
        EligibilityAgeBand fromBand = eligibilityRules.classifyAge(user.getBirthday());
        EligibilityAgeBand toBand = eligibilityRules.classifyAge(command.birthday());
        sessionCommandService.consumeReauthentication(
                userId,
                currentSessionId,
                reauthenticationCredential,
                ReauthenticationPurpose.BIRTHDAY_CORRECTION
        );

        LocalDateTime now = now();
        long requestedForVersion = user.getVersion();
        boolean sameBand = fromBand == toBand;
        BirthdayCorrectionStatus status = sameBand
                ? BirthdayCorrectionStatus.AUTO_APPROVED
                : BirthdayCorrectionStatus.PENDING_REVIEW;
        BirthdayCorrectionRequest correction = new BirthdayCorrectionRequest(
                user,
                user.getBirthday(),
                command.birthday(),
                command.reason(),
                requestedForVersion,
                fromBand,
                toBand,
                status,
                now
        );

        boolean restricted = !sameBand && isLowerPrivilege(toBand, fromBand);
        MemberState previousState = user.getMemberState();
        if (sameBand) {
            user.correctBirthday(command.birthday());
            userRepository.saveAndFlush(user);
        } else if (restricted) {
            user.restrictForBirthdayCorrection(toBand);
            userRepository.saveAndFlush(user);
            correction.markRestricted(now);
            entryRepository.unshareAllByUserId(userId);
            sessionCommandService.revokeAllForMember(userId, RESTRICTION_REASON);
            continuationRepository.revokeActiveForUser(user, now);
            recordStateChange(user, previousState, now);
        }
        requestRepository.save(correction);
        outboxRepository.save(new OutboxEvent(
                UUID.randomUUID().toString(),
                "BIRTHDAY_CORRECTION",
                correction.getPublicId(),
                sameBand ? AUTO_APPROVED_EVENT : REQUESTED_EVENT,
                versionPayload(user),
                now
        ));
        return new BirthdayCorrectionResponse(
                correction.getPublicId(),
                correction.getStatus().name(),
                restricted,
                user.getMemberState().name(),
                user.getVersion()
        );
    }

    private void recordStateChange(User user, MemberState fromState, LocalDateTime now) {
        String eventId = UUID.randomUUID().toString();
        auditRepository.save(new MemberStateAudit(
                user,
                eventId,
                fromState,
                user.getMemberState(),
                RESTRICTION_REASON,
                MemberStateActorType.MEMBER,
                now
        ));
        outboxRepository.save(new OutboxEvent(
                eventId,
                "MEMBER",
                user.getPublicId(),
                "MEMBER_STATE_CHANGED",
                statePayload(fromState, user),
                now
        ));
    }

    private boolean isLowerPrivilege(EligibilityAgeBand target, EligibilityAgeBand current) {
        return target.ordinal() < current.ordinal();
    }

    private void requireActive(User user) {
        if (user.getMemberState() != MemberState.ACTIVE) {
            throw new MemberStateConflictException("Birthday cannot be corrected in the current state");
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

    private String statePayload(MemberState fromState, User user) {
        return "{\"fromState\":\"%s\",\"toState\":\"%s\",\"version\":%d}"
                .formatted(fromState, user.getMemberState(), user.getVersion());
    }

    private LocalDateTime now() {
        return LocalDateTime.now(clock);
    }
}
