package com.monsters.service.member;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.auth.ContinuationNextAction;
import com.monsters.dto.member.MemberStateCommandRequest;
import com.monsters.dto.member.MemberRestorationRequest;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
import com.monsters.repository.audit.MemberStateAuditRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.MemberContinuationCredentialRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.service.auth.ContinuationCredentialService;
import com.monsters.service.session.DeviceSessionCommandService;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class MemberAccountLifecycleServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private MemberContinuationCredentialRepository continuationRepository;
    @Mock private MemberStateAuditRepository auditRepository;
    @Mock private OutboxEventRepository outboxRepository;
    @Mock private EntryRepository entryRepository;
    @Mock private DeviceSessionCommandService sessionCommandService;
    @Mock private ContinuationCredentialService continuationCredentialService;

    @Test
    void deactivateShouldRevokeEverySessionAndPermanentlyUnshare() {
        User user = user(5L);
        when(userRepository.findForUpdateByIdAndDeletedFalse(7L)).thenReturn(Optional.of(user));

        var response = service().deactivate(7L, new MemberStateCommandRequest(true, 5L));

        assertThat(response.memberState()).isEqualTo("USER_DEACTIVATED");
        assertThat(user.getMemberState()).isEqualTo(MemberState.USER_DEACTIVATED);
        verify(entryRepository).unshareAllByUserId(7L);
        verify(sessionCommandService).revokeAllForMember(7L, "MEMBER_SELF_DEACTIVATED");
        verify(continuationRepository).revokeActiveForUser(any(User.class), any());
    }

    @Test
    void restoreShouldConsumeOwnerContinuationWithoutRestoringShares() {
        User user = user(5L);
        user.deactivate();
        when(userRepository.findForUpdateByIdAndDeletedFalse(7L)).thenReturn(Optional.of(user));
        when(continuationCredentialService.consume(
                "continuation",
                ContinuationNextAction.REACTIVATE_ACCOUNT
        )).thenReturn(user);

        var response = service().restore(
                7L,
                "continuation",
                new MemberRestorationRequest(true)
        );

        assertThat(response.memberState()).isEqualTo("ACTIVE");
        assertThat(response.nextAction()).isEqualTo("SIGN_IN");
        verify(entryRepository, never()).unshareAllByUserId(any());
    }

    private MemberAccountLifecycleService service() {
        return new MemberAccountLifecycleService(
                userRepository,
                continuationRepository,
                auditRepository,
                outboxRepository,
                entryRepository,
                sessionCommandService,
                continuationCredentialService,
                Clock.fixed(Instant.parse("2026-09-01T00:00:00Z"), ZoneOffset.UTC)
        );
    }

    private User user(long version) {
        User user = new User("legacy", "old@example.com", "小貘");
        ReflectionTestUtils.setField(user, "id", 7L);
        ReflectionTestUtils.setField(user, "version", version);
        return user;
    }
}
