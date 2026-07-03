package com.monsters.user.repository;

import com.monsters.user.entity.UserCredential;
import com.monsters.user.entity.User;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserCredentialRepository extends JpaRepository<UserCredential, Long> {

    Optional<UserCredential> findByUser(User user);
}
