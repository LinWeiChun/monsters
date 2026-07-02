package com.example.demo.dao;

import com.example.demo.entity.Diary;

import java.util.List;
import java.util.Optional;

public interface DiaryDAO extends BaseDAO<Diary> {
    List<Diary> findByAccount(String account);
    List<Diary> findByShare();

    List<Diary> findByShareByAccount(String account);

    Optional<Diary> findByIdAndAccount(Integer id, String account);
}
