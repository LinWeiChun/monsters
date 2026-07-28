package com.monsters.service.entry;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
public class EntryDraftCleanupService {

    private final EntryDraftService entryDraftService;

    public EntryDraftCleanupService(EntryDraftService entryDraftService) {
        this.entryDraftService = entryDraftService;
    }

    @Scheduled(
            cron = "${app.entry-draft.cleanup-cron:0 30 3 * * *}",
            zone = "Asia/Taipei"
    )
    public void cleanupExpiredDrafts() {
        entryDraftService.cleanupExpired();
    }
}
