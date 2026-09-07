package com.monsters.repository.user;

import com.monsters.entity.user.MemberContinuationCredential;
import com.monsters.entity.user.User;
import java.time.LocalDateTime;
import java.util.Optional;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface MemberContinuationCredentialRepository
        extends JpaRepository<MemberContinuationCredential, Long> {

    Optional<MemberContinuationCredential> findByTokenHash(String tokenHash);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT credential FROM MemberContinuationCredential credential "
            + "JOIN FETCH credential.user WHERE credential.tokenHash = :tokenHash")
    Optional<MemberContinuationCredential> findForUpdateByTokenHash(
            @Param("tokenHash") String tokenHash
    );

    @Modifying
    @Query("""
            UPDATE MemberContinuationCredential credential
            SET credential.revokedAt = :revokedAt
            WHERE credential.user = :user
              AND credential.revokedAt IS NULL
              AND credential.expiresAt > :revokedAt
            """)
    int revokeActiveForUser(
            @Param("user") User user,
            @Param("revokedAt") LocalDateTime revokedAt
    );
}
