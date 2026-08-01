package com.monsters.repository.user;
import com.monsters.entity.user.*;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
public interface GuardianConsentRepository extends JpaRepository<GuardianConsent, Long> {
    Optional<GuardianConsent> findByPublicId(String publicId);
    Optional<GuardianConsent> findFirstByUserAndStatusOrderByIdDesc(User user, GuardianConsentStatus status);
}
