package com.example.demo.dao;

import com.example.demo.entity.DiarySocialComment;

import java.util.List;

public interface DiarySocialCommentDAO extends BaseDAO<DiarySocialComment> {
    List<DiarySocialComment> findByDiaryId(Integer diaryId);
}
