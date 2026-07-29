package com.monsters.service.registration;

import com.monsters.config.registration.RegistrationEmailVerificationProperties;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UnverifiedMemberCleanupService {

    private final JdbcTemplate jdbcTemplate;
    private final RegistrationEmailVerificationProperties properties;
    private final Clock clock;

    public UnverifiedMemberCleanupService(
            JdbcTemplate jdbcTemplate,
            RegistrationEmailVerificationProperties properties,
            Clock clock
    ) {
        this.jdbcTemplate = jdbcTemplate;
        this.properties = properties;
        this.clock = clock;
    }

    @Transactional
    public int cleanup() {
        validateConfiguration();
        LocalDateTime cutoff = LocalDateTime.now(clock)
                .minusDays(properties.getUnverifiedRetentionDays());
        List<Long> memberIds = jdbcTemplate.queryForList(
                """
                SELECT candidate.id
                FROM users candidate
                WHERE candidate.member_state = 'PENDING_EMAIL_VERIFICATION'
                  AND candidate.created_at < ?
                  AND NOT EXISTS (
                      SELECT 1 FROM user_oauth_accounts item WHERE item.user_id = candidate.id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM user_password_locks item WHERE item.user_id = candidate.id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM user_monsters item WHERE item.user_id = candidate.id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM user_active_monsters item WHERE item.user_id = candidate.id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM entries item WHERE item.user_id = candidate.id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM entry_drafts item WHERE item.user_id = candidate.id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM entry_likes item WHERE item.user_id = candidate.id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM entry_comments item WHERE item.user_id = candidate.id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM user_daily_test_answers item WHERE item.user_id = candidate.id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM feedback item WHERE item.user_id = candidate.id
                  )
                ORDER BY candidate.id
                LIMIT ?
                FOR UPDATE SKIP LOCKED
                """,
                Long.class,
                cutoff,
                properties.getCleanupBatchSize()
        );

        int deleted = 0;
        for (Long memberId : memberIds) {
            jdbcTemplate.update(
                    "DELETE FROM password_reset_tokens WHERE user_id = ?",
                    memberId
            );
            jdbcTemplate.update(
                    "DELETE FROM user_credentials WHERE user_id = ?",
                    memberId
            );
            deleted += jdbcTemplate.update(
                    """
                    DELETE FROM users
                    WHERE id = ?
                      AND member_state = 'PENDING_EMAIL_VERIFICATION'
                    """,
                    memberId
            );
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
