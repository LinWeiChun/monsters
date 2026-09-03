package com.monsters.service.auth;

import com.monsters.dto.auth.GoogleReauthenticationRequest;
import com.monsters.dto.auth.SessionReauthenticationResponse;
import com.monsters.entity.session.ReauthenticationPurpose;
import com.monsters.entity.user.UserOAuthAccount;
import com.monsters.exception.common.UnauthorizedException;
import com.monsters.repository.user.UserOAuthAccountRepository;
import com.monsters.security.common.GoogleIdTokenVerifier;
import com.monsters.security.common.GoogleUserInfo;
import com.monsters.service.session.DeviceSessionCommandService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class GoogleReauthenticationService {

    private final GoogleIdTokenVerifier googleIdTokenVerifier;
    private final UserOAuthAccountRepository oauthAccountRepository;
    private final DeviceSessionCommandService sessionCommandService;

    public GoogleReauthenticationService(
            GoogleIdTokenVerifier googleIdTokenVerifier,
            UserOAuthAccountRepository oauthAccountRepository,
            DeviceSessionCommandService sessionCommandService
    ) {
        this.googleIdTokenVerifier = googleIdTokenVerifier;
        this.oauthAccountRepository = oauthAccountRepository;
        this.sessionCommandService = sessionCommandService;
    }

    @Transactional
    public SessionReauthenticationResponse reauthenticate(
            Long userId,
            String currentSessionId,
            GoogleReauthenticationRequest request
    ) {
        ReauthenticationPurpose purpose = request.purpose();
        if (!purpose.isMemberDataPurpose()) {
            throw invalidIdentity();
        }
        GoogleUserInfo googleUser = googleIdTokenVerifier.verify(request.idToken());
        var linkedAccount = oauthAccountRepository.findByProviderAndProviderUserId(
                UserOAuthAccount.PROVIDER_GOOGLE,
                googleUser.providerUserId()
        ).orElseThrow(this::invalidIdentity);
        if (!linkedAccount.getUser().getId().equals(userId)) {
            throw invalidIdentity();
        }
        return sessionCommandService.issueVerifiedReauthentication(
                userId,
                currentSessionId,
                purpose
        );
    }

    private UnauthorizedException invalidIdentity() {
        return new UnauthorizedException("Google reauthentication failed");
    }
}
