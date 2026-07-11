package com.monsters.repository.user;

import com.monsters.entity.user.UserCredential;
import com.monsters.entity.user.User;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserCredentialRepository extends JpaRepository<UserCredential, Long> {

    Optional<UserCredential> findByUser(User user);
}
