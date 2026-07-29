# Database Init

此目錄放置 MySQL Docker container 第一次建立資料庫時會自動執行的 SQL。

目前檔案：

| 檔案 | 說明 |
|---|---|
| `01_schema.sql` | 建立與 Flyway V1 相同的初始 baseline；Backend 啟動後再套用 V2 以上 migration |

手動 Migration：

| 檔案 | 說明 |
|---|---|
| `../migrations/20260711_01_add_annoyance_type_codes_and_seed.sql` | 既有環境補上 annoyance type code、唯一約束與六筆初始分類；可在 Workbench 重跑 |
| `../migrations/20260711_02_make_entry_media_private.sql` | 將 entry media 改為 private R2 object key 並補上 MIME、大小、時長與 video constraint；可在已完成 migration 的環境重跑 |
| `../migrations/20260711_03_make_mood_score_unique.sql` | 將 mood score 改為唯一約束，並建立 `SCORE_1`～`SCORE_5` 共用 seed |
| `../migrations/20260713_01_seed_missing_annoyance_lookups.sql` | 修復已存在但缺少 Phase 3 annoyance type seed 的既有資料庫 |

正式 Flyway Migration：

| 檔案 | 說明 |
|---|---|
| `../../backend/src/main/resources/db/migration/V1__current_schema_baseline.sql` | 將目前 init schema 固定為不可改寫的 Flyway baseline |
| `../../backend/src/main/resources/db/migration/V2__add_member_state_machine.sql` | 新增會員 UUID、七態狀態機、optimistic version、continuation credential、Audit 與 Outbox |
| `../../backend/src/main/resources/db/migration/V3__add_registration_and_email_verification.sql` | 導入 Email-only 註冊、文件同意、Email 驗證 Token 與持久化限流桶 |

注意事項：

- SQL 只會在 Docker volume 第一次建立時執行。
- 若本機已存在 `mysql_data` volume，修改此目錄 SQL 不會自動套用到既有資料庫。
- 既有環境需依版本順序手動執行尚未套用的 `database/migrations/` script；每支 script 只執行一次。
- `20260711_01` 會先檢查欄位與唯一索引是否已存在，已存在時只補 seed，不會因 duplicate column / duplicate key 中止。
- `20260711_02` 只會在 legacy `entry_media.media_url` 仍存在且 `entry_media` 非空時中止；既有媒體必須另行完成經審查的 private R2 資料 migration。若 schema 已是 `object_key`，可重跑補齊缺漏的欄位、索引與 constraint。
- `20260711_03` 會在 mood score 重複，或既有 1～5 分資料與 `SCORE_1`～`SCORE_5` 對應衝突時中止，不會靜默覆寫既有語意。
- 若新增煩惱送出時出現 `Annoyance category not found`，先查詢 `annoyance_types` 是否存在 `ACADEMIC`、`CAREER`、`LOVE`、`FRIENDSHIP`、`FAMILY`、`OTHER` 六筆 code；缺漏時套用 `20260713_01`。
- 進入正式資料保存階段後，資料庫異動應建立 migration script，不得直接依賴 Docker init SQL。
- Backend 啟動時由 Flyway 驗證並執行 migration；Docker init 建立的非空 V1 資料庫會 baseline 為 V1 後依序套用 V2、V3，真正空資料庫由 Flyway V1 起完整建立。
- 不得把 V2 以上欄位直接合併回 `01_schema.sql`，否則非空 Docker 資料庫 baseline 後會重複執行相同 migration。
