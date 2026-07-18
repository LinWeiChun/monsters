# DATABASE_SPEC.md

# 貘nsters Database Spec

## 一、資料庫基礎規範

本專案使用 MySQL 8.4，資料庫名稱為 `monsters`。

Spring Boot 只能透過 JPA / Repository 存取資料庫；Flutter 不得直接存取資料庫，必須透過 REST API。

### 1.1 連線設定

| 項目 | 預設值 | 說明 |
|---|---|---|
| DB_URL | jdbc:mysql://localhost:3306/monsters?useSSL=false&serverTimezone=Asia/Taipei&allowPublicKeyRetrieval=true | MySQL JDBC URL |
| DB_USERNAME | monsters | MySQL 使用者 |
| DB_PASSWORD | monsters | MySQL 密碼 |

### 1.2 Spring Profile

| Profile | 設定檔 | 說明 |
|---|---|---|
| default | application.yml | 共用設定、profile、JPA 基礎設定 |
| dev | application-dev.yml | 本機開發 MySQL 設定，不追蹤至 Git |
| prod | application-prod.yml | 正式環境設定，必須使用環境變數 |

### 1.3 Docker Compose

`database/init/*.sql` 會掛載到 MySQL container 的 `/docker-entrypoint-initdb.d`，只在資料庫 volume 第一次建立時執行。

### 1.4 命名與共用欄位

- Table：`snake_case`
- Column：`snake_case`
- Primary Key：`id`
- Foreign Key：`<table_singular>_id`
- Boolean：`is_` 前綴
- 時間欄位：使用 `DATETIME`

所有主要資料表必須包含：

| 欄位 | 型別 | 說明 |
|---|---|---|
| id | BIGINT PRIMARY KEY AUTO_INCREMENT | 主鍵 |
| created_at | DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP | 建立時間 |
| updated_at | DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新時間 |

需要軟刪除的使用者產生資料，必須另外包含：

| 欄位 | 型別 | 說明 |
|---|---|---|
| is_deleted | BOOLEAN NOT NULL DEFAULT FALSE | 是否刪除 |
| deleted_at | DATETIME NULL | 刪除時間 |

## 二、正規化重構原則

本次依照 `system_data` 舊程式與現有 API 文件進行資料庫正規化，採以下原則：

1. 不再以 `account` 作為跨表關聯鍵，統一改用 `users.id`。
2. 使用者認證資料與使用者個人資料拆分。
3. Diary 與 Annoyance 共用 `entries` 主表，使用 `entry_type` 區分。
4. 圖片、音訊、手繪圖等媒體從 Diary / Annoyance 主表拆至 `entry_media`。
5. 社群按讚與留言改為共用 `entry_likes`、`entry_comments`。
6. 怪物基本資料與圖片 / GIF / 配件等資產拆分。
7. 每日測驗選項從固定欄位拆成 `daily_test_options`。
8. 查詢型資料使用 lookup table，例如 `annoyance_types`、`moods`、`monster_groups`。
9. 使用 unique constraint 避免重複資料，例如 Email、OAuth 帳號、使用者怪物、按讚。
10. 需要列表查詢的時間欄位、外鍵欄位必須建立 index。

## 三、資料表設計

### 3.1 users

使用者基本資料。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | 使用者 ID |
| account | VARCHAR(50) | UNIQUE NOT NULL | 使用者帳號，英文開頭，可包含英文、數字、底線，長度 4 到 50 |
| email | VARCHAR(255) | UNIQUE NOT NULL | Email |
| user_name | VARCHAR(80) | NOT NULL | 顯示名稱 |
| birthday | DATE | NULL | 生日 |
| avatar_url | VARCHAR(500) | NULL | 頭像 URL |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |
| is_deleted | BOOLEAN | NOT NULL | 是否刪除 |
| deleted_at | DATETIME | NULL | 刪除時間 |

### 3.2 user_credentials

Email / Password 登入憑證。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| user_id | BIGINT | FK UNIQUE NOT NULL | 使用者 ID |
| password_hash | VARCHAR(255) | NOT NULL | BCrypt 密碼雜湊 |
| password_updated_at | DATETIME | NULL | 密碼更新時間 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

### 3.2.1 password_reset_tokens

忘記密碼 reset token。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| user_id | BIGINT | FK NOT NULL | 使用者 ID |
| token_hash | VARCHAR(255) | UNIQUE NOT NULL | reset token hash |
| expires_at | DATETIME | NOT NULL | 過期時間 |
| used_at | DATETIME | NULL | 使用時間，NULL 表示尚未使用 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

Index：

- `user_id, used_at`
- `expires_at`

規則：

- 不得保存 reset token 明文。
- 同一使用者重新申請忘記密碼時，未使用的舊 token 需失效。
- token 使用後必須寫入 `used_at`。
- 過期、已使用或對應已刪除使用者的 token 不得重設密碼。

### 3.2.2 revoked_tokens

登出或 refresh rotation 後撤銷的 JWT。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| token_hash | VARCHAR(255) | UNIQUE NOT NULL | JWT hash |
| expires_at | DATETIME | NOT NULL | 原 JWT 過期時間 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

Index：

- `expires_at`

規則：

- 不得保存 JWT 明文。
- 登出時保存 access token hash；若 request 提供 refresh token，也保存 refresh token hash。
- Refresh token 成功換發時必須保存舊 refresh token hash 與原 token 過期時間，防止 rotation 後重複使用。
- JWT 驗證流程必須拒絕存在於本表且尚未過期的 token。
- 可定期刪除 `expires_at` 已過期的紀錄。

### 3.3 user_oauth_accounts

第三方登入帳號。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| user_id | BIGINT | FK NOT NULL | 使用者 ID |
| provider | VARCHAR(30) | NOT NULL | OAuth provider，例如 google |
| provider_user_id | VARCHAR(255) | NOT NULL | 第三方使用者 ID |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

Unique：`provider, provider_user_id`

Google 登入規則：

- Google provider 固定使用 `google`。
- `provider_user_id` 必須保存 Google ID Token 的 `sub`，不得保存 ID Token 本體。
- 首次 Google 登入時，若 email 尚未存在於未刪除的 `users`，需由 email 前綴產生唯一 `account`，並建立 `users` 與 `user_oauth_accounts`。
- 首次 Google 登入時，若 email 已存在於未刪除的 `users`，需建立 `user_oauth_accounts` 並連結既有使用者。
- 已連結的 Google 帳號登入時，需透過 `provider + provider_user_id` 查詢使用者。
- 已刪除使用者不得透過既有 OAuth 帳號登入。

### 3.4 user_password_locks

使用者隱私鎖設定。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| user_id | BIGINT | FK UNIQUE NOT NULL | 使用者 ID |
| lock_password_hash | VARCHAR(255) | NOT NULL | 隱私鎖密碼雜湊 |
| enabled | BOOLEAN | NOT NULL | 是否啟用 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

### 3.5 monster_groups

怪物分組，對應舊系統 `all_monster.group`。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | 分組 ID |
| code | VARCHAR(50) | UNIQUE NOT NULL | 分組代碼 |
| name | VARCHAR(80) | NOT NULL | 分組名稱 |
| display_order | INT | NOT NULL | 顯示順序 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

### 3.6 monsters

怪物主資料。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | 怪物 ID |
| monster_group_id | BIGINT | FK NOT NULL | 怪物分組 ID |
| name_chinese | VARCHAR(80) | NOT NULL | 中文名稱 |
| name_english | VARCHAR(80) | NOT NULL | 英文名稱 |
| description | TEXT | NULL | 說明 |
| is_default | BOOLEAN | NOT NULL | 是否為預設怪物 |
| display_order | INT | NOT NULL | 顯示順序 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

### 3.7 monster_assets

怪物圖片、頭像、左右 GIF、配件圖等資產。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | 資產 ID |
| monster_id | BIGINT | FK NOT NULL | 怪物 ID |
| asset_type | VARCHAR(30) | NOT NULL | avatar、image、left_gif、right_gif、item |
| asset_url | VARCHAR(500) | NOT NULL | 資產 URL |
| display_order | INT | NOT NULL | 顯示順序 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

### 3.8 user_monsters

使用者擁有的怪物。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| user_id | BIGINT | FK NOT NULL | 使用者 ID |
| monster_id | BIGINT | FK NOT NULL | 怪物 ID |
| obtained_at | DATETIME | NOT NULL | 取得時間 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

Unique：`user_id, monster_id`

### 3.9 user_active_monsters

使用者每個怪物分組目前套用的怪物。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| user_id | BIGINT | FK NOT NULL | 使用者 ID |
| monster_group_id | BIGINT | FK NOT NULL | 怪物分組 ID |
| user_monster_id | BIGINT | FK NOT NULL | 使用者怪物 ID |
| selected_at | DATETIME | NOT NULL | 套用時間 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

Unique：`user_id, monster_group_id`

### 3.10 annoyance_types

煩惱分類。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | 分類 ID |
| code | VARCHAR(50) | UNIQUE NOT NULL | 穩定分類代碼，供 API 使用 |
| type_name | VARCHAR(80) | UNIQUE NOT NULL | 分類名稱 |
| display_order | INT | NOT NULL | 顯示順序 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

初始 code 固定為 `ACADEMIC`、`CAREER`、`LOVE`、`FRIENDSHIP`、`FAMILY`、`OTHER`，Client 不傳 Database ID。

| code | type_name | display_order |
|---|---|---:|
| `ACADEMIC` | 課業 | 1 |
| `CAREER` | 事業 | 2 |
| `LOVE` | 愛情 | 3 |
| `FRIENDSHIP` | 友情 | 4 |
| `FAMILY` | 親情 | 5 |
| `OTHER` | 其他 | 6 |

### 3.11 moods

情緒 lookup table，取代舊系統 diary / annoyance 的 `mood` 字串與 `index` 欄位。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | 情緒 ID |
| code | VARCHAR(50) | UNIQUE NOT NULL | 情緒代碼 |
| label | VARCHAR(80) | NOT NULL | 顯示名稱 |
| score | TINYINT | UNIQUE NOT NULL | 分數，固定 1 到 5 |
| image_url | VARCHAR(500) | NULL | 情緒圖片 URL |
| display_order | INT | NOT NULL | 顯示順序 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

初始 seed 使用不綁定好壞或煩惱程度語意的共用分數 code，供 Annoyance 與 Diary 共用：

| code | label | score | display_order |
|---|---|---:|---:|
| `SCORE_1` | 1分 | 1 | 1 |
| `SCORE_2` | 2分 | 2 | 2 |
| `SCORE_3` | 3分 | 3 | 3 |
| `SCORE_4` | 4分 | 4 | 4 |
| `SCORE_5` | 5分 | 5 | 5 |

### 3.12 entries

使用者紀錄主表。Diary 與 Annoyance 共用此表，透過 `entry_type` 區分。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | 紀錄 ID |
| user_id | BIGINT | FK NOT NULL | 使用者 ID |
| entry_type | VARCHAR(20) | NOT NULL | DIARY 或 ANNOYANCE |
| monster_id | BIGINT | FK NULL | 當下使用怪物 |
| annoyance_type_id | BIGINT | FK NULL | 煩惱分類，僅 ANNOYANCE 使用 |
| mood_id | BIGINT | FK NOT NULL | 情緒 ID |
| content | TEXT | NULL | 文字內容 |
| is_shared | BOOLEAN | NOT NULL | 是否分享至社群 |
| is_solved | BOOLEAN | NOT NULL | 是否已解決，僅 ANNOYANCE 使用 |
| occurred_at | DATETIME | NOT NULL | 使用者紀錄時間 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |
| is_deleted | BOOLEAN | NOT NULL | 是否刪除 |
| deleted_at | DATETIME | NULL | 刪除時間 |

規則：

- `entry_type = 'DIARY'` 時，`annoyance_type_id` 必須為 NULL，`is_solved` 固定為 false。
- `entry_type = 'ANNOYANCE'` 時，`annoyance_type_id` 必須有值。
- Annoyance Service 依 `annoyance_types.code` 與 `moods.score` 解析 FK；Client 不得傳 lookup ID。
- 每筆 ANNOYANCE 使用一種主要記錄方式：文字存於 `entries.content`，或一筆 image／audio／video 媒體；另可有一筆 drawing。此組合由 Service 驗證。

### 3.13 entry_media

紀錄媒體資料。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | 媒體 ID |
| entry_id | BIGINT | FK NOT NULL | 紀錄 ID |
| media_type | VARCHAR(30) | NOT NULL | image、audio、video、drawing |
| object_key | VARCHAR(500) | UNIQUE NOT NULL | Private R2 object key，不得回傳 Client |
| content_type | VARCHAR(100) | NOT NULL | 已驗證的 MIME type |
| file_size_bytes | BIGINT | NOT NULL | 檔案大小 bytes |
| duration_seconds | DECIMAL(10,3) | NULL | 錄音／影片秒數；圖片與心情圖為 NULL |
| display_order | INT | NOT NULL | 顯示順序 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |
| is_deleted | BOOLEAN | NOT NULL | 是否刪除 |
| deleted_at | DATETIME | NULL | 刪除時間 |

規則：

- Entry media 使用與 public avatar 分離的 private R2 bucket；Database 不保存 public URL。
- `object_key` 由 Backend 產生且必須唯一，Client 不得提供或取得此值。
- `media_type` 僅允許 `image`、`audio`、`video`、`drawing`。
- `file_size_bytes` 必須大於 0。
- `audio` 與 `video` 必須保存經 `ffprobe` 驗證的正數 `duration_seconds`；其他類型必須為 NULL。
- 媒體下載由 Backend 先驗證 entry owner 或分享狀態，再以 object key 向 R2 取回並串流。

### 3.14 entry_likes

社群貼文按讚。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| entry_id | BIGINT | FK NOT NULL | 紀錄 ID |
| user_id | BIGINT | FK NOT NULL | 按讚使用者 ID |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

Unique：`entry_id, user_id`

### 3.15 entry_comments

社群貼文留言。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | 留言 ID |
| entry_id | BIGINT | FK NOT NULL | 紀錄 ID |
| user_id | BIGINT | FK NOT NULL | 留言使用者 ID |
| content | TEXT | NOT NULL | 留言內容 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |
| is_deleted | BOOLEAN | NOT NULL | 是否刪除 |
| deleted_at | DATETIME | NULL | 刪除時間 |

### 3.16 answer_books

答案之書。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| answer_text | TEXT | NOT NULL | 答案內容 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

### 3.17 daily_tests

每日測驗題目。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | 題目 ID |
| question | TEXT | NOT NULL | 題目 |
| explanation | TEXT | NULL | 答案說明 |
| reference_url | VARCHAR(500) | NULL | 參考連結 |
| active_date | DATE | NULL | 指定日期，NULL 代表可隨機 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

### 3.18 daily_test_options

每日測驗選項。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | 選項 ID |
| daily_test_id | BIGINT | FK NOT NULL | 題目 ID |
| option_text | TEXT | NOT NULL | 選項內容 |
| is_correct | BOOLEAN | NOT NULL | 是否正解 |
| display_order | INT | NOT NULL | 顯示順序 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

### 3.19 user_daily_test_answers

使用者每日測驗作答紀錄。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| user_id | BIGINT | FK NOT NULL | 使用者 ID |
| daily_test_id | BIGINT | FK NOT NULL | 題目 ID |
| selected_option_id | BIGINT | FK NOT NULL | 使用者選項 |
| answered_date | DATE | NOT NULL | 作答日期 |
| is_correct | BOOLEAN | NOT NULL | 是否答對 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

Unique：`user_id, answered_date`

### 3.20 psychological_tests

心理測驗資源。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| title | VARCHAR(150) | NOT NULL | 標題 |
| url | VARCHAR(500) | NOT NULL | 連結 |
| description | TEXT | NULL | 說明 |
| display_order | INT | NOT NULL | 顯示順序 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

### 3.21 mind_games

心情小遊戲。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| title | VARCHAR(150) | NOT NULL | 標題 |
| url | VARCHAR(500) | NOT NULL | 連結 |
| description | TEXT | NULL | 說明 |
| display_order | INT | NOT NULL | 顯示順序 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

### 3.22 stress_relief_methods

紓壓方法。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| title | VARCHAR(150) | NOT NULL | 標題 |
| content | TEXT | NOT NULL | 內容 |
| display_order | INT | NOT NULL | 顯示順序 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

### 3.23 stress_relief_method_assets

紓壓方法圖片、音訊或外部資源。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| stress_relief_method_id | BIGINT | FK NOT NULL | 紓壓方法 ID |
| asset_type | VARCHAR(30) | NOT NULL | image、audio、link |
| asset_url | VARCHAR(500) | NOT NULL | 資源 URL |
| display_order | INT | NOT NULL | 顯示順序 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

### 3.24 feedback

使用者意見回饋。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| user_id | BIGINT | FK NULL | 使用者 ID，允許匿名 |
| contact_email | VARCHAR(255) | NULL | 聯絡 Email |
| content | TEXT | NOT NULL | 回饋內容 |
| status | VARCHAR(30) | NOT NULL | open、processing、closed |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

## 四、關聯總覽

- `users` 1 對 1 `user_credentials`
- `users` 1 對多 `user_oauth_accounts`
- `users` 1 對 1 `user_password_locks`
- `monster_groups` 1 對多 `monsters`
- `monsters` 1 對多 `monster_assets`
- `users` 多對多 `monsters`，透過 `user_monsters`
- `users` 1 對多 `user_active_monsters`
- `users` 1 對多 `entries`
- `entries` 1 對多 `entry_media`
- `entries` 1 對多 `entry_likes`
- `entries` 1 對多 `entry_comments`
- `annoyance_types` 1 對多 `entries`
- `moods` 1 對多 `entries`
- `daily_tests` 1 對多 `daily_test_options`
- `users` 1 對多 `user_daily_test_answers`
- `stress_relief_methods` 1 對多 `stress_relief_method_assets`

## 五、舊系統對應

本章僅用於說明舊系統資料結構與新版資料表的對應關係。

`system_data/` 中的舊資料表、欄位名稱與關聯設計僅供參考，不代表新版資料庫必須完全沿用。

若舊系統存在以下情況，新版應重新設計：

- 表名拼字錯誤
- 欄位語意不明
- 欄位型別不合理
- 重複資料過多
- 關聯未正規化
- 使用字串儲存可正規化資料
- 缺少 foreign key、index 或 constraint

### `system_data/` Database 參考紀錄格式

| 項目 | 說明 |
|---|---|
| 舊系統參考位置 | `system_data/...` |
| 可參考內容 | 舊表、舊欄位、資料語意、資料關聯 |
| 不可沿用內容 | 拼字錯誤表名、未正規化欄位、明文密碼、不合理型別 |
| 新版調整方式 | 依新版 schema、constraint、index 與 migration mapping 重新設計 |
| 是否需更新正式規格 | 是 / 否 |

| system_data 舊表 / 欄位 | 新表 / 欄位 | 說明 |
|---|---|---|
| `personal_info.account` | `users.account` | 僅保留舊系統匯入與相容用途，不作為主要關聯鍵 |
| `personal_info.mail` | `users.email` | Email 改為 unique |
| `personal_info.password` | `user_credentials.password_hash` | 密碼只存 BCrypt hash |
| `personal_info.lock` | `user_password_locks.lock_password_hash` | 隱私鎖密碼需 hash |
| `personal_info.photo` | `users.avatar_url` | 頭像 URL |
| `personal_info.daily_test` | `user_daily_test_answers` | 每日測驗狀態改為作答紀錄 |
| `all_monster.group` | `monster_groups` | 怪物群組正規化 |
| `all_monster.photo/avatar/right_gif/left_gif` | `monster_assets` | 怪物資產拆表 |
| `personal_monster` | `user_monsters` | 使用 `user_id` + `monster_id` |
| `personal_monster_use` | `user_active_monsters` | 使用者目前套用怪物 |
| `annoyance` | `entries` | `entry_type = 'ANNOYANCE'` |
| `diary` | `entries` | `entry_type = 'DIARY'` |
| `image_content/audio_content` | `entry_media` | 媒體拆表 |
| `annoyance_social` / `diary_social` | `entry_likes` | 社群按讚共用表 |
| `annoyance_social_comment` / `diary_social_comment` | `entry_comments` | 社群留言共用表 |
| `daily_test.option_one` 到 `option_four` | `daily_test_options` | 選項拆表 |
| `daily_test.answer` | `daily_test_options.is_correct` | 正解綁定選項 |
| `daily_test.learn` | `daily_tests.explanation` | 說明文字 |
| `daily_test.web` | `daily_tests.reference_url` | 參考連結 |
| `answer_book.content` | `answer_books.answer_text` | 欄位命名統一 |
| `mind_game.name/web` | `mind_games.title/url` | 欄位命名統一 |

## 六、Index 與 Constraint 規範

必要 unique constraint：

- `users.email`
- `users.account`
- `user_credentials.user_id`
- `user_oauth_accounts(provider, provider_user_id)`
- `user_password_locks.user_id`
- `monster_groups.code`
- `user_monsters(user_id, monster_id)`
- `user_active_monsters(user_id, monster_group_id)`
- `annoyance_types.type_name`
- `annoyance_types.code`
- `moods.code`
- `moods.score`
- `entry_media.object_key`
- `entry_likes(entry_id, user_id)`
- `user_daily_test_answers(user_id, answered_date)`

必要 index：

- 所有 foreign key 欄位
- `entries(user_id, entry_type, occurred_at)`
- `entries(entry_type, is_shared, occurred_at)`
- `entry_comments(entry_id, created_at)`
- `daily_tests(active_date)`

Annoyance 列表的 `page`、`size`、`sort` 由查詢的 `LIMIT`／`OFFSET` 與排序實作，不在任何資料表新增頁碼欄位。

## 七、Migration / Init SQL

目前初始化 schema：

```text
database/init/01_schema.sql
```

注意事項：

- `database/init/*.sql` 只會在 MySQL Docker volume 第一次建立時執行。
- 若本機已有 `mysql_data` volume，修改 init SQL 後不會自動套用到既有資料庫。
- 正式進入資料保存階段後，資料庫結構異動應改用正式 migration 工具或手動 migration script，不得直接依賴 Docker init SQL。

若需從 `system_data/` 舊資料庫匯入資料，應建立明確的 migration mapping，不得直接將舊表結構搬入新版資料庫。

Phase 3 annoyance type migration：`database/migrations/20260711_01_add_annoyance_type_codes_and_seed.sql`。既有環境只執行一次；全新環境由 `database/init/01_schema.sql` 直接建立並 seed。

Phase 3 private entry media migration：`database/migrations/20260711_02_make_entry_media_private.sql`。此 migration 會在 `entry_media` 已有資料時主動中止；既有資料必須先匯出，另行建立經審查的 public URL → private R2 object key 資料 migration，不得直接將 public URL 原值當成 object key。

Phase 3 mood score migration：`database/migrations/20260711_03_make_mood_score_unique.sql`。此 migration 建立 `moods.score` 唯一約束與 `SCORE_1`～`SCORE_5` seed；若既有分數重複或 code / score 對應衝突會主動中止，必須先審查與清理資料。

Migration 應包含：

- 舊表名稱
- 舊欄位名稱
- 新表名稱
- 新欄位名稱
- 資料轉換規則
- 是否允許 NULL
- 是否需要預設值
- 是否需要清洗資料
- 是否保留舊 ID 對照

## 八、後續 Entity 實作規範

後端 Entity 必須遵守：

- package：`com.monsters.entity.<module>`
- 共用欄位繼承 `com.monsters.entity.common.BaseEntity`
- API Response 不得直接回傳 Entity，必須使用 DTO
- Service 負責 transaction
- Repository 只負責資料存取
- 密碼、JWT、隱私鎖不得寫入 log

---

## Register API Database Mapping

`POST /api/auth/register` writes data to the normalized auth tables:

| API Field | Table | Column | Note |
|---|---|---|---|
| email | users | email | Lowercase normalized before duplicate check |
| userName | users | user_name | Trimmed before persistence |
| password | user_credentials | password_hash | Stored as BCrypt hash only |

Register API must not store raw passwords, JWT values, or secrets in logs.

## Login API Database Mapping

`POST /api/auth/login` reads data from the normalized auth tables:

| API Field | Table | Column | Note |
|---|---|---|---|
| email | users | email | Lowercase normalized before lookup; deleted users are rejected |
| password | user_credentials | password_hash | Compared with BCrypt `PasswordEncoder.matches` |

Login API returns JWT access and refresh tokens, but tokens must not be persisted or written to logs.

## User API Database Mapping

`GET /api/users/me` reads the authenticated user's normalized profile data:

| API Field | Table | Column | Note |
|---|---|---|---|
| userId | users | id | Read from authenticated JWT principal, not from client input |
| account | users | account | Kept for old-system compatibility and import only |
| email | users | email | Read-only in this API |
| userName | users | user_name | Display name |
| birthday | users | birthday | Nullable profile field |
| avatarUrl | users | avatar_url | Nullable public avatar URL |

`PUT /api/users/me` updates only editable profile columns:

| API Field | Table | Column | Note |
|---|---|---|---|
| userName | users | user_name | Required, max length 80, trimmed before persistence |
| birthday | users | birthday | Nullable `DATE` value |

`PUT /api/users/me/avatar` uploads the avatar file to Cloudflare R2 and updates only the public URL:

| API Field | Table | Column | Note |
|---|---|---|---|
| file | users | avatar_url | File binary is not stored in MySQL; only the public R2 URL is persisted |

User APIs must query or update only non-deleted users and must not accept `userId` or `account` from client input for the current-user profile flow.

## Password Lock API Database Mapping

`PUT /api/users/me/password-lock` creates or updates the authenticated user's password lock:

| API Field | Table | Column | Note |
|---|---|---|---|
| lockPassword | user_password_locks | lock_password_hash | Stored as BCrypt hash only |
| - | user_password_locks | enabled | Set to `true` when a lock is created or updated |

`POST /api/users/me/password-lock/verify` reads the authenticated user's enabled password lock:

| API Field | Table | Column | Note |
|---|---|---|---|
| lockPassword | user_password_locks | lock_password_hash | Compared with BCrypt `PasswordEncoder.matches` |

Password Lock API must not store or log raw lock passwords. The client must not submit `userId` or `account`; the backend uses the authenticated JWT principal.
