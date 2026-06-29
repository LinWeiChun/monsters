# AGENTS.md

# 貘nsters AI 開發規範

本專案使用 Codex、Cursor Agent、GitHub Copilot Agent 或其他 AI Coding Agent 作為輔助開發工具。

AI 在產生、修改、刪除任何程式碼或文件以前，必須先閱讀並遵守本文件。

---

## 一、專案資訊

### 1.1 專案名稱

貘nsters

### 1.2 專案目的

建立一套提供使用者抒發情緒、記錄日記、管理煩惱、社群互動、怪獸蒐集與心理紓壓功能的跨平台系統。

支援平台：

- Android App
- iOS App
- Web 瀏覽器

### 1.3 文件說明

本專案所有需求、設計與開發規範皆依本專案文件管理。

詳細閱讀順序請參考：
「十六、需求來源」。

不得自行增加未定義需求。

---

## 二、系統架構

本專案採用前後端分離架構。

```text
Flutter / Dart
(Android / iOS / Web)
        ↓
REST API
        ↓
Java / Spring Boot
        ↓
MySQL
```

### 2.1 架構限制

- Flutter 不得直接存取 MySQL。
- 所有資料存取必須透過 REST API。
- 後端不得直接回傳 Entity 給前端。
- 前端不得將商業邏輯寫在 Widget 內。
- 後端 Controller 不得包含商業邏輯。

---

## 三、專案資料夾建議

### 3.1 Flutter

```text
frontend/
└── lib/
    ├── app/
    ├── core/
    │   ├── constants/
    │   ├── errors/
    │   ├── network/
    │   ├── router/
    │   └── utils/
    ├── features/
    │   ├── auth/
    │   ├── user/
    │   ├── annoyance/
    │   ├── diary/
    │   ├── history/
    │   ├── monster/
    │   ├── community/
    │   └── interactive/
    └── main.dart
```

每個 `features/<module>/` 建議包含：

```text
data/
  models/
  repositories/
domain/
  entities/
  repositories/
  usecases/
presentation/
  providers/
  screens/
  widgets/
```

### 3.2 Spring Boot

```text
backend/
└── src/main/java/com/monsters/
    ├── config/
    ├── controller/
    ├── dto/
    ├── entity/
    ├── exception/
    ├── repository/
    ├── service/
    └── util/
```

---

## 四、程式撰寫原則

### 4.1 後端分層

```text
Controller → Service → Repository → Database
```

Controller 只負責：

- 接收 Request
- 驗證基本 Request 格式
- 呼叫 Service
- 回傳 Response

Service 只負責：

- 商業邏輯
- 權限檢查
- 資料狀態檢查
- Transaction 控制

Repository 只負責：

- 資料查詢
- 資料新增
- 資料修改
- 資料刪除

### 4.2 前端分層

```text
Screen / Widget → Provider → UseCase / Repository → API Service
```

Widget 不得直接呼叫 API。

---

## 五、Flutter 開發規範

使用下列套件與設計方式：

- State Management：Riverpod
- HTTP Client：Dio
- Router：go_router
- Local Storage：SharedPreferences
- JSON Serialization：json_serializable

### 5.1 跨平台規範

Flutter 程式必須同時考慮：

- Android
- iOS
- Web

不得使用只支援單一平台的 API，除非已建立平台判斷與替代方案。

### 5.2 UI 規範

- 畫面應符合《系統手冊》與 `UI_SPEC.md`。
- 手機版優先，但 Web 必須有基本可用版面。
- Web 版最大內容寬度建議限制，避免元件過度拉伸。
- 共用元件應抽出為 Widget，不得重複撰寫。

---

## 六、資料庫規範

資料庫使用 MySQL。

所有 Table 必須包含：

- `id`
- `created_at`
- `updated_at`

若業務情境需要刪除資料，優先使用 soft delete：

- `deleted_at`
- `is_deleted`

所有 Foreign Key 必須建立合理關聯。

資料表與欄位命名全部使用 `snake_case`。

不得在未確認需求前修改資料表結構。

---

## 七、API 規範

所有 API 使用 RESTful 設計。

| Method | 用途 |
|---|---|
| GET | 查詢 |
| POST | 新增 |
| PUT | 修改 |
| PATCH | 局部修改狀態 |
| DELETE | 刪除或軟刪除 |

### 7.1 統一 Response 格式

```json
{
  "success": true,
  "message": "",
  "data": {}
}
```

### 7.2 錯誤 Response 格式

```json
{
  "success": false,
  "message": "錯誤訊息",
  "data": null
}
```

### 7.3 API 限制

- 不得直接回傳 Entity。
- 必須使用 DTO。
- 必須驗證輸入資料。
- 必須處理例外。
- 需要登入的 API 必須驗證 Token。

---

## 八、命名規則

| 類型 | 規則 | 範例 |
|---|---|---|
| Java Class | UpperCamelCase | `UserController` |
| Dart Class | UpperCamelCase | `MonsterRepository` |
| Variable | lowerCamelCase | `userName` |
| Constant | UPPER_SNAKE_CASE | `DEFAULT_PAGE_SIZE` |
| Flutter 檔名 | snake_case.dart | `monster_detail_screen.dart` |
| API Path | kebab 或 snake_case，需全專案一致 | `/api/annoyances` |
| Database | snake_case | `personal_info` |

---

## 九、Git Commit 規範

使用 Conventional Commits。

```text
feat: 新增功能
fix: 修正錯誤
refactor: 重構
docs: 文件更新
test: 測試
chore: 建置或設定調整
style: 格式調整
```

Branch 命名：

```text
feature/<module>
fix/<module>
refactor/<module>
docs/<module>
```

---

## 十、開發順序

依照 `TASKS.md` 執行。

不得跳過尚未完成的功能。

每完成一項功能後，必須完成：

1.API
2.Entity
3.DTO
4.Repository
5.Service
6.Controller
7.Database Migration（若有）
8.Flutter Model
9.Flutter Repository
10.Provider
11.UI
12.Error Handling
13.Test
14.Document
15.Change Log

---

## 十一、程式品質

AI 產出的程式必須符合：

- 可編譯
- 可執行
- 不留下 TODO、FIXME 或空實作
- 加入必要註解
- 完整錯誤處理
- 驗證輸入資料
- 遵守 SOLID
- 避免重複程式碼
- 避免硬編碼設定值
- 避免把密碼、Token、金鑰寫死在程式碼中

---

## 十二、測試規範

每個模組至少包含：

### 後端

- Unit Test
- Service Test
- Controller Test
- Repository Test（需要時）

### 前端

- Unit Test
- Widget Test
- Provider Test

### API

- 正常流程
- 欄位缺漏
- 權限不足
- 找不到資料
- 資料狀態不合法

---

## 十三、安全規範

- 密碼必須雜湊，不得明文儲存。
- Token 必須有期限。
- 個人資料、日記、煩惱內容不得在未授權情況下被其他使用者讀取。
- 社群分享內容必須依分享狀態控制公開與否。
- 密碼鎖不得明文儲存。
- 上傳檔案必須檢查副檔名、大小與 MIME Type。

---

## 十四、禁止事項

AI 不得：

AI 不得：

- 自行增加功能
- 自行刪除需求
- 自行修改 API
- 自行修改資料表
- 自行覆蓋使用者修改
- 在文件未定義時自行推測

若文件未定義，必須先提出問題。

---

## 十五、文件位置

所有專案規格文件皆放置於 `docs/` 資料夾。

```
docs/
├── PROJECT_SPEC.md         # 專案需求規格
├── DATABASE_SPEC.md        # 資料庫設計規格
├── API_SPEC.md             # REST API 規格
├── UI_SPEC.md              # Flutter UI 規格
├── CODING_STANDARD.md      # 程式撰寫規範
└── TASKS.md                # AI 開發任務清單
```

其他重要文件：

```
AGENTS.md                   # AI 工作規範（最高優先權）
README.md                   # 專案說明
CHANGE_LOG.md               # 專案異動紀錄
CHANGE_HISTORY.xlsx         # 專案異動歷程（Excel）
CHANGE_HISTORY.csv          # 專案異動歷程（CSV，可選）
```

---

## 十六、需求來源

AI 在開發任何功能時，必須依照下列優先順序閱讀文件：

1. AGENTS.md
2. docs/PROJECT_SPEC.md
3. docs/DATABASE_SPEC.md
4. docs/API_SPEC.md
5. docs/UI_SPEC.md
6. docs/CODING_STANDARD.md
7. docs/TASKS.md
8. 《系統手冊》
9. 《系統簡介》
10. 使用者最新指示

若多份文件內容互相衝突：

* 不得自行推測。
* 必須停止實作並回報衝突內容。
* 必須提出建議方案，等待使用者確認後才能繼續。

---

## 十七、文件同步規範

若本次修改涉及以下內容，AI 必須同步更新對應文件。

| 修改內容            | 必須同步更新                                                  |
| --------------- | ------------------------------------------------------- |
| 新增功能            | docs/PROJECT_SPEC.md、docs/TASKS.md                      |
| API 修改          | docs/API_SPEC.md                                        |
| 資料表修改           | docs/DATABASE_SPEC.md                                   |
| UI 修改           | docs/UI_SPEC.md                                         |
| Coding Style 修改 | docs/CODING_STANDARD.md                                 |
| 開發流程修改          | AGENTS.md                                               |
| 完成任務            | CHANGE_LOG.md、CHANGE_HISTORY.xlsx（或 CHANGE_HISTORY.csv） |

不得只修改程式碼而未同步更新文件。

---

## 十八、AI 啟動流程

AI 每次開始工作時，必須依序執行：

1. 閱讀 AGENTS.md。
2. 閱讀 docs/PROJECT_SPEC.md。
3. 閱讀 docs/DATABASE_SPEC.md。
4. 閱讀 docs/API_SPEC.md。
5. 閱讀 docs/UI_SPEC.md。
6. 閱讀 docs/CODING_STANDARD.md。
7. 閱讀 docs/TASKS.md。
8. 確認目前要執行的 Task。
9. 開始實作。
10. 完成後更新 CHANGE_LOG.md 與 CHANGE_HISTORY.xlsx（或 CHANGE_HISTORY.csv）。
11. 回報本次修改內容。

---

## 十九、版本管理

版本號採用 Semantic Version。

MAJOR.MINOR.PATCH

例如

1.0.0

1.0.1

1.1.0

2.0.0

每次完成一個 Phase

更新

RELEASE_NOTE.md

---

# 二十、AI 回覆格式

AI 每完成一項 Task 或回應使用者需求時，必須依照下列格式回覆。

## 20.1 工作完成報告

每次回覆至少包含：

### 一、本次完成內容

說明本次完成的功能、修正或文件更新。

### 二、修改檔案

列出所有修改的檔案。

例如：

```text
backend/controller/AuthController.java
backend/service/AuthService.java
frontend/lib/features/auth/login_screen.dart
docs/API_SPEC.md
```

### 三、新增檔案

列出所有新增的檔案。

### 四、刪除檔案

若有刪除檔案，必須列出原因。

### 五、Migration

若涉及資料庫：

* 是否新增 Migration
* Migration 名稱
* Migration 說明

若沒有：

```text
無
```

### 六、API

列出：

* 新增 API
* 修改 API
* 移除 API

### 七、Database

說明：

* Table
* Column
* Index
* Constraint

是否異動。

### 八、文件更新

說明同步更新了哪些文件。

例如：

```text
docs/API_SPEC.md

docs/PROJECT_SPEC.md

CHANGE_LOG.md
```

### 九、測試方式

說明：

* 如何執行
* 如何驗證
* 如何測試

### 十、Commit 建議

例如：

```text
feat(auth): 完成會員登入功能
```

### 十一、待確認事項

若有未定義需求，必須列出。

不得自行猜測。

---

# 二十一、禁止產生未完成程式碼

AI 不得產生：

* TODO
* FIXME
* HACK
* XXX
* throw UnsupportedOperationException
* return null（非必要情況）
* 空 Method
* 空 Class
* Dead Code
* 未使用 Import
* 未使用 Variable
* 未完成的 Interface

若功能尚未完成，

必須先詢問使用者，

不得留下未完成程式。

---

# 二十二、Logging 規範

## 後端

統一使用：

SLF4J

不得使用：

```java
System.out.println()
```

所有例外必須記錄 Log。

重要事件必須記錄：

* Login
* Logout
* Register
* Error
* Permission Denied
* API Exception

不得記錄：

* Password
* Token
* 個人隱私資料

---

## Flutter

統一使用 Logger。

不得大量使用：

```dart
print()
```

Release Mode 不得輸出 Debug Log。

---

# 二十三、Exception 規範

不得使用：

```java
catch (Exception e)
```

應建立：

* Global Exception Handler
* Custom Exception
* Business Exception
* Validation Exception

所有 Exception 必須回傳統一格式：

```json
{
  "success": false,
  "message": "錯誤訊息",
  "data": null
}
```

不得將 Stack Trace 回傳給前端。

Exception 必須記錄 Log。

---

# 二十四、SQL 與相依套件規範

## SQL 規範

禁止：

```sql
SELECT *
```

禁止：

大量 Native SQL。

優先使用：

* Spring Data JPA
* JpaRepository
* Specification

若未來導入 QueryDSL，

優先使用 QueryDSL。

所有 SQL 必須：

* 使用 Index
* 避免 N+1 Query
* 避免重複查詢
* 避免 Full Table Scan

---

## 第三方套件

AI 不得自行新增第三方套件。

若需新增，

必須先說明：

1. 套件用途
2. 是否有官方替代方案
3. 是否已有現有套件可完成
4. 對專案影響
5. 是否需修改授權(License)

取得使用者同意後，

方可新增。
