package com.monsters.repository.session;

import com.monsters.entity.session.UserSession;
import java.util.Optional;
import java.util.List;
import java.time.LocalDateTime;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import jakarta.persistence.LockModeType;

public interface UserSessionRepository extends JpaRepository<UserSession, Long> {

    Optional<UserSession> findByPublicIdAndUser_Id(String publicId, Long userId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT session FROM UserSession session "
            + "WHERE session.publicId = :publicId AND session.user.id = :userId")
    Optional<UserSession> findForUpdateByPublicIdAndUserId(
            @Param("publicId") String publicId,
            @Param("userId") Long userId
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    List<UserSession> findAllByUser_IdAndRevokedAtIsNull(Long userId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    List<UserSession> findAllByUser_IdAndRevokedAtIsNullAndPublicIdNot(Long userId, String publicId);

    Page<UserSession> findByUser_IdAndRevokedAtIsNullAndIdleExpiresAtAfterAndAbsoluteExpiresAtAfterOrderByIdDesc(
            Long userId,
            LocalDateTime idleNow,
            LocalDateTime absoluteNow,
            Pageable pageable
    );
}
