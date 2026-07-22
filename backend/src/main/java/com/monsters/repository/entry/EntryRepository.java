package com.monsters.repository.entry;

import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryType;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface EntryRepository extends JpaRepository<Entry, Long> {

    Optional<Entry> findByIdAndEntryTypeAndDeletedFalse(Long id, EntryType entryType);

    Optional<Entry> findByIdAndUserIdAndEntryTypeAndDeletedFalse(
            Long id,
            Long userId,
            EntryType entryType
    );

    @Query(
            value = """
                    SELECT e
                    FROM Entry e, Mood mood
                    WHERE mood.id = e.moodId
                      AND e.userId = :userId
                      AND e.entryType = :entryType
                      AND e.deleted = false
                      AND (:solved IS NULL OR e.solved = :solved)
                      AND (:shared IS NULL OR e.shared = :shared)
                    ORDER BY
                      CASE WHEN :sortField = 'occurredAt' AND :sortDirection = 'asc'
                           THEN e.occurredAt END ASC,
                      CASE WHEN :sortField = 'occurredAt' AND :sortDirection = 'desc'
                           THEN e.occurredAt END DESC,
                      CASE WHEN :sortField = 'createdAt' AND :sortDirection = 'asc'
                           THEN e.createdAt END ASC,
                      CASE WHEN :sortField = 'createdAt' AND :sortDirection = 'desc'
                           THEN e.createdAt END DESC,
                      CASE WHEN :sortField = 'score' AND :sortDirection = 'asc'
                           THEN mood.score END ASC,
                      CASE WHEN :sortField = 'score' AND :sortDirection = 'desc'
                           THEN mood.score END DESC,
                      e.id DESC
                    """,
            countQuery = """
                    SELECT COUNT(e)
                    FROM Entry e, Mood mood
                    WHERE mood.id = e.moodId
                      AND e.userId = :userId
                      AND e.entryType = :entryType
                      AND e.deleted = false
                      AND (:solved IS NULL OR e.solved = :solved)
                      AND (:shared IS NULL OR e.shared = :shared)
                    """
    )
    Page<Entry> findEntryPage(
            @Param("userId") Long userId,
            @Param("entryType") EntryType entryType,
            @Param("solved") Boolean solved,
            @Param("shared") Boolean shared,
            @Param("sortField") String sortField,
            @Param("sortDirection") String sortDirection,
            Pageable pageable
    );
}
