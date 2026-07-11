package com.monsters.repository.entry;

import com.monsters.entity.entry.Mood;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MoodRepository extends JpaRepository<Mood, Long> {

    Optional<Mood> findByScore(int score);
}
