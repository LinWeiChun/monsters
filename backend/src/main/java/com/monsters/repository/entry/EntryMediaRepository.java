package com.monsters.repository.entry;

import com.monsters.entity.entry.EntryMedia;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EntryMediaRepository extends JpaRepository<EntryMedia, Long> {

    List<EntryMedia> findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc(Long entryId);

    Optional<EntryMedia> findByIdAndEntryIdAndDeletedFalse(Long id, Long entryId);
}
