package com.monsters.repository.session;

import com.monsters.entity.session.SessionReauthenticationCredential;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SessionReauthenticationCredentialRepository
        extends JpaRepository<SessionReauthenticationCredential, Long> {

    Optional<SessionReauthenticationCredential> findByTokenHashAndPurpose(
            String tokenHash,
            String purpose
    );
}
