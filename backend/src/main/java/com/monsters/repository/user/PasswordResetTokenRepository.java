package com.monsters.repository.user;

import com.monsters.entity.user.PasswordResetToken;
import com.monsters.entity.user.User;
import java.util.Optional;
import java.time.LocalDateTime;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<PasswordResetToken> findByTokenHash(String tokenHash);

    @Modifying
    @Query("UPDATE PasswordResetToken token SET token.revokedAt = :revokedAt "
            + "WHERE token.user = :user AND token.usedAt IS NULL AND token.revokedAt IS NULL")
    int revokeActiveForUser(
            @Param("user") User user,
            @Param("revokedAt") LocalDateTime revokedAt
    );
}
