package com.example.demo.service.impl;

import com.example.demo.bean.DiarySocialCommentBean;
import com.example.demo.dao.DiarySocialCommentDAO;
import com.example.demo.entity.DiarySocialComment;
import com.example.demo.service.DiarySocialCommentService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class DiarySocialCommentServiceImpl extends BaseServiceImplement<DiarySocialCommentDAO, DiarySocialComment, DiarySocialCommentBean> implements DiarySocialCommentService {

    private final DiarySocialCommentDAO diarySocialCommentDAO;

    public DiarySocialCommentServiceImpl(DiarySocialCommentDAO baseDAO, DiarySocialCommentDAO diarySocialCommentDAO) {
        super(baseDAO);
        this.diarySocialCommentDAO = diarySocialCommentDAO;
    }

    @Transactional
    @Override
    public DiarySocialCommentBean createAndReturnBean(DiarySocialCommentBean bean) {
        DiarySocialComment diarySocialComment = createVO(bean);
        diarySocialComment.setDate(LocalDateTime.now());
        diarySocialCommentDAO.insert(diarySocialComment);
        return createBean(diarySocialComment);
    }
    @Override
    public List<DiarySocialCommentBean> findByDiaryId(Integer diaryId) {
        List<DiarySocialComment> userList = diarySocialCommentDAO.findByDiaryId(diaryId);
        List<DiarySocialCommentBean> diarySocialCommentBeanList = new ArrayList<>();
        for(DiarySocialComment diarySocialComment : userList){
            diarySocialCommentBeanList.add(createBean(diarySocialComment));
        }
        return diarySocialCommentBeanList;
    }
    @Override
    protected DiarySocialComment createVO(DiarySocialCommentBean bean) {
        DiarySocialComment entity = new DiarySocialComment();
        entity.setId(bean.getId());
        entity.setCommentUser(bean.getCommentUser());
        entity.setDiaryId(bean.getDiaryId());
        entity.setContent(bean.getCommentContent());
        entity.setDate(bean.getDate());
        return entity;
    }

    @Override
    protected DiarySocialCommentBean createBean(DiarySocialComment entity) {
        DiarySocialCommentBean bean = new DiarySocialCommentBean();
        bean.setId(entity.getId());
        bean.setCommentUser(entity.getCommentUser());
        bean.setDiaryId(entity.getDiaryId());
        bean.setCommentContent(entity.getContent());
        bean.setDate(entity.getDate());
        return bean;
    }
}
