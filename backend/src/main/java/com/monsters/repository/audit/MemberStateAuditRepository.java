package com.monsters.repository.audit;

import com.monsters.entity.audit.MemberStateAudit;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemberStateAuditRepository extends JpaRepository<MemberStateAudit, Long> {
}
