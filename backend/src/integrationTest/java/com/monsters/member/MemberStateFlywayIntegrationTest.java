package com.monsters.member;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import org.flywaydb.core.Flyway;
import org.flywaydb.core.api.MigrationVersion;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ScriptUtils;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
class MemberStateFlywayIntegrationTest {

    @Container
    static final MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.4")
            .withDatabaseName("monsters_migration_test")
            .withUsername("monsters_test")
            .withPassword("synthetic-password");

    @Test
    void emptyDatabaseAndPreviousVersionShouldMigrateToMemberStateSchema() throws Exception {
        Flyway.configure()
                .dataSource(mysql.getJdbcUrl(), mysql.getUsername(), mysql.getPassword())
                .locations("classpath:db/migration")
                .load()
                .migrate();

        assertMemberStateTablesExist();

        Flyway.configure()
                .dataSource(mysql.getJdbcUrl(), mysql.getUsername(), mysql.getPassword())
                .locations("classpath:db/migration")
                .cleanDisabled(false)
                .load()
                .clean();

        try (Connection connection = mysql.createConnection("");
             Statement statement = connection.createStatement()) {
            ScriptUtils.executeSqlScript(
                    connection,
                    new ClassPathResource("db/migration/V1__current_schema_baseline.sql")
            );
            statement.executeUpdate("""
                    INSERT INTO users (account, email, user_name)
                    VALUES ('legacy_member', 'legacy.member@example.test', 'Synthetic Legacy Member')
                    """);
        }

        Flyway.configure()
                .dataSource(mysql.getJdbcUrl(), mysql.getUsername(), mysql.getPassword())
                .locations("classpath:db/migration")
                .baselineOnMigrate(true)
                .baselineVersion(MigrationVersion.fromVersion("1"))
                .load()
                .migrate();

        try (Connection connection = mysql.createConnection("");
             PreparedStatement statement = connection.prepareStatement("""
                     SELECT public_id, member_state, version
                     FROM users
                     WHERE account = 'legacy_member'
                     """);
             ResultSet result = statement.executeQuery()) {
            assertThat(result.next()).isTrue();
            assertThat(result.getString("public_id")).matches(
                    "[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}"
            );
            assertThat(result.getString("member_state")).isEqualTo("ACTIVE");
            assertThat(result.getLong("version")).isZero();
        }

        assertMemberStateTablesExist();
    }

    private void assertMemberStateTablesExist() throws Exception {
        try (Connection connection = mysql.createConnection("");
             PreparedStatement statement = connection.prepareStatement("""
                     SELECT COUNT(*)
                     FROM information_schema.tables
                     WHERE table_schema = DATABASE()
                       AND table_name IN (
                         'member_continuation_credentials',
                         'member_state_audits',
                         'outbox_events'
                       )
                     """);
             ResultSet result = statement.executeQuery()) {
            assertThat(result.next()).isTrue();
            assertThat(result.getInt(1)).isEqualTo(3);
        }
    }
}
