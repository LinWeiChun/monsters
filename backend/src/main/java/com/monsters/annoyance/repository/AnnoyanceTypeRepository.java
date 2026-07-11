package com.monsters.annoyance.repository;

import com.monsters.annoyance.entity.AnnoyanceType;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AnnoyanceTypeRepository extends JpaRepository<AnnoyanceType, Long> {

    Optional<AnnoyanceType> findByCode(String code);

    List<AnnoyanceType> findAllByOrderByDisplayOrderAsc();
}
