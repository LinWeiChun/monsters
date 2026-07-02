package com.example.demo.dao;

import com.example.demo.entity.AnnoyanceSocialComment;

import java.util.List;

public interface AnnoyanceSocialCommentDAO extends BaseDAO<AnnoyanceSocialComment>{
    List<AnnoyanceSocialComment> findByAnnoyanceId(Integer annoyanceId);
}
