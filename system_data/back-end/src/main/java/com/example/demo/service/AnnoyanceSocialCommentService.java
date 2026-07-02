package com.example.demo.service;

import com.example.demo.bean.AnnoyanceSocialCommentBean;

import java.util.List;

public interface AnnoyanceSocialCommentService extends BaseService<AnnoyanceSocialCommentBean>{
    List<AnnoyanceSocialCommentBean> findByAnnoyanceId(Integer annoyanceId);
}
