package com.example.demo.service;

import com.example.demo.bean.DiaryBean;
import org.apache.ibatis.javassist.NotFoundException;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface DiaryService extends BaseService<DiaryBean> {
    List<DiaryBean> searchAnnoyanceByAccount(String account);

    List<DiaryBean> searchAnnoyanceByShare();

    @Transactional(readOnly = false)
    void updateDiary(Integer id, String account, DiaryBean diaryBean) throws NotFoundException;
}
