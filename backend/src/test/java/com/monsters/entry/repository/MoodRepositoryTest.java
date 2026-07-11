package com.monsters.entry.repository;

import static org.assertj.core.api.Assertions.assertThat;

import com.monsters.entry.entity.Mood;
import java.lang.reflect.Method;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.data.jpa.repository.JpaRepository;

class MoodRepositoryTest {

    @Test
    void shouldExposeScoreLookup() throws NoSuchMethodException {
        assertThat(JpaRepository.class).isAssignableFrom(MoodRepository.class);

        Method method = MoodRepository.class.getMethod("findByScore", int.class);

        assertThat(method.getReturnType()).isEqualTo(Optional.class);
        assertThat(method.getGenericReturnType().getTypeName()).contains(Mood.class.getName());
    }
}
