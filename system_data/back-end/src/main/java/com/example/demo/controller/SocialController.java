package com.example.demo.controller;

import com.example.demo.bean.*;
import com.example.demo.service.DiarySocialCommentService;
import com.example.demo.service.impl.AnnoyanceServiceImpl;
import com.example.demo.service.impl.AnnoyanceSocialCommentServiceImpl;
import com.example.demo.service.impl.DiaryServiceImpl;
import com.example.demo.service.impl.PersonalInfoServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

@AllArgsConstructor
@Controller
@RequestMapping(value = "/social")
public class SocialController {
    private final AnnoyanceServiceImpl annoyanceService;
    private final DiaryServiceImpl diaryService;
    private final PersonalInfoServiceImpl personalInfoService;
    private final AnnoyanceSocialCommentServiceImpl annoyanceSocialCommentService;
    private final DiarySocialCommentService diarySocialCommentService;

    @ResponseBody
    @GetMapping(path = "/all/{type}", produces = "application/json; charset=UTF-8")
    public ResponseEntity searchSocialAll(@PathVariable(name = "type") Integer type) {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        ArrayNode dataNode = result.putArray("data");
        try {
            List<AnnoyanceBean> annoyanceList = annoyanceService.searchAnnoyanceByShare();
            List<DiaryBean> diaryList = diaryService.searchAnnoyanceByShare();
            if (annoyanceList.size() != 0 || diaryList.size() != 0) {
                Collections.sort(annoyanceList, new Comparator<AnnoyanceBean>() {
                    @Override
                    public int compare(AnnoyanceBean o1, AnnoyanceBean o2) {
                        return o2.getTime().compareTo(o1.getTime());
                    }
                });
                Collections.sort(diaryList, new Comparator<DiaryBean>() {
                    @Override
                    public int compare(DiaryBean o1, DiaryBean o2) {
                        return o2.getTime().compareTo(o1.getTime());
                    }
                });
                switch (type) {
                    case 1:
                        for (AnnoyanceBean annoyanceBean : annoyanceList) {
                            ObjectNode annoyanceNode = dataNode.addObject();
                            Optional<PersonalInfoBean> personalInfo = personalInfoService.getByPK(annoyanceBean.getAccount());
                            String nickName = personalInfo.get().getNickName();
                            annoyanceNode.put("id", annoyanceBean.getId());
                            annoyanceNode.put("nickName", nickName);
                            annoyanceNode.put("content", annoyanceBean.getContent());
                            annoyanceNode.put("imageContent", annoyanceBean.getImageContent());
                            annoyanceNode.put("audioContent", annoyanceBean.getAudioContent());
                            annoyanceNode.put("type", annoyanceBean.getType());
                            annoyanceNode.put("monsterId", annoyanceBean.getMonsterId() / 4);
                            annoyanceNode.put("mood", annoyanceBean.getMood());
                            annoyanceNode.put("avatar", personalInfo.get().getPhoto());
                            annoyanceNode.put("index", annoyanceBean.getIndex());
                            annoyanceNode.put("time", annoyanceBean.getTime().format(DateTimeFormatter.ofPattern("MM/dd")));
                            annoyanceNode.put("solve", annoyanceBean.getSolve());
                            annoyanceNode.put("share", annoyanceBean.getShare());
                        }
                        break;
                    case 2:
                        for (DiaryBean diaryBean : diaryList) {
                            ObjectNode diaryNode = dataNode.addObject();
                            Optional<PersonalInfoBean> personalInfo = personalInfoService.getByPK(diaryBean.getAccount());
                            String nickName = personalInfo.get().getNickName();
                            diaryNode.put("id", diaryBean.getId());
                            diaryNode.put("nickName", nickName);
                            diaryNode.put("content", diaryBean.getContent());
                            diaryNode.put("mood", diaryBean.getMood());
                            diaryNode.put("monsterId", diaryBean.getMonsterId() / 4);
                            diaryNode.put("avatar", personalInfo.get().getPhoto());
                            diaryNode.put("index", diaryBean.getIndex());
                            diaryNode.put("time", diaryBean.getTime().format(DateTimeFormatter.ofPattern("MM/dd")));
                            diaryNode.put("share", diaryBean.getShare());
                        }
                        break;
                    case 3:
                        for (AnnoyanceBean annoyanceBean : annoyanceList) {
                            ObjectNode annoyanceNode = dataNode.addObject();
                            Optional<PersonalInfoBean> personalInfo = personalInfoService.getByPK(annoyanceBean.getAccount());
                            String nickName = personalInfo.get().getNickName();
                            annoyanceNode.put("id", annoyanceBean.getId());
                            annoyanceNode.put("nickName", nickName);
                            annoyanceNode.put("content", annoyanceBean.getContent());
                            annoyanceNode.put("imageContent", annoyanceBean.getImageContent());
                            annoyanceNode.put("audioContent", annoyanceBean.getAudioContent());
                            annoyanceNode.put("type", annoyanceBean.getType());
                            annoyanceNode.put("monsterId", annoyanceBean.getMonsterId() / 4);
                            annoyanceNode.put("avatar", personalInfo.get().getPhoto());
                            annoyanceNode.put("mood", annoyanceBean.getMood());
                            annoyanceNode.put("index", annoyanceBean.getIndex());
                            annoyanceNode.put("time", annoyanceBean.getTime().format(DateTimeFormatter.ofPattern("MM/dd")));
                            annoyanceNode.put("solve", annoyanceBean.getSolve());
                            annoyanceNode.put("share", annoyanceBean.getShare());
                        }
                        for (DiaryBean diaryBean : diaryList) {
                            ObjectNode diaryNode = dataNode.addObject();
                            Optional<PersonalInfoBean> personalInfo = personalInfoService.getByPK(diaryBean.getAccount());
                            String nickName = personalInfo.get().getNickName();
                            diaryNode.put("id", diaryBean.getId());
                            diaryNode.put("nickName", nickName);
                            diaryNode.put("content", diaryBean.getContent());
                            diaryNode.put("imageContent", diaryBean.getImageContent());
                            diaryNode.put("audioContent", diaryBean.getAudioContent());
                            diaryNode.put("mood", diaryBean.getMood());
                            diaryNode.put("monsterId", diaryBean.getMonsterId() / 4);
                            diaryNode.put("avatar", personalInfo.get().getPhoto());
                            diaryNode.put("index", diaryBean.getIndex());
                            diaryNode.put("time", diaryBean.getTime().format(DateTimeFormatter.ofPattern("MM/dd")));
                            diaryNode.put("share", diaryBean.getShare());
                        }
                        break;
                    default:
                        break;
                }
                result.put("result", true);
                result.put("errorCode", "200");
                result.put("message", "查詢成功");
            } else {
                result.put("result", false);
                result.put("errorCode", "");
                result.put("message", "查詢失敗");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    @ResponseBody
    @GetMapping(path = "/{account}", produces = "application/json; charset=UTF-8")
    public ResponseEntity searchSocialByAccount(@PathVariable(name = "account") String account) {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        ArrayNode dataNode = result.putArray("data");
        try {
            List<AnnoyanceBean> annoyanceList = annoyanceService.searchAnnoyanceByShareByAccount(account);
            List<DiaryBean> diaryList = diaryService.searchAnnoyanceByShareByAccount(account);
            if (annoyanceList.size() != 0 || diaryList.size() != 0) {
                Collections.sort(annoyanceList, new Comparator<AnnoyanceBean>() {
                    @Override
                    public int compare(AnnoyanceBean o1, AnnoyanceBean o2) {
                        return o2.getTime().compareTo(o1.getTime());
                    }
                });
                Collections.sort(diaryList, new Comparator<DiaryBean>() {
                    @Override
                    public int compare(DiaryBean o1, DiaryBean o2) {
                        return o2.getTime().compareTo(o1.getTime());
                    }
                });
                for (AnnoyanceBean annoyanceBean : annoyanceList) {
                    ObjectNode annoyanceNode = dataNode.addObject();
                    Optional<PersonalInfoBean> personalInfo = personalInfoService.getByPK(annoyanceBean.getAccount());
                    String nickName = personalInfo.get().getNickName();
                    annoyanceNode.put("id", annoyanceBean.getId());
                    annoyanceNode.put("content", annoyanceBean.getContent());
                    annoyanceNode.put("imageContent", annoyanceBean.getImageContent());
                    annoyanceNode.put("audioContent", annoyanceBean.getAudioContent());
                    annoyanceNode.put("nickName", nickName);
                    annoyanceNode.put("type", annoyanceBean.getType());
                    annoyanceNode.put("monsterId", annoyanceBean.getMonsterId() / 4);
                    annoyanceNode.put("avatar", personalInfo.get().getPhoto());
                    annoyanceNode.put("mood", annoyanceBean.getMood());
                    annoyanceNode.put("index", annoyanceBean.getIndex());
                    annoyanceNode.put("time", annoyanceBean.getTime().format(DateTimeFormatter.ofPattern("MM/dd")));
                    annoyanceNode.put("solve", annoyanceBean.getSolve());
                    annoyanceNode.put("share", annoyanceBean.getShare());
                }
                for (DiaryBean diaryBean : diaryList) {
                    ObjectNode diaryNode = dataNode.addObject();
                    Optional<PersonalInfoBean> personalInfo = personalInfoService.getByPK(diaryBean.getAccount());
                    String nickName = personalInfo.get().getNickName();
                    diaryNode.put("id", diaryBean.getId());
                    diaryNode.put("nickName", nickName);
                    diaryNode.put("content", diaryBean.getContent());
                    diaryNode.put("imageContent", diaryBean.getImageContent());
                    diaryNode.put("audioContent", diaryBean.getAudioContent());
                    diaryNode.put("mood", diaryBean.getMood());
                    diaryNode.put("monsterId", diaryBean.getMonsterId() / 4);
                    diaryNode.put("avatar", personalInfo.get().getPhoto());
                    diaryNode.put("index", diaryBean.getIndex());
                    diaryNode.put("time", diaryBean.getTime().format(DateTimeFormatter.ofPattern("MM/dd")));
                    diaryNode.put("share", diaryBean.getShare());
                }
                result.put("result", true);
                result.put("errorCode", "200");
                result.put("message", "查詢成功");
            } else {
                result.put("result", false);
                result.put("errorCode", "");
                result.put("message", "查詢失敗");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    @ResponseBody
    @PostMapping(path = "/comment/annoyance", produces = "application/json; charset=UTF-8")
    public ResponseEntity createAnnoyanceComment(@RequestBody AnnoyanceSocialCommentBean annoyanceSocialCommentBean) {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        ObjectNode dataNode = result.putObject("data");
        System.out.println(annoyanceSocialCommentBean);
        try {
            if (!annoyanceService.getByPK(annoyanceSocialCommentBean.getAnnoyanceId()).isPresent()) {
                result.put("result", false);
                result.put("errorCode", "");
                result.put("message", "找不到此煩惱");
            }
            annoyanceSocialCommentService.createAndReturnBean(annoyanceSocialCommentBean);
            result.put("result", true);
            result.put("errorCode", "200");
            result.put("message", "留言成功");
        } catch (Exception e) {
            result.put("result", false);
            result.put("errorCode", "");
            result.put("message", "");
            e.printStackTrace();
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    @ResponseBody
    @PostMapping(path = "/comment/diary", produces = "application/json; charset=UTF-8")
    public ResponseEntity createDiaryComment(@RequestBody DiarySocialCommentBean diarySocialCommentBean) {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        ObjectNode dataNode = result.putObject("data");
        System.out.println(diarySocialCommentBean);
        try {
            if (!diaryService.getByPK(diarySocialCommentBean.getDiaryId()).isPresent()) {
                result.put("result", false);
                result.put("errorCode", "");
                result.put("message", "找不到此日記");
            }
            diarySocialCommentService.createAndReturnBean(diarySocialCommentBean);
            result.put("result", true);
            result.put("errorCode", "200");
            result.put("message", "留言成功");
        } catch (Exception e) {
            result.put("result", false);
            result.put("errorCode", "");
            result.put("message", "");
            e.printStackTrace();
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }


    @ResponseBody
    @GetMapping(path = "comment/{type}/{id}", produces = "application/json; charset=UTF-8")
    public ResponseEntity searchComment(@PathVariable(name = "type") int type,
                                        @PathVariable(name = "id") Integer id) {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        ArrayNode dataNode = result.putArray("data");
        List<AnnoyanceSocialCommentBean> annoyanceSocialCommentBeanList =
                annoyanceSocialCommentService.findByAnnoyanceId(id);
        List<DiarySocialCommentBean> diarySocialCommentBeanList =
                diarySocialCommentService.findByDiaryId(id);
        try {
            if (annoyanceSocialCommentBeanList.size()!=0 || diarySocialCommentBeanList.size()!=0) {
                Collections.sort(annoyanceSocialCommentBeanList, new Comparator<AnnoyanceSocialCommentBean>() {
                    @Override
                    public int compare(AnnoyanceSocialCommentBean o1, AnnoyanceSocialCommentBean o2) {
                        return o2.getDate().compareTo(o1.getDate());
                    }
                });
                Collections.sort(diarySocialCommentBeanList, new Comparator<DiarySocialCommentBean>() {
                    @Override
                    public int compare(DiarySocialCommentBean o1, DiarySocialCommentBean o2) {
                        return o2.getDate().compareTo(o1.getDate());
                    }
                });
                switch (type) {
                    case 1:
                        for (AnnoyanceSocialCommentBean annoyanceSocialCommentBean : annoyanceSocialCommentBeanList) {
                            ObjectNode commentNode = dataNode.addObject();
                            Optional<PersonalInfoBean> personalInfo = personalInfoService.getByPK(annoyanceSocialCommentBean.getCommentUser());
                            String nickName = personalInfo.get().getNickName();
                            String photo = personalInfo.get().getPhoto();
                            commentNode.put("id", annoyanceSocialCommentBean.getId());
                            commentNode.put("commentUser", nickName);
                            commentNode.put("photo", photo);
                            commentNode.put("annoyanceId", annoyanceSocialCommentBean.getAnnoyanceId());
                            commentNode.put("commentContent", annoyanceSocialCommentBean.getCommentContent());
                            commentNode.put("date", annoyanceSocialCommentBean.getDate().format(DateTimeFormatter.ofPattern("MM/dd")));
                        }
                        break;
                    case 2:
                        for (DiarySocialCommentBean diarySocialCommentBean : diarySocialCommentBeanList) {
                            ObjectNode commentNode = dataNode.addObject();
                            Optional<PersonalInfoBean> personalInfo = personalInfoService.getByPK(diarySocialCommentBean.getCommentUser());
                            String nickName = personalInfo.get().getNickName();
                            String photo = personalInfo.get().getPhoto();
                            commentNode.put("id", diarySocialCommentBean.getId());
                            commentNode.put("commentUser", nickName);
                            commentNode.put("photo", photo);
                            commentNode.put("diaryId", diarySocialCommentBean.getDiaryId());
                            commentNode.put("commentContent", diarySocialCommentBean.getCommentContent());
                            commentNode.put("date", diarySocialCommentBean.getDate().format(DateTimeFormatter.ofPattern("MM/dd")));
                        }
                        break;
                    default:
                        break;
                }
                result.put("result", true);
                result.put("errorCode", "200");
                result.put("message", "查詢成功");
            } else {
                result.put("result", false);
                result.put("errorCode", "");
                result.put("message", "查詢失敗");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

}
