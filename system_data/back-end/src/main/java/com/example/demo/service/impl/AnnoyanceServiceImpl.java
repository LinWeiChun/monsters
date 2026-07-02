package com.example.demo.service.impl;

import com.example.demo.bean.AnnoyanceBean;
import com.example.demo.dao.AnnoyanceDAO;
import com.example.demo.entity.Annoyance;
import com.example.demo.service.AnnoyanceService;
import org.apache.ibatis.javassist.NotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class AnnoyanceServiceImpl extends BaseServiceImplement<AnnoyanceDAO, Annoyance, AnnoyanceBean> implements AnnoyanceService {

    @Autowired
    private final AnnoyanceDAO annoyanceDAO;

    public AnnoyanceServiceImpl(AnnoyanceDAO baseDAO) {
        super(baseDAO);
        this.annoyanceDAO = baseDAO;
    }

    @Transactional
    @Override
    public AnnoyanceBean createAndReturnBean(AnnoyanceBean bean) {
        Annoyance annoyance = createVO(bean);
        annoyance.setTime(LocalDateTime.now());
        annoyanceDAO.insert(annoyance);
        bean = createBean(annoyance);
        return bean;
    }

    @Transactional
    @Override
    public List<AnnoyanceBean> searchAnnoyanceByAccount(String account) {
        List<Annoyance> userList = annoyanceDAO.findByAccount(account);
        List<AnnoyanceBean> annoyanceBeanList = new ArrayList<>();
        for (Annoyance annoyance : userList) {
            annoyanceBeanList.add(createBean(annoyance));
        }
        return annoyanceBeanList;
    }

    @Override
    public List<AnnoyanceBean> searchAnnoyanceByShare() {
        List<Annoyance> userList = annoyanceDAO.findByShare();
        List<AnnoyanceBean> annoyanceBeanList = new ArrayList<>();
        for (Annoyance annoyance : userList) {
            annoyanceBeanList.add(createBean(annoyance));
        }
        return annoyanceBeanList;
    }

    @Override
    public List<AnnoyanceBean> searchAnnoyanceIsSolveByAccount(int solve, String account) {
        List<Annoyance> userList = annoyanceDAO.findBySolve(solve, account);
        List<AnnoyanceBean> annoyanceBeanList = new ArrayList<>();
        for (Annoyance annoyance : userList) {
            annoyanceBeanList.add(createBean(annoyance));
        }
        return annoyanceBeanList;
    }

    public List<AnnoyanceBean> searchAnnoyanceByShareByAccount(String account) {
        List<Annoyance> userList = annoyanceDAO.findByShareByAccount(account);
        List<AnnoyanceBean> annoyanceBeanList = new ArrayList<>();
        for (Annoyance annoyance : userList) {
            annoyanceBeanList.add(createBean(annoyance));
        }
        return annoyanceBeanList;
    }

    @Override
    public void updateAnnoyance(Integer id, String account, AnnoyanceBean annoyanceBean) throws NotFoundException {
        Optional<Annoyance> annoyanceOptional = annoyanceDAO.findByIdAndAccount(id, account);
        if (annoyanceOptional.isPresent()) {
            Annoyance annoyance = annoyanceOptional.get();
            annoyanceBean.setMonsterId(annoyance.getMonsterId());
            copy(annoyanceBean, annoyance);
            annoyanceDAO.update(annoyance);
        } else {
            throw new NotFoundException("該帳號 : " + account + "找不到此煩惱 : " + id);
        }
    }

    @Override
    protected Annoyance createVO(AnnoyanceBean bean) {
        Annoyance entity = new Annoyance();
        entity.setId(bean.getId());
        entity.setAccount(bean.getAccount());
        entity.setContent(bean.getContent());
        entity.setImageContent(bean.getImageContent());
        entity.setAudioContent(bean.getAudioContent());
        entity.setType(bean.getType());
        entity.setMonsterId(bean.getMonsterId());
        entity.setMood(bean.getMood());
        entity.setIndex(bean.getIndex());
        entity.setTime(bean.getTime());
        entity.setSolve(bean.getSolve());
        entity.setShare(bean.getShare());
        return entity;
    }

    @Override
    protected AnnoyanceBean createBean(Annoyance entity) {
        AnnoyanceBean bean = new AnnoyanceBean();
        bean.setId(entity.getId());
        bean.setAccount(entity.getAccount());
        bean.setContent(entity.getContent());
        bean.setImageContent(entity.getImageContent());
        bean.setAudioContent(entity.getAudioContent());
        bean.setType(entity.getType());
        bean.setMonsterId(entity.getMonsterId());
        bean.setMood(entity.getMood());
        bean.setIndex(entity.getIndex());
        bean.setTime(entity.getTime());
        bean.setSolve(entity.getSolve());
        bean.setShare(entity.getShare());
        return bean;
    }
}