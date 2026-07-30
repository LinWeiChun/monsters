package com.monsters.entity.user;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "member_document_acceptances")
public class MemberDocumentAcceptance extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "document_type", nullable = false, length = 30)
    private MemberDocumentType documentType;

    @Column(name = "document_version", nullable = false, length = 80)
    private String documentVersion;

    @Column(name = "accepted_at", nullable = false)
    private LocalDateTime acceptedAt;

    @Column(name = "revoked_at")
    private LocalDateTime revokedAt;

    protected MemberDocumentAcceptance() {
    }

    public MemberDocumentAcceptance(
            User user,
            MemberDocumentType documentType,
            String documentVersion,
            LocalDateTime acceptedAt
    ) {
        this.user = user;
        this.documentType = documentType;
        this.documentVersion = documentVersion;
        this.acceptedAt = acceptedAt;
    }
}
