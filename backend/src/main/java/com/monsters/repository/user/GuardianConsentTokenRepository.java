package com.monsters.repository.user;
import com.monsters.entity.user.*;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
public interface GuardianConsentTokenRepository extends JpaRepository<GuardianConsentToken, Long> {
    Optional<GuardianConsentToken> findByTokenHash(String tokenHash);
    @Modifying
    @Query("""
        UPDATE GuardianConsentToken token SET token.revokedAt = :now
        WHERE token.consent = :consent AND token.purpose = :purpose
          AND token.usedAt IS NULL AND token.revokedAt IS NULL
        """)
    int revokeActive(@Param("consent") GuardianConsent consent,
        @Param("purpose") GuardianConsentTokenPurpose purpose, @Param("now") LocalDateTime now);
}
