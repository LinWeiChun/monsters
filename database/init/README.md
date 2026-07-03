# Database Init

此目錄放置 MySQL Docker container 第一次建立資料庫時會自動執行的 SQL。

目前檔案：

| 檔案 | 說明 |
|---|---|
| `01_schema.sql` | 建立正規化後的初始資料庫 schema |

注意事項：

- SQL 只會在 Docker volume 第一次建立時執行。
- 若本機已存在 `mysql_data` volume，修改此目錄 SQL 不會自動套用到既有資料庫。
- 進入正式資料保存階段後，資料庫異動應建立 migration script，不得直接依賴 Docker init SQL。
