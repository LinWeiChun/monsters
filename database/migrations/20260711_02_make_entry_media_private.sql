USE monsters;

-- This project does not automatically migrate legacy public media URLs. The migration
-- intentionally stops when entry_media already contains rows; export and migrate those
-- rows to private R2 object keys through a separately reviewed data migration first.
DROP PROCEDURE IF EXISTS assert_entry_media_empty_for_private_migration;

DELIMITER //
CREATE PROCEDURE assert_entry_media_empty_for_private_migration()
BEGIN
  IF EXISTS (SELECT 1 FROM entry_media LIMIT 1) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'entry_media must be empty before private R2 migration';
  END IF;
END//
DELIMITER ;

CALL assert_entry_media_empty_for_private_migration();
DROP PROCEDURE assert_entry_media_empty_for_private_migration;

ALTER TABLE entry_media
  CHANGE COLUMN media_url object_key VARCHAR(500) NOT NULL,
  ADD COLUMN content_type VARCHAR(100) NOT NULL AFTER object_key,
  ADD COLUMN file_size_bytes BIGINT NOT NULL AFTER content_type,
  ADD COLUMN duration_seconds DECIMAL(10,3) NULL AFTER file_size_bytes,
  ADD UNIQUE KEY uk_entry_media_object_key (object_key),
  DROP CHECK chk_entry_media_type,
  ADD CONSTRAINT chk_entry_media_type
    CHECK (media_type IN ('image', 'audio', 'video', 'drawing')),
  ADD CONSTRAINT chk_entry_media_size
    CHECK (file_size_bytes > 0),
  ADD CONSTRAINT chk_entry_media_duration
    CHECK (
      (media_type IN ('audio', 'video') AND duration_seconds > 0)
      OR (media_type IN ('image', 'drawing') AND duration_seconds IS NULL)
    );
