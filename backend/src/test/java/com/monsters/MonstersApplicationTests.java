package com.monsters;

import com.monsters.user.repository.UserCredentialRepository;
import com.monsters.user.repository.UserOAuthAccountRepository;
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

    @Test
    void contextLoads() {
    }
}
