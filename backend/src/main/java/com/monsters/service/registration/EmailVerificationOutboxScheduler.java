package com.monsters.service.registration;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(
        prefix = "app.registration.email-verification",
        name = "worker-enabled",
        havingValue = "true"
)
public class EmailVerificationOutboxScheduler {

    private final EmailVerificationOutboxWorker worker;
    private final com.monsters.service.eligibility.GuardianConsentOutboxWorker guardianWorker;

    public EmailVerificationOutboxScheduler(EmailVerificationOutboxWorker worker,
            com.monsters.service.eligibility.GuardianConsentOutboxWorker guardianWorker) {
        this.worker = worker;
        this.guardianWorker = guardianWorker;
    }

    @Scheduled(
            fixedDelayString =
                    "${app.registration.email-verification.worker-delay-ms:5000}"
    )
    public void processPending() {
        worker.processPending();
        guardianWorker.processPending();
    }
}
