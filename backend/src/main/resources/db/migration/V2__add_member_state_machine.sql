ALTER TABLE users
  ADD COLUMN public_id VARCHAR(36) NULL AFTER id,
  ADD COLUMN member_state VARCHAR(40) NOT NULL DEFAULT 'ACTIVE' AFTER deleted_at,
  ADD COLUMN version BIGINT NOT NULL DEFAULT 0 AFTER member_state;

UPDATE users
SET public_id = LOWER(UUID())
WHERE public_id IS NULL;

ALTER TABLE users
  MODIFY COLUMN public_id VARCHAR(36) NOT NULL,
  ADD CONSTRAINT uk_users_public_id UNIQUE (public_id),
  ADD CONSTRAINT chk_users_member_state CHECK (
    member_state IN (
      'PENDING_EMAIL_VERIFICATION',
      'PENDING_ELIGIBILITY',
      'ACTIVE',
      'USER_DEACTIVATED',
      'ADMIN_SUSPENDED',
      'DELETION_PENDING',
      'DELETED'
    )
  );

CREATE TABLE member_continuation_credentials (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  token_hash VARCHAR(64) NOT NULL,
  next_action VARCHAR(40) NOT NULL,
  issued_for_state VARCHAR(40) NOT NULL,
  issued_for_version BIGINT NOT NULL,
  expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_member_continuation_token_hash (token_hash),
  KEY idx_member_continuation_user_active (user_id, revoked_at, expires_at),
  CONSTRAINT fk_member_continuation_user
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE member_state_audits (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NULL,
  event_id VARCHAR(36) NOT NULL,
  from_state VARCHAR(40) NOT NULL,
  to_state VARCHAR(40) NOT NULL,
  reason_code VARCHAR(80) NOT NULL,
  actor_type VARCHAR(20) NOT NULL,
  occurred_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_member_state_audits_event_id (event_id),
  KEY idx_member_state_audits_user_occurred (user_id, occurred_at),
  CONSTRAINT fk_member_state_audits_user
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE outbox_events (
  id BIGINT NOT NULL AUTO_INCREMENT,
  event_id VARCHAR(36) NOT NULL,
  aggregate_type VARCHAR(80) NOT NULL,
  aggregate_id VARCHAR(36) NOT NULL,
  event_type VARCHAR(100) NOT NULL,
  payload TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  attempts INT NOT NULL DEFAULT 0,
  available_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_outbox_events_event_id (event_id),
  KEY idx_outbox_events_poll (status, available_at, id),
  CONSTRAINT chk_outbox_events_status CHECK (
    status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED')
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
