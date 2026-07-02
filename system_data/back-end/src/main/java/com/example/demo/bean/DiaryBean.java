package com.example.demo.bean;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class DiaryBean extends BaseBean {
    private Integer id;
    private String account;
    private String content;
    private String imageContent;
    private String audioContent;
    private int monsterId;
    private String mood;
    private Integer index;
    private LocalDateTime time = LocalDateTime.now();
    private Integer share;
}
