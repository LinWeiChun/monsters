package com.monsters.repository.registration;

import com.monsters.entity.registration.RegistrationRateLimitBucket;
import com.monsters.entity.registration.RegistrationRateLimitScope;
import jakarta.persistence.LockModeType;
import java.time.LocalDateTime;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface RegistrationRateLimitBucketRepository
        extends JpaRepository<RegistrationRateLimitBucket, Long> {

    @Modifying
    @Query(
            value = """
                    INSERT IGNORE INTO registration_rate_limit_buckets (
                        bucket_scope,
                        key_hash,
                        window_started_at,
                        attempts,
                        created_at,
                        updated_at
                    ) VALUES (:scope, :keyHash, :now, 0, :now, :now)
                    """,
            nativeQuery = true
    )
    int insertIfMissing(
            @Param("scope") String scope,
            @Param("keyHash") String keyHash,
            @Param("now") LocalDateTime now
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<RegistrationRateLimitBucket> findByScopeAndKeyHash(
            RegistrationRateLimitScope scope,
            String keyHash
    );
}
