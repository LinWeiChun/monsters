package com.example.demo.service;

import com.example.demo.bean.PersonalInfoBean;
import com.example.demo.bean.PersonalMonsterBean;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface PersonalInfoService extends BaseService<PersonalInfoBean>{
    @Transactional(readOnly = false)
    List<PersonalMonsterBean> updateDailyTest(String account);

    @Transactional(readOnly = false)
    void updateInformation(String account, PersonalInfoBean personalInfoBean);

    List<PersonalInfoBean> searchPersonalInfoByAccount(String account);
}
