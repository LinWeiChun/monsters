package com.monsters.entity.user;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class MemberStateTest {

    @Test
    void safetyPriorityShouldDominateLowerRiskMemberStates() {
        assertThat(MemberState.DELETED.dominates(MemberState.DELETION_PENDING)).isTrue();
        assertThat(MemberState.DELETION_PENDING.dominates(MemberState.ADMIN_SUSPENDED)).isTrue();
        assertThat(MemberState.ADMIN_SUSPENDED.dominates(MemberState.USER_DEACTIVATED)).isTrue();
        assertThat(MemberState.USER_DEACTIVATED.dominates(MemberState.PENDING_ELIGIBILITY)).isTrue();
        assertThat(MemberState.PENDING_EMAIL_VERIFICATION.dominates(MemberState.ACTIVE)).isTrue();
        assertThat(MemberState.PENDING_ELIGIBILITY.dominates(MemberState.PENDING_EMAIL_VERIFICATION)).isFalse();
        assertThat(MemberState.ACTIVE.dominates(MemberState.DELETED)).isFalse();
    }

    @Test
    void deletedShouldBeTerminal() {
        assertThat(MemberState.DELETED.isTerminal()).isTrue();
        assertThat(MemberState.DELETION_PENDING.isTerminal()).isFalse();
    }
}
