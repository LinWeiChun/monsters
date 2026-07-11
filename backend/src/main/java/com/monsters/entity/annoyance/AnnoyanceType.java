package com.monsters.entity.annoyance;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "annoyance_types")
public class AnnoyanceType extends BaseEntity {

    @Column(name = "code", nullable = false, length = 50, unique = true)
    private String code;

    @Column(name = "type_name", nullable = false, length = 80, unique = true)
    private String typeName;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    protected AnnoyanceType() {
    }

    public AnnoyanceType(String code, String typeName, int displayOrder) {
        this.code = code;
        this.typeName = typeName;
        this.displayOrder = displayOrder;
    }

    public String getCode() {
        return code;
    }

    public String getTypeName() {
        return typeName;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }
}
