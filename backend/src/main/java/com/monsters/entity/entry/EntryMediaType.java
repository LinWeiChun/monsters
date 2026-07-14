package com.monsters.entity.entry;

import java.util.Arrays;

public enum EntryMediaType {
    IMAGE("image"),
    AUDIO("audio"),
    VIDEO("video"),
    DRAWING("drawing");

    private final String databaseValue;

    EntryMediaType(String databaseValue) {
        this.databaseValue = databaseValue;
    }

    public String databaseValue() {
        return databaseValue;
    }

    public static EntryMediaType fromDatabaseValue(String value) {
        return Arrays.stream(values())
                .filter(type -> type.databaseValue.equals(value))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Unsupported entry media type"));
    }
}
