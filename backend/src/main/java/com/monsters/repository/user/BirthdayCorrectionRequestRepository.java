package com.monsters.repository.user;

import com.monsters.entity.user.BirthdayCorrectionRequest;
import com.monsters.entity.user.BirthdayCorrectionStatus;
import java.util.Collection;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BirthdayCorrectionRequestRepository
        extends JpaRepository<BirthdayCorrectionRequest, Long> {

    Optional<BirthdayCorrectionRequest> findFirstByUser_IdAndStatusInOrderByIdDesc(
            Long userId,
            Collection<BirthdayCorrectionStatus> statuses
    );

    boolean existsByUser_IdAndStatusIn(
            Long userId,
            Collection<BirthdayCorrectionStatus> statuses
    );
}
