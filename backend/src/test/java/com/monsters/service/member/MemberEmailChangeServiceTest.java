package com.monsters.service.member;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.member.EmailChangeRequest;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.session.ReauthenticationPurpose;
import com.monsters.entity.session.UserSession;
import com.monsters.entity.user.MemberEmailChangeRequest;
import com.monsters.entity.user.MemberEmailChangeStatus;
import com.monsters.entity.user.User;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.MemberEmailChangeRequestRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.security.common.MemberEmailChangeTokenService;
import com.monsters.service.session.DeviceSessionCommandService;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class MemberEmailChangeServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private MemberEmailChangeRequestRepository requestRepository;
    @Mock private OutboxEventRepository outboxRepository;
    @Mock private DeviceSessionCommandService sessionCommandService;

    private final MemberEmailChangeTokenService tokenService = new MemberEmailChangeTokenService();

    @Test
    void requestShouldKeepCurrentEmailAndBindPurposeVersionAndSession() {
        User user = activeUser(7L, 4L);
        UserSession session = session(user);
        when(userRepository.findForUpdateByIdAndDeletedFalse(7L)).thenReturn(Optional.of(user));
        when(userRepository.existsByEmailAndDeletedFalse("new@example.com")).thenReturn(false);
        when(sessionCommandService.consumeReauthentication(
                7L,
                session.getPublicId(),
                "proof",
                ReauthenticationPurpose.EMAIL_CHANGE
        )).thenReturn(session);
        when(requestRepository.save(any(MemberEmailChangeRequest.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        var response = service().requestChange(
                7L,
                session.getPublicId(),
                "proof",
                new EmailChangeRequest(" New@Example.com ", 4L)
        );

        assertThat(user.getEmail()).isEqualTo("old@example.com");
        assertThat(response.status()).isEqualTo("PENDING_DELIVERY");
        ArgumentCaptor<MemberEmailChangeRequest> request = ArgumentCaptor.forClass(
                MemberEmailChangeRequest.class
        );
        verify(requestRepository).save(request.capture());
        assertThat(request.getValue().getNewEmail()).isEqualTo("new@example.com");
        assertThat(request.getValue().getOriginalEmail()).isEqualTo("old@example.com");
        assertThat(request.getValue().getRequestedForVersion()).isEqualTo(4L);
        ArgumentCaptor<OutboxEvent> event = ArgumentCaptor.forClass(OutboxEvent.class);
        verify(outboxRepository).save(event.capture());
        assertThat(event.getValue().getPayload()).isEqualTo("{}");
    }

    @Test
    void completeShouldSwitchEmailAndRevokeOnlyOtherSessions() {
        User user = activeUser(7L, 4L);
        UserSession session = session(user);
        String rawToken = "token-value";
        MemberEmailChangeRequest request = new MemberEmailChangeRequest(
                user,
                session,
                user.getEmail(),
                "new@example.com",
                4L
        );
        request.awaitVerification(
                tokenService.hashToken(rawToken),
                LocalDateTime.of(2026, 9, 2, 8, 0)
        );
        when(requestRepository.findForUpdateByTokenHash(tokenService.hashToken(rawToken)))
                .thenReturn(Optional.of(request));
        when(userRepository.findForUpdateByIdAndDeletedFalse(7L)).thenReturn(Optional.of(user));
        when(userRepository.existsByEmailAndDeletedFalse("new@example.com")).thenReturn(false);

        var response = service().complete(rawToken);

        assertThat(user.getEmail()).isEqualTo("new@example.com");
        assertThat(request.getStatus()).isEqualTo(MemberEmailChangeStatus.COMPLETED);
        assertThat(response.status()).isEqualTo("COMPLETED");
        verify(sessionCommandService).revokeOthersAfterEmailChange(7L, session.getPublicId());
    }

    private MemberEmailChangeService service() {
        return new MemberEmailChangeService(
                userRepository,
                requestRepository,
                outboxRepository,
                sessionCommandService,
                tokenService,
                clock()
        );
    }

    private User activeUser(Long id, long version) {
        User user = new User("legacy", "old@example.com", "小貘");
        ReflectionTestUtils.setField(user, "id", id);
        ReflectionTestUtils.setField(user, "version", version);
        return user;
    }

    private UserSession session(User user) {
        UserSession session = new UserSession(user, LocalDateTime.of(2026, 9, 1, 8, 0), 3600, 7200);
        ReflectionTestUtils.setField(session, "id", 10L);
        return session;
    }

    private Clock clock() {
        return Clock.fixed(Instant.parse("2026-09-01T00:00:00Z"), ZoneId.of("Asia/Taipei"));
    }
}
