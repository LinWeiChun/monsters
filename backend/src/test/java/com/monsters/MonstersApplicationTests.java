package com.monsters;

import com.monsters.repository.annoyance.AnnoyanceTypeRepository;
import com.monsters.repository.entry.EntryMediaRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.entry.MoodRepository;
import com.monsters.repository.user.PasswordResetTokenRepository;
import com.monsters.repository.user.RevokedTokenRepository;
import com.monsters.repository.user.UserCredentialRepository;
import com.monsters.repository.user.UserOAuthAccountRepository;
import com.monsters.repository.user.UserPasswordLockRepository;
import com.monsters.repository.user.UserRepository;
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
