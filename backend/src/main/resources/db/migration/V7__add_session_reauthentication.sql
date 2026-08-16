CREATE TABLE session_reauthentication_credentials (
  id BIGINT NOT NULL AUTO_INCREMENT,
  session_id BIGINT NOT NULL,
  token_hash VARCHAR(64) NOT NULL,
  purpose VARCHAR(40) NOT NULL,
  issued_at DATETIME NOT NULL,
  expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_session_reauthentication_credentials_hash (token_hash),
  KEY idx_session_reauthentication_session_expiry (session_id, expires_at),
  CONSTRAINT fk_session_reauthentication_session
    FOREIGN KEY (session_id) REFERENCES user_sessions (id) ON DELETE CASCADE,
  CONSTRAINT chk_session_reauthentication_purpose CHECK (
    purpose IN ('SESSION_MANAGEMENT')
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE session_security_audits
  DROP CHECK chk_session_security_audits_type;

ALTER TABLE session_security_audits
  ADD CONSTRAINT chk_session_security_audits_type CHECK (
    event_type IN (
      'SESSION_CREATED',
      'SESSION_REFRESH_ROTATED',
      'SESSION_REFRESH_REUSE_DETECTED',
      'SESSION_REAUTHENTICATED',
      'SESSION_REVOKED'
    )
  );
