package com.example.demo.entity;

import lombok.Data;

import javax.persistence.*;


@Entity
@Data
@Table(name = "all_monster")
public class AllMonster {
    @Id
    @Column(name = "id", nullable = false)
    private Integer id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "rerity", nullable = false)
    private Integer rerity;

    @Column(name = "gif", nullable = false)
    private String gif;
}
