ALTER TABLE session_reauthentication_credentials
  DROP CHECK chk_session_reauthentication_purpose;

ALTER TABLE session_reauthentication_credentials
  ADD CONSTRAINT chk_session_reauthentication_purpose CHECK (
    purpose IN ('SESSION_MANAGEMENT', 'LOGIN_METHOD_LINK')
  );

ALTER TABLE session_security_audits
  DROP CHECK chk_session_security_audits_type;

ALTER TABLE session_security_audits
  ADD CONSTRAINT chk_session_security_audits_type CHECK (
    event_type IN (
      'SESSION_CREATED',
      'SESSION_REFRESH_ROTATED',
      'SESSION_REFRESH_REUSE_DETECTED',
      'SESSION_REAUTHENTICATED',
      'SESSION_REVOKED',
      'LOGIN_METHOD_LINKED'
    )
  );
