package com.example.demo.dao.impl;

import com.example.demo.dao.AllMonsterDAO;
import com.example.demo.entity.AllMonster;
import org.hibernate.criterion.DetachedCriteria;
import org.hibernate.criterion.Restrictions;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public class AllMonsterDAOImpl extends BaseDAOImplement<AllMonster> implements AllMonsterDAO {
    @Override
    public List<AllMonster> findByGroup(Integer group) {
        DetachedCriteria detachedCriteria = DetachedCriteria.forClass(AllMonster.class);
        detachedCriteria.add(Restrictions.eq("group", group));
        return findByCriteria(detachedCriteria);
    }
    @Override
    public Optional<AllMonster> findByGroupAndMain(Integer group, Integer main) {
        DetachedCriteria detachedCriteria = DetachedCriteria.forClass(AllMonster.class);
        detachedCriteria.add(Restrictions.eq("group", group));
        detachedCriteria.add(Restrictions.eq("main", main));
        return getOne(detachedCriteria);
    }
}
