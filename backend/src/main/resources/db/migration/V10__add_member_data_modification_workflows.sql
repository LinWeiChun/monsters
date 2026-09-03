ALTER TABLE session_reauthentication_credentials
  DROP CHECK chk_session_reauthentication_purpose;

ALTER TABLE session_reauthentication_credentials
  ADD CONSTRAINT chk_session_reauthentication_purpose CHECK (
    purpose IN (
      'SESSION_MANAGEMENT',
      'LOGIN_METHOD_LINK',
      'EMAIL_CHANGE',
      'BIRTHDAY_CORRECTION'
    )
  );

CREATE TABLE member_email_change_requests (
  id BIGINT NOT NULL AUTO_INCREMENT,
  public_id VARCHAR(36) NOT NULL,
  user_id BIGINT NOT NULL,
  initiating_session_id BIGINT NOT NULL,
  original_email VARCHAR(255) NOT NULL,
  new_email VARCHAR(255) NOT NULL,
  requested_for_version BIGINT NOT NULL,
  token_hash VARCHAR(64) NULL,
  expires_at DATETIME NULL,
  status VARCHAR(30) NOT NULL,
  verified_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_member_email_change_public_id (public_id),
  UNIQUE KEY uk_member_email_change_token_hash (token_hash),
  KEY idx_member_email_change_user_status (user_id, status, id),
  CONSTRAINT fk_member_email_change_user
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_member_email_change_session
    FOREIGN KEY (initiating_session_id) REFERENCES user_sessions (id) ON DELETE CASCADE,
  CONSTRAINT chk_member_email_change_status CHECK (
    status IN (
      'PENDING_DELIVERY',
      'PENDING_VERIFICATION',
      'COMPLETED',
      'SUPERSEDED',
      'EXPIRED'
    )
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE birthday_correction_requests (
  id BIGINT NOT NULL AUTO_INCREMENT,
  public_id VARCHAR(36) NOT NULL,
  user_id BIGINT NOT NULL,
  current_birthday DATE NOT NULL,
  requested_birthday DATE NOT NULL,
  reason_code VARCHAR(40) NOT NULL,
  requested_for_version BIGINT NOT NULL,
  from_age_band VARCHAR(20) NOT NULL,
  to_age_band VARCHAR(20) NOT NULL,
  status VARCHAR(30) NOT NULL,
  restricted_at DATETIME NULL,
  decided_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_birthday_correction_public_id (public_id),
  KEY idx_birthday_correction_user_status (user_id, status, id),
  CONSTRAINT fk_birthday_correction_user
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT chk_birthday_correction_reason CHECK (
    reason_code IN ('DATA_ENTRY_ERROR', 'LEGAL_RECORD_CORRECTION', 'OTHER')
  ),
  CONSTRAINT chk_birthday_correction_age_bands CHECK (
    from_age_band IN ('UNDERAGE', 'MINOR', 'ADULT')
    AND to_age_band IN ('UNDERAGE', 'MINOR', 'ADULT')
  ),
  CONSTRAINT chk_birthday_correction_status CHECK (
    status IN ('AUTO_APPROVED', 'PENDING_REVIEW', 'APPROVED', 'REJECTED', 'APPEALED')
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
