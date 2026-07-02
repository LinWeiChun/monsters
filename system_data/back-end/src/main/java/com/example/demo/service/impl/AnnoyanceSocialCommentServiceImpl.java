package com.example.demo.service.impl;

import com.example.demo.bean.AnnoyanceSocialCommentBean;
import com.example.demo.dao.AnnoyanceSocialCommentDAO;
import com.example.demo.entity.AnnoyanceSocialComment;
import com.example.demo.service.AnnoyanceSocialCommentService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class AnnoyanceSocialCommentServiceImpl extends BaseServiceImplement<AnnoyanceSocialCommentDAO, AnnoyanceSocialComment, AnnoyanceSocialCommentBean> implements AnnoyanceSocialCommentService {

    private final AnnoyanceSocialCommentDAO annoyanceSocialCommentDAO;

    public AnnoyanceSocialCommentServiceImpl(AnnoyanceSocialCommentDAO baseDAO, AnnoyanceSocialCommentDAO annoyanceSocialCommentDAO) {
        super(baseDAO);
        this.annoyanceSocialCommentDAO = annoyanceSocialCommentDAO;
    }

    @Transactional
    @Override
    public AnnoyanceSocialCommentBean createAndReturnBean(AnnoyanceSocialCommentBean bean) {
        AnnoyanceSocialComment annoyanceSocialComment = createVO(bean);
        annoyanceSocialComment.setDate(LocalDateTime.now());
        annoyanceSocialCommentDAO.insert(annoyanceSocialComment);
        return createBean(annoyanceSocialComment);
    }

    @Override
    public List<AnnoyanceSocialCommentBean> findByAnnoyanceId(Integer annoyanceId) {
        List<AnnoyanceSocialComment> userList = annoyanceSocialCommentDAO.findByAnnoyanceId(annoyanceId);
        List<AnnoyanceSocialCommentBean> annoyanceSocialCommentBeanList = new ArrayList<>();
        for(AnnoyanceSocialComment annoyanceSocialComment : userList){
            annoyanceSocialCommentBeanList.add(createBean(annoyanceSocialComment));
        }
        return annoyanceSocialCommentBeanList;
    }
    @Override
    protected AnnoyanceSocialComment createVO(AnnoyanceSocialCommentBean bean) {
        AnnoyanceSocialComment entity = new AnnoyanceSocialComment();
        entity.setId(bean.getId());
        entity.setCommentUser(bean.getCommentUser());
        entity.setAnnoyanceId(bean.getAnnoyanceId());
        entity.setContent(bean.getCommentContent());
        entity.setDate(bean.getDate());
        return entity;
    }

    @Override
    protected AnnoyanceSocialCommentBean createBean(AnnoyanceSocialComment entity) {
        AnnoyanceSocialCommentBean bean = new AnnoyanceSocialCommentBean();
        bean.setId(entity.getId());
        bean.setCommentUser(entity.getCommentUser());
        bean.setAnnoyanceId(entity.getAnnoyanceId());
        bean.setCommentContent(entity.getContent());
        bean.setDate(entity.getDate());
        return bean;
    }

}
