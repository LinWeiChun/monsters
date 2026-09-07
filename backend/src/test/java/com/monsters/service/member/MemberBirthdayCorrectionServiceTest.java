package com.monsters.service.member;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.member.BirthdayCorrectionCommand;
import com.monsters.entity.session.ReauthenticationPurpose;
import com.monsters.entity.user.BirthdayCorrectionReason;
import com.monsters.entity.user.BirthdayCorrectionRequest;
import com.monsters.entity.user.CommunityEligibilityStatus;
import com.monsters.entity.user.EligibilityStatus;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
import com.monsters.repository.audit.MemberStateAuditRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.BirthdayCorrectionRequestRepository;
import com.monsters.repository.user.MemberContinuationCredentialRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.service.eligibility.EligibilityRules;
import com.monsters.service.session.DeviceSessionCommandService;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class MemberBirthdayCorrectionServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private BirthdayCorrectionRequestRepository requestRepository;
    @Mock private MemberContinuationCredentialRepository continuationRepository;
    @Mock private MemberStateAuditRepository auditRepository;
    @Mock private OutboxEventRepository outboxRepository;
    @Mock private EntryRepository entryRepository;
    @Mock private DeviceSessionCommandService sessionCommandService;

    @Test
    void sameAgeBandShouldAutoApproveWithoutRevokingSessions() {
        User user = adultUser();
        when(userRepository.findForUpdateByIdAndDeletedFalse(7L)).thenReturn(Optional.of(user));
        when(requestRepository.existsByUser_IdAndStatusIn(eq(7L), anyList())).thenReturn(false);
        when(requestRepository.save(any(BirthdayCorrectionRequest.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        var response = service().requestCorrection(
                7L,
                "session-id",
                "proof",
                new BirthdayCorrectionCommand(
                        LocalDate.of(1999, 8, 31),
                        BirthdayCorrectionReason.DATA_ENTRY_ERROR,
                        3L
                )
        );

        assertThat(response.status()).isEqualTo("AUTO_APPROVED");
        assertThat(response.restricted()).isFalse();
        assertThat(user.getBirthday()).isEqualTo(LocalDate.of(1999, 8, 31));
        verify(sessionCommandService, never()).revokeAllForMember(any(), any());
    }

    @Test
    void adultToMinorShouldImmediatelyRestrictRevokeAndUnshare() {
        User user = adultUser();
        when(userRepository.findForUpdateByIdAndDeletedFalse(7L)).thenReturn(Optional.of(user));
        when(requestRepository.existsByUser_IdAndStatusIn(eq(7L), anyList())).thenReturn(false);
        when(requestRepository.save(any(BirthdayCorrectionRequest.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        var response = service().requestCorrection(
                7L,
                "session-id",
                "proof",
                new BirthdayCorrectionCommand(
                        LocalDate.of(2010, 9, 1),
                        BirthdayCorrectionReason.LEGAL_RECORD_CORRECTION,
                        3L
                )
        );

        assertThat(response.status()).isEqualTo("PENDING_REVIEW");
        assertThat(response.restricted()).isTrue();
        assertThat(user.getMemberState()).isEqualTo(MemberState.PENDING_ELIGIBILITY);
        assertThat(user.getEligibilityStatus()).isEqualTo(EligibilityStatus.GUARDIAN_CONSENT_PENDING);
        assertThat(user.getCommunityEligibilityStatus()).isEqualTo(CommunityEligibilityStatus.INELIGIBLE);
        assertThat(user.getBirthday()).isEqualTo(LocalDate.of(2000, 1, 1));
        verify(entryRepository).unshareAllByUserId(7L);
        verify(sessionCommandService).revokeAllForMember(
                7L,
                "BIRTHDAY_CORRECTION_RESTRICTION"
        );
        verify(continuationRepository).revokeActiveForUser(any(User.class), any());
        verify(sessionCommandService).consumeReauthentication(
                7L,
                "session-id",
                "proof",
                ReauthenticationPurpose.BIRTHDAY_CORRECTION
        );
    }

    private MemberBirthdayCorrectionService service() {
        Clock clock = Clock.fixed(Instant.parse("2026-09-01T00:00:00Z"), ZoneId.of("Asia/Taipei"));
        return new MemberBirthdayCorrectionService(
                userRepository,
                requestRepository,
                continuationRepository,
                auditRepository,
                outboxRepository,
                entryRepository,
                sessionCommandService,
                new EligibilityRules(clock),
                clock
        );
    }

    private User adultUser() {
        User user = new User("legacy", "old@example.com", "小貘");
        ReflectionTestUtils.setField(user, "id", 7L);
        ReflectionTestUtils.setField(user, "version", 3L);
        ReflectionTestUtils.setField(user, "birthday", LocalDate.of(2000, 1, 1));
        ReflectionTestUtils.setField(user, "serviceRegion", "TW");
        ReflectionTestUtils.setField(user, "eligibilityStatus", EligibilityStatus.ELIGIBLE_ADULT);
        ReflectionTestUtils.setField(
                user,
                "communityEligibilityStatus",
                CommunityEligibilityStatus.ELIGIBLE
        );
        return user;
    }
}
