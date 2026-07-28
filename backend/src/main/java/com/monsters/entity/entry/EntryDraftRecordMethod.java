package com.monsters.entity.entry;

public enum EntryDraftRecordMethod {
    TEXT,
    IMAGE,
    AUDIO,
    VIDEO;

    public EntryMediaType mediaType() {
        return switch (this) {
            case IMAGE -> EntryMediaType.IMAGE;
            case AUDIO -> EntryMediaType.AUDIO;
            case VIDEO -> EntryMediaType.VIDEO;
            case TEXT -> throw new IllegalStateException("TEXT does not use content media");
        };
    }
}
