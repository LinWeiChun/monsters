package com.example.demo.dao.impl;

import com.example.demo.dao.PersonalMonsterUseDAO;
import com.example.demo.entity.PersonalMonsterUse;
import org.hibernate.criterion.DetachedCriteria;
import org.hibernate.criterion.Restrictions;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public class PersonalMonsterUseDAOImpl  extends BaseDAOImplement<PersonalMonsterUse> implements PersonalMonsterUseDAO {
    @Override
    public Optional<PersonalMonsterUse> findByAccountAndMonsterGroup(String account, Integer monsterGroup) {
        DetachedCriteria detachedCriteria = DetachedCriteria.forClass(PersonalMonsterUse.class);
        detachedCriteria.add(Restrictions.eq("account", account));
        detachedCriteria.add(Restrictions.eq("monsterGroup", monsterGroup));
        return getOne(detachedCriteria);
    }
}
