package com.monsters.repository.audit;

import com.monsters.entity.audit.SessionSecurityAudit;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SessionSecurityAuditRepository extends JpaRepository<SessionSecurityAudit, Long> {
}
