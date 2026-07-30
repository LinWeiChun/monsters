package com.monsters.service.registration;

import com.monsters.dto.auth.EmailVerificationResendRequest;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.user.MemberState;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.UserRepository;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EmailVerificationResendService {

    private final RegistrationRateLimitService rateLimitService;
    private final UserRepository userRepository;
    private final OutboxEventRepository outboxRepository;
    private final Clock clock;

    public EmailVerificationResendService(
            RegistrationRateLimitService rateLimitService,
            UserRepository userRepository,
            OutboxEventRepository outboxRepository,
            Clock clock
    ) {
        this.rateLimitService = rateLimitService;
        this.userRepository = userRepository;
        this.outboxRepository = outboxRepository;
        this.clock = clock;
    }

    @Transactional
    public void request(EmailVerificationResendRequest request, String remoteAddress) {
        String email = request.email().trim().toLowerCase(Locale.ROOT);
        rateLimitService.accept(email, remoteAddress);
        userRepository.findByEmailAndDeletedFalse(email)
                .filter(user -> user.getMemberState() == MemberState.PENDING_EMAIL_VERIFICATION)
                .ifPresent(member -> {
                    LocalDateTime now = LocalDateTime.now(clock);
                    outboxRepository.save(new OutboxEvent(
                            UUID.randomUUID().toString(),
                            "MEMBER",
                            member.getPublicId(),
                            "EMAIL_VERIFICATION_REQUESTED",
                            "{\"memberState\":\"PENDING_EMAIL_VERIFICATION\"}",
                            now
                    ));
                });
    }
}
