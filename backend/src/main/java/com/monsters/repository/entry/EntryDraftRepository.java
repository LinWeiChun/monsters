package com.monsters.repository.entry;

import com.monsters.entity.entry.EntryDraft;
import com.monsters.entity.entry.EntryType;
import jakarta.persistence.LockModeType;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface EntryDraftRepository extends JpaRepository<EntryDraft, Long> {

    Optional<EntryDraft> findByUserIdAndEntryType(Long userId, EntryType entryType);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            SELECT draft
            FROM EntryDraft draft
            WHERE draft.userId = :userId
              AND draft.entryType = :entryType
            """)
    Optional<EntryDraft> findByUserIdAndEntryTypeForUpdate(
            @Param("userId") Long userId,
            @Param("entryType") EntryType entryType
    );

    Optional<EntryDraft> findByUserIdAndEntryTypeAndExpiresAtAfter(
            Long userId,
            EntryType entryType,
            LocalDateTime now
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            SELECT draft
            FROM EntryDraft draft
            WHERE draft.userId = :userId
              AND draft.entryType = :entryType
              AND draft.expiresAt > :now
            """)
    Optional<EntryDraft> findActiveByUserIdAndEntryTypeForUpdate(
            @Param("userId") Long userId,
            @Param("entryType") EntryType entryType,
            @Param("now") LocalDateTime now
    );

    List<EntryDraft> findTop100ByExpiresAtLessThanEqualOrderByExpiresAtAscIdAsc(
            LocalDateTime now
    );

    @Query("""
            SELECT draft
            FROM EntryDraft draft
            WHERE draft.expiresAt <= :cutoff
              AND (
                draft.expiresAt > :afterExpiresAt
                OR (
                  draft.expiresAt = :afterExpiresAt
                  AND draft.id > :afterId
                )
              )
            ORDER BY draft.expiresAt ASC, draft.id ASC
            """)
    List<EntryDraft> findExpiredAfter(
            @Param("cutoff") LocalDateTime cutoff,
            @Param("afterExpiresAt") LocalDateTime afterExpiresAt,
            @Param("afterId") Long afterId,
            Pageable pageable
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            SELECT draft
            FROM EntryDraft draft
            WHERE draft.id = :draftId
              AND draft.expiresAt <= :cutoff
            """)
    Optional<EntryDraft> findExpiredByIdForUpdate(
            @Param("draftId") Long draftId,
            @Param("cutoff") LocalDateTime cutoff
    );
}
