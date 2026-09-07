package com.monsters.service.member;

import com.monsters.dto.auth.ContinuationNextAction;
import com.monsters.dto.member.MemberStateCommandRequest;
import com.monsters.dto.member.MemberStateResponse;
import com.monsters.dto.member.MemberRestorationRequest;
import com.monsters.entity.audit.MemberStateActorType;
import com.monsters.entity.audit.MemberStateAudit;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.exception.member.MemberStateConflictException;
import com.monsters.exception.member.VersionConflictException;
import com.monsters.repository.audit.MemberStateAuditRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.MemberContinuationCredentialRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.service.auth.ContinuationCredentialService;
import com.monsters.service.session.DeviceSessionCommandService;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MemberAccountLifecycleService {

    private static final String SELF_DEACTIVATED = "MEMBER_SELF_DEACTIVATED";
    private static final String SELF_RESTORED = "MEMBER_SELF_RESTORED";

    private final UserRepository userRepository;
    private final MemberContinuationCredentialRepository continuationRepository;
    private final MemberStateAuditRepository auditRepository;
    private final OutboxEventRepository outboxRepository;
    private final EntryRepository entryRepository;
    private final DeviceSessionCommandService sessionCommandService;
    private final ContinuationCredentialService continuationCredentialService;
    private final Clock clock;

    public MemberAccountLifecycleService(
            UserRepository userRepository,
            MemberContinuationCredentialRepository continuationRepository,
            MemberStateAuditRepository auditRepository,
            OutboxEventRepository outboxRepository,
            EntryRepository entryRepository,
            DeviceSessionCommandService sessionCommandService,
            ContinuationCredentialService continuationCredentialService,
            Clock clock
    ) {
        this.userRepository = userRepository;
        this.continuationRepository = continuationRepository;
        this.auditRepository = auditRepository;
        this.outboxRepository = outboxRepository;
        this.entryRepository = entryRepository;
        this.sessionCommandService = sessionCommandService;
        this.continuationCredentialService = continuationCredentialService;
        this.clock = clock;
    }

    @Transactional
    public MemberStateResponse deactivate(Long userId, MemberStateCommandRequest request) {
        User user = userRepository.findForUpdateByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Member not found"));
        requireVersion(user, request.expectedVersion());
        if (user.getMemberState() != MemberState.ACTIVE) {
            throw new MemberStateConflictException("Member cannot self-deactivate from the current state");
        }
        MemberState fromState = user.getMemberState();
        user.deactivate();
        userRepository.saveAndFlush(user);
        LocalDateTime now = now();
        entryRepository.unshareAllByUserId(userId);
        sessionCommandService.revokeAllForMember(userId, SELF_DEACTIVATED);
        continuationRepository.revokeActiveForUser(user, now);
        recordStateChange(user, fromState, SELF_DEACTIVATED, now);
        return new MemberStateResponse(user.getMemberState().name(), user.getVersion(), null);
    }

    @Transactional
    public MemberStateResponse restore(
            Long userId,
            String rawContinuationCredential,
            MemberRestorationRequest request
    ) {
        User user = userRepository.findForUpdateByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Member not found"));
        if (user.getMemberState() != MemberState.USER_DEACTIVATED) {
            throw new MemberStateConflictException("Member cannot be restored from the current state");
        }
        User credentialUser = continuationCredentialService.consume(
                rawContinuationCredential,
                ContinuationNextAction.REACTIVATE_ACCOUNT
        );
        if (!credentialUser.getId().equals(userId)) {
            throw new MemberStateConflictException("Member restoration credential is not owner-scoped");
        }
        MemberState fromState = user.getMemberState();
        user.reactivate();
        userRepository.saveAndFlush(user);
        LocalDateTime now = now();
        recordStateChange(user, fromState, SELF_RESTORED, now);
        return new MemberStateResponse(user.getMemberState().name(), user.getVersion(), "SIGN_IN");
    }

    private void recordStateChange(
            User user,
            MemberState fromState,
            String reason,
            LocalDateTime now
    ) {
        String eventId = UUID.randomUUID().toString();
        auditRepository.save(new MemberStateAudit(
                user,
                eventId,
                fromState,
                user.getMemberState(),
                reason,
                MemberStateActorType.MEMBER,
                now
        ));
        outboxRepository.save(new OutboxEvent(
                eventId,
                "MEMBER",
                user.getPublicId(),
                "MEMBER_STATE_CHANGED",
                "{\"fromState\":\"%s\",\"toState\":\"%s\",\"version\":%d}"
                        .formatted(fromState, user.getMemberState(), user.getVersion()),
                now
        ));
    }

    private void requireVersion(User user, long expectedVersion) {
        if (user.getVersion() != expectedVersion) {
            throw new VersionConflictException("Member version is stale");
        }
    }

    private LocalDateTime now() {
        return LocalDateTime.now(clock);
    }
}
