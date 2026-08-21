package com.monsters.repository.session;

import com.monsters.entity.session.SessionReauthenticationCredential;
import jakarta.persistence.LockModeType;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface SessionReauthenticationCredentialRepository
        extends JpaRepository<SessionReauthenticationCredential, Long> {

    Optional<SessionReauthenticationCredential> findByTokenHashAndPurpose(
            String tokenHash,
            String purpose
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT credential FROM SessionReauthenticationCredential credential "
            + "WHERE credential.tokenHash = :tokenHash AND credential.purpose = :purpose")
    Optional<SessionReauthenticationCredential> findForUpdateByTokenHashAndPurpose(
            @Param("tokenHash") String tokenHash,
            @Param("purpose") String purpose
    );
}
