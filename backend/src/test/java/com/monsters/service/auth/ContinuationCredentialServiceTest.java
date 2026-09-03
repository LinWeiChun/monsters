package com.monsters.service.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

import com.monsters.dto.auth.ContinuationNextAction;
import com.monsters.entity.user.MemberContinuationCredential;
import com.monsters.entity.user.User;
import com.monsters.exception.common.BusinessException;
import com.monsters.repository.user.BirthdayCorrectionRequestRepository;
import com.monsters.repository.user.MemberContinuationCredentialRepository;
import com.monsters.repository.user.UserRepository;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class ContinuationCredentialServiceTest {

    private static final Clock CLOCK = Clock.fixed(
            Instant.parse("2026-09-01T03:00:00Z"),
            ZoneOffset.UTC
    );

    @Mock private MemberContinuationCredentialRepository credentialRepository;
    @Mock private BirthdayCorrectionRequestRepository birthdayCorrectionRepository;
    @Mock private UserRepository userRepository;

    private ContinuationCredentialService service;

    @BeforeEach
    void setUp() {
        service = new ContinuationCredentialService(
                credentialRepository,
                birthdayCorrectionRepository,
                userRepository,
                CLOCK
        );
    }

    @Test
    void shouldIssueReviewActionWhenEligibilityIsHeldByBirthdayCorrection() {
        User member = User.pendingEligibilityFromVerifiedEmail("member@example.test");
        ReflectionTestUtils.setField(member, "id", 7L);
        when(birthdayCorrectionRepository.existsByUser_IdAndStatusIn(eq(7L), anyList()))
                .thenReturn(true);
        when(userRepository.findPersistedVersionById(7L)).thenReturn(Optional.of(0L));

        IssuedContinuationCredential issued = service.issueFor(member);

        assertThat(issued.nextAction()).isEqualTo(ContinuationNextAction.REVIEW_BIRTHDAY_CORRECTION);
        assertThat(issued.expiresIn()).isEqualTo(600);
    }

    @Test
    void shouldRejectContinuationCredentialAfterMemberVersionChanges() {
        User member = new User("synthetic_account", "member@example.test", "Member");
        ReflectionTestUtils.setField(member, "id", 7L);
        member.deactivate();
        when(userRepository.findPersistedVersionById(7L)).thenReturn(Optional.of(0L));
        ArgumentCaptor<MemberContinuationCredential> saved =
                ArgumentCaptor.forClass(MemberContinuationCredential.class);
        when(credentialRepository.save(saved.capture())).thenAnswer(invocation -> invocation.getArgument(0));
        IssuedContinuationCredential issued = service.issueFor(member);
        when(credentialRepository.findForUpdateByTokenHash(any()))
                .thenReturn(Optional.of(saved.getValue()));
        ReflectionTestUtils.setField(member, "version", 1L);

        assertThatThrownBy(() -> service.consume(
                issued.credential(),
                ContinuationNextAction.REACTIVATE_ACCOUNT
        )).isInstanceOf(BusinessException.class)
                .hasMessage("Member restoration continuation is invalid or expired");
    }
}
