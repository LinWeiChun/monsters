package com.monsters.user.repository;

import com.monsters.user.entity.PasswordResetToken;
import com.monsters.user.entity.User;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {

    Optional<PasswordResetToken> findByTokenHashAndUsedAtIsNull(String tokenHash);

    void deleteByUserAndUsedAtIsNull(User user);
}
