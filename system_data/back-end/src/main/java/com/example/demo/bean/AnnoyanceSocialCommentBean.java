package com.example.demo.bean;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AnnoyanceSocialCommentBean extends BaseBean{
    private Integer id;
    private String commentUser;
    private Integer annoyanceId;
    private String commentContent;
    private LocalDateTime date = LocalDateTime.now();
}
