package com.example.demo.service.impl;

import com.example.demo.bean.PersonalMonsterUseBean;
import com.example.demo.dao.PersonalMonsterUseDAO;
import com.example.demo.entity.PersonalMonsterUse;
import com.example.demo.service.PersonalMonsterUseService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class PersonalMonsterUseServiceImpl  extends BaseServiceImplement<PersonalMonsterUseDAO, PersonalMonsterUse, PersonalMonsterUseBean> implements PersonalMonsterUseService {
    private final PersonalMonsterUseDAO personalMonsterUseDAO;

    public PersonalMonsterUseServiceImpl(PersonalMonsterUseDAO personalMonsterUseDAO) {
        super(personalMonsterUseDAO);
        this.personalMonsterUseDAO = personalMonsterUseDAO;
    }
    @Transactional
    @Override
    public PersonalMonsterUseBean createAndReturnBean(PersonalMonsterUseBean bean) {
        PersonalMonsterUse personalMonsterUse = createVO(bean);
        personalMonsterUseDAO.insert(personalMonsterUse);
        return createBean(personalMonsterUse);
    }

    @Override
    public void updateMonsterSkin(String account, PersonalMonsterUseBean personalMonsterUseBean) {
        Optional<PersonalMonsterUse> personalMonsterUseOptional = personalMonsterUseDAO.findByAccountAndMonsterGroup(account, personalMonsterUseBean.getMonsterGroup());
        if (personalMonsterUseOptional.isPresent()) {
            PersonalMonsterUse personalMonsterUse = personalMonsterUseOptional.get();
            copy(personalMonsterUseBean, personalMonsterUse);
            personalMonsterUseDAO.update(personalMonsterUse);
        }
    }

    @Override
    public Optional<PersonalMonsterUseBean> findByAccountAndMonsterGroup(String account, Integer monsterGroup) {
        Optional<PersonalMonsterUse> personalMonsterUseOptional = personalMonsterUseDAO.findByAccountAndMonsterGroup(account, monsterGroup);
        PersonalMonsterUseBean personalMonsterUseBean = new PersonalMonsterUseBean();
        if (personalMonsterUseOptional.isPresent()) {
            PersonalMonsterUse personalMonsterUse = personalMonsterUseOptional.get();
            copy(personalMonsterUse, personalMonsterUseBean);
            return Optional.of(personalMonsterUseBean);
        }else {
            return Optional.empty();
        }
    }

    @Override
    protected PersonalMonsterUse createVO(PersonalMonsterUseBean bean) {
        PersonalMonsterUse entity = new PersonalMonsterUse();
        entity.setAccount(bean.getAccount());
        entity.setMonsterGroup(bean.getMonsterGroup());
        entity.setUse(bean.getUse());
        return entity;
    }

    @Override
    protected PersonalMonsterUseBean createBean(PersonalMonsterUse entity) {
        PersonalMonsterUseBean bean = new PersonalMonsterUseBean();
        bean.setAccount(entity.getAccount());
        bean.setUse(entity.getUse());
        bean.setMonsterGroup(entity.getMonsterGroup());
        return bean;
    }
}
