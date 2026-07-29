package com.monsters.job;

public record AsyncJob(
        String jobType,
        String requestId
) {
}
