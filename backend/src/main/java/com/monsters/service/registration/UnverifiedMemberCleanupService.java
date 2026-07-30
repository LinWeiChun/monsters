package com.monsters.service.registration;

import com.monsters.config.registration.RegistrationEmailVerificationProperties;
import com.monsters.repository.registration.UnverifiedMemberCleanupRepository;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UnverifiedMemberCleanupService {

    private final UnverifiedMemberCleanupRepository cleanupRepository;
    private final RegistrationEmailVerificationProperties properties;
    private final Clock clock;

    public UnverifiedMemberCleanupService(
            UnverifiedMemberCleanupRepository cleanupRepository,
            RegistrationEmailVerificationProperties properties,
            Clock clock
    ) {
        this.cleanupRepository = cleanupRepository;
        this.properties = properties;
        this.clock = clock;
    }

    @Transactional
    public int cleanup() {
        validateConfiguration();
        LocalDateTime cutoff = LocalDateTime.now(clock)
                .minusDays(properties.getUnverifiedRetentionDays());
        List<Long> memberIds = cleanupRepository.lockEmptyCandidateIds(
                cutoff,
                properties.getCleanupBatchSize()
        );

        int deleted = 0;
        for (Long memberId : memberIds) {
            cleanupRepository.deleteAuthenticationData(memberId);
            deleted += cleanupRepository.deletePendingMember(memberId);
        }
        return deleted;
    }

    private void validateConfiguration() {
        if (properties.getUnverifiedRetentionDays() <= 0
                || properties.getCleanupBatchSize() <= 0) {
            throw new IllegalStateException("Unverified member cleanup configuration is invalid");
        }
    }
}
