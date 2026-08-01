package com.monsters.repository.session;

import com.monsters.entity.session.RefreshSessionCredential;
import com.monsters.entity.session.UserSession;
import jakarta.persistence.LockModeType;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface RefreshSessionCredentialRepository
        extends JpaRepository<RefreshSessionCredential, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            select credential
            from RefreshSessionCredential credential
            join fetch credential.session session
            join fetch session.user
            where credential.tokenHash = :tokenHash
            """)
    Optional<RefreshSessionCredential> findForRotation(@Param("tokenHash") String tokenHash);

    Optional<RefreshSessionCredential> findBySessionAndSequenceNumber(
            UserSession session,
            long sequenceNumber
    );
}
