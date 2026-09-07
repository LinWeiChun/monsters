package com.monsters.service.member;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(
        prefix = "app.member.email-change",
        name = "worker-enabled",
        havingValue = "true"
)
public class MemberEmailChangeOutboxScheduler {

    private final MemberEmailChangeOutboxWorker worker;

    public MemberEmailChangeOutboxScheduler(MemberEmailChangeOutboxWorker worker) {
        this.worker = worker;
    }

    @Scheduled(fixedDelayString = "${app.member.email-change.worker-delay-ms:5000}")
    public void processPending() {
        worker.processPending();
    }
}
