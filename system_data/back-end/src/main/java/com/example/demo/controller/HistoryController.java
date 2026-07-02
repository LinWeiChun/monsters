package com.example.demo.controller;

import com.example.demo.bean.AnnoyanceBean;
import com.example.demo.bean.DiaryBean;
import com.example.demo.service.impl.AnnoyanceServiceImpl;
import com.example.demo.service.impl.DiaryServiceImpl;
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

@AllArgsConstructor
@Controller
@RequestMapping(value = "/history")
public class HistoryController {
    private final AnnoyanceServiceImpl annoyanceService;
    private final DiaryServiceImpl diaryService;

    @ResponseBody
    @GetMapping(path = "/{account}/{type}", produces = "application/json; charset=UTF-8")
    public ResponseEntity SearchAllByAccount(@PathVariable(name = "account") String account,
                                             @PathVariable(name = "type") Integer type) {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        ArrayNode dataNode = result.putArray("data");
        try {
            List<AnnoyanceBean> annoyanceList = annoyanceService.searchAnnoyanceByAccount(account);
            List<DiaryBean> diaryList = diaryService.searchAnnoyanceByAccount(account);
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
                            annoyanceNode.put("id", annoyanceBean.getId());
                            annoyanceNode.put("content", annoyanceBean.getContent());
                            annoyanceNode.put("imageContent", annoyanceBean.getImageContent());
                            annoyanceNode.put("audioContent", annoyanceBean.getAudioContent());
                            annoyanceNode.put("type", annoyanceBean.getType());
                            annoyanceNode.put("monsterId", annoyanceBean.getMonsterId()/4);
                            annoyanceNode.put("mood", annoyanceBean.getMood());
                            annoyanceNode.put("index", annoyanceBean.getIndex());
                            annoyanceNode.put("time", annoyanceBean.getTime().format(DateTimeFormatter.ofPattern("MM/dd")));
                            annoyanceNode.put("solve", annoyanceBean.getSolve());
                            annoyanceNode.put("share", annoyanceBean.getShare());
                        }
                        break;
                    case 2:
                        for (DiaryBean diaryBean : diaryList) {
                            ObjectNode diaryNode = dataNode.addObject();
                            diaryNode.put("id", diaryBean.getId());
                            diaryNode.put("content", diaryBean.getContent());
                            diaryNode.put("imageContent", diaryBean.getImageContent());
                            diaryNode.put("audioContent", diaryBean.getAudioContent());
                            diaryNode.put("monsterId", diaryBean.getMonsterId()/4);
                            diaryNode.put("mood", diaryBean.getMood());
                            diaryNode.put("index", diaryBean.getIndex());
                            diaryNode.put("time", diaryBean.getTime().format(DateTimeFormatter.ofPattern("MM/dd")));
                            diaryNode.put("share", diaryBean.getShare());
                        }
                        break;
                    case 3:
                        for (AnnoyanceBean annoyanceBean : annoyanceList) {
                            ObjectNode annoyanceNode = dataNode.addObject();
                            annoyanceNode.put("id", annoyanceBean.getId());
                            annoyanceNode.put("content", annoyanceBean.getContent());
                            annoyanceNode.put("imageContent", annoyanceBean.getImageContent());
                            annoyanceNode.put("audioContent", annoyanceBean.getAudioContent());
                            annoyanceNode.put("type", annoyanceBean.getType());
                            annoyanceNode.put("monsterId", annoyanceBean.getMonsterId()/4);
                            annoyanceNode.put("mood", annoyanceBean.getMood());
                            annoyanceNode.put("index", annoyanceBean.getIndex());
                            annoyanceNode.put("time", annoyanceBean.getTime().format(DateTimeFormatter.ofPattern("MM/dd")));
                            annoyanceNode.put("solve", annoyanceBean.getSolve());
                            annoyanceNode.put("share", annoyanceBean.getShare());
                        }
                        for (DiaryBean diaryBean : diaryList) {
                            ObjectNode diaryNode = dataNode.addObject();
                            diaryNode.put("id", diaryBean.getId());
                            diaryNode.put("content", diaryBean.getContent());
                            diaryNode.put("imageContent", diaryBean.getImageContent());
                            diaryNode.put("audioContent", diaryBean.getAudioContent());
                            diaryNode.put("mood", diaryBean.getMood());
                            diaryNode.put("monsterId", diaryBean.getMonsterId()/4);
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
    @GetMapping(path = "/annoyance/{solve}/{account}", produces = "application/json; charset=UTF-8")
    public ResponseEntity SearchAnnoyanceSolveByAccount(@PathVariable(name = "solve") int solve,
                                                        @PathVariable(name = "account") String account) {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        ArrayNode dataNode = result.putArray("data");
        try {
            List<AnnoyanceBean> annoyanceList = annoyanceService.searchAnnoyanceIsSolveByAccount(solve, account);
            if (annoyanceList.size() != 0) {
                Collections.sort(annoyanceList, new Comparator<AnnoyanceBean>() {
                    @Override
                    public int compare(AnnoyanceBean o1, AnnoyanceBean o2) {
                        return o2.getTime().compareTo(o1.getTime());
                    }
                });
                for (AnnoyanceBean annoyanceBean : annoyanceList) {
                    ObjectNode annoyanceNode = dataNode.addObject();
                    annoyanceNode.put("id", annoyanceBean.getId());
                    annoyanceNode.put("content", annoyanceBean.getContent());
                    annoyanceNode.put("type", annoyanceBean.getType());
                    annoyanceNode.put("monsterId", annoyanceBean.getMonsterId() / 4);
                    annoyanceNode.put("mood", annoyanceBean.getMood());
                    annoyanceNode.put("index", annoyanceBean.getIndex());
                    annoyanceNode.put("time", annoyanceBean.getTime().format(DateTimeFormatter.ofPattern("MM/dd")));
                    annoyanceNode.put("solve", annoyanceBean.getSolve());
                    annoyanceNode.put("share", annoyanceBean.getShare());
                    annoyanceNode.put("imageContent", annoyanceBean.getImageContent());
                    annoyanceNode.put("audioContent", annoyanceBean.getAudioContent());
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
    @GetMapping(path = "/index/{account}/{type}")
    public ResponseEntity searchIndex(@PathVariable(name = "account") String account,
                                      @PathVariable(name = "type") Integer type) {
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode result = mapper.createObjectNode();
        ArrayNode dataNode = result.putArray("data");
        try {
            List<AnnoyanceBean> annoyanceList = annoyanceService.searchAnnoyanceByAccount(account);
            List<DiaryBean> diaryList = diaryService.searchAnnoyanceByAccount(account);
            switch (type) {
                case 1:
                    if (annoyanceList.size() != 0) {
                        Collections.sort(annoyanceList, new Comparator<AnnoyanceBean>() {
                            @Override
                            public int compare(AnnoyanceBean o1, AnnoyanceBean o2) {
                                return o2.getTime().compareTo(o1.getTime());
                            }
                        });
                        if (annoyanceList.size() >= 7) {
                            for (int i = 0; i < 7; i++) {
                                ObjectNode annoyanceNode = dataNode.addObject();
                                annoyanceNode.put("index", annoyanceList.get(i).getIndex());
                                annoyanceNode.put("time", annoyanceList.get(i).getTime().format(DateTimeFormatter.ofPattern("MM/dd hh:mm")));
                            }
                        } else {
                            for (int i = 0; i < annoyanceList.size(); i++) {
                                ObjectNode annoyanceNode = dataNode.addObject();
                                annoyanceNode.put("index", annoyanceList.get(i).getIndex());
                                annoyanceNode.put("time", annoyanceList.get(i).getTime().format(DateTimeFormatter.ofPattern("MM/dd hh:mm")));
                            }
                        }
                        result.put("result", true);
                        result.put("errorCode", "200");
                        result.put("message", "查詢成功");
                    } else {
                        result.put("result", false);
                        result.put("errorCode", "");
                        result.put("message", "查詢失敗");
                    }
                case 2:
                    if (diaryList.size() != 0) {
                        Collections.sort(diaryList, new Comparator<DiaryBean>() {
                            @Override
                            public int compare(DiaryBean o1, DiaryBean o2) {
                                return o2.getTime().compareTo(o1.getTime());
                            }
                        });
                        if (diaryList.size() >= 7) {
                            for (int i = 0; i < 7; i++) {
                                ObjectNode annoyanceNode = dataNode.addObject();
                                annoyanceNode.put("index", diaryList.get(i).getIndex());
                                annoyanceNode.put("time", diaryList.get(i).getTime().format(DateTimeFormatter.ofPattern("MM/dd hh:mm")));
                            }
                        } else {
                            for (int i = 0; i < diaryList.size(); i++) {
                                ObjectNode annoyanceNode = dataNode.addObject();
                                annoyanceNode.put("index", diaryList.get(i).getIndex());
                                annoyanceNode.put("time", diaryList.get(i).getTime().format(DateTimeFormatter.ofPattern("MM/dd hh:mm")));
                            }
                        }
                        result.put("result", true);
                        result.put("errorCode", "200");
                        result.put("message", "查詢成功");
                    } else {
                        result.put("result", false);
                        result.put("errorCode", "");
                        result.put("message", "查詢失敗");
                    }
                case 3:
                    break;
                default:
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }
}
