package com.example.demo.controller;

import com.example.demo.bean.AllMonsterBean;
import com.example.demo.bean.AnnoyanceBean;
import com.example.demo.bean.PersonalMonsterBean;
import com.example.demo.bean.PersonalMonsterUseBean;
import com.example.demo.service.impl.AllMonsterServiceImpl;
import com.example.demo.service.impl.AnnoyanceServiceImpl;
import com.example.demo.service.impl.PersonalMonsterServiceImpl;
import com.example.demo.service.impl.PersonalMonsterUseServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import lombok.AllArgsConstructor;
import org.apache.ibatis.javassist.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * @author linwe
 */
@AllArgsConstructor
@Controller
@RequestMapping(value = "/annoyance")
public class AnnoyanceController {
    private final AnnoyanceServiceImpl annoyanceService;
    private final AllMonsterServiceImpl allMonsterService;
    private final PersonalMonsterServiceImpl personalMonsterService;
    private final PersonalMonsterUseServiceImpl personalMonsterUseService;

    private final String CONTENT_FILE = "D:/monsters/back-end/file/annoyance/content/";
    private final String MOOD_FILE = "D:/monsters/back-end/file/annoyance/mood/";

    @ResponseBody
    @PostMapping("/create")
    public ResponseEntity createAnnoyance(@RequestBody AnnoyanceBean annoyanceBean) {
        int index = 0;
        int probability = 0;
        boolean isAddMonster = true;
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        ArrayNode dataNode = result.putArray("data");
        try {
            if (annoyanceBean.getContent() == null && annoyanceBean.getContent().isEmpty() &&
                    annoyanceBean.getImageContent() == null && annoyanceBean.getImageContent().isEmpty() &&
                    annoyanceBean.getAudioContent() == null && annoyanceBean.getAudioContent().isEmpty()) {
                result.put("result", false);
                result.put("errorCode", "");
                result.put("message", "新增失敗");
            } else {
                if (annoyanceBean.getMood().equals("是")) {
                    annoyanceBean.setMood(annoyanceBean.getMood());
                }
                if(annoyanceBean.getAudioContent()!=null){
                    annoyanceBean.setAudioContent(annoyanceBean.getAudioContent());
                }
                if(annoyanceBean.getImageContent()!=null){
                    annoyanceBean.setImageContent(annoyanceBean.getImageContent());
                }

                List<AllMonsterBean> allMonster = allMonsterService.searchAll();
                // 抽1~100為機率
                probability = (int) (Math.random() * 100);
                index = (int) (Math.random() * 20);
                if (probability < 50) {
                    index = (int) (Math.random() * 10);
                } else if (probability < 85) {
                    index = (int) (Math.random() * 5) + 10;
                } else {
                    index = (int) (Math.random() * 5) + 15;
                }
                index *= 4;

                while (allMonster.get(index).getMain() != 0) {
                    index = (int) (Math.random() * 20);
                    if (probability < 50) {
                        index = (int) (Math.random() * 10);
                    } else if (probability < 85) {
                        index = (int) (Math.random() * 5) + 10;
                    } else {
                        index = (int) (Math.random() * 5) + 15;
                    }
                    index *= 4;
                }
                annoyanceBean.setMonsterId(allMonster.get(index).getId());
                annoyanceService.createAndReturnBean(annoyanceBean);
                PersonalMonsterBean personalMonsterBean = new PersonalMonsterBean();
                PersonalMonsterUseBean personalMonsterUseBean = new PersonalMonsterUseBean();
                List<PersonalMonsterBean> personalMonsterList = personalMonsterService.findByAccount(annoyanceBean.getAccount());
                for (PersonalMonsterBean personalMonster : personalMonsterList) {
                    System.out.println(personalMonster.getMonsterId() + "/" + allMonster.get(index).getId());
                    if (personalMonster.getMonsterId().equals(allMonster.get(index).getId())) {
                        isAddMonster = false;
                        break;
                    }
                }
                System.out.println(isAddMonster);
                personalMonsterUseBean.setAccount(annoyanceBean.getAccount());
                personalMonsterUseBean.setMonsterGroup(allMonster.get(index).getGroup());
                personalMonsterUseBean.setUse(0);
                Optional<PersonalMonsterUseBean> personalMonsterUseBeanOptional = personalMonsterUseService.findByAccountAndMonsterGroup(personalMonsterUseBean.getAccount(), personalMonsterUseBean.getMonsterGroup());
                System.out.println(personalMonsterUseBeanOptional.isPresent());
                if (!personalMonsterUseBeanOptional.isPresent()) {
                    personalMonsterUseService.createAndReturnBean(personalMonsterUseBean);
                }
                if (isAddMonster) {
                    personalMonsterBean.setAccount(annoyanceBean.getAccount());
                    personalMonsterBean.setMonsterId(allMonster.get(index).getId());
                    personalMonsterBean.setMonsterGroup(allMonster.get(index).getGroup());
                    ObjectNode personalMonsterNode = dataNode.addObject();
                    personalMonsterNode.put("newMonster", true);
                    personalMonsterNode.put("newMonsterGroup", allMonster.get(index).getGroup());
                    personalMonsterService.createAndReturnBean(personalMonsterBean);
                } else {
                    ObjectNode personalMonsterNode = dataNode.addObject();
                    personalMonsterNode.put("newMonster", false);
                    personalMonsterNode.put("newMonsterGroup", allMonster.get(index).getGroup());
                }
                result.put("result", true);
                result.put("errorCode", "200");
                result.put("message", "新增成功");
            }
        } catch (Exception e) {
            System.out.println(e);
            result.put("result", false);
            result.put("errorCode", "");
            result.put("message", "新增失敗");
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    @ResponseBody
    @PatchMapping("/modify/{id}/{account}")
    public ResponseEntity modifyAnnoyance(@PathVariable(name = "id") int id, @PathVariable(name = "account") String account, @RequestBody AnnoyanceBean annoyanceBean) throws NotFoundException {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        annoyanceService.updateAnnoyance(id, account, annoyanceBean);
        result.put("result", true);
        result.put("errorCode", "200");
        result.put("message", "修改成功");
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }
}
