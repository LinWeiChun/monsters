# DATABASE_SPEC.md

# 貘nsters 資料庫設計規格

## 一、資料庫原則

資料庫使用 MySQL。

預設資料庫名稱：

```text
monsters
```

後端連線使用環境變數設定：

| 環境變數 | 預設值 | 說明 |
|---|---|---|
| DB_URL | jdbc:mysql://localhost:3306/monsters?useSSL=false&serverTimezone=Asia/Taipei&allowPublicKeyRetrieval=true | MySQL JDBC URL |
| DB_USERNAME | monsters | MySQL 帳號 |
| DB_PASSWORD | monsters | MySQL 密碼 |

Spring Boot Profile 設定：

| Profile | 設定檔 | 說明 |
|---|---|---|
| 共用 | application.yml | App 名稱、預設 profile、JPA 共用設定 |
| dev | application-dev.yml | 本機開發 MySQL 預設連線 |
| prod | application-prod.yml | 正式環境連線，必須由環境變數提供 |

所有資料表命名使用 `snake_case`。

每個資料表預設包含：

- `id` BIGINT PRIMARY KEY AUTO_INCREMENT
- `created_at` DATETIME NOT NULL
- `updated_at` DATETIME NOT NULL

若需要軟刪除，加入：

- `is_deleted` BOOLEAN DEFAULT FALSE
- `deleted_at` DATETIME NULL

## 二、主要資料表

以下欄位作為目前開發依據。若後續需相容舊資料庫，必須先更新本文件再實作。

### 2.1 personal_info 使用者資料

用途：儲存使用者帳號、個人資料、頭貼、密碼鎖設定等。

| 欄位 | 說明 |
|---|---|
| id | 使用者 ID |
| account | 帳號 |
| email | Email |
| password | 密碼雜湊 |
| google_id | Google 帳號識別 |
| user_name | 使用者名稱 |
| avatar_url | 頭貼 URL |
| lock_password | 四位數密碼鎖雜湊 |
| created_at | 建立時間 |
| updated_at | 更新時間 |

### 2.2 all_monster 怪獸資料

用途：儲存所有可取得的怪獸。

| 欄位 | 說明 |
|---|---|
| id | 怪獸 ID |
| monster_name | 怪獸名稱 |
| description | 怪獸描述 |
| image_url | 圖片 URL |
| default_skin_url | 預設造型 URL |
| created_at | 建立時間 |
| updated_at | 更新時間 |

### 2.3 personal_monster 個人怪獸

用途：紀錄使用者已獲得的怪獸與目前造型。

| 欄位 | 說明 |
|---|---|
| id | ID |
| user_id | 使用者 ID |
| monster_id | 怪獸 ID |
| current_skin_url | 目前使用造型 |
| obtained_at | 獲得時間 |
| created_at | 建立時間 |
| updated_at | 更新時間 |

### 2.4 annoyance 記錄煩惱資料

用途：儲存使用者煩惱內容、分數、分享狀態與解決狀態。

| 欄位 | 說明 |
|---|---|
| id | 煩惱 ID |
| user_id | 使用者 ID |
| annoyance_type_id | 煩惱類別 ID |
| content | 文字內容 |
| media_url | 媒體 URL |
| mood_drawing_url | 心情圖 URL |
| mood_score | 心情分數 |
| is_shared | 是否分享到社群 |
| is_solved | 是否已解決 |
| created_at | 建立時間 |
| updated_at | 更新時間 |

### 2.5 annoyance_type 煩惱類別

用途：儲存煩惱類別。

| 欄位 | 說明 |
|---|---|
| id | 類別 ID |
| type_name | 類別名稱 |
| created_at | 建立時間 |
| updated_at | 更新時間 |

### 2.6 annoyance_social_like 煩惱社群按愛心

用途：儲存使用者對煩惱社群文章的愛心狀態。

| 欄位 | 說明 |
|---|---|
| id | ID |
| annoyance_id | 煩惱 ID |
| user_id | 使用者 ID |
| created_at | 建立時間 |
| updated_at | 更新時間 |

### 2.7 annoyance_social_comment 煩惱社群留言

用途：儲存使用者對煩惱社群文章的留言。

| 欄位 | 說明 |
|---|---|
| id | 留言 ID |
| annoyance_id | 煩惱 ID |
| user_id | 使用者 ID |
| comment | 留言內容 |
| created_at | 建立時間 |
| updated_at | 更新時間 |

### 2.8 diary 記錄日記資料

用途：儲存日記內容、媒體、心情分數與分享狀態。

| 欄位 | 說明 |
|---|---|
| id | 日記 ID |
| user_id | 使用者 ID |
| content | 文字內容 |
| media_url | 媒體 URL |
| mood_drawing_url | 心情圖 URL |
| mood_score | 心情分數 |
| is_shared | 是否分享到社群 |
| created_at | 建立時間 |
| updated_at | 更新時間 |

### 2.9 diary_social_like 日記社群按愛心

用途：儲存使用者對日記社群文章的愛心狀態。

| 欄位 | 說明 |
|---|---|
| id | ID |
| diary_id | 日記 ID |
| user_id | 使用者 ID |
| created_at | 建立時間 |
| updated_at | 更新時間 |

### 2.10 diary_social_comment 日記社群留言

用途：儲存使用者對日記社群文章的留言。

| 欄位 | 說明 |
|---|---|
| id | 留言 ID |
| diary_id | 日記 ID |
| user_id | 使用者 ID |
| comment | 留言內容 |
| created_at | 建立時間 |
| updated_at | 更新時間 |

### 2.11 answer_book 解答之書

用途：儲存隨機解答文字。

| 欄位 | 說明 |
|---|---|
| id | 解答 ID |
| answer_text | 解答內容 |
| created_at | 建立時間 |
| updated_at | 更新時間 |

### 2.12 mind_game 心理小遊戲

用途：儲存外部心理小遊戲連結。

| 欄位 | 說明 |
|---|---|
| id | 小遊戲 ID |
| title | 標題 |
| url | 外部連結 |
| description | 說明 |
| created_at | 建立時間 |
| updated_at | 更新時間 |

### 2.13 daily_test 每日測驗

用途：儲存每日測驗題目、選項、答案與解析。

| 欄位 | 說明 |
|---|---|
| id | 題目 ID |
| question | 題目 |
| option_a | 選項 A |
| option_b | 選項 B |
| option_c | 選項 C |
| option_d | 選項 D |
| correct_option | 正確答案 |
| explanation | 解析 |
| created_at | 建立時間 |
| updated_at | 更新時間 |

## 三、資料關聯

- `personal_info` 1 對多 `annoyance`
- `personal_info` 1 對多 `diary`
- `personal_info` 1 對多 `personal_monster`
- `all_monster` 1 對多 `personal_monster`
- `annoyance_type` 1 對多 `annoyance`
- `annoyance` 1 對多 `annoyance_social_like`
- `annoyance` 1 對多 `annoyance_social_comment`
- `diary` 1 對多 `diary_social_like`
- `diary` 1 對多 `diary_social_comment`

## 四、注意事項

- 原手冊中表名 `diary_socila_like` 與 `dialy_test` 疑似拼字錯誤。除非要完全相容舊資料庫，建議新系統統一為 `diary_social_like` 與 `daily_test`。
- 若需要相容舊資料，需在開發前確認是否保留原表名。
