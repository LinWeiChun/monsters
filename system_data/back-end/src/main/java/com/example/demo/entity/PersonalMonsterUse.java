package com.example.demo.entity;

import com.example.demo.config.DatabaseConfig;
import lombok.Data;

import javax.persistence.*;

@Data
@Entity
@Table(name = "personal_monster_use", schema = DatabaseConfig.DATA_BASE_NAME)
@IdClass(PersonalMonsterUseId.class)
public class PersonalMonsterUse {
    @Id
    @Column(name = "`account`", nullable = false, length = 45)
    private String account;

    @Id
    @Column(name = "`monster_group`", nullable = false)
    private Integer monsterGroup;

    @Column(name = "`use`", nullable = false)
    private Integer use;
}
