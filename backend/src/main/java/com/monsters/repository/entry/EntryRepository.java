package com.monsters.repository.entry;

import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryType;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EntryRepository extends JpaRepository<Entry, Long> {

    Optional<Entry> findByIdAndUserIdAndEntryTypeAndDeletedFalse(
            Long id,
            Long userId,
            EntryType entryType
    );
}
