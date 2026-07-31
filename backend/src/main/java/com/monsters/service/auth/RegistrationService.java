package com.monsters.service.auth;

import com.monsters.dto.auth.RegistrationPolicyResponse;
import com.monsters.dto.auth.RegistrationRequest;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.user.MemberDocumentAcceptance;
import com.monsters.entity.user.MemberDocumentType;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
import com.monsters.entity.user.UserCredential;
import com.monsters.exception.common.BusinessException;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.MemberDocumentAcceptanceRepository;
import com.monsters.repository.user.UserCredentialRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.service.registration.RegistrationRateLimitService;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RegistrationService {

    private static final Logger LOGGER = LoggerFactory.getLogger(RegistrationService.class);

    private final UserRepository userRepository;
    private final UserCredentialRepository userCredentialRepository;
    private final MemberDocumentAcceptanceRepository acceptanceRepository;
    private final OutboxEventRepository outboxRepository;
    private final PasswordEncoder passwordEncoder;
    private final RegistrationPolicyService registrationPolicyService;
    private final RegistrationRateLimitService rateLimitService;
    private final Clock clock;

    public RegistrationService(
            UserRepository userRepository,
            UserCredentialRepository userCredentialRepository,
            MemberDocumentAcceptanceRepository acceptanceRepository,
            OutboxEventRepository outboxRepository,
            PasswordEncoder passwordEncoder,
            RegistrationPolicyService registrationPolicyService,
            RegistrationRateLimitService rateLimitService,
            Clock clock
    ) {
        this.userRepository = userRepository;
        this.userCredentialRepository = userCredentialRepository;
        this.acceptanceRepository = acceptanceRepository;
        this.outboxRepository = outboxRepository;
        this.passwordEncoder = passwordEncoder;
        this.registrationPolicyService = registrationPolicyService;
        this.rateLimitService = rateLimitService;
        this.clock = clock;
    }

    @Transactional
    public void register(RegistrationRequest request, String remoteAddress) {
        RegistrationPolicyResponse policy = registrationPolicyService.currentPolicy();
        requireCurrentPolicy(request, policy);

        String email = normalizeEmail(request.email());
        rateLimitService.accept(email, remoteAddress);
        LOGGER.info("Registration request accepted");
        Optional<User> existingMember = userRepository.findByEmail(email);
        if (existingMember.isPresent()) {
            User member = existingMember.orElseThrow();
            if (!member.isDeleted()
                    && member.getMemberState() == MemberState.PENDING_EMAIL_VERIFICATION) {
                enqueueVerification(member, LocalDateTime.now(clock));
            }
            return;
        }

        LocalDateTime now = LocalDateTime.now(clock);
        User member = userRepository.save(User.pendingEmailVerification(email));
        userCredentialRepository.save(new UserCredential(
                member,
                passwordEncoder.encode(request.password()),
                now
        ));
        acceptanceRepository.save(new MemberDocumentAcceptance(
                member,
                MemberDocumentType.TERMS,
                policy.termsVersion(),
                now
        ));
        acceptanceRepository.save(new MemberDocumentAcceptance(
                member,
                MemberDocumentType.PRIVACY,
                policy.privacyVersion(),
                now
        ));
        enqueueVerification(member, now);
    }

    private void enqueueVerification(User member, LocalDateTime availableAt) {
        outboxRepository.save(new OutboxEvent(
                UUID.randomUUID().toString(),
                "MEMBER",
                member.getPublicId(),
                "EMAIL_VERIFICATION_REQUESTED",
                "{\"memberState\":\"" + MemberState.PENDING_EMAIL_VERIFICATION.name() + "\"}",
                availableAt
        ));
    }

    private void requireCurrentPolicy(
            RegistrationRequest request,
            RegistrationPolicyResponse policy
    ) {
        if (!policy.termsVersion().equals(request.acceptedTermsVersion())
                || !policy.privacyVersion().equals(request.acceptedPrivacyVersion())) {
            throw new BusinessException(
                    HttpStatus.CONFLICT,
                    "REGISTRATION_POLICY_OUTDATED",
                    "Registration policy has changed"
            );
        }
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
