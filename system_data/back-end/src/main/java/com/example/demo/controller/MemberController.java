package com.example.demo.controller;

import com.example.demo.bean.PersonalInfoBean;
import com.example.demo.bean.PersonalMonsterBean;
import com.example.demo.bean.PersonalMonsterUseBean;
import com.example.demo.service.PersonalInfoService;
import com.example.demo.service.impl.PersonalMonsterServiceImpl;
import com.example.demo.service.impl.PersonalMonsterUseServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@AllArgsConstructor
@RestController
@RequestMapping(value = "/member")
public class MemberController {
    private final PersonalInfoService personalInfoService;
    private final PasswordEncoder passwordEncoder;

    private final PersonalMonsterServiceImpl personalMonsterService;
    private final PersonalMonsterUseServiceImpl personalMonsterUseService;

    @ResponseBody
    @PostMapping(value = "/create")
    public ResponseEntity register(@RequestBody PersonalInfoBean personalInfoBean) {
        boolean isCreate = false;
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        result.putObject("data");
        Optional<PersonalInfoBean> personalInfoBeanOptional = personalInfoService.getByPK(personalInfoBean.getAccount());
        List<PersonalInfoBean> personalInfoBeanList = personalInfoService.searchAll();
        try {
            if (personalInfoBeanOptional.isPresent()) {
                result.put("result", false);
                result.put("errorCode", "401");
                result.put("message", "帳號已被註冊");
            } else {
                for(PersonalInfoBean userBean : personalInfoBeanList){
                    if(userBean.getMail().equals(personalInfoBean.getMail())){
                        result.put("result", false);
                        result.put("errorCode", "402");
                        result.put("message", "信箱已被使用");
                        isCreate = false;
                        break;
                    }else if(userBean.getNickName().equals(personalInfoBean.getNickName())){
                        result.put("result", false);
                        result.put("errorCode", "403");
                        result.put("message", "暱稱已被使用");
                        isCreate = false;
                        break;
                    }else {
                        isCreate = true;
                    }
                }
                if(isCreate) {
                    personalInfoService.createAndReturnBean(personalInfoBean);
                    PersonalMonsterBean personalMonsterBean = new PersonalMonsterBean();
                    PersonalMonsterUseBean personalMonsterUseBean = new PersonalMonsterUseBean();
                    personalMonsterBean.setAccount(personalInfoBean.getAccount());
                    personalMonsterBean.setMonsterId(0);
                    personalMonsterBean.setMonsterGroup(0);
                    personalMonsterUseBean.setAccount(personalInfoBean.getAccount());
                    personalMonsterUseBean.setMonsterGroup(0);
                    personalMonsterUseBean.setUse(0);
                    personalMonsterService.createAndReturnBean(personalMonsterBean);
                    personalMonsterUseService.createAndReturnBean(personalMonsterUseBean);
                    result.put("result", true);
                    result.put("errorCode", "200");
                    result.put("message", "註冊成功");
                }
            }
        } catch (Exception e) {
            result.put("result", false);
            result.put("errorCode", "");
            result.put("message", "註冊失敗");
            e.printStackTrace();
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    @ResponseBody
    @PostMapping(value = "/login")
    public ResponseEntity login(@RequestBody PersonalInfoBean personalInfoBean) {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        ArrayNode dataNode = result.putArray("data");
        try {
            Optional<PersonalInfoBean> personalInfoBeanOptional = personalInfoService.getByPK(personalInfoBean.getAccount());
            PersonalInfoBean local = personalInfoBeanOptional.get();
            ObjectNode personalInfoNode = dataNode.addObject();
            if (passwordEncoder.matches(personalInfoBean.getPassword(), local.getPassword())) {
                personalInfoNode.put("account", local.getAccount());
                personalInfoNode.put("birthday", local.getBirthday().toString());
                personalInfoNode.put("mail", local.getMail());
                personalInfoNode.put("nickName", local.getNickName());
                personalInfoNode.put("lock", local.getLock());
                personalInfoNode.put("photo", local.getPhoto());
                personalInfoNode.put("dailyTest", local.getDailyTest());
                personalInfoNode.put("result", true);
                personalInfoNode.put("errorCode", "200");
                personalInfoNode.put("message", "登入成功");
            } else {
                personalInfoNode.put("result", false);
                personalInfoNode.put("errorCode", "");
                personalInfoNode.put("message", "登入失敗");
            }
        } catch (Exception e) {
            System.out.println(e);
            result.put("result", false);
            result.put("message", "登入失敗");
            e.printStackTrace();
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    @ResponseBody
    @GetMapping(path = "/{account}", produces = "application/json; charset=UTF-8")
    public ResponseEntity SearchPersonalInfoByAccount(@PathVariable(name = "account") String account) {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        ArrayNode dataNode = result.putArray("data");
        try {
            List<PersonalInfoBean> personalInfoList = personalInfoService.searchPersonalInfoByAccount(account);
            ObjectNode personalInfoNode = dataNode.addObject();
            for (PersonalInfoBean personalInfoBean : personalInfoList) {
                personalInfoNode.put("nickName", personalInfoBean.getNickName());
                personalInfoNode.put("birthday", personalInfoBean.getBirthday().toString());
                personalInfoNode.put("mail", personalInfoBean.getMail());
                personalInfoNode.put("account", personalInfoBean.getAccount());
                personalInfoNode.put("photo", personalInfoBean.getPhoto());
                personalInfoNode.put("dailyTest", personalInfoBean.getDailyTest());
                personalInfoNode.put("lock", personalInfoBean.getLock());
                result.put("result", true);
                result.put("errorCode", "200");
                result.put("message", "查詢成功");
            }
        } catch (Exception e) {
            System.out.println(e);
            result.put("result", false);
            result.put("message", "註冊失敗");
            e.printStackTrace();
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    @ResponseBody
    @PatchMapping(value = "/modify/{account}", produces = "application/json; charset=UTF-8")
    public ResponseEntity modifyMemberByAccount(@PathVariable(name = "account") String account, @RequestBody PersonalInfoBean personalInfoBean) {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        personalInfoService.updateInformation(account, personalInfoBean);
        result.put("result", true);
        result.put("errorCode", "200");
        result.put("message", "修改成功");
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    @ResponseBody
    @GetMapping(value = "/dailyTest/{account}")
    public ResponseEntity dailyTest(@PathVariable(name = "account") String account) {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        ArrayNode dataNode = result.putArray("data");

        Optional<PersonalInfoBean> personalInfoBeanOptional = personalInfoService.getByPK(account);
        List<PersonalMonsterBean> personalMonsterBeanList = personalInfoService.updateDailyTest(
                personalInfoBeanOptional.get().getAccount());

        ObjectNode personalInfoNode = dataNode.addObject();
        boolean checker=true;
        for (PersonalMonsterBean personalMonsterBean : personalMonsterBeanList) {
            personalInfoNode.put("monsterId", personalMonsterBean.getMonsterId());
            personalInfoNode.put("monsterGroup", personalMonsterBean.getMonsterGroup());
            checker=false;
        }
        if(checker){
            personalInfoNode.put("monsterId", -1);
            personalInfoNode.put("monsterGroup", -1);
        }
        personalInfoNode.put("dailyTest", personalInfoBeanOptional.get().getDailyTest() + 1);
        result.put("result", true);
        result.put("errorCode", "200");
        result.put("message", "修改成功");
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }
}
