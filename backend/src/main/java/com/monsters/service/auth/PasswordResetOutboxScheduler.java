package com.monsters.service.auth;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(
        prefix = "app.password-reset",
        name = "worker-enabled",
        havingValue = "true"
)
public class PasswordResetOutboxScheduler {

    private final PasswordResetOutboxWorker worker;

    public PasswordResetOutboxScheduler(PasswordResetOutboxWorker worker) {
        this.worker = worker;
    }

    @Scheduled(fixedDelayString = "${app.password-reset.worker-delay-ms:5000}")
    public void processPending() {
        worker.processPending();
    }
}
