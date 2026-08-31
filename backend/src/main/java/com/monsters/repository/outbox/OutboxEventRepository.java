package com.monsters.repository.outbox;

import com.monsters.entity.outbox.OutboxEvent;
import com.monsters.entity.outbox.OutboxStatus;
import java.time.LocalDateTime;
import java.util.List;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

public interface OutboxEventRepository extends JpaRepository<OutboxEvent, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    List<OutboxEvent> findTop50ByEventTypeAndStatusAndAvailableAtLessThanEqualOrderByIdAsc(
            String eventType,
            OutboxStatus status,
            LocalDateTime availableAt
    );

    boolean existsByEventTypeAndAggregateIdAndIdGreaterThan(
            String eventType,
            String aggregateId,
            Long id
    );
}
