ALTER TABLE users
  MODIFY COLUMN account VARCHAR(50) NULL,
  MODIFY COLUMN user_name VARCHAR(80) NULL;

CREATE TABLE member_document_acceptances (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  document_type VARCHAR(30) NOT NULL,
  document_version VARCHAR(80) NOT NULL,
  accepted_at DATETIME NOT NULL,
  revoked_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_member_document_acceptance (user_id, document_type, document_version),
  KEY idx_member_document_acceptances_user (user_id, document_type, revoked_at),
  CONSTRAINT fk_member_document_acceptances_user
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT chk_member_document_acceptances_type CHECK (
    document_type IN ('TERMS', 'PRIVACY', 'COMMUNITY_RULES', 'MINOR_NOTICE')
  )
);

CREATE TABLE email_verification_tokens (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  token_hash VARCHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  revoked_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_email_verification_token_hash (token_hash),
  KEY idx_email_verification_tokens_user_active (user_id, used_at, revoked_at, expires_at),
  CONSTRAINT fk_email_verification_tokens_user
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE registration_rate_limit_buckets (
  id BIGINT NOT NULL AUTO_INCREMENT,
  bucket_scope VARCHAR(20) NOT NULL,
  key_hash VARCHAR(64) NOT NULL,
  window_started_at DATETIME NOT NULL,
  attempts INT NOT NULL DEFAULT 0,
  last_attempt_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_registration_rate_limit_bucket (bucket_scope, key_hash),
  CONSTRAINT chk_registration_rate_limit_scope CHECK (
    bucket_scope IN ('EMAIL', 'IP')
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
