# Database Init

此目錄放置 MySQL Docker container 第一次建立資料庫時會自動執行的 SQL。

目前檔案：

| 檔案 | 說明 |
|---|---|
| `01_schema.sql` | 建立正規化後的初始資料庫 schema |

手動 Migration：

| 檔案 | 說明 |
|---|---|
| `../migrations/20260711_01_add_annoyance_type_codes_and_seed.sql` | 既有環境補上 annoyance type code、唯一約束與六筆初始分類 |

注意事項：

- SQL 只會在 Docker volume 第一次建立時執行。
- 若本機已存在 `mysql_data` volume，修改此目錄 SQL 不會自動套用到既有資料庫。
- 既有環境需依版本順序手動執行尚未套用的 `database/migrations/` script；每支 script 只執行一次。
- 進入正式資料保存階段後，資料庫異動應建立 migration script，不得直接依賴 Docker init SQL。
