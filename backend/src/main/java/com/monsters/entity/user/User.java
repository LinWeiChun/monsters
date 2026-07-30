package com.monsters.entity.user;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "users")
public class User extends BaseEntity {

    @Column(name = "public_id", nullable = false, length = 36, unique = true, updatable = false)
    private String publicId;

    @Column(name = "account", length = 50, unique = true)
    private String account;

    @Column(name = "email", nullable = false, length = 255, unique = true)
    private String email;

    @Column(name = "user_name", length = 80)
    private String userName;

    @Column(name = "birthday")
    private LocalDate birthday;

    @Column(name = "avatar_url", length = 500)
    private String avatarUrl;

    @Column(name = "is_deleted", nullable = false)
    private boolean deleted;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "member_state", nullable = false, length = 40)
    private MemberState memberState;

    @Version
    @Column(name = "version", nullable = false)
    private long version;

    protected User() {
    }

    public User(String account, String email, String userName) {
        this.publicId = UUID.randomUUID().toString();
        this.account = account;
        this.email = email;
        this.userName = userName;
        this.deleted = false;
        this.memberState = MemberState.ACTIVE;
    }

    public static User pendingEmailVerification(String email) {
        User user = new User();
        user.publicId = UUID.randomUUID().toString();
        user.email = email;
        user.deleted = false;
        user.memberState = MemberState.PENDING_EMAIL_VERIFICATION;
        return user;
    }

    public void updateProfile(String userName, LocalDate birthday) {
        this.userName = userName;
        this.birthday = birthday;
    }

    public void updateAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public void completeEligibility() {
        if (memberState != MemberState.PENDING_ELIGIBILITY) {
            throw new IllegalStateException("Member is not pending eligibility");
        }
        memberState = MemberState.ACTIVE;
    }

    public void completeEmailVerification() {
        if (memberState != MemberState.PENDING_EMAIL_VERIFICATION) {
            throw new IllegalStateException("Member is not pending email verification");
        }
        memberState = MemberState.PENDING_ELIGIBILITY;
    }

    public String getAccount() {
        return account;
    }

    public String getPublicId() {
        return publicId;
    }

    public String getEmail() {
        return email;
    }

    public String getUserName() {
        return userName;
    }

    public LocalDate getBirthday() {
        return birthday;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public boolean isDeleted() {
        return deleted;
    }

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }

    public MemberState getMemberState() {
        return memberState;
    }

    public long getVersion() {
        return version;
    }
}
