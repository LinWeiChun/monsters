package com.monsters.entity.entry;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.lang.reflect.Field;
import org.junit.jupiter.api.Test;

class MoodTest {

    @Test
    void shouldMapMoodLookupAndUniqueScore() throws NoSuchFieldException {
        assertThat(Mood.class).hasAnnotation(Entity.class);
        assertThat(Mood.class.getAnnotation(Table.class).name()).isEqualTo("moods");

        Field scoreField = Mood.class.getDeclaredField("score");
        Column scoreColumn = scoreField.getAnnotation(Column.class);
        assertThat(scoreColumn.nullable()).isFalse();
        assertThat(scoreColumn.unique()).isTrue();
    }

    @Test
    void shouldExposeLookupValues() {
        Mood mood = new Mood("VERY_BAD", "很不好", 1, "/moods/1.png", 1);

        assertThat(mood.getCode()).isEqualTo("VERY_BAD");
        assertThat(mood.getLabel()).isEqualTo("很不好");
        assertThat(mood.getScore()).isEqualTo(1);
        assertThat(mood.getImageUrl()).isEqualTo("/moods/1.png");
        assertThat(mood.getDisplayOrder()).isEqualTo(1);
    }
}
