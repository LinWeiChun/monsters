CREATE TABLE user_sessions (
  id BIGINT NOT NULL AUTO_INCREMENT,
  public_id VARCHAR(36) NOT NULL,
  user_id BIGINT NOT NULL,
  session_type VARCHAR(20) NOT NULL DEFAULT 'MEMBER',
  last_activity_at DATETIME NOT NULL,
  idle_expires_at DATETIME NOT NULL,
  absolute_expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL,
  revocation_reason VARCHAR(80) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_sessions_public_id (public_id),
  KEY idx_user_sessions_user_active (user_id, revoked_at, absolute_expires_at),
  CONSTRAINT fk_user_sessions_user
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT chk_user_sessions_type CHECK (session_type IN ('MEMBER'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE refresh_session_credentials (
  id BIGINT NOT NULL AUTO_INCREMENT,
  session_id BIGINT NOT NULL,
  token_hash VARCHAR(64) NOT NULL,
  sequence_number BIGINT NOT NULL,
  issued_at DATETIME NOT NULL,
  rotated_at DATETIME NULL,
  grace_expires_at DATETIME NULL,
  reuse_detected_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_refresh_session_credentials_hash (token_hash),
  UNIQUE KEY uk_refresh_session_credentials_sequence (session_id, sequence_number),
  CONSTRAINT fk_refresh_session_credentials_session
    FOREIGN KEY (session_id) REFERENCES user_sessions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE session_security_audits (
  id BIGINT NOT NULL AUTO_INCREMENT,
  session_id BIGINT NOT NULL,
  event_id VARCHAR(36) NOT NULL,
  event_type VARCHAR(80) NOT NULL,
  occurred_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_session_security_audits_event_id (event_id),
  KEY idx_session_security_audits_session_occurred (session_id, occurred_at),
  CONSTRAINT fk_session_security_audits_session
    FOREIGN KEY (session_id) REFERENCES user_sessions (id) ON DELETE CASCADE,
  CONSTRAINT chk_session_security_audits_type CHECK (
    event_type IN ('SESSION_CREATED', 'SESSION_REFRESH_ROTATED', 'SESSION_REFRESH_REUSE_DETECTED')
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
