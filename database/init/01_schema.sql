CREATE DATABASE IF NOT EXISTS monsters
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE monsters;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT NOT NULL AUTO_INCREMENT,
  account VARCHAR(50) NULL,
  email VARCHAR(255) NOT NULL,
  user_name VARCHAR(80) NOT NULL,
  birthday DATE NULL,
  avatar_url VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_users_account (account),
  UNIQUE KEY uk_users_email (email),
  KEY idx_users_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_credentials (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  password_updated_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_credentials_user_id (user_id),
  CONSTRAINT fk_user_credentials_user
    FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  token_hash VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_password_reset_tokens_token_hash (token_hash),
  KEY idx_password_reset_tokens_user_used (user_id, used_at),
  KEY idx_password_reset_tokens_expires_at (expires_at),
  CONSTRAINT fk_password_reset_tokens_user
    FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_oauth_accounts (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  provider VARCHAR(30) NOT NULL,
  provider_user_id VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_oauth_provider_user (provider, provider_user_id),
  KEY idx_user_oauth_user_id (user_id),
  CONSTRAINT fk_user_oauth_accounts_user
    FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_password_locks (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  lock_password_hash VARCHAR(255) NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_password_locks_user_id (user_id),
  CONSTRAINT fk_user_password_locks_user
    FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS monster_groups (
  id BIGINT NOT NULL AUTO_INCREMENT,
  code VARCHAR(50) NOT NULL,
  name VARCHAR(80) NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_monster_groups_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS monsters (
  id BIGINT NOT NULL AUTO_INCREMENT,
  monster_group_id BIGINT NOT NULL,
  name_chinese VARCHAR(80) NOT NULL,
  name_english VARCHAR(80) NOT NULL,
  description TEXT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_monsters_group_id (monster_group_id),
  CONSTRAINT fk_monsters_monster_group
    FOREIGN KEY (monster_group_id) REFERENCES monster_groups (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS monster_assets (
  id BIGINT NOT NULL AUTO_INCREMENT,
  monster_id BIGINT NOT NULL,
  asset_type VARCHAR(30) NOT NULL,
  asset_url VARCHAR(500) NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_monster_assets_monster_id (monster_id),
  CONSTRAINT fk_monster_assets_monster
    FOREIGN KEY (monster_id) REFERENCES monsters (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_monsters (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  monster_id BIGINT NOT NULL,
  obtained_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_monsters_user_monster (user_id, monster_id),
  KEY idx_user_monsters_monster_id (monster_id),
  CONSTRAINT fk_user_monsters_user
    FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_user_monsters_monster
    FOREIGN KEY (monster_id) REFERENCES monsters (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_active_monsters (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  monster_group_id BIGINT NOT NULL,
  user_monster_id BIGINT NOT NULL,
  selected_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_active_monsters_user_group (user_id, monster_group_id),
  KEY idx_user_active_monsters_user_monster_id (user_monster_id),
  KEY idx_user_active_monsters_group_id (monster_group_id),
  CONSTRAINT fk_user_active_monsters_user
    FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_user_active_monsters_group
    FOREIGN KEY (monster_group_id) REFERENCES monster_groups (id),
  CONSTRAINT fk_user_active_monsters_user_monster
    FOREIGN KEY (user_monster_id) REFERENCES user_monsters (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS annoyance_types (
  id BIGINT NOT NULL AUTO_INCREMENT,
  type_name VARCHAR(80) NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_annoyance_types_type_name (type_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS moods (
  id BIGINT NOT NULL AUTO_INCREMENT,
  code VARCHAR(50) NOT NULL,
  label VARCHAR(80) NOT NULL,
  score TINYINT NOT NULL,
  image_url VARCHAR(500) NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_moods_code (code),
  KEY idx_moods_score (score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS entries (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  entry_type VARCHAR(20) NOT NULL,
  monster_id BIGINT NULL,
  annoyance_type_id BIGINT NULL,
  mood_id BIGINT NOT NULL,
  content TEXT NULL,
  is_shared BOOLEAN NOT NULL DEFAULT FALSE,
  is_solved BOOLEAN NOT NULL DEFAULT FALSE,
  occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_entries_user_type_occurred (user_id, entry_type, occurred_at),
  KEY idx_entries_shared_type_occurred (entry_type, is_shared, occurred_at),
  KEY idx_entries_monster_id (monster_id),
  KEY idx_entries_annoyance_type_id (annoyance_type_id),
  KEY idx_entries_mood_id (mood_id),
  CONSTRAINT fk_entries_user
    FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_entries_monster
    FOREIGN KEY (monster_id) REFERENCES monsters (id),
  CONSTRAINT fk_entries_annoyance_type
    FOREIGN KEY (annoyance_type_id) REFERENCES annoyance_types (id),
  CONSTRAINT fk_entries_mood
    FOREIGN KEY (mood_id) REFERENCES moods (id),
  CONSTRAINT chk_entries_type
    CHECK (entry_type IN ('DIARY', 'ANNOYANCE')),
  CONSTRAINT chk_entries_annoyance_type
    CHECK (
      (entry_type = 'DIARY' AND annoyance_type_id IS NULL)
      OR (entry_type = 'ANNOYANCE' AND annoyance_type_id IS NOT NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS entry_media (
  id BIGINT NOT NULL AUTO_INCREMENT,
  entry_id BIGINT NOT NULL,
  media_type VARCHAR(30) NOT NULL,
  media_url VARCHAR(500) NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_entry_media_entry_id (entry_id),
  CONSTRAINT fk_entry_media_entry
    FOREIGN KEY (entry_id) REFERENCES entries (id),
  CONSTRAINT chk_entry_media_type
    CHECK (media_type IN ('image', 'audio', 'drawing'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS entry_likes (
  id BIGINT NOT NULL AUTO_INCREMENT,
  entry_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_entry_likes_entry_user (entry_id, user_id),
  KEY idx_entry_likes_user_id (user_id),
  CONSTRAINT fk_entry_likes_entry
    FOREIGN KEY (entry_id) REFERENCES entries (id),
  CONSTRAINT fk_entry_likes_user
    FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS entry_comments (
  id BIGINT NOT NULL AUTO_INCREMENT,
  entry_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_entry_comments_entry_created (entry_id, created_at),
  KEY idx_entry_comments_user_id (user_id),
  CONSTRAINT fk_entry_comments_entry
    FOREIGN KEY (entry_id) REFERENCES entries (id),
  CONSTRAINT fk_entry_comments_user
    FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS answer_books (
  id BIGINT NOT NULL AUTO_INCREMENT,
  answer_text TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS daily_tests (
  id BIGINT NOT NULL AUTO_INCREMENT,
  question TEXT NOT NULL,
  explanation TEXT NULL,
  reference_url VARCHAR(500) NULL,
  active_date DATE NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_daily_tests_active_date (active_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS daily_test_options (
  id BIGINT NOT NULL AUTO_INCREMENT,
  daily_test_id BIGINT NOT NULL,
  option_text TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_daily_test_options_test_id (daily_test_id),
  CONSTRAINT fk_daily_test_options_daily_test
    FOREIGN KEY (daily_test_id) REFERENCES daily_tests (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_daily_test_answers (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  daily_test_id BIGINT NOT NULL,
  selected_option_id BIGINT NOT NULL,
  answered_date DATE NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_daily_test_answers_user_date (user_id, answered_date),
  KEY idx_user_daily_test_answers_test_id (daily_test_id),
  KEY idx_user_daily_test_answers_option_id (selected_option_id),
  CONSTRAINT fk_user_daily_test_answers_user
    FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_user_daily_test_answers_daily_test
    FOREIGN KEY (daily_test_id) REFERENCES daily_tests (id),
  CONSTRAINT fk_user_daily_test_answers_option
    FOREIGN KEY (selected_option_id) REFERENCES daily_test_options (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS psychological_tests (
  id BIGINT NOT NULL AUTO_INCREMENT,
  title VARCHAR(150) NOT NULL,
  url VARCHAR(500) NOT NULL,
  description TEXT NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS mind_games (
  id BIGINT NOT NULL AUTO_INCREMENT,
  title VARCHAR(150) NOT NULL,
  url VARCHAR(500) NOT NULL,
  description TEXT NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS stress_relief_methods (
  id BIGINT NOT NULL AUTO_INCREMENT,
  title VARCHAR(150) NOT NULL,
  content TEXT NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS stress_relief_method_assets (
  id BIGINT NOT NULL AUTO_INCREMENT,
  stress_relief_method_id BIGINT NOT NULL,
  asset_type VARCHAR(30) NOT NULL,
  asset_url VARCHAR(500) NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_stress_relief_assets_method_id (stress_relief_method_id),
  CONSTRAINT fk_stress_relief_assets_method
    FOREIGN KEY (stress_relief_method_id) REFERENCES stress_relief_methods (id),
  CONSTRAINT chk_stress_relief_asset_type
    CHECK (asset_type IN ('image', 'audio', 'link'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS feedback (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NULL,
  contact_email VARCHAR(255) NULL,
  content TEXT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'open',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_feedback_user_id (user_id),
  KEY idx_feedback_status_created (status, created_at),
  CONSTRAINT fk_feedback_user
    FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT chk_feedback_status
    CHECK (status IN ('open', 'processing', 'closed'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
