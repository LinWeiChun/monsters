package com.monsters.entry.repository;

import com.monsters.entry.entity.Mood;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MoodRepository extends JpaRepository<Mood, Long> {

    Optional<Mood> findByScore(int score);
}
