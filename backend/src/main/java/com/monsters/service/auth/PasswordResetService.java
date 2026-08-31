package com.monsters.service.auth;

import com.monsters.dto.auth.PasswordResetCompletionRequest;
import com.monsters.dto.auth.PasswordResetEmailRequest;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.user.PasswordResetToken;
import com.monsters.entity.user.User;
import com.monsters.entity.user.UserCredential;
import com.monsters.exception.common.BusinessException;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.PasswordResetTokenRepository;
import com.monsters.repository.user.UserCredentialRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.security.common.PasswordResetTokenService;
import com.monsters.security.password.PasswordHashService;
import com.monsters.security.password.PasswordPolicy;
import com.monsters.service.session.DeviceSessionCommandService;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PasswordResetService {

    static final String REQUESTED_EVENT = "PASSWORD_RESET_REQUESTED";
    private static final String COMPLETED_EVENT = "PASSWORD_RESET_COMPLETED";

    private final UserRepository userRepository;
    private final UserCredentialRepository credentialRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final OutboxEventRepository outboxRepository;
    private final PasswordResetTokenService tokenService;
    private final PasswordPolicy passwordPolicy;
    private final PasswordHashService passwordHashService;
    private final DeviceSessionCommandService sessionCommandService;
    private final PasswordResetRateLimitService rateLimitService;
    private final Clock clock;

    public PasswordResetService(
            UserRepository userRepository,
            UserCredentialRepository credentialRepository,
            PasswordResetTokenRepository tokenRepository,
            OutboxEventRepository outboxRepository,
            PasswordResetTokenService tokenService,
            PasswordPolicy passwordPolicy,
            PasswordHashService passwordHashService,
            DeviceSessionCommandService sessionCommandService,
            PasswordResetRateLimitService rateLimitService,
            Clock clock
    ) {
        this.userRepository = userRepository;
        this.credentialRepository = credentialRepository;
        this.tokenRepository = tokenRepository;
        this.outboxRepository = outboxRepository;
        this.tokenService = tokenService;
        this.passwordPolicy = passwordPolicy;
        this.passwordHashService = passwordHashService;
        this.sessionCommandService = sessionCommandService;
        this.rateLimitService = rateLimitService;
        this.clock = clock;
    }

    @Transactional
    public void request(PasswordResetEmailRequest request, String remoteAddress) {
        String email = request.email().trim().toLowerCase(Locale.ROOT);
        rateLimitService.accept(email, remoteAddress);
        userRepository.findByEmailAndDeletedFalse(email).ifPresent(this::enqueueResetEmail);
    }

    @Transactional
    public void complete(PasswordResetCompletionRequest request) {
        LocalDateTime now = now();
        PasswordResetToken token = tokenRepository.findByTokenHash(tokenService.hashToken(request.token()))
                .orElseThrow(this::invalidToken);
        if (token.isRevoked() || token.getUser().isDeleted()) {
            throw invalidToken();
        }
        if (token.isUsed()) {
            throw new BusinessException(
                    HttpStatus.BAD_REQUEST,
                    "PASSWORD_RESET_TOKEN_USED",
                    "Password reset token has already been used"
            );
        }
        if (token.isExpired(now)) {
            throw new BusinessException(
                    HttpStatus.BAD_REQUEST,
                    "PASSWORD_RESET_TOKEN_EXPIRED",
                    "Password reset token has expired"
            );
        }

        User member = token.getUser();
        String passwordHash = passwordHashService.encode(
                passwordPolicy.normalizeAndValidate(request.newPassword())
        );
        credentialRepository.findByUser(member).ifPresentOrElse(
                credential -> credential.updatePasswordHash(passwordHash),
                () -> credentialRepository.save(new UserCredential(member, passwordHash))
        );
        token.markUsed(now);
        tokenRepository.revokeActiveForUser(member, now);
        int revokedSessions = sessionCommandService.revokeAllAfterPasswordReset(member.getId());
        outboxRepository.save(new OutboxEvent(
                UUID.randomUUID().toString(),
                "MEMBER",
                member.getPublicId(),
                COMPLETED_EVENT,
                "{\"revokedSessions\":" + revokedSessions + "}",
                now
        ));
    }

    private void enqueueResetEmail(User member) {
        LocalDateTime now = now();
        tokenRepository.revokeActiveForUser(member, now);
        outboxRepository.save(new OutboxEvent(
                UUID.randomUUID().toString(),
                "MEMBER",
                member.getPublicId(),
                REQUESTED_EVENT,
                "{}",
                now
        ));
    }

    private BusinessException invalidToken() {
        return new BusinessException(
                HttpStatus.BAD_REQUEST,
                "PASSWORD_RESET_TOKEN_INVALID",
                "Password reset token is invalid"
        );
    }

    private LocalDateTime now() {
        return LocalDateTime.now(clock);
    }
}
