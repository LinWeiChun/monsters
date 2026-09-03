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
import com.monsters.service.eligibility.EligibilityAgeBand;

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

    @Column(name = "service_region", length = 2)
    private String serviceRegion;

    @Enumerated(EnumType.STRING)
    @Column(name = "eligibility_status", nullable = false, length = 40)
    private EligibilityStatus eligibilityStatus = EligibilityStatus.PENDING_PROFILE;

    @Enumerated(EnumType.STRING)
    @Column(name = "community_eligibility_status", nullable = false, length = 40)
    private CommunityEligibilityStatus communityEligibilityStatus = CommunityEligibilityStatus.INELIGIBLE;

    @Column(name = "nickname_disclosure_version", length = 80)
    private String nicknameDisclosureVersion;

    @Column(name = "nickname_disclosure_confirmed_at")
    private LocalDateTime nicknameDisclosureConfirmedAt;

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
        user.eligibilityStatus = EligibilityStatus.PENDING_PROFILE;
        user.communityEligibilityStatus = CommunityEligibilityStatus.INELIGIBLE;
        return user;
    }

    public static User pendingEligibilityFromVerifiedEmail(String email) {
        User user = new User();
        user.publicId = UUID.randomUUID().toString();
        user.email = email;
        user.deleted = false;
        user.memberState = MemberState.PENDING_ELIGIBILITY;
        user.eligibilityStatus = EligibilityStatus.PENDING_PROFILE;
        user.communityEligibilityStatus = CommunityEligibilityStatus.INELIGIBLE;
        return user;
    }

    public void updateProfile(String userName, LocalDate birthday) {
        this.userName = userName;
        this.birthday = birthday;
    }

    public void updatePublicNickname(String publicNickname) {
        this.userName = publicNickname;
    }

    public void changeEmail(String email) {
        this.email = email;
    }

    public void correctBirthday(LocalDate correctedBirthday) {
        this.birthday = correctedBirthday;
    }

    public void restrictForBirthdayCorrection(EligibilityAgeBand requestedAgeBand) {
        if (requestedAgeBand == EligibilityAgeBand.ADULT) {
            return;
        }
        this.communityEligibilityStatus = CommunityEligibilityStatus.INELIGIBLE;
        this.eligibilityStatus = requestedAgeBand == EligibilityAgeBand.UNDERAGE
                ? EligibilityStatus.INELIGIBLE_UNDERAGE
                : EligibilityStatus.GUARDIAN_CONSENT_PENDING;
        this.memberState = MemberState.PENDING_ELIGIBILITY;
    }

    public void deactivate() {
        if (memberState != MemberState.ACTIVE) {
            throw new IllegalStateException("Only an active member can self-deactivate");
        }
        memberState = MemberState.USER_DEACTIVATED;
        communityEligibilityStatus = CommunityEligibilityStatus.INELIGIBLE;
    }

    public void reactivate() {
        if (memberState != MemberState.USER_DEACTIVATED) {
            throw new IllegalStateException("Only a self-deactivated member can be restored");
        }
        memberState = MemberState.ACTIVE;
        communityEligibilityStatus = eligibilityStatus == EligibilityStatus.ELIGIBLE_ADULT
                && nicknameDisclosureConfirmedAt != null
                ? CommunityEligibilityStatus.ELIGIBLE
                : CommunityEligibilityStatus.INELIGIBLE;
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

    public void restrictEligibility(String region, LocalDate birthday, EligibilityStatus status) {
        this.serviceRegion = region;
        this.birthday = birthday;
        this.userName = null;
        this.eligibilityStatus = status;
        this.communityEligibilityStatus = CommunityEligibilityStatus.INELIGIBLE;
        this.nicknameDisclosureVersion = null;
        this.nicknameDisclosureConfirmedAt = null;
    }

    public void awaitGuardianConsent(String region, LocalDate birthday, String nickname) {
        this.serviceRegion = region; this.birthday = birthday; this.userName = nickname;
        this.eligibilityStatus = EligibilityStatus.GUARDIAN_CONSENT_PENDING;
        this.communityEligibilityStatus = CommunityEligibilityStatus.INELIGIBLE;
    }

    public void grantMinorEligibility() {
        this.eligibilityStatus = EligibilityStatus.ELIGIBLE_PRIVATE_ONLY;
        this.communityEligibilityStatus = CommunityEligibilityStatus.INELIGIBLE;
        completeEligibility();
    }

    public void grantAdultEligibility(String region, LocalDate birthday, String nickname,
            boolean disclosureConfirmed, String disclosureVersion, LocalDateTime now) {
        this.serviceRegion = region; this.birthday = birthday; this.userName = nickname;
        this.eligibilityStatus = EligibilityStatus.ELIGIBLE_ADULT;
        this.communityEligibilityStatus = disclosureConfirmed
                ? CommunityEligibilityStatus.ELIGIBLE
                : CommunityEligibilityStatus.PENDING_NICKNAME_CONFIRMATION;
        this.nicknameDisclosureVersion = disclosureConfirmed ? disclosureVersion : null;
        this.nicknameDisclosureConfirmedAt = disclosureConfirmed ? now : null;
        completeEligibility();
    }

    public void withdrawGuardianEligibility() {
        this.eligibilityStatus = EligibilityStatus.GUARDIAN_CONSENT_WITHDRAWN;
        this.communityEligibilityStatus = CommunityEligibilityStatus.INELIGIBLE;
        this.memberState = MemberState.PENDING_ELIGIBILITY;
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

    public String getServiceRegion() { return serviceRegion; }
    public EligibilityStatus getEligibilityStatus() { return eligibilityStatus; }
    public CommunityEligibilityStatus getCommunityEligibilityStatus() { return communityEligibilityStatus; }
    public String getNicknameDisclosureVersion() { return nicknameDisclosureVersion; }
    public LocalDateTime getNicknameDisclosureConfirmedAt() { return nicknameDisclosureConfirmedAt; }

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
