package com.monsters.repository.registration;

import java.time.LocalDateTime;
import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class UnverifiedMemberCleanupRepository {

    private final JdbcTemplate jdbcTemplate;

    public UnverifiedMemberCleanupRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Long> lockEmptyCandidateIds(LocalDateTime cutoff, int batchSize) {
        return jdbcTemplate.queryForList(
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
                batchSize
        );
    }

    public void deleteAuthenticationData(long memberId) {
        jdbcTemplate.update(
                "DELETE FROM password_reset_tokens WHERE user_id = ?",
                memberId
        );
        jdbcTemplate.update(
                "DELETE FROM user_credentials WHERE user_id = ?",
                memberId
        );
    }

    public int deletePendingMember(long memberId) {
        return jdbcTemplate.update(
                """
                DELETE FROM users
                WHERE id = ?
                  AND member_state = 'PENDING_EMAIL_VERIFICATION'
                """,
                memberId
        );
    }
}
