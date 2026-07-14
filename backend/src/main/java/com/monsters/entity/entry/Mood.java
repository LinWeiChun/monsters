package com.monsters.entity.entry;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "moods")
public class Mood extends BaseEntity {

    @Column(name = "code", nullable = false, length = 50, unique = true)
    private String code;

    @Column(name = "label", nullable = false, length = 80)
    private String label;

    @Column(name = "score", nullable = false, unique = true)
    private int score;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    protected Mood() {
    }

    public Mood(String code, String label, int score, String imageUrl, int displayOrder) {
        this.code = code;
        this.label = label;
        this.score = score;
        this.imageUrl = imageUrl;
        this.displayOrder = displayOrder;
    }

    public String getCode() {
        return code;
    }

    public String getLabel() {
        return label;
    }

    public int getScore() {
        return score;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }
}
