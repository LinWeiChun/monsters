package com.example.demo.dao;

import com.example.demo.entity.PersonalMonsterUse;

import java.util.Optional;

public interface PersonalMonsterUseDAO  extends BaseDAO<PersonalMonsterUse>{
    Optional<PersonalMonsterUse> findByAccountAndMonsterGroup(String account, Integer monsterGroup);
}
