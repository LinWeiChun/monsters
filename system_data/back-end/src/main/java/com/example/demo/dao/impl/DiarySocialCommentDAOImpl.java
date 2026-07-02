package com.example.demo.dao.impl;

import com.example.demo.dao.DiarySocialCommentDAO;
import com.example.demo.entity.DiarySocialComment;
import org.hibernate.criterion.DetachedCriteria;
import org.hibernate.criterion.Restrictions;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class DiarySocialCommentDAOImpl extends BaseDAOImplement<DiarySocialComment> implements DiarySocialCommentDAO {
    @Override
    public List<DiarySocialComment> findByDiaryId(Integer diaryId) {
        DetachedCriteria detachedCriteria = DetachedCriteria.forClass(DiarySocialComment.class);
        detachedCriteria.add(Restrictions.eq("diaryId", diaryId));
        return findByCriteria(detachedCriteria);
    }
}
