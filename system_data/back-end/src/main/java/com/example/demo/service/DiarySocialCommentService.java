package com.example.demo.service;

import com.example.demo.bean.DiarySocialCommentBean;

import java.util.List;

public interface DiarySocialCommentService extends BaseService<DiarySocialCommentBean>{
    List<DiarySocialCommentBean> findByDiaryId(Integer diaryId);
}
