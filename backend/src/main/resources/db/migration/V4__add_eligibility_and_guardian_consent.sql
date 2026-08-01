ALTER TABLE users
  ADD COLUMN service_region VARCHAR(2) NULL AFTER birthday,
  ADD COLUMN eligibility_status VARCHAR(40) NOT NULL DEFAULT 'PENDING_PROFILE' AFTER service_region,
  ADD COLUMN community_eligibility_status VARCHAR(40) NOT NULL DEFAULT 'INELIGIBLE' AFTER eligibility_status,
  ADD COLUMN nickname_disclosure_version VARCHAR(80) NULL AFTER community_eligibility_status,
  ADD COLUMN nickname_disclosure_confirmed_at DATETIME NULL AFTER nickname_disclosure_version;

UPDATE users
SET eligibility_status = 'ELIGIBLE_ADULT'
WHERE member_state = 'ACTIVE';

ALTER TABLE users
  ADD CONSTRAINT chk_users_service_region CHECK (service_region IS NULL OR CHAR_LENGTH(service_region) = 2),
  ADD CONSTRAINT chk_users_eligibility_status CHECK (
    eligibility_status IN (
      'PENDING_PROFILE', 'GUARDIAN_CONSENT_PENDING', 'ELIGIBLE_PRIVATE_ONLY',
      'ELIGIBLE_ADULT', 'INELIGIBLE_UNDERAGE', 'INELIGIBLE_REGION',
      'GUARDIAN_CONSENT_WITHDRAWN'
    )
  ),
  ADD CONSTRAINT chk_users_community_eligibility_status CHECK (
    community_eligibility_status IN ('INELIGIBLE', 'PENDING_NICKNAME_CONFIRMATION', 'ELIGIBLE')
  );

CREATE TABLE guardian_consents (
  id BIGINT NOT NULL AUTO_INCREMENT,
  public_id VARCHAR(36) NOT NULL,
  user_id BIGINT NOT NULL,
  guardian_email VARCHAR(255) NOT NULL,
  document_version VARCHAR(80) NOT NULL,
  status VARCHAR(20) NOT NULL,
  requested_at DATETIME NOT NULL,
  granted_at DATETIME NULL,
  withdrawn_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_guardian_consents_public_id (public_id),
  KEY idx_guardian_consents_user_status (user_id, status),
  CONSTRAINT fk_guardian_consents_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT chk_guardian_consents_status CHECK (status IN ('PENDING', 'GRANTED', 'WITHDRAWN', 'SUPERSEDED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE guardian_consent_tokens (
  id BIGINT NOT NULL AUTO_INCREMENT,
  guardian_consent_id BIGINT NOT NULL,
  purpose VARCHAR(20) NOT NULL,
  token_hash VARCHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  revoked_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_guardian_consent_tokens_hash (token_hash),
  KEY idx_guardian_consent_tokens_active (guardian_consent_id, purpose, used_at, revoked_at, expires_at),
  CONSTRAINT fk_guardian_consent_tokens_consent
    FOREIGN KEY (guardian_consent_id) REFERENCES guardian_consents (id) ON DELETE CASCADE,
  CONSTRAINT chk_guardian_consent_tokens_purpose CHECK (purpose IN ('GRANT', 'WITHDRAW'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
