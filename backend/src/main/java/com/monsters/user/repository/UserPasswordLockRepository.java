package com.monsters.user.repository;

import com.monsters.user.entity.UserPasswordLock;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserPasswordLockRepository extends JpaRepository<UserPasswordLock, Long> {

    Optional<UserPasswordLock> findByUserId(Long userId);

    Optional<UserPasswordLock> findByUserIdAndEnabledTrue(Long userId);
}
