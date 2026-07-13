USE monsters;

-- This project does not automatically migrate legacy public media URLs. The migration
-- intentionally stops only when the legacy media_url column still exists and entry_media
-- already contains rows; export and migrate those rows to private R2 object keys through
-- a separately reviewed data migration first.
DROP PROCEDURE IF EXISTS ensure_entry_media_private_schema;

DELIMITER //
CREATE PROCEDURE ensure_entry_media_private_schema()
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'entry_media'
      AND column_name = 'media_url'
  ) THEN
    IF EXISTS (SELECT 1 FROM entry_media LIMIT 1) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'entry_media must be empty before private R2 migration';
    END IF;

    ALTER TABLE entry_media
      CHANGE COLUMN media_url object_key VARCHAR(500) NOT NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'entry_media'
      AND column_name = 'object_key'
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'entry_media.object_key is missing; review schema before migration';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'entry_media'
      AND column_name = 'content_type'
  ) THEN
    ALTER TABLE entry_media
      ADD COLUMN content_type VARCHAR(100) NOT NULL AFTER object_key;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'entry_media'
      AND column_name = 'file_size_bytes'
  ) THEN
    ALTER TABLE entry_media
      ADD COLUMN file_size_bytes BIGINT NOT NULL AFTER content_type;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'entry_media'
      AND column_name = 'duration_seconds'
  ) THEN
    ALTER TABLE entry_media
      ADD COLUMN duration_seconds DECIMAL(10,3) NULL AFTER file_size_bytes;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'entry_media'
      AND index_name = 'uk_entry_media_object_key'
  ) THEN
    ALTER TABLE entry_media
      ADD UNIQUE KEY uk_entry_media_object_key (object_key);
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.check_constraints
    WHERE constraint_schema = DATABASE()
      AND constraint_name = 'chk_entry_media_type'
  ) THEN
    ALTER TABLE entry_media
      DROP CHECK chk_entry_media_type;
  END IF;

  ALTER TABLE entry_media
    ADD CONSTRAINT chk_entry_media_type
      CHECK (media_type IN ('image', 'audio', 'video', 'drawing'));

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.check_constraints
    WHERE constraint_schema = DATABASE()
      AND constraint_name = 'chk_entry_media_size'
  ) THEN
    ALTER TABLE entry_media
      ADD CONSTRAINT chk_entry_media_size
        CHECK (file_size_bytes > 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.check_constraints
    WHERE constraint_schema = DATABASE()
      AND constraint_name = 'chk_entry_media_duration'
  ) THEN
    ALTER TABLE entry_media
      ADD CONSTRAINT chk_entry_media_duration
        CHECK (
          (media_type IN ('audio', 'video') AND duration_seconds > 0)
          OR (media_type IN ('image', 'drawing') AND duration_seconds IS NULL)
        );
  END IF;
END//
DELIMITER ;

CALL ensure_entry_media_private_schema();
DROP PROCEDURE IF EXISTS ensure_entry_media_private_schema;
