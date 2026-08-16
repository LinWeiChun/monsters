ALTER TABLE user_sessions
  ADD COLUMN device_type VARCHAR(16) NOT NULL DEFAULT 'UNKNOWN' AFTER session_type,
  ADD COLUMN device_summary VARCHAR(120) NOT NULL DEFAULT 'Unknown device' AFTER device_type,
  ADD CONSTRAINT chk_user_sessions_device_type CHECK (
    device_type IN ('WEB', 'ANDROID', 'IOS', 'UNKNOWN')
  );
