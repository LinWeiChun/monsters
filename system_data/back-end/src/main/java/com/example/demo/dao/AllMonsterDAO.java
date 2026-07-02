package com.example.demo.dao;

import com.example.demo.entity.AllMonster;

import java.util.List;
import java.util.Optional;

public interface AllMonsterDAO extends BaseDAO<AllMonster> {
    List<AllMonster> findByGroup(Integer group);
    Optional<AllMonster> findByGroupAndMain(Integer group, Integer main);
}
