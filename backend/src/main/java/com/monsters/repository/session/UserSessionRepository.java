package com.monsters.repository.session;

import com.monsters.entity.session.UserSession;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserSessionRepository extends JpaRepository<UserSession, Long> {

    Optional<UserSession> findByPublicIdAndUser_Id(String publicId, Long userId);
}
