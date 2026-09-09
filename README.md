# 貘nsters（Monsters）

> 一套面向台灣使用者、以私人情緒記錄與自我照顧為核心的非醫療跨平台系統。

本專案採用 **Flutter + Spring Boot + MySQL** 架構，並以 **AI Assisted Development（AI 輔助開發）** 為核心開發流程。

支援平台：

* Android
* iOS
* Web

目前前端開發與驗收以 **Flutter Web-first** 為主，Android／iOS 仍維持共用程式相容。Web 畫面必須支援瀏覽器視窗即時縮放，並依 Mobile（小於 600px）、Tablet（600px 至 1199px）、Desktop（1200px 以上）流暢切換，不需重新整理頁面。

---

# 目前狀態

- `develop` 已完成 Phase 0 至 Phase 3。
- `feature/phase4` 保留日記功能候選成果，但尚未整合至 `develop`。
- Phase 4 整合完成後，必須先執行「基礎安全與領域模型」階段；完成前暫停 Phase 5 以後功能。
- 第一個對真實使用者開放的版本是台灣限定、正式資料等級的私人核心封閉測試。
- 公開暱稱社群必須等檢舉、封鎖、人工審核、申訴、稽核及特權帳號 MFA 完成後才可開啟；暱稱非唯一且不得用於登入或 owner 判斷。

本專案不是醫療、診斷或治療服務。私人日記、煩惱、媒體、情緒負荷與自我探索結果不會被 AI、關鍵字或人工後台自動分析。第一版不採端對端加密，詳細邊界以 [PROJECT_SPEC](docs/PROJECT_SPEC.md)、[CONTEXT](CONTEXT.md) 與 [ADR](docs/adr/) 為準。

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
├── CONTEXT.md
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
│   ├── TASKS.md
│   └── adr/
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

CONTEXT.md

↓

system_data/ 系統手冊、系統簡介與參考程式

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

docs/DECISIONS.md 與相關 docs/adr/

↓

docs/TASKS.md
```

不得跳過任何步驟。

---

# 建議 Prompt

第一次開始開發時，請對 AI 使用以下指令：

```text
請先閱讀 AGENTS.md。

接著依序閱讀：

CONTEXT.md
system_data/系統手冊
system_data/系統簡介
system_data/參考程式 或 system_data/ 內既有程式
docs/GIT_RULE.md
docs/PROJECT_SPEC.md
docs/DATABASE_SPEC.md
docs/API_SPEC.md
docs/UI_SPEC.md
docs/CODING_STANDARD.md
docs/DECISIONS.md
docs/adr/ 中與任務相關的 ADR
docs/TASKS.md

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
| CONTEXT.md                | 領域共同語言         |
| PROJECT_SPEC.md           | 專案需求規格         |
| DATABASE_SPEC.md          | 資料庫設計          |
| API_SPEC.md               | REST API 規格    |
| UI_SPEC.md                | Flutter UI 規格  |
| CODING_STANDARD.md        | Coding Style   |
| TASKS.md                  | AI 開發任務        |
| docs/adr/                 | 難以逆轉的架構決策      |
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

下表記錄 `develop` 目前可用的環境變數。標為「待淘汰」的設定只供 Phase 4.5 Migration 與回歸測試，不得用於新功能；核准目標值以 `docs/API_SPEC.md` 與 `docs/DECISIONS.md` 為準。

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
| `CORS_ALLOWED_HEADERS` | 後端允許的 request header | `Authorization,Content-Type,Range,X-Session-Transport,X-CSRF-Protection` |
| `CORS_EXPOSED_HEADERS` | 後端回傳可被前端讀取的 header | `Authorization,Accept-Ranges,Content-Length,Content-Range` |
| `CORS_ALLOW_CREDENTIALS` | 是否允許 credentials | `true` |
| `CORS_MAX_AGE` | preflight cache 秒數 | `3600` |
| `JWT_ISSUER` | JWT issuer | `monsters` |
| `JWT_SECRET` | JWT 簽章密鑰 | 空字串，正式環境必須提供 |
| `JWT_ACCESS_TOKEN_EXPIRATION_SECONDS` | v1 Access token 有效秒數 | `600` |
| `JWT_REFRESH_TOKEN_EXPIRATION_SECONDS` | 待淘汰 JWT Refresh token 有效秒數；目標改為 opaque session | `2592000`（30 天，rotation） |
| `SESSION_IDLE_EXPIRATION_SECONDS` | 一般Session閒置期限 | `2592000`（30天） |
| `SESSION_ABSOLUTE_EXPIRATION_SECONDS` | 一般Session絕對期限 | `7776000`（90天） |
| `SESSION_REFRESH_CONCURRENCY_GRACE_SECONDS` | 相同輪替結果並行容忍 | `10` |
| `SESSION_REFRESH_DERIVATION_KEY` | opaque Refresh輪替獨立Secret | 空字串；正式環境至少32-byte |
| `WEB_SESSION_TRUSTED_ORIGIN_PATTERNS` | Web Cookie Session可信Origin pattern | `http://localhost:*,http://127.0.0.1:*`；正式環境只列前端網域 |
| `WEB_SESSION_COOKIE_MAX_AGE_SECONDS` | Web `__Host-monsters-refresh`最長保存秒數 | `7776000`（90天） |
| `REGISTRATION_TERMS_VERSION` | 目前服務條款版本 | 空字串，註冊前必須提供 |
| `REGISTRATION_TERMS_URL` | 目前服務條款 HTTPS URL | 空字串，註冊前必須提供 |
| `REGISTRATION_PRIVACY_VERSION` | 目前隱私權政策版本 | 空字串，註冊前必須提供 |
| `REGISTRATION_PRIVACY_URL` | 目前隱私權政策 HTTPS URL | 空字串，註冊前必須提供 |
| `REGISTRATION_RATE_LIMIT_HASH_KEY` | 註冊／重寄 HMAC 限流 secret | 空字串，註冊前必須提供 |
| `EMAIL_VERIFICATION_PUBLIC_URL` | Flutter Web `/verify-email` 完整 HTTPS URL | 空字串，寄信前必須提供 |
| `SMTP_HOST`、`SMTP_PORT` | Resend SMTP STARTTLS 連線 | `smtp.resend.com`、`587` |
| `SMTP_USERNAME` | Resend SMTP 帳號 | `resend` |
| `RESEND_API_KEY` | Resend API Key，作為 SMTP password | 空字串，僅由環境 Secret 提供 |
| `SMTP_PASSWORD` | 舊版 SMTP password 相容備援 | 空字串 |
| `REGISTRATION_SMTP_FROM` | 已在 Resend 驗證網域的 Email 寄件者 | 空字串 |
| `REGISTRATION_SMTP_ENABLED` | 啟用 SMTP Adapter | `false` |
| `EMAIL_VERIFICATION_WORKER_ENABLED` | 啟用 Email Outbox Worker | `false` |
| `PASSWORD_RESET_PUBLIC_URL` | Flutter Web `/reset-password`完整HTTPS URL | 空字串，密碼重設寄信前必須提供 |
| `PASSWORD_RESET_RATE_LIMIT_HASH_KEY` | 密碼重設Email／IP限流獨立HMAC secret | 未設定時沿用`REGISTRATION_RATE_LIMIT_HASH_KEY`；正式環境建議獨立Secret |
| `PASSWORD_RESET_WORKER_ENABLED` | 啟用Password Reset Outbox Worker | `false` |
| `PASSWORD_RESET_MAX_DELIVERY_ATTEMPTS` | 寄送失敗前最大嘗試次數 | `5` |
| `PASSWORD_RESET_SMTP_SUBJECT` | 密碼重設信主旨 | `貘nsters 密碼重設` |
| `UNVERIFIED_MEMBER_CLEANUP_ENABLED` | 啟用七日空會員清理 | `false` |
| `MINOR_NOTICE_VERSION`、`MINOR_NOTICE_URL` | 未成年人說明版本與 HTTPS URL | 空字串 |
| `GUARDIAN_CONSENT_VERSION`、`GUARDIAN_CONSENT_URL` | 監護人同意文件版本與 HTTPS URL | 空字串 |
| `PUBLIC_NICKNAME_DISCLOSURE_VERSION`、`PUBLIC_NICKNAME_DISCLOSURE_URL` | 公開暱稱揭露版本與 HTTPS URL | 空字串 |
| `GUARDIAN_ACTION_PUBLIC_URL` | 監護人短效單次連結頁 HTTPS URL | 空字串 |
| `R2_ACCOUNT_ID` | Cloudflare R2 Account ID | 空字串，使用 R2 前必須提供 |
| `R2_ACCESS_KEY_ID` | R2 S3 Access Key ID | 空字串，使用 R2 前必須提供 |
| `R2_SECRET_ACCESS_KEY` | R2 S3 Secret Access Key | 空字串，使用 R2 前必須提供 |
| `R2_BUCKET` | 待淘汰的公開頭貼 bucket；新功能不得使用 | 空字串 |
| `R2_PUBLIC_BASE_URL` | 待淘汰的公開頭貼 URL；新功能不得使用 | 空字串 |
| `R2_ENTRY_MEDIA_BUCKET` | Private entry media bucket | 空字串，煩惱媒體上傳前必須提供且不得開啟 public access |
| `R2_ENTRY_MEDIA_KEY_PREFIX` | Private entry media object prefix | `entries/media` |
| `FFPROBE_PATH` | ffprobe executable | `ffprobe` |
| `FFPROBE_TIMEOUT_SECONDS` | 媒體時長檢查 timeout 秒數 | `10` |
| `MULTIPART_MAX_FILE_SIZE` | Backend 單檔 multipart 全域上限 | `50MB` |
| `MULTIPART_MAX_REQUEST_SIZE` | Backend multipart request 全域上限 | `60MB` |

## 測試與建置

前端：

```bash
cd frontend
flutter analyze
flutter test
flutter build web
```

Web 本機開發預設使用固定網址 `http://localhost:5050`：

```bash
cd frontend
GOOGLE_CLIENT_ID=your-web-client-id.apps.googleusercontent.com \
  ./tool/run_web_local.sh
```

開發者可直接拖曳瀏覽器寬度檢查 RWD；主要驗收寬度為 390、600、900、1024、1200、1440 與 1920px。共用 breakpoint 與內容寬度規則定義於 `frontend/lib/layout/responsive_layout.dart`，頁面不得自行建立互相衝突的切換值。

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
