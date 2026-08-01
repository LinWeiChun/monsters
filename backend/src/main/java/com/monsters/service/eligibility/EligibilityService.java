package com.monsters.service.eligibility;

import com.monsters.config.registration.EligibilityPolicyProperties;
import com.monsters.dto.auth.*;
import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.user.*;
import com.monsters.exception.common.BusinessException;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.*;
import com.monsters.service.auth.ContinuationCredentialService;
import java.time.*;
import java.util.Locale;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class EligibilityService {
    private final UserRepository users;
    private final GuardianConsentRepository consents;
    private final MemberDocumentAcceptanceRepository acceptances;
    private final OutboxEventRepository outbox;
    private final ContinuationCredentialService continuations;
    private final EligibilityRules rules;
    private final EligibilityPolicyProperties policy;
    private final Clock clock;
    public EligibilityService(UserRepository users, GuardianConsentRepository consents,
            MemberDocumentAcceptanceRepository acceptances, OutboxEventRepository outbox,
            ContinuationCredentialService continuations, EligibilityRules rules,
            EligibilityPolicyProperties policy, Clock clock) {
        this.users = users; this.consents = consents; this.acceptances = acceptances; this.outbox = outbox;
        this.continuations = continuations; this.rules = rules; this.policy = policy; this.clock = clock;
    }

    public EligibilityPolicyResponse currentPolicy() {
        return new EligibilityPolicyResponse(policy.getServiceRegion(), 13, 18,
                document(policy.getMinorNoticeVersion(), policy.getMinorNoticeUrl()),
                document(policy.getGuardianConsentVersion(), policy.getGuardianConsentUrl()),
                document(policy.getPublicNicknameDisclosureVersion(), policy.getPublicNicknameDisclosureUrl()));
    }

    @Transactional
    public EligibilityCompletionResponse complete(Long memberId, String rawCredential,
            EligibilityCompletionRequest request) {
        User user = users.findByIdAndDeletedFalse(memberId).orElseThrow(this::invalidContinuation);
        if (user.getMemberState() != MemberState.PENDING_ELIGIBILITY) throw invalidContinuation();
        String region = request.serviceRegion().toUpperCase(Locale.ROOT);
        EligibilityAgeBand ageBand = rules.classifyAge(request.birthday());
        if (!policy.getServiceRegion().equals(region)) {
            user.restrictEligibility(region, request.birthday(), EligibilityStatus.INELIGIBLE_REGION);
            continuations.consumeEligibilityCredential(rawCredential);
            return response(user, "REVIEW_ELIGIBILITY_RESTRICTION", null);
        }
        if (ageBand == EligibilityAgeBand.UNDERAGE) {
            user.restrictEligibility(region, request.birthday(), EligibilityStatus.INELIGIBLE_UNDERAGE);
            continuations.consumeEligibilityCredential(rawCredential);
            return response(user, "REVIEW_ELIGIBILITY_RESTRICTION", null);
        }
        String nickname = rules.normalizePublicNickname(request.publicNickname());
        LocalDateTime now = LocalDateTime.now(clock);
        if (ageBand == EligibilityAgeBand.ADULT) {
            if (request.confirmPublicNicknameDisclosure()) {
                requireVersion("publicNicknameDisclosureVersion", request.publicNicknameDisclosureVersion(),
                        policy.getPublicNicknameDisclosureVersion());
            }
            continuations.consumeEligibilityCredential(rawCredential);
            user.grantAdultEligibility(region, request.birthday(), nickname,
                    request.confirmPublicNicknameDisclosure(), request.publicNicknameDisclosureVersion(), now);
            return response(user, "SIGN_IN", null);
        }
        requireText("guardianEmail", request.guardianEmail());
        requireVersion("acceptedMinorNoticeVersion", request.acceptedMinorNoticeVersion(),
                policy.getMinorNoticeVersion());
        requireVersion("guardianConsentVersion", request.guardianConsentVersion(),
                policy.getGuardianConsentVersion());
        acceptances.save(new MemberDocumentAcceptance(user, MemberDocumentType.MINOR_NOTICE,
                request.acceptedMinorNoticeVersion(), now));
        user.awaitGuardianConsent(region, request.birthday(), nickname);
        GuardianConsent consent = consents.save(new GuardianConsent(user,
                request.guardianEmail().strip().toLowerCase(Locale.ROOT), request.guardianConsentVersion(), now));
        outbox.save(new OutboxEvent(UUID.randomUUID().toString(), "GUARDIAN_CONSENT",
                consent.getPublicId(), "GUARDIAN_CONSENT_GRANT_REQUESTED", "{}", now));
        continuations.consumeEligibilityCredential(rawCredential);
        return response(user, "AWAIT_GUARDIAN_CONSENT", consent.getPublicId());
    }

    private EligibilityCompletionResponse response(User user, String action, String reference) {
        return new EligibilityCompletionResponse(user.getEligibilityStatus().name(),
                user.getCommunityEligibilityStatus().name(), action, reference);
    }
    private EligibilityPolicyResponse.Document document(String version, String url) {
        return new EligibilityPolicyResponse.Document(version, url);
    }
    private void requireText(String field, String value) {
        if (!StringUtils.hasText(value)) throw new EligibilityValidationException(field,
                field.toUpperCase(Locale.ROOT) + "_REQUIRED", field + " is required");
    }
    private void requireVersion(String field, String supplied, String expected) {
        if (!StringUtils.hasText(expected) || !expected.equals(supplied)) {
            throw new EligibilityValidationException(field, "DOCUMENT_VERSION_MISMATCH",
                    "Current document version must be accepted");
        }
    }
    private BusinessException invalidContinuation() {
        return new BusinessException(HttpStatus.UNAUTHORIZED, "ELIGIBILITY_CONTINUATION_INVALID",
                "Eligibility continuation is invalid or expired");
    }
}
