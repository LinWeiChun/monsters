package com.example.demo.entity;

import lombok.Data;

import javax.persistence.*;
import java.time.LocalDateTime;


@Data
@Entity
@Table(name = "`annoyance`")
public class Annoyance {
    @Id
    @Column(name = "`id`", nullable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "`account`", nullable = false, length = 45)
    private String account;

    @Column(name = "`content`")
    private String content;

    @Column(name = "`image_content`")
    private String imageContent;

    @Column(name = "`audio_content`")
    private String audioContent;

    @Column(name = "`type`", nullable = false)
    private Integer type;

    @Column(name = "`monster_id`")
    private Integer monsterId;

    @Column(name = "`mood`", nullable = false)
    private String mood;

    @Column(name = "`index`")
    private int index;

    @Column(name = "`time`")
    private LocalDateTime time;

    @Column(name = "`solve`")
    private Integer solve;

    @Column(name = "`share`")
    private Integer share;
}
