package com.monsters;

import com.monsters.annoyance.repository.AnnoyanceTypeRepository;
import com.monsters.entry.repository.EntryMediaRepository;
import com.monsters.entry.repository.EntryRepository;
import com.monsters.entry.repository.MoodRepository;
import com.monsters.user.repository.PasswordResetTokenRepository;
import com.monsters.user.repository.RevokedTokenRepository;
import com.monsters.user.repository.UserCredentialRepository;
import com.monsters.user.repository.UserOAuthAccountRepository;
import com.monsters.user.repository.UserPasswordLockRepository;
import com.monsters.user.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;

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
    private EntryRepository entryRepository;

    @MockBean
    private EntryMediaRepository entryMediaRepository;

    @MockBean
    private MoodRepository moodRepository;

    @MockBean
    private AnnoyanceTypeRepository annoyanceTypeRepository;

    @Test
    void contextLoads() {
    }
}
