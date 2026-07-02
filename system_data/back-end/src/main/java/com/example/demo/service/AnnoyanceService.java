package com.example.demo.service;

import com.example.demo.bean.AnnoyanceBean;
import org.apache.ibatis.javassist.NotFoundException;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * @author linwe
 */
public interface AnnoyanceService extends BaseService<AnnoyanceBean>{
    List<AnnoyanceBean> searchAnnoyanceByAccount(String account);

    List<AnnoyanceBean> searchAnnoyanceByShare();

    List<AnnoyanceBean> searchAnnoyanceIsSolveByAccount(int solve, String account);

    @Transactional(readOnly = false)
    void updateAnnoyance(Integer id, String account, AnnoyanceBean annoyanceBean) throws NotFoundException;

}
