package com.monsters.registration;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import org.flywaydb.core.Flyway;
import org.flywaydb.core.api.MigrationVersion;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
class RegistrationMigrationIntegrationTest {

    @Container
    static final MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.4")
            .withDatabaseName("registration_migration_test")
            .withUsername("registration_migration_test")
            .withPassword("synthetic-password");

    @Test
    void emptySchemaShouldMigrateDirectlyToMemberDataModificationVersion() throws Exception {
        Flyway flyway = flyway(null);
        flyway.clean();

        assertThat(flyway.migrate().success).isTrue();
        assertThat(flyway.info().current().getVersion().getVersion()).isEqualTo("10");
        assertRegistrationTablesAndNullableOnboardingColumns();
    }

    @Test
    void versionTwoSchemaShouldUpgradeWithoutBreakingLegacyMembers() throws Exception {
        Flyway versionTwo = flyway(MigrationVersion.fromVersion("2"));
        versionTwo.clean();
        assertThat(versionTwo.migrate().success).isTrue();

        try (Connection connection = connection();
                Statement statement = connection.createStatement()) {
            statement.executeUpdate("""
                    INSERT INTO users (
                        public_id,
                        account,
                        email,
                        user_name,
                        is_deleted,
                        member_state,
                        version,
                        created_at,
                        updated_at
                    ) VALUES (
                        '00000000-0000-0000-0000-000000000001',
                        'legacy_member',
                        'legacy.member@example.test',
                        'Legacy Member',
                        FALSE,
                        'ACTIVE',
                        0,
                        CURRENT_TIMESTAMP,
                        CURRENT_TIMESTAMP
                    )
                    """);
        }

        Flyway latest = flyway(null);
        assertThat(latest.migrate().success).isTrue();
        assertThat(latest.info().current().getVersion().getVersion()).isEqualTo("10");
        assertRegistrationTablesAndNullableOnboardingColumns();
        try (Connection connection = connection();
                Statement statement = connection.createStatement();
                ResultSet result = statement.executeQuery(
                        "SELECT member_state, eligibility_status, community_eligibility_status "
                                + "FROM users WHERE account = 'legacy_member'"
                )) {
            assertThat(result.next()).isTrue();
            assertThat(result.getString("member_state")).isEqualTo("ACTIVE");
            assertThat(result.getString("eligibility_status")).isEqualTo("ELIGIBLE_ADULT");
            assertThat(result.getString("community_eligibility_status")).isEqualTo("INELIGIBLE");
        }
    }

    private Flyway flyway(MigrationVersion target) {
        var configuration = Flyway.configure()
                .dataSource(mysql.getJdbcUrl(), mysql.getUsername(), mysql.getPassword())
                .locations("classpath:db/migration")
                .cleanDisabled(false);
        if (target != null) {
            configuration.target(target);
        }
        return configuration.load();
    }

    private void assertRegistrationTablesAndNullableOnboardingColumns()
            throws Exception {
        try (Connection connection = connection()) {
            DatabaseMetaData metadata = connection.getMetaData();
            assertThat(tableExists(metadata, "member_document_acceptances")).isTrue();
            assertThat(tableExists(metadata, "email_verification_tokens")).isTrue();
            assertThat(tableExists(metadata, "registration_rate_limit_buckets")).isTrue();
            assertThat(tableExists(metadata, "guardian_consents")).isTrue();
            assertThat(tableExists(metadata, "guardian_consent_tokens")).isTrue();
            assertThat(tableExists(metadata, "user_sessions")).isTrue();
            assertThat(tableExists(metadata, "refresh_session_credentials")).isTrue();
            assertThat(tableExists(metadata, "session_security_audits")).isTrue();
            assertThat(tableExists(metadata, "session_reauthentication_credentials")).isTrue();
            assertThat(columnNullable(metadata, "user_sessions", "device_type")).isFalse();
            assertThat(columnNullable(metadata, "user_sessions", "device_summary")).isFalse();
            assertThat(columnNullable(metadata, "users", "account")).isTrue();
            assertThat(columnNullable(metadata, "users", "user_name")).isTrue();
        }
    }

    private boolean tableExists(DatabaseMetaData metadata, String table)
            throws Exception {
        try (ResultSet result = metadata.getTables(
                mysql.getDatabaseName(),
                null,
                table,
                new String[]{"TABLE"}
        )) {
            return result.next();
        }
    }

    private boolean columnNullable(
            DatabaseMetaData metadata,
            String table,
            String column
    ) throws Exception {
        try (ResultSet result = metadata.getColumns(
                mysql.getDatabaseName(),
                null,
                table,
                column
        )) {
            assertThat(result.next()).isTrue();
            return result.getInt("NULLABLE") == DatabaseMetaData.columnNullable;
        }
    }

    private Connection connection() throws Exception {
        return DriverManager.getConnection(
                mysql.getJdbcUrl(),
                mysql.getUsername(),
                mysql.getPassword()
        );
    }
}
