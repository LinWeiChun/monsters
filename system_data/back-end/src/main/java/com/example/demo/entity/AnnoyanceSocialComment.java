package com.example.demo.entity;

import com.example.demo.config.DatabaseConfig;
import lombok.Data;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "annoyance_social_comment", schema = DatabaseConfig.DATA_BASE_NAME)
public class AnnoyanceSocialComment {

    @Id
    @Column(name = "`id`", nullable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "`comment_user`", nullable = false)
    private String commentUser;

    @Column(name = "`annoyance_social_id`", nullable = false)
    private Integer annoyanceId;

    @Column(name = "`content`", nullable = false)
    private String content;

    @Column(name = "`date`", nullable = false)
    private LocalDateTime date;
}