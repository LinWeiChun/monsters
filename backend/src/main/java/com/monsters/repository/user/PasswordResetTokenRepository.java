package com.monsters.repository.user;

import com.monsters.entity.user.PasswordResetToken;
import com.monsters.entity.user.User;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {

    Optional<PasswordResetToken> findByTokenHashAndUsedAtIsNull(String tokenHash);

    void deleteByUserAndUsedAtIsNull(User user);
}
