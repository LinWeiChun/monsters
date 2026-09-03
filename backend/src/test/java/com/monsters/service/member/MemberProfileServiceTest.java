package com.monsters.service.member;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.member.PublicNicknameUpdateRequest;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.user.User;
import com.monsters.exception.member.VersionConflictException;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.BirthdayCorrectionRequestRepository;
import com.monsters.repository.user.MemberEmailChangeRequestRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.service.eligibility.EligibilityRules;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneId;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class MemberProfileServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private MemberEmailChangeRequestRepository emailChangeRepository;
    @Mock private BirthdayCorrectionRequestRepository birthdayCorrectionRepository;
    @Mock private OutboxEventRepository outboxRepository;

    @Test
    void updatePublicNicknameShouldNormalizeAndPublishOnlyVersion() {
        User user = activeUser(7L, 3L);
        when(userRepository.findForUpdateByIdAndDeletedFalse(7L)).thenReturn(Optional.of(user));
        when(emailChangeRepository.findFirstByUser_IdAndStatusInOrderByIdDesc(any(), anyList()))
                .thenReturn(Optional.empty());
        when(birthdayCorrectionRepository.findFirstByUser_IdAndStatusInOrderByIdDesc(any(), anyList()))
                .thenReturn(Optional.empty());

        var response = service().updatePublicNickname(
                7L,
                new PublicNicknameUpdateRequest("  小貘 e\u0301  ", true, 3L)
        );

        assertThat(user.getUserName()).isEqualTo("小貘 é");
        assertThat(response.publicNickname()).isEqualTo("小貘 é");
        ArgumentCaptor<OutboxEvent> event = ArgumentCaptor.forClass(OutboxEvent.class);
        verify(outboxRepository).save(event.capture());
        assertThat(event.getValue().getEventType()).isEqualTo("PUBLIC_NICKNAME_UPDATED");
        assertThat(event.getValue().getPayload()).doesNotContain("小貘");
    }

    @Test
    void updatePublicNicknameShouldRejectStaleVersion() {
        User user = activeUser(7L, 4L);
        when(userRepository.findForUpdateByIdAndDeletedFalse(7L)).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> service().updatePublicNickname(
                7L,
                new PublicNicknameUpdateRequest("新暱稱", true, 3L)
        )).isInstanceOf(VersionConflictException.class);
    }

    private MemberProfileService service() {
        Clock clock = Clock.fixed(Instant.parse("2026-09-01T00:00:00Z"), ZoneId.of("Asia/Taipei"));
        return new MemberProfileService(
                userRepository,
                emailChangeRepository,
                birthdayCorrectionRepository,
                outboxRepository,
                new EligibilityRules(clock),
                clock
        );
    }

    private User activeUser(Long id, long version) {
        User user = new User("legacy", "old@example.com", "原暱稱");
        ReflectionTestUtils.setField(user, "id", id);
        ReflectionTestUtils.setField(user, "version", version);
        return user;
    }
}
