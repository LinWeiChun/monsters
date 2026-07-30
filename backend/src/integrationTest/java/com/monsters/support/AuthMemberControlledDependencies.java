package com.monsters.support;

import static org.mockito.Mockito.mock;

import com.monsters.job.AsyncJob;
import com.monsters.job.AsyncJobDispatcher;
import com.monsters.notification.email.EmailDeliveryPort;
import com.monsters.notification.email.EmailDeliveryRequest;
import com.monsters.security.common.GoogleIdTokenVerifier;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;

@TestConfiguration
public class AuthMemberControlledDependencies {

    public static final Instant TEST_NOW = Instant.parse("2026-07-29T01:00:00Z");

    @Bean
    @Primary
    Clock testClock() {
        return Clock.fixed(TEST_NOW, ZoneOffset.UTC);
    }

    @Bean
    @Primary
    GoogleIdTokenVerifier googleIdTokenVerifier() {
        return mock(GoogleIdTokenVerifier.class);
    }

    @Bean
    RecordingEmailDelivery recordingEmailDelivery() {
        return new RecordingEmailDelivery();
    }

    @Bean
    RecordingAsyncJobDispatcher recordingAsyncJobDispatcher() {
        return new RecordingAsyncJobDispatcher();
    }

    public static final class RecordingEmailDelivery implements EmailDeliveryPort {

        private final List<EmailDeliveryRequest> requests = new ArrayList<>();
        private int failuresRemaining;

        @Override
        public void deliver(EmailDeliveryRequest request) {
            if (failuresRemaining > 0) {
                failuresRemaining--;
                throw new IllegalStateException("Synthetic email delivery failure");
            }
            requests.add(request);
        }

        public List<EmailDeliveryRequest> requests() {
            return List.copyOf(requests);
        }

        public void failNext(int count) {
            failuresRemaining = count;
        }

        public void reset() {
            failuresRemaining = 0;
            requests.clear();
        }
    }

    public static final class RecordingAsyncJobDispatcher implements AsyncJobDispatcher {

        private final List<AsyncJob> jobs = new ArrayList<>();

        @Override
        public void dispatch(AsyncJob job) {
            jobs.add(job);
        }

        public List<AsyncJob> jobs() {
            return List.copyOf(jobs);
        }

        public void reset() {
            jobs.clear();
        }
    }

}
