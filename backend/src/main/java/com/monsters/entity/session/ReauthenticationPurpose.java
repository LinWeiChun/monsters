package com.monsters.entity.session;

public enum ReauthenticationPurpose {
    SESSION_MANAGEMENT,
    LOGIN_METHOD_LINK,
    EMAIL_CHANGE,
    BIRTHDAY_CORRECTION;

    public boolean isMemberDataPurpose() {
        return this == EMAIL_CHANGE || this == BIRTHDAY_CORRECTION;
    }
}
