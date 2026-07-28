USE monsters;

CREATE TABLE IF NOT EXISTS entry_drafts (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  entry_type VARCHAR(20) NOT NULL,
  current_step VARCHAR(30) NOT NULL,
  annoyance_type_id BIGINT NULL,
  record_method VARCHAR(20) NULL,
  content TEXT NULL,
  wants_drawing BOOLEAN NULL,
  score TINYINT NULL,
  is_shared BOOLEAN NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_entry_drafts_user_type (user_id, entry_type),
  KEY idx_entry_drafts_annoyance_type_id (annoyance_type_id),
  KEY idx_entry_drafts_expires_at (expires_at),
  CONSTRAINT fk_entry_drafts_user
    FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_entry_drafts_annoyance_type
    FOREIGN KEY (annoyance_type_id) REFERENCES annoyance_types (id),
  CONSTRAINT chk_entry_drafts_type
    CHECK (entry_type IN ('DIARY', 'ANNOYANCE')),
  CONSTRAINT chk_entry_drafts_step
    CHECK (current_step IN (
      'INTRO', 'CATEGORY', 'RECORD_METHOD', 'CONTENT', 'DRAWING_DECISION',
      'DRAWING', 'SCORE', 'SHARING', 'REVIEW'
    )),
  CONSTRAINT chk_entry_drafts_record_method
    CHECK (record_method IS NULL OR record_method IN ('TEXT', 'IMAGE', 'AUDIO', 'VIDEO')),
  CONSTRAINT chk_entry_drafts_score
    CHECK (score IS NULL OR score BETWEEN 1 AND 5),
  CONSTRAINT chk_entry_drafts_annoyance_type
    CHECK (
      (entry_type = 'DIARY' AND annoyance_type_id IS NULL)
      OR entry_type = 'ANNOYANCE'
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS entry_draft_media (
  id BIGINT NOT NULL AUTO_INCREMENT,
  entry_draft_id BIGINT NOT NULL,
  media_role VARCHAR(20) NOT NULL,
  media_type VARCHAR(30) NOT NULL,
  object_key VARCHAR(500) NOT NULL,
  original_filename VARCHAR(255) NOT NULL,
  content_type VARCHAR(100) NOT NULL,
  file_size_bytes BIGINT NOT NULL,
  duration_seconds DECIMAL(10,3) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_entry_draft_media_role (entry_draft_id, media_role),
  UNIQUE KEY uk_entry_draft_media_object_key (object_key),
  CONSTRAINT fk_entry_draft_media_draft
    FOREIGN KEY (entry_draft_id) REFERENCES entry_drafts (id) ON DELETE CASCADE,
  CONSTRAINT chk_entry_draft_media_role
    CHECK (media_role IN ('CONTENT', 'DRAWING')),
  CONSTRAINT chk_entry_draft_media_type
    CHECK (media_type IN ('image', 'audio', 'video', 'drawing')),
  CONSTRAINT chk_entry_draft_media_size
    CHECK (file_size_bytes > 0),
  CONSTRAINT chk_entry_draft_media_duration
    CHECK (
      (media_type IN ('audio', 'video') AND duration_seconds > 0)
      OR (media_type IN ('image', 'drawing') AND duration_seconds IS NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
