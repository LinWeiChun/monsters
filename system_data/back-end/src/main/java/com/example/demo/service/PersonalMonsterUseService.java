package com.example.demo.service;

import com.example.demo.bean.PersonalMonsterUseBean;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

public interface PersonalMonsterUseService extends BaseService<PersonalMonsterUseBean> {
    @Transactional(readOnly = false)
    void updateMonsterSkin(String account, PersonalMonsterUseBean personalMonsterUseBean);

    Optional<PersonalMonsterUseBean> findByAccountAndMonsterGroup(String account, Integer monsterGroup);
}
