package com.example.demo.dao.impl;

import com.example.demo.dao.AnnoyanceSocialCommentDAO;
import com.example.demo.entity.AnnoyanceSocialComment;
import org.hibernate.criterion.DetachedCriteria;
import org.hibernate.criterion.Restrictions;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class AnnoyanceSocialCommentDAOImpl extends BaseDAOImplement<AnnoyanceSocialComment> implements AnnoyanceSocialCommentDAO {
    @Override
    public List<AnnoyanceSocialComment> findByAnnoyanceId(Integer annoyanceId) {
        DetachedCriteria detachedCriteria = DetachedCriteria.forClass(AnnoyanceSocialComment.class);
        detachedCriteria.add(Restrictions.eq("annoyanceId", annoyanceId));
        return findByCriteria(detachedCriteria);
    }
}
