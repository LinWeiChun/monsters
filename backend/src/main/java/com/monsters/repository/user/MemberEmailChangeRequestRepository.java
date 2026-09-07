package com.monsters.repository.user;

import com.monsters.entity.user.MemberEmailChangeRequest;
import com.monsters.entity.user.MemberEmailChangeStatus;
import jakarta.persistence.LockModeType;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface MemberEmailChangeRequestRepository
        extends JpaRepository<MemberEmailChangeRequest, Long> {

    Optional<MemberEmailChangeRequest> findByPublicId(String publicId);

    List<MemberEmailChangeRequest> findAllByUser_IdAndStatusIn(
            Long userId,
            Collection<MemberEmailChangeStatus> statuses
    );

    Optional<MemberEmailChangeRequest> findFirstByUser_IdAndStatusInOrderByIdDesc(
            Long userId,
            Collection<MemberEmailChangeStatus> statuses
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT request FROM MemberEmailChangeRequest request "
            + "JOIN FETCH request.user "
            + "JOIN FETCH request.initiatingSession "
            + "WHERE request.tokenHash = :tokenHash")
    Optional<MemberEmailChangeRequest> findForUpdateByTokenHash(
            @Param("tokenHash") String tokenHash
    );
}
