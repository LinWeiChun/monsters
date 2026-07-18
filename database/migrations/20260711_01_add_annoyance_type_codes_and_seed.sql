USE monsters;

DROP PROCEDURE IF EXISTS ensure_annoyance_type_code_column;
DELIMITER $$
CREATE PROCEDURE ensure_annoyance_type_code_column()
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'annoyance_types'
      AND column_name = 'code'
  ) THEN
    ALTER TABLE annoyance_types
      ADD COLUMN code VARCHAR(50) NULL AFTER id;
  END IF;
END$$
DELIMITER ;
CALL ensure_annoyance_type_code_column();
DROP PROCEDURE IF EXISTS ensure_annoyance_type_code_column;

UPDATE annoyance_types SET code = 'ACADEMIC' WHERE type_name = '課業' AND code IS NULL;
UPDATE annoyance_types SET code = 'CAREER' WHERE type_name = '事業' AND code IS NULL;
UPDATE annoyance_types SET code = 'LOVE' WHERE type_name = '愛情' AND code IS NULL;
UPDATE annoyance_types SET code = 'FRIENDSHIP' WHERE type_name = '友情' AND code IS NULL;
UPDATE annoyance_types SET code = 'FAMILY' WHERE type_name = '親情' AND code IS NULL;
UPDATE annoyance_types SET code = 'OTHER' WHERE type_name = '其他' AND code IS NULL;

INSERT INTO annoyance_types (
  code,
  type_name,
  display_order,
  created_at,
  updated_at
)
VALUES
  ('ACADEMIC', '課業', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('CAREER', '事業', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('LOVE', '愛情', 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('FRIENDSHIP', '友情', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('FAMILY', '親情', 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('OTHER', '其他', 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE
  code = VALUES(code),
  type_name = VALUES(type_name),
  display_order = VALUES(display_order);

ALTER TABLE annoyance_types
  MODIFY COLUMN code VARCHAR(50) NOT NULL;

DROP PROCEDURE IF EXISTS ensure_annoyance_type_code_index;
DELIMITER $$
CREATE PROCEDURE ensure_annoyance_type_code_index()
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'annoyance_types'
      AND index_name = 'uk_annoyance_types_code'
  ) THEN
    ALTER TABLE annoyance_types
      ADD UNIQUE KEY uk_annoyance_types_code (code);
  END IF;
END$$
DELIMITER ;
CALL ensure_annoyance_type_code_index();
DROP PROCEDURE IF EXISTS ensure_annoyance_type_code_index;
