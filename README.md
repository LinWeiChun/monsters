# 貘nsters（Monsters）

> 一套提供使用者抒發情緒、記錄日記、管理煩惱、社群互動、怪獸蒐集與心理紓壓功能的跨平台系統。

本專案採用 **Flutter + Spring Boot + MySQL** 架構，並以 **AI Assisted Development（AI 輔助開發）** 為核心開發流程。

支援平台：

* Android
* iOS
* Web

---

# 專案特色

* Flutter 跨平台開發
* Spring Boot REST API
* MySQL 資料庫
* Riverpod 狀態管理
* Clean Architecture
* AI Agent 協助開發（Codex / Cursor / GitHub Copilot Agent）
* 完整需求、API、資料庫與 UI 規格文件

---

# 技術架構

```text
Flutter
(Android / iOS / Web)

        │

 REST API

        │

Spring Boot

        │

 MySQL
```

---

# Repository 結構

```text
monsters/
│
├── AGENTS.md
├── README.md
├── .gitignore
├── .github/
│
├── docs/
│   ├── GIT_RULE.md
│   ├── PROJECT_SPEC.md
│   ├── DATABASE_SPEC.md
│   ├── API_SPEC.md
│   ├── UI_SPEC.md
│   ├── CODING_STANDARD.md
│   ├── DECISIONS.md
│   └── TASKS.md
│
├── frontend/
│
├── backend/
│
├── database/
│
├── icon/
│
├── log/
│   ├── CHANGE_LOG.md
│   ├── CHANGE_HISTORY.csv
│   └── CHANGE_HISTORY.xlsx
│
└── system_data/              # 舊系統參考程式、素材與資料結構，僅供新版開發參考
```

---

# AI 開發流程

所有 AI Agent（Codex、Cursor、GitHub Copilot Agent…）開始工作前，**必須先閱讀文件**。

閱讀順序：

```text
AGENTS.md

↓

docs/GIT_RULE.md

↓

docs/PROJECT_SPEC.md

↓

docs/DATABASE_SPEC.md

↓

docs/API_SPEC.md

↓

docs/UI_SPEC.md

↓

docs/CODING_STANDARD.md

↓

docs/DECISIONS.md

↓

docs/TASKS.md

↓

system_data/ 系統手冊、系統簡介與參考程式
```

不得跳過任何步驟。

---

# 建議 Prompt

第一次開始開發時，請對 AI 使用以下指令：

```text
請先閱讀 AGENTS.md。

接著依序閱讀：

docs/GIT_RULE.md
docs/PROJECT_SPEC.md
docs/DATABASE_SPEC.md
docs/API_SPEC.md
docs/UI_SPEC.md
docs/CODING_STANDARD.md
docs/DECISIONS.md
docs/TASKS.md
system_data/系統手冊
system_data/系統簡介
system_data/參考程式 或 system_data/ 內既有程式

閱讀完成後，確認目前應執行的 Task。

依照 AGENTS.md 規範開始實作。

不得跳過任何 Phase。

每完成一項 Task 必須：

1. 檢查 `system_data/` 是否有可參考的舊系統流程、程式或素材。
2. 將舊系統參考內容轉換為新版架構可接受的設計，不得直接照搬。
3. 更新 CHANGE_LOG.md。
4. 更新 CHANGE_HISTORY.csv（或 CHANGE_HISTORY.xlsx）。
5. 更新相關文件。
6. 依照 AGENTS.md 回覆格式產生工作報告，並說明本次 `system_data/` 參考結果。
```

---

# Git Flow

Branch：

```text
main

develop

feature/phase<n>

feature/phase<n>-<module>

fix/<module>

refactor/<module>

docs/<module>
```

Commit：

```text
feat:

fix:

refactor:

docs:

test:

style:

chore:
```

---

# 文件說明

| 文件                        | 用途             |
| ------------------------- | -------------- |
| AGENTS.md                 | AI 開發規範（最高優先權） |
| PROJECT_SPEC.md           | 專案需求規格         |
| DATABASE_SPEC.md          | 資料庫設計          |
| API_SPEC.md               | REST API 規格    |
| UI_SPEC.md                | Flutter UI 規格  |
| CODING_STANDARD.md        | Coding Style   |
| TASKS.md                  | AI 開發任務        |
| CHANGE_LOG.md             | 專案異動紀錄         |
| CHANGE_HISTORY.csv / xlsx | 專案異動歷程         |

---

# 開發規則

所有 AI Agent 必須遵守：

* 不得自行新增需求。
* 不得修改資料表。
* 不得修改 API。
* 不得修改需求文件。
* 不得跳過 TASKS。
* 每次完成任務必須同步更新文件。
* 每次完成任務必須更新 Change Log。
* 若需求衝突，必須停止並詢問使用者。

---

# 如何開始開發

## 必要環境

| 工具 | 版本 / 說明 |
|------|-------------|
| Git | 用於分支與版本管理 |
| Flutter | 依 `docs/CODING_STANDARD.md` 規範使用穩定版 |
| Dart | 隨 Flutter SDK 安裝 |
| JDK | JDK 18 |
| Docker Desktop | 用於啟動 MySQL 與 Backend |

確認工具版本：

```bash
git --version
flutter --version
java -version
docker --version
docker compose version
```

Windows PowerShell 可暫時指定 JDK 18：

```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-18.0.2"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
```

## 取得專案

```bash
git clone <repository-url>
cd monsters
git checkout develop
```

依照 Git 規範，每個 Phase 開始前先從 `develop` 建立 Phase 整合分支：

```bash
git checkout -b feature/phase<n>
```

Phase 內的每個 Task 再從對應 Phase 分支建立獨立分支：

```bash
git checkout feature/phase<n>
git checkout -b feature/phase<n>-<module>
```

文件修改請使用同樣的 Phase 前綴：

```bash
git checkout -b docs/phase<n>-<module>
```

Task Pull Request 先合併至 `feature/phase<n>`；Phase 全部完成並通過整合測試後，再將 `feature/phase<n>` 合併至 `develop`。

## 前端執行

```bash
cd frontend
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## 後端執行

```bash
cd backend
./gradlew test
./gradlew bootRun
```

Windows PowerShell：

```powershell
cd backend
.\gradlew.bat test
.\gradlew.bat bootRun
```

後端預設使用 `dev` profile。若需切換 profile：

```powershell
$env:SPRING_PROFILES_ACTIVE = "dev"
```

## Docker Compose 執行

從 Repository 根目錄執行：

```bash
docker compose config
docker compose up --build
```

服務位置：

```text
Backend: http://localhost:8080
MySQL: localhost:3306
```

停止服務：

```bash
docker compose down
```

若需要連資料庫，預設設定如下：

| 項目 | 預設值 |
|------|--------|
| Database | `monsters` |
| Username | `monsters` |
| Password | `monsters` |
| Host | `localhost` |
| Port | `3306` |

## 環境變數

| 變數 | 用途 | 預設值 |
|------|------|--------|
| `SPRING_PROFILES_ACTIVE` | Spring Boot profile | `dev` |
| `DB_URL` | JDBC 連線字串 | `jdbc:mysql://localhost:3306/monsters?useSSL=false&serverTimezone=Asia/Taipei&allowPublicKeyRetrieval=true` |
| `DB_USERNAME` | MySQL 使用者 | `monsters` |
| `DB_PASSWORD` | MySQL 密碼 | `monsters` |
| `MYSQL_DATABASE` | Docker MySQL database | `monsters` |
| `MYSQL_USER` | Docker MySQL 使用者 | `monsters` |
| `MYSQL_PASSWORD` | Docker MySQL 密碼 | `monsters` |
| `MYSQL_ROOT_PASSWORD` | Docker MySQL root 密碼 | `root` |
| `MYSQL_PORT` | 對外 MySQL port | `3306` |
| `BACKEND_PORT` | 對外 Backend port | `8080` |
| `CORS_ALLOWED_ORIGIN_PATTERNS` | 後端允許的前端來源 pattern | `http://localhost:*,http://127.0.0.1:*` |
| `CORS_ALLOWED_METHODS` | 後端允許的 HTTP method | `GET,POST,PUT,PATCH,DELETE,OPTIONS` |
| `CORS_ALLOWED_HEADERS` | 後端允許的 request header | `Authorization,Content-Type` |
| `CORS_EXPOSED_HEADERS` | 後端回傳可被前端讀取的 header | `Authorization` |
| `CORS_ALLOW_CREDENTIALS` | 是否允許 credentials | `true` |
| `CORS_MAX_AGE` | preflight cache 秒數 | `3600` |
| `JWT_ISSUER` | JWT issuer | `monsters` |
| `JWT_SECRET` | JWT 簽章密鑰 | 空字串，正式環境必須提供 |
| `JWT_ACCESS_TOKEN_EXPIRATION_SECONDS` | Access token 有效秒數 | `3600` |
| `JWT_REFRESH_TOKEN_EXPIRATION_SECONDS` | Refresh token 有效秒數 | `1209600` |
| `R2_ACCOUNT_ID` | Cloudflare R2 Account ID | 空字串，使用 R2 前必須提供 |
| `R2_ACCESS_KEY_ID` | R2 S3 Access Key ID | 空字串，使用 R2 前必須提供 |
| `R2_SECRET_ACCESS_KEY` | R2 S3 Secret Access Key | 空字串，使用 R2 前必須提供 |
| `R2_BUCKET` | Public avatar bucket | 空字串，頭貼上傳前必須提供 |
| `R2_PUBLIC_BASE_URL` | Public avatar URL base | 空字串，頭貼上傳前必須提供 |
| `R2_ENTRY_MEDIA_BUCKET` | Private entry media bucket | 空字串，煩惱媒體上傳前必須提供且不得開啟 public access |
| `R2_ENTRY_MEDIA_KEY_PREFIX` | Private entry media object prefix | `entries/media` |
| `FFPROBE_PATH` | ffprobe executable | `ffprobe` |
| `FFPROBE_TIMEOUT_SECONDS` | 媒體時長檢查 timeout 秒數 | `10` |

## 測試與建置

前端：

```bash
cd frontend
flutter analyze
flutter test
flutter build web
```

後端：

```bash
cd backend
./gradlew build
```

Windows PowerShell：

```powershell
cd backend
.\gradlew.bat build
```

## 完成後

提交前請確認：

```bash
git status
git diff --check
```

提交格式需符合 Conventional Commits：

```bash
git add <files>
git commit -m "feat(scope): 完成任務說明"
git push origin <branch>
```

---

# system_data 使用規範

`system_data/` 用於存放舊系統參考程式、專案設定、圖片素材與資料結構參考。

此目錄的用途是協助 AI 與開發者理解舊系統的：

- 功能流程
- 畫面互動
- 資料欄位
- API 行為
- 商業邏輯
- 命名習慣
- 可重用素材

使用限制：

- 不得直接複製舊程式到正式專案架構。
- 不得直接沿用舊系統中不符合新版規範的命名、架構或錯誤設計。
- 不得任意修改、刪除、搬移或格式化 `system_data/` 內容。
- 不得將金鑰、密碼、憑證、jar、metadata、build artifact 或非必要雜檔納入版本控制。
- 若需正式使用舊素材，必須重新整理命名、路徑、授權與資產規格。

當 `system_data/` 與正式文件衝突時，以正式文件為準。

---

# License

本專案僅供學術研究、專題開發及授權用途。

未經授權，不得商業使用。

---

# 維護者

Developer

WeiChun Lin

AI Development

OpenAI Codex
