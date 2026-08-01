package com.monsters.service.eligibility;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

import com.monsters.dto.auth.GuardianWithdrawalRequest;
import com.monsters.entity.user.*;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.user.*;
import java.time.*;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class GuardianConsentServiceTest {
    private static final Clock CLOCK = Clock.fixed(Instant.parse("2026-08-01T10:00:00Z"), ZoneOffset.UTC);

    @Test
    void grantConsumesTheSingleUseTokenAndActivatesOnlyPrivateMinorEligibility() {
        Fixture fixture = new Fixture(GuardianConsentTokenPurpose.GRANT);

        var result = fixture.service.grant("synthetic-token");

        assertThat(result.status()).isEqualTo("GRANTED");
        verify(fixture.token).consume(LocalDateTime.now(CLOCK));
        verify(fixture.consent).grant(LocalDateTime.now(CLOCK));
        verify(fixture.user).grantMinorEligibility();
    }

    @Test
    void withdrawalImmediatelyRestrictsTheMemberAndRevokesContinuations() {
        Fixture fixture = new Fixture(GuardianConsentTokenPurpose.WITHDRAW);

        var result = fixture.service.withdraw("synthetic-token");

        assertThat(result.status()).isEqualTo("WITHDRAWN");
        verify(fixture.consent).withdraw(LocalDateTime.now(CLOCK));
        verify(fixture.user).withdrawGuardianEligibility();
        verify(fixture.continuations).revokeActiveForUser(fixture.user, LocalDateTime.now(CLOCK));
    }

    @Test
    void nonMatchingWithdrawalRequestKeepsTheSameSafePublicBehavior() {
        Fixture fixture = new Fixture(GuardianConsentTokenPurpose.WITHDRAW);
        when(fixture.consents.findByPublicId("00000000-0000-0000-0000-000000000000"))
                .thenReturn(Optional.empty());

        fixture.service.requestWithdrawal(new GuardianWithdrawalRequest(
                "00000000-0000-0000-0000-000000000000", "unknown@example.test"));

        verifyNoInteractions(fixture.outbox);
    }

    private static class Fixture {
        final GuardianConsentRepository consents = mock(GuardianConsentRepository.class);
        final GuardianConsentTokenRepository tokens = mock(GuardianConsentTokenRepository.class);
        final MemberContinuationCredentialRepository continuations = mock(MemberContinuationCredentialRepository.class);
        final OutboxEventRepository outbox = mock(OutboxEventRepository.class);
        final GuardianConsentToken token = mock(GuardianConsentToken.class);
        final GuardianConsent consent = mock(GuardianConsent.class);
        final User user = mock(User.class);
        final GuardianConsentService service = new GuardianConsentService(consents, tokens, continuations, outbox, CLOCK);
        Fixture(GuardianConsentTokenPurpose purpose) {
            when(tokens.findByTokenHash(GuardianConsentService.hash("synthetic-token"))).thenReturn(Optional.of(token));
            when(token.isUsableAt(LocalDateTime.now(CLOCK))).thenReturn(true);
            when(token.getPurpose()).thenReturn(purpose);
            when(token.getConsent()).thenReturn(consent);
            when(consent.getUser()).thenReturn(user);
        }
    }
}
