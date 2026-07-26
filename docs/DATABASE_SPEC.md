# DATABASE_SPEC.md

# 貘nsters Database Spec

> 狀態說明：本文件同時記錄 `develop` 目前 Schema 與 2026-07-26 已核准的目標 Schema。第二章的目標模型具有規格優先權；第三章既有表格是 Migration 輸入，不代表仍可新增依賴。所有目標變更必須於基礎安全階段透過 Flyway 實作，不得直接覆蓋正式資料庫。

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
- 系統事件時間：使用 UTC `DATETIME`
- 具有使用者日期語意的 Entry：另保存建立當下的本地日期、IANA timezone 與 UTC offset

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

1. 移除使用者可見 `account`；內部關聯統一使用 `users.id`，Client 使用不可推測 `public_id`。
2. 使用者認證資料與使用者個人資料拆分。
3. Diary 與 Annoyance 共用 `entries` 主表，使用 `entry_type` 區分。
4. 圖片、音訊、手繪圖等媒體從 Diary / Annoyance 主表拆至 `entry_media`。
5. 私人 `entries` 不直接承載社群互動；分享建立 `community_posts` 公開快照，支持與留言依附 Community Post。
6. 怪物基本資料與圖片 / GIF / 配件等資產拆分。
7. 每日測驗選項從固定欄位拆成 `daily_test_options`。
8. 查詢型資料使用 lookup table，例如 `annoyance_types`、`moods`、`monster_groups`。
9. 使用 unique constraint 避免重複資料，例如 Email、OAuth 帳號、使用者怪物、按讚。
10. 需要列表查詢的時間欄位、外鍵欄位必須建立 index。
11. 正式 Schema 變更使用 Flyway；已在共用環境執行的 Migration 不得改寫。
12. 刪除、匯出、工作階段、監護人同意、內容審閱與背景工作必須有可查核的狀態，不以 boolean 或一次性 best-effort 取代生命週期。

### 2.1 已核准目標模型

下列模型須於 Phase 4 整合後的「基礎安全與領域模型」階段，以 expand／migrate／contract 方式導入：

| 領域 | 目標資料結構與不可變規則 |
|---|---|
| 使用者 | `users` 新增 UUID `public_id`、服務地區、生日、資格狀態與選定貘怪頭貼關聯；移除 `account`、`avatar_url` 與使用者頭貼上傳依賴 |
| Email 驗證 | 一次性驗證 Token 只保存 hash、到期時間與使用時間；七天未驗證且無內容的空帳號可清除 |
| 憑證 | `user_credentials` 保存 Argon2id 參數版本；舊 BCrypt 只供登入時漸進遷移 |
| OAuth | `user_oauth_accounts` 以 provider＋`sub` 唯一；同 Email 不得自動連結，連結／解除需重新驗證 |
| 工作階段 | `user_sessions` 表示裝置、建立／最後活動／閒置／絕對到期與撤銷狀態；Refresh Token 另表只保存 hash、family、rotation 與 reuse 狀態 |
| 年齡與同意 | 監護人同意、條款同意、成人重新同意都保存文件版本、時間、狀態與撤回時間；監護人 Email 不授予內容存取權 |
| 角色 | `MEMBER`、`MODERATOR`、`ADMIN`、`CONTENT_REVIEWER` 分離；Community Eligibility 另存，不是角色 |
| Entry | Diary／Annoyance 共用核心；`public_id`、`version`、UTC 時間、本地日期、timezone、offset、選填情緒負荷、選填私人分類與刪除狀態 |
| Entry Media | 保存私人 object key、真實格式、處理狀態、掃描狀態、大小、時長與清除狀態；未通過隔離處理不得成為可用媒體 |
| Community Post | 保存 Entry owner、獨立快照、公開主題、版本、發布／取消分享／審核狀態；不保存私人分數、私人分類或原始日期 |
| 社群治理 | 留言、支持、檢舉、封鎖、處置、申訴與敏感警示皆依附 Community Post；留言為單層，支持只有一種且不建立公開排行 |
| 內容系統 | 自我探索、教育小測驗、外部資源與固定貘怪回應使用版本化內容、適用年齡、來源、Reviewer 與發布狀態 |
| 圖鑑 | `user_monsters` 維持唯一擁有關聯，另保存固定 Unlock Milestone 與防重達成事件；不建立隨機抽取或代幣 |
| 資料權利 | 匯出工作、刪除申請、刪除 marker、法律保全、通知與清理工作具有可重試狀態及期限 |
| 非同步工作 | Transactional Outbox 與 Worker job 保存最小識別、防重鍵、嘗試次數、下次重試與最終失敗狀態，不保存私人內容 |
| 稽核 | 保存特權操作、角色變更、安全與刪除事件；不得保存私人原文、Token、Email、監護人資料或已刪除會員的可逆識別 |

### 2.2 核心資料限制

- Entry 情緒負荷為 nullable `TINYINT`，有值時只能為 1 至 5；1 代表較輕，5 代表較重。
- Entry 私人分類為 nullable；Diary 與 Annoyance 都可略過。
- Entry 文字最多 20,000 個 Unicode 字元，Community Post 最多 10,000 字，留言最多 1,000 字。
- 每位會員正式媒體配額第一版為 1 GB；超過配額只拒絕新增媒體。
- 所有 Client 可引用資源都有唯一 UUID `public_id`；內部 `BIGINT id` 不得回傳一般 Client。
- 所有可修改 Aggregate 使用 `version` 作 optimistic concurrency control；刪除優先於舊版本更新。
- Community Post 取消分享或刪除後，其版本、留言與支持立即不可見並於七天內清除。
- 個別內容於七天內清除、備份與 R2 舊版本最長 30 天輪替；災難還原後必須重播刪除與撤銷 marker。

### 2.3 資料保存期限

| 資料 | 保存期限 |
|---|---|
| 一般應用與錯誤 Log | 30 天 |
| 登入、Token、密碼與帳號安全事件 | 180 天 |
| 檢舉、下架、停權、申訴與角色變更稽核 | 1 年 |
| 回饋案件文字 | 關閉後 90 天 |
| 內容／帳號刪除工作資料 | 正式資料七天內清除；不含內容的事件依稽核期限 |
| 加密備份與 R2 舊版本 | 最長 30 天 |
| 法律保全 | 僅依正式要求的最小範圍與明確期限，定期複核 |

## 三、目前 `develop` 資料表設計（待 Flyway Migration）

本章描述現有基線，供 Migration 與相容測試使用。凡與第二章衝突者，以第二章為目標規格；不得再新增對 `account`、公開 `avatar_url`、JWT Refresh Token、伺服器 PIN、`entries.is_shared`、`entry_likes` 或 `entry_comments` 的新依賴。

### 3.1 users

使用者基本資料。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | 使用者 ID |
| account | VARCHAR(50) | UNIQUE NOT NULL | 舊基線帳號欄位；目標 Schema 移除 |
| email | VARCHAR(255) | UNIQUE NOT NULL | Email |
| user_name | VARCHAR(80) | NOT NULL | 顯示名稱 |
| birthday | DATE | NULL | 生日 |
| avatar_url | VARCHAR(500) | NULL | 舊基線公開頭像 URL；目標 Schema 改為已取得貘怪素材關聯 |
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
| password_hash | VARCHAR(255) | NOT NULL | 舊資料可能為 BCrypt；新密碼使用可辨識參數版本的 Argon2id 雜湊 |
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

### 3.2.2 revoked_tokens（舊基線）

登出或 refresh rotation 後撤銷的 JWT。目標模型改由 `user_sessions` 與不透明 Refresh Token family 管理；本表只作 Migration 輸入。

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

Google 登入目標規則：

- Google provider 固定使用 `google`。
- `provider_user_id` 必須保存 Google ID Token 的 `sub`，不得保存 ID Token 本體。
- 首次 Google 登入時，若 email 尚未存在於未刪除的 `users`，建立待完成服務地區與年齡資格流程的會員，不產生 `account`。
- Google email 與既有會員相同時不得自動連結；需先重新驗證既有登入方式並明確建立 OAuth 關聯。
- 已連結的 Google 帳號登入時，需透過 `provider + provider_user_id` 查詢使用者。
- 已刪除使用者不得透過既有 OAuth 帳號登入。

### 3.4 user_password_locks（目標移除）

舊基線的伺服器隱私鎖設定。目標模型由 Android／iOS 每台裝置安全儲存本機 PIN，Backend 不保存、不驗證也不回傳 PIN。

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
| mood_id | BIGINT | FK NULL | 選填情緒負荷 lookup |
| content | TEXT | NULL | 文字內容 |
| is_shared | BOOLEAN | NOT NULL | 舊基線分享旗標；目標模型改為獨立 `community_posts` |
| is_solved | BOOLEAN | NOT NULL | 是否已解決，僅 ANNOYANCE 使用 |
| occurred_at | DATETIME | NOT NULL | UTC 紀錄時間；目標模型另保存當時本地日期、timezone 與 offset |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |
| is_deleted | BOOLEAN | NOT NULL | 是否刪除 |
| deleted_at | DATETIME | NULL | 刪除時間 |

規則：

- `entry_type = 'DIARY'` 時，`annoyance_type_id` 必須為 NULL，`is_solved` 固定為 false。
- `entry_type = 'ANNOYANCE'` 時，`annoyance_type_id` 可略過；有值時必須為有效 lookup。
- Service 依分類 code 與情緒負荷 score 解析 FK；兩者皆可略過，Client 不得傳 lookup ID。
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

- Entry media 使用 private R2 bucket；Database 不保存 public URL。使用者頭貼不接受上傳。
- `object_key` 由 Backend 產生且必須唯一，Client 不得提供或取得此值。
- `media_type` 僅允許 `image`、`audio`、`video`、`drawing`。
- `file_size_bytes` 必須大於 0。
- `audio` 與 `video` 必須保存經 `ffprobe` 驗證的正數 `duration_seconds`；其他類型必須為 NULL。
- 媒體先完成隔離、真實格式解析、重新處理、中繼資料移除與惡意檔案掃描；下載由 Backend 驗證 Entry owner，公開快照則依 Community Post 資格另行授權。

### 3.14 entry_likes（目標由 Community Post 支持取代）

社群貼文按讚。

| 欄位 | 型別 | 約束 | 說明 |
|---|---|---|---|
| id | BIGINT | PK | ID |
| entry_id | BIGINT | FK NOT NULL | 紀錄 ID |
| user_id | BIGINT | FK NOT NULL | 按讚使用者 ID |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | NOT NULL | 更新時間 |

Unique：`entry_id, user_id`

### 3.15 entry_comments（目標由 Community Post 留言取代）

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

### 3.20 psychological_tests（目標重新命名為 Self Exploration）

舊基線心理測驗資源。目標模型不得使用診斷式名稱，並拆為版本化 Self Exploration、Educational Quiz 與 External Resource。

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
- `users` 1 對 1 `user_password_locks`（舊基線；目標移除）
- `monster_groups` 1 對多 `monsters`
- `monsters` 1 對多 `monster_assets`
- `users` 多對多 `monsters`，透過 `user_monsters`
- `users` 1 對多 `user_active_monsters`
- `users` 1 對多 `entries`
- `entries` 1 對多 `entry_media`
- `entries` 1 對多 `entry_likes`（舊基線；目標改由 Community Post 承載）
- `entries` 1 對多 `entry_comments`（舊基線；目標改由 Community Post 承載）
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

Phase 3 annoyance type migration：`database/migrations/20260711_01_add_annoyance_type_codes_and_seed.sql`。既有環境只執行一次；全新環境由 `database/init/01_schema.sql` 直接建立並 seed。Migration seed 明確以 `CURRENT_TIMESTAMP` 寫入 `created_at`、`updated_at`，相容未提供欄位預設值的既有環境。

Phase 3 private entry media migration：`database/migrations/20260711_02_make_entry_media_private.sql`。此 migration 會在 `entry_media` 已有資料時主動中止；既有資料必須先匯出，另行建立經審查的 public URL → private R2 object key 資料 migration，不得直接將 public URL 原值當成 object key。

Phase 3 mood score migration：`database/migrations/20260711_03_make_mood_score_unique.sql`。此 migration 建立 `moods.score` 唯一約束與 `SCORE_1`～`SCORE_5` seed，並以 `CURRENT_TIMESTAMP` 寫入建立及更新時間；若既有分數重複或 code / score 對應衝突會主動中止，必須先審查與清理資料。

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

## 目前 Auth／User API Database Mapping（Historical）

本章以下 mapping 描述 `develop` 現況，只供 Flyway Migration 與回歸測試。v1 不使用 `account`、public avatar、JWT Refresh Token、server password lock 或新 BCrypt hash。

### v1 目標 Mapping

| Use Case | 主要資料 |
|---|---|
| Register | `users.email`、Email verification status、Argon2id `user_credentials`；不建立 `account` |
| Login | `users.email`＋credential hash 或 OAuth provider＋`sub`；建立 `user_sessions` 與 opaque Refresh Token hash |
| Profile | UUID public user identity、private user name、locked birthday、region、eligibility 與 selected owned monster asset |
| Email Change | reauth evidence、pending verified email、old／new notification events 與 session revocation |
| Local Privacy Lock | Database 無 PIN table、hash 或 verify endpoint；只存在 App secure storage |

## Register API Database Mapping

`POST /api/auth/register` writes data to the normalized auth tables:

| API Field | Table | Column | Note |
|---|---|---|---|
| email | users | email | Lowercase normalized before duplicate check |
| userName | users | user_name | Trimmed before persistence |
| password | user_credentials | password_hash | Historical BCrypt baseline；v1 new hash uses Argon2id |

Register API must not store raw passwords, JWT values, or secrets in logs.

## Login API Database Mapping

`POST /api/auth/login` reads data from the normalized auth tables:

| API Field | Table | Column | Note |
|---|---|---|---|
| email | users | email | Lowercase normalized before lookup; deleted users are rejected |
| password | user_credentials | password_hash | Compared with BCrypt `PasswordEncoder.matches` |

Historical Login API returns JWT access and refresh tokens；v1 改為短效 JWT Access 與 opaque Refresh session，任何 Token 都不得寫入 Log。

## User API Database Mapping

`GET /api/users/me` reads the authenticated user's normalized profile data:

| API Field | Table | Column | Note |
|---|---|---|---|
| userId | users | id | Read from authenticated JWT principal, not from client input |
| account | users | account | Deprecated；v1 移除 |
| email | users | email | Read-only in this API |
| userName | users | user_name | Display name |
| birthday | users | birthday | Nullable profile field |
| avatarUrl | users | avatar_url | Deprecated；v1 改為 owned monster asset 關聯 |

`PUT /api/users/me` updates only editable profile columns:

| API Field | Table | Column | Note |
|---|---|---|---|
| userName | users | user_name | Required, max length 80, trimmed before persistence |
| birthday | users | birthday | Nullable `DATE` value |

`PUT /api/users/me/avatar` 是待移除的 historical endpoint：

| API Field | Table | Column | Note |
|---|---|---|---|
| file | users | avatar_url | Deprecated；v1 禁止使用者頭貼上傳 |

User APIs must query or update only non-deleted users and must not accept `userId` or `account` from client input for the current-user profile flow.

## Password Lock API Database Mapping（Deprecated）

`PUT /api/users/me/password-lock` creates or updates the authenticated user's password lock:

| API Field | Table | Column | Note |
|---|---|---|---|
| lockPassword | user_password_locks | lock_password_hash | Stored as BCrypt hash only |
| - | user_password_locks | enabled | Set to `true` when a lock is created or updated |

`POST /api/users/me/password-lock/verify` reads the authenticated user's enabled password lock:

| API Field | Table | Column | Note |
|---|---|---|---|
| lockPassword | user_password_locks | lock_password_hash | Compared with BCrypt `PasswordEncoder.matches` |

本章只描述 historical server PIN。Phase 4.5 移除此 API 與 table；v1 Backend 不得接收、保存或驗證本機 PIN。
