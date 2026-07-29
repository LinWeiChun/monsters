package com.monsters.service.member;

import com.monsters.entity.audit.MemberStateActorType;
import com.monsters.entity.audit.MemberStateAudit;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.member.MemberStateConflictException;
import com.monsters.exception.member.VersionConflictException;
import com.monsters.repository.audit.MemberStateAuditRepository;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.MemberContinuationCredentialRepository;
import com.monsters.repository.user.UserRepository;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MemberLifecycleService {

    private static final String AGGREGATE_TYPE = "MEMBER";
    private static final String EVENT_TYPE = "MEMBER_STATE_CHANGED";
    private static final String ELIGIBILITY_COMPLETED = "ELIGIBILITY_COMPLETED";

    private final UserRepository userRepository;
    private final MemberContinuationCredentialRepository continuationCredentialRepository;
    private final MemberStateAuditRepository auditRepository;
    private final OutboxEventRepository outboxRepository;
    private final Clock clock;

    public MemberLifecycleService(
            UserRepository userRepository,
            MemberContinuationCredentialRepository continuationCredentialRepository,
            MemberStateAuditRepository auditRepository,
            OutboxEventRepository outboxRepository,
            Clock clock
    ) {
        this.userRepository = userRepository;
        this.continuationCredentialRepository = continuationCredentialRepository;
        this.auditRepository = auditRepository;
        this.outboxRepository = outboxRepository;
        this.clock = clock;
    }

    @Transactional
    public void completeEligibility(Long memberId, long expectedVersion) {
        User user = userRepository.findByIdAndDeletedFalse(memberId)
                .orElseThrow(() -> new ResourceNotFoundException("Member not found"));
        if (user.getVersion() != expectedVersion) {
            throw new VersionConflictException("Member version is stale");
        }
        if (user.getMemberState() != MemberState.PENDING_ELIGIBILITY) {
            throw new MemberStateConflictException("Member cannot complete eligibility from the current state");
        }

        MemberState fromState = user.getMemberState();
        user.completeEligibility();
        userRepository.saveAndFlush(user);

        LocalDateTime occurredAt = LocalDateTime.now(clock);
        continuationCredentialRepository.revokeActiveForUser(user, occurredAt);
        String eventId = UUID.randomUUID().toString();
        auditRepository.save(new MemberStateAudit(
                user,
                eventId,
                fromState,
                user.getMemberState(),
                ELIGIBILITY_COMPLETED,
                MemberStateActorType.SYSTEM,
                occurredAt
        ));
        outboxRepository.save(new OutboxEvent(
                eventId,
                AGGREGATE_TYPE,
                user.getPublicId(),
                EVENT_TYPE,
                stateChangedPayload(fromState, user),
                occurredAt
        ));
    }

    private String stateChangedPayload(MemberState fromState, User user) {
        return """
                {"fromState":"%s","toState":"%s","version":%d}
                """.formatted(fromState, user.getMemberState(), user.getVersion()).trim();
    }
}
