package com.monsters.entity.user;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "user_password_locks")
public class UserPasswordLock extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "lock_password_hash", nullable = false, length = 255)
    private String lockPasswordHash;

    @Column(name = "enabled", nullable = false)
    private boolean enabled;

    protected UserPasswordLock() {
    }

    public UserPasswordLock(User user, String lockPasswordHash) {
        this.user = user;
        this.lockPasswordHash = lockPasswordHash;
        this.enabled = true;
    }

    public User getUser() {
        return user;
    }

    public String getLockPasswordHash() {
        return lockPasswordHash;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public void updateLockPasswordHash(String lockPasswordHash) {
        this.lockPasswordHash = lockPasswordHash;
        this.enabled = true;
    }
}
