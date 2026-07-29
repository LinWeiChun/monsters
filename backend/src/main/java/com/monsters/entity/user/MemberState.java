package com.monsters.entity.user;

public enum MemberState {
    PENDING_EMAIL_VERIFICATION(1),
    PENDING_ELIGIBILITY(1),
    ACTIVE(0),
    USER_DEACTIVATED(2),
    ADMIN_SUSPENDED(3),
    DELETION_PENDING(4),
    DELETED(5);

    private final int safetyPriority;

    MemberState(int safetyPriority) {
        this.safetyPriority = safetyPriority;
    }

    public boolean dominates(MemberState other) {
        return safetyPriority > other.safetyPriority;
    }

    public boolean isTerminal() {
        return this == DELETED;
    }
}
