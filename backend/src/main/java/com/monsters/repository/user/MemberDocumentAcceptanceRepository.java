package com.monsters.repository.user;

import com.monsters.entity.user.MemberDocumentAcceptance;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemberDocumentAcceptanceRepository
        extends JpaRepository<MemberDocumentAcceptance, Long> {
}
