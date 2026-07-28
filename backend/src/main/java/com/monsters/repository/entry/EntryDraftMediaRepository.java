package com.monsters.repository.entry;

import com.monsters.entity.entry.EntryDraftMedia;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EntryDraftMediaRepository extends JpaRepository<EntryDraftMedia, Long> {

    List<EntryDraftMedia> findAllByEntryDraftIdOrderByMediaRoleAsc(Long entryDraftId);

    Optional<EntryDraftMedia> findByIdAndEntryDraftId(Long id, Long entryDraftId);
}
