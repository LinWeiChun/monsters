package com.monsters.entry.entity;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.Test;

class MoodSchemaTest {

    @Test
    void freshSchemaShouldUseUniqueScoreAndNeutralSeeds() throws IOException {
        String schema = Files.readString(Path.of("..", "database", "init", "01_schema.sql"));

        assertThat(schema).contains("UNIQUE KEY uk_moods_score (score)");
        assertThat(schema).contains("('SCORE_1', '1分', 1, NULL, 1)");
        assertThat(schema).contains("('SCORE_5', '5分', 5, NULL, 5)");
    }

    @Test
    void existingDatabaseMigrationShouldGuardConflictsAndSeedScores() throws IOException {
        String migration = Files.readString(Path.of(
                "..",
                "database",
                "migrations",
                "20260711_03_make_mood_score_unique.sql"
        ));

        assertThat(migration).contains("HAVING COUNT(*) > 1");
        assertThat(migration).contains("review data before migration");
        assertThat(migration).contains("ADD CONSTRAINT uk_moods_score UNIQUE (score)");
        assertThat(migration).contains("('SCORE_1', '1分', 1, NULL, 1)");
        assertThat(migration).contains("('SCORE_5', '5分', 5, NULL, 5)");
    }
}
