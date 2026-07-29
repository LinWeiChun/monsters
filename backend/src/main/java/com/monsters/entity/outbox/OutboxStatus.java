package com.monsters.entity.outbox;

public enum OutboxStatus {
    PENDING,
    PROCESSING,
    COMPLETED,
    FAILED
}
