USE monsters;

DROP PROCEDURE IF EXISTS ensure_unique_mood_score;

DELIMITER //
CREATE PROCEDURE ensure_unique_mood_score()
BEGIN
  IF EXISTS (
    SELECT score
    FROM moods
    GROUP BY score
    HAVING COUNT(*) > 1
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'moods contains duplicate score values; clean data before migration';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM moods
    WHERE (score BETWEEN 1 AND 5 AND code <> CONCAT('SCORE_', score))
       OR (code IN ('SCORE_1', 'SCORE_2', 'SCORE_3', 'SCORE_4', 'SCORE_5')
           AND score <> CAST(SUBSTRING(code, 7) AS UNSIGNED))
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'moods score seed conflicts with existing rows; review data before migration';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'moods'
      AND column_name = 'score'
      AND non_unique = 0
  ) THEN
    IF EXISTS (
      SELECT 1
      FROM information_schema.statistics
      WHERE table_schema = DATABASE()
        AND table_name = 'moods'
        AND index_name = 'idx_moods_score'
    ) THEN
      ALTER TABLE moods DROP INDEX idx_moods_score;
    END IF;

    ALTER TABLE moods ADD CONSTRAINT uk_moods_score UNIQUE (score);
  END IF;

  INSERT INTO moods (
    code,
    label,
    score,
    image_url,
    display_order,
    created_at,
    updated_at
  )
  VALUES
    ('SCORE_1', '1分', 1, NULL, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('SCORE_2', '2分', 2, NULL, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('SCORE_3', '3分', 3, NULL, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('SCORE_4', '4分', 4, NULL, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('SCORE_5', '5分', 5, NULL, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
  ON DUPLICATE KEY UPDATE
    label = VALUES(label),
    image_url = VALUES(image_url),
    display_order = VALUES(display_order);
END//
DELIMITER ;

CALL ensure_unique_mood_score();
DROP PROCEDURE ensure_unique_mood_score;
