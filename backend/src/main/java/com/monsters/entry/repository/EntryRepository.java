package com.monsters.entry.repository;

import com.monsters.entry.entity.Entry;
import com.monsters.entry.entity.EntryType;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EntryRepository extends JpaRepository<Entry, Long> {

    Optional<Entry> findByIdAndUserIdAndEntryTypeAndDeletedFalse(
            Long id,
            Long userId,
            EntryType entryType
    );
}
