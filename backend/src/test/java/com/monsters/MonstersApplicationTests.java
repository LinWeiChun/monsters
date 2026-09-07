package com.monsters;

import com.monsters.repository.annoyance.AnnoyanceTypeRepository;
import com.monsters.repository.audit.MemberStateAuditRepository;
import com.monsters.repository.entry.EntryMediaRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.entry.EntryDraftMediaRepository;
import com.monsters.repository.entry.EntryDraftRepository;
import com.monsters.repository.entry.MoodRepository;
import com.monsters.repository.outbox.OutboxEventRepository;
import com.monsters.repository.registration.RegistrationRateLimitBucketRepository;
import com.monsters.repository.session.RefreshSessionCredentialRepository;
import com.monsters.repository.session.UserSessionRepository;
import com.monsters.repository.session.SessionReauthenticationCredentialRepository;
import com.monsters.repository.audit.SessionSecurityAuditRepository;
import com.monsters.repository.user.EmailVerificationTokenRepository;
import com.monsters.repository.user.MemberDocumentAcceptanceRepository;
import com.monsters.repository.user.MemberContinuationCredentialRepository;
import com.monsters.repository.user.MemberEmailChangeRequestRepository;
import com.monsters.repository.user.BirthdayCorrectionRequestRepository;
import com.monsters.repository.user.PasswordResetTokenRepository;
import com.monsters.repository.user.RevokedTokenRepository;
import com.monsters.repository.user.UserCredentialRepository;
import com.monsters.repository.user.UserOAuthAccountRepository;
import com.monsters.repository.user.GuardianConsentRepository;
import com.monsters.repository.user.GuardianConsentTokenRepository;
import com.monsters.repository.user.UserPasswordLockRepository;
import com.monsters.repository.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.autoconfigure.mail.MailProperties;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

@SpringBootTest(properties = {
        "spring.autoconfigure.exclude="
                + "org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,"
                + "org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration"
})
class MonstersApplicationTests {

    @Autowired
    private MailProperties mailProperties;

    @MockBean
    private UserRepository userRepository;

    @MockBean
    private UserCredentialRepository userCredentialRepository;

    @MockBean
    private UserOAuthAccountRepository userOAuthAccountRepository;

    @MockBean
    private PasswordResetTokenRepository passwordResetTokenRepository;

    @MockBean
    private RevokedTokenRepository revokedTokenRepository;

    @MockBean
    private UserPasswordLockRepository userPasswordLockRepository;

    @MockBean
    private MemberContinuationCredentialRepository memberContinuationCredentialRepository;

    @MockBean
    private MemberEmailChangeRequestRepository memberEmailChangeRequestRepository;

    @MockBean
    private BirthdayCorrectionRequestRepository birthdayCorrectionRequestRepository;

    @MockBean
    private MemberStateAuditRepository memberStateAuditRepository;

    @MockBean
    private OutboxEventRepository outboxEventRepository;

    @MockBean
    private UserSessionRepository userSessionRepository;

    @MockBean
    private RefreshSessionCredentialRepository refreshSessionCredentialRepository;

    @MockBean
    private SessionSecurityAuditRepository sessionSecurityAuditRepository;

    @MockBean
    private SessionReauthenticationCredentialRepository sessionReauthenticationCredentialRepository;

    @MockBean
    private MemberDocumentAcceptanceRepository memberDocumentAcceptanceRepository;

    @MockBean
    private EmailVerificationTokenRepository emailVerificationTokenRepository;

    @MockBean
    private GuardianConsentRepository guardianConsentRepository;

    @MockBean
    private GuardianConsentTokenRepository guardianConsentTokenRepository;

    @MockBean
    private RegistrationRateLimitBucketRepository registrationRateLimitBucketRepository;

    @MockBean
    private JdbcTemplate jdbcTemplate;

    @MockBean
    private EntryRepository entryRepository;

    @MockBean
    private EntryMediaRepository entryMediaRepository;

    @MockBean
    private EntryDraftRepository entryDraftRepository;

    @MockBean
    private EntryDraftMediaRepository entryDraftMediaRepository;

    @MockBean
    private MoodRepository moodRepository;

    @MockBean
    private AnnoyanceTypeRepository annoyanceTypeRepository;

    @Test
    void contextLoads() {
    }

    @Test
    void usesResendAsTheDefaultSmtpProvider() {
        org.assertj.core.api.Assertions.assertThat(mailProperties.getHost())
                .isEqualTo("smtp.resend.com");
        org.assertj.core.api.Assertions.assertThat(mailProperties.getPort()).isEqualTo(587);
        org.assertj.core.api.Assertions.assertThat(mailProperties.getUsername()).isEqualTo("resend");
    }
}
