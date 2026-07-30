package com.monsters.service.registration;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(
        prefix = "app.registration.email-verification",
        name = "cleanup-enabled",
        havingValue = "true"
)
public class UnverifiedMemberCleanupScheduler {

    private final UnverifiedMemberCleanupService cleanupService;

    public UnverifiedMemberCleanupScheduler(UnverifiedMemberCleanupService cleanupService) {
        this.cleanupService = cleanupService;
    }

    @Scheduled(
            cron = "${app.registration.email-verification.cleanup-cron:0 45 3 * * *}"
    )
    public void cleanup() {
        cleanupService.cleanup();
    }
}
