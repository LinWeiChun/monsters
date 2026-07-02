package com.example.demo.dao.impl;

import com.example.demo.dao.DiaryDAO;
import com.example.demo.entity.Diary;
import org.hibernate.criterion.DetachedCriteria;
import org.hibernate.criterion.Restrictions;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public class DiaryDAOImpl extends BaseDAOImplement<Diary> implements DiaryDAO {
    @Override
    public List<Diary> findByAccount(String account) {
        DetachedCriteria detachedCriteria = DetachedCriteria.forClass(Diary.class);
        detachedCriteria.add(Restrictions.eq("account", account));
        return findByCriteria(detachedCriteria);
    }

    @Override
    public List<Diary> findByShare() {
        DetachedCriteria detachedCriteria = DetachedCriteria.forClass(Diary.class);
        detachedCriteria.add(Restrictions.eq("share", 1));
        return findByCriteria(detachedCriteria);
    }

    @Override
    public List<Diary> findByShareByAccount(String account) {
        DetachedCriteria detachedCriteria = DetachedCriteria.forClass(Diary.class);
        detachedCriteria.add(Restrictions.eq("share", 1));
        detachedCriteria.add(Restrictions.eq("account", account));
        return findByCriteria(detachedCriteria);
    }

    @Override
    public Optional<Diary> findByIdAndAccount(Integer id, String account) {
        DetachedCriteria detachedCriteria = DetachedCriteria.forClass(Diary.class);
        detachedCriteria.add(Restrictions.eq("id", id));
        detachedCriteria.add(Restrictions.eq("account", account));
        return Optional.empty();
    }
}
