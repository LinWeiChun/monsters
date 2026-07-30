package com.monsters.repository.user;

import com.monsters.entity.user.EmailVerificationToken;
import com.monsters.entity.user.User;
import java.time.LocalDateTime;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface EmailVerificationTokenRepository
        extends JpaRepository<EmailVerificationToken, Long> {

    Optional<EmailVerificationToken> findByTokenHash(String tokenHash);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
            UPDATE EmailVerificationToken token
            SET token.revokedAt = :revokedAt
            WHERE token.user = :user
              AND token.usedAt IS NULL
              AND token.revokedAt IS NULL
            """)
    int revokeActiveForUser(
            @Param("user") User user,
            @Param("revokedAt") LocalDateTime revokedAt
    );
}
