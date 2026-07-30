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
import com.monsters.repository.user.EmailVerificationTokenRepository;
import com.monsters.repository.user.MemberDocumentAcceptanceRepository;
import com.monsters.repository.user.MemberContinuationCredentialRepository;
import com.monsters.repository.user.PasswordResetTokenRepository;
import com.monsters.repository.user.RevokedTokenRepository;
import com.monsters.repository.user.UserCredentialRepository;
import com.monsters.repository.user.UserOAuthAccountRepository;
import com.monsters.repository.user.UserPasswordLockRepository;
import com.monsters.repository.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.jdbc.core.JdbcTemplate;

@SpringBootTest(properties = {
        "spring.autoconfigure.exclude="
                + "org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,"
                + "org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration"
})
class MonstersApplicationTests {

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
    private MemberStateAuditRepository memberStateAuditRepository;

    @MockBean
    private OutboxEventRepository outboxEventRepository;

    @MockBean
    private MemberDocumentAcceptanceRepository memberDocumentAcceptanceRepository;

    @MockBean
    private EmailVerificationTokenRepository emailVerificationTokenRepository;

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
}
