package com.example.demo.bean;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class DiarySocialCommentBean extends BaseBean {
    private Integer id;
    private String commentUser;
    private Integer diaryId;
    private String commentContent;
    private LocalDateTime date = LocalDateTime.now();
}
