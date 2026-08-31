ALTER TABLE password_reset_tokens
  MODIFY COLUMN token_hash VARCHAR(64) NOT NULL,
  ADD COLUMN revoked_at DATETIME NULL AFTER used_at,
  DROP INDEX idx_password_reset_tokens_user_used,
  ADD KEY idx_password_reset_tokens_user_active (
    user_id,
    used_at,
    revoked_at,
    expires_at
  );
