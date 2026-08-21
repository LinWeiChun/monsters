package com.monsters.service.auth;

import com.monsters.dto.auth.GoogleAccountLinkRequest;
import com.monsters.dto.auth.GoogleAccountLinkResponse;
import com.monsters.dto.auth.GoogleLoginRequest;
import com.monsters.dto.auth.VerifiedEmailLoginResponse;
import com.monsters.entity.audit.SessionSecurityAudit;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.session.ReauthenticationPurpose;
import com.monsters.entity.session.UserSession;
import com.monsters.entity.user.MemberState;
import com.monsters.entity.user.User;
import com.monsters.entity.user.UserOAuthAccount;
import com.monsters.exception.common.BusinessException;
import com.monsters.exception.common.UnauthorizedException;
import com.monsters.repository.audit.SessionSecurityAuditRepository;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.UserOAuthAccountRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.security.common.GoogleIdTokenVerifier;
import com.monsters.security.common.GoogleUserInfo;
import com.monsters.security.session.SessionDeviceContext;
import com.monsters.service.session.DeviceSessionCommandService;
import com.monsters.service.session.SessionAuthenticationResult;
import com.monsters.service.session.SessionFamilyService;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class GoogleAccountService {

    private static final String LOGIN_METHOD_LINKED = "LOGIN_METHOD_LINKED";

    private final GoogleIdTokenVerifier googleIdTokenVerifier;
    private final UserRepository userRepository;
    private final UserOAuthAccountRepository oauthAccountRepository;
    private final ContinuationCredentialService continuationCredentialService;
    private final SessionFamilyService sessionFamilyService;
    private final DeviceSessionCommandService sessionCommandService;
    private final SessionSecurityAuditRepository auditRepository;
    private final OutboxEventRepository outboxRepository;
    private final Clock clock;

    public GoogleAccountService(
            GoogleIdTokenVerifier googleIdTokenVerifier,
            UserRepository userRepository,
            UserOAuthAccountRepository oauthAccountRepository,
            ContinuationCredentialService continuationCredentialService,
            SessionFamilyService sessionFamilyService,
            DeviceSessionCommandService sessionCommandService,
            SessionSecurityAuditRepository auditRepository,
            OutboxEventRepository outboxRepository,
            Clock clock
    ) {
        this.googleIdTokenVerifier = googleIdTokenVerifier;
        this.userRepository = userRepository;
        this.oauthAccountRepository = oauthAccountRepository;
        this.continuationCredentialService = continuationCredentialService;
        this.sessionFamilyService = sessionFamilyService;
        this.sessionCommandService = sessionCommandService;
        this.auditRepository = auditRepository;
        this.outboxRepository = outboxRepository;
        this.clock = clock;
    }

    @Transactional
    public VerifiedEmailLoginResponse login(
            GoogleLoginRequest request,
            SessionDeviceContext deviceContext
    ) {
        GoogleUserInfo googleUser = googleIdTokenVerifier.verify(request.idToken());
        Optional<UserOAuthAccount> linkedAccount = oauthAccountRepository
                .findByProviderAndProviderUserId(
                        UserOAuthAccount.PROVIDER_GOOGLE,
                        googleUser.providerUserId()
                );
        if (linkedAccount.isPresent()) {
            return authenticate(linkedAccount.get().getUser(), deviceContext);
        }

        String email = normalizeEmail(googleUser.email());
        if (userRepository.findByEmailAndDeletedFalse(email).isPresent()) {
            return VerifiedEmailLoginResponse.googleAccountLinkRequired();
        }
        if (userRepository.findByEmail(email).isPresent()) {
            throw invalidGoogleIdentity();
        }

        User user = userRepository.save(User.pendingEligibilityFromVerifiedEmail(email));
        oauthAccountRepository.save(new UserOAuthAccount(
                user,
                UserOAuthAccount.PROVIDER_GOOGLE,
                googleUser.providerUserId()
        ));
        return authenticate(user, deviceContext);
    }

    @Transactional
    public GoogleAccountLinkResponse link(
            Long userId,
            String currentSessionId,
            String reauthenticationCredential,
            GoogleAccountLinkRequest request
    ) {
        GoogleUserInfo googleUser = googleIdTokenVerifier.verify(request.idToken());
        User user = userRepository.findByIdAndDeletedFalse(userId)
                .filter(candidate -> candidate.getMemberState() == MemberState.ACTIVE)
                .orElseThrow(this::linkConflict);
        UserSession currentSession = sessionCommandService.consumeReauthentication(
                userId,
                currentSessionId,
                reauthenticationCredential,
                ReauthenticationPurpose.LOGIN_METHOD_LINK
        );

        if (!normalizeEmail(user.getEmail()).equals(normalizeEmail(googleUser.email()))) {
            throw linkConflict();
        }

        Optional<UserOAuthAccount> subjectAccount = oauthAccountRepository
                .findByProviderAndProviderUserId(
                        UserOAuthAccount.PROVIDER_GOOGLE,
                        googleUser.providerUserId()
                );
        if (subjectAccount.isPresent()) {
            if (subjectAccount.get().getUser().getId().equals(userId)) {
                return new GoogleAccountLinkResponse(true, true, false);
            }
            throw linkConflict();
        }
        if (oauthAccountRepository.findByUser_IdAndProvider(
                userId,
                UserOAuthAccount.PROVIDER_GOOGLE
        ).isPresent()) {
            throw linkConflict();
        }

        oauthAccountRepository.save(new UserOAuthAccount(
                user,
                UserOAuthAccount.PROVIDER_GOOGLE,
                googleUser.providerUserId()
        ));
        boolean otherSessionsRevoked = sessionCommandService
                .revokeOthersAfterLoginMethodChange(userId, currentSessionId);
        recordLinkedEvent(currentSession);
        return new GoogleAccountLinkResponse(true, true, otherSessionsRevoked);
    }

    private VerifiedEmailLoginResponse authenticate(
            User user,
            SessionDeviceContext deviceContext
    ) {
        if (user.isDeleted() || user.getMemberState() == MemberState.DELETED) {
            throw invalidGoogleIdentity();
        }
        if (user.getMemberState() != MemberState.ACTIVE) {
            IssuedContinuationCredential credential = continuationCredentialService.issueFor(user);
            return VerifiedEmailLoginResponse.continuation(
                    credential.credential(),
                    credential.nextAction(),
                    credential.expiresIn()
            );
        }
        SessionAuthenticationResult session = sessionFamilyService.create(user, deviceContext);
        return VerifiedEmailLoginResponse.authenticated(
                session.accessToken(),
                session.refreshCredential(),
                session.tokenType(),
                session.expiresIn(),
                session.user()
        );
    }

    private void recordLinkedEvent(UserSession session) {
        LocalDateTime now = LocalDateTime.now(clock);
        String eventId = UUID.randomUUID().toString();
        auditRepository.save(new SessionSecurityAudit(session, eventId, LOGIN_METHOD_LINKED, now));
        outboxRepository.save(new OutboxEvent(
                eventId,
                "USER_SESSION",
                session.getPublicId(),
                LOGIN_METHOD_LINKED,
                "{}",
                now
        ));
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }

    private UnauthorizedException invalidGoogleIdentity() {
        return new UnauthorizedException("Invalid Google ID token");
    }

    private BusinessException linkConflict() {
        return new BusinessException(
                HttpStatus.CONFLICT,
                "GOOGLE_ACCOUNT_LINK_CONFLICT",
                "Google account cannot be linked"
        );
    }
}
