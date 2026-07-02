# 專案異動紀錄

本文件用於記錄貘nsters 專案每次由 AI Coding Agent 或開發者完成的檔案異動。

AI 每次完成任務後，必須新增一筆紀錄，並同步更新 `CHANGE_HISTORY.csv` 或 `CHANGE_HISTORY.xlsx`。

新增 Log 紀錄前，必須先檢查既有 Log 日期；若存在超過一個月的紀錄，需先刪除過期紀錄，再新增本次紀錄。

---

## 紀錄格式

```markdown
## YYYY-MM-DD HH:mm

Task
TASK-XXX 任務名稱

修改人
Codex / Cursor Agent / GitHub Copilot Agent / Developer

### 本次完成

- 說明本次完成內容

### 新增

- path/to/new_file

### 修改

- path/to/modified_file

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- 說明如何測試

### Commit 建議

```text
feat(scope): 說明本次異動
```

### 備註 / 待確認事項

- 無
```

---

## 2026-07-02 09:37

Task
DOC-009 merge system_data reference to develop

靽格鈭?
Codex

### ?祆活摰?

- 撠? `docs/system-data-reference` merge ??`develop`嚗? merge commit 靽?????
- 靘蝙?刻????蔥??`develop` ?? local branch嚗??芾 merge `main`嚗?蝚血? GIT_RULE.md??
- 靽格?頂蝯梁?撘?獢??空白問題，清理 trailing whitespace 與 EOF 空白。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限，未發現超過一個月紀錄。

### ?啣?

- ??

### 靽格

- `system_data/` 部分舊參考程式檔
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### ?芷

- ??

### Migration

- ??

### API

- ??

### Database

- ??

### 皜祈岫

- `git branch --no-merged develop`
- `git diff --check HEAD^ HEAD`
- `git status --short --branch`

### Commit 撱箄降

```text
chore(git): 合併 system_data 參考資料
```

### ?酉 / 敺Ⅱ隤???

- `main` 仍顯示為未合併至 `develop`，但依 GIT_RULE.md 禁止執行 `git merge main`，本次未處理。

---
## 2026-07-02 09:10

Task
DOC-008 system_data 選擇性追蹤程式與圖片

變更者
Codex

### 本次完成

- 依使用者要求重新將 `system_data/` 納入 Git，但只追蹤程式檔案、專案設定檔與圖片素材。
- 調整 `.gitignore` 為白名單規則，預設忽略 `system_data/**`，再放行 source、Flutter/Android/iOS/Windows 專案設定與圖片格式。
- 刪除 `system_data/` 內不需推上 Git 的 PDF、docx、mp4、txt 雜檔、jks、jar、metadata、README 等非程式或非圖片資料，共 15 個檔案。
- 更新 README 與 UI 規格，使文件與「保留程式檔案及圖片資料」規則一致。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限；目前無超過一個月紀錄，未刪除過期 Log。

### 新增

- `system_data/` 內程式檔案、專案設定檔與圖片素材

### 修改

- `.gitignore`
- `README.md`
- `docs/UI_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- `system_data/` 內非程式與非圖片資料 15 個檔案

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- `git diff --check`
- 檢查 `system_data/` 剩餘檔案副檔名
- 檢查 `git status --ignored -- system_data`

### Commit 建議

```text
docs(system-data): 追蹤舊系統程式與圖片資料
```

### 備註 / 待確認事項

- `system_data/` 僅供舊系統參考；正式新版程式仍以 `frontend/`、`backend/`、`database/` 為準。

---

## 2026-07-02 09:02

Task
DOC-007 system_data 舊系統參考文件化

靽格鈭?
Codex

### ?祆活摰?

- 參考 `system_data` 舊後端 Entity，整理新版資料庫可採用與需調整的欄位、關聯與命名原則。
- 參考 `system_data` 舊 Flutter 程式，整理新版 UI 可採用的畫面流程、互動方式與不得沿用的實作方式。
- 將 `system_data/` 設定為 Git 不追蹤，並保留其本機參考用途說明。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限；目前無超過一個月紀錄，未刪除過期 Log。

### ?啣?

- 無

### 靽格

- `.gitignore`
- `README.md`
- `docs/DATABASE_SPEC.md`
- `docs/UI_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### ?芷

- `system_data/四技第111405組-貘nsters APP-系統手冊.pdf`（僅自 Git 索引移除，保留本機檔案）
- `system_data/四技第111405組-貘nsters APP-系統簡介.pdf`（僅自 Git 索引移除，保留本機檔案）

### Migration

- 無

### API

- 無

### Database

- 文件補充舊系統資料庫參考與新版調整原則，未修改實體資料庫。

### 皜祈岫

- `git diff --check`
- `git status --short --ignored -- system_data`

### Commit 撱箄降

```text
docs(system-data): 補充舊系統參考規範
```

### ?酉 / 敺Ⅱ隤???

- `system_data/` 只作為本機參考資料，不再納入 Git 追蹤。

---

## 2026-07-01 15:14

Task
TASK-011 建立 Security / JWT 基礎設定

修改人
Codex

### 本次完成

- 新增 Spring Security starter。
- 新增 `SecurityConfig`，設定 Stateless session、停用 CSRF、啟用 CORS、開放 Auth API 並保護 `/api/**`。
- 新增 `SecurityExceptionHandler`，統一輸出 401 / 403 `ApiResponse<Void>`。
- 新增 `JwtProperties`，集中管理 JWT issuer、secret 與 token 有效時間設定。
- 新增 `BCryptPasswordEncoder` Bean。
- 新增 `SecurityConfigTest`，驗證 JWT 設定綁定、BCrypt、Auth API 匿名存取與受保護 API 401 回應。
- 更新 README、Backend README、`docs/API_SPEC.md` 與 `docs/TASKS.md`。
- 新增 Log 前已檢查保存期限，現有 Log 未超過一個月，無需刪除。

### 新增

- `backend/src/main/java/com/monsters/common/security/JwtProperties.java`
- `backend/src/main/java/com/monsters/common/security/SecurityConfig.java`
- `backend/src/main/java/com/monsters/common/security/SecurityExceptionHandler.java`
- `backend/src/test/java/com/monsters/common/security/SecurityConfigTest.java`

### 修改

- `README.md`
- `backend/README.md`
- `backend/build.gradle`
- `backend/src/main/resources/application.yml`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 新增 Security 基礎規則：Auth API 允許匿名，其餘 `/api/**` 需驗證。
- 未新增業務 API endpoint。

### Database

- 無

### 測試

- `.\gradlew.bat test`
- `.\gradlew.bat build`
- `git diff --check`

### Commit 建議

```text
feat(security): 建立 security jwt 基礎設定
```

### 備註 / 待確認事項

- 正式環境必須設定 `JWT_SECRET`。
- 本 Task 未導入額外 JWT 第三方套件，token 產生與驗證會在 Auth API Task 實作。

---

## 2026-07-01 15:03

Task
DOC-006 停止追蹤本機 dev 設定檔

修改人
Codex

### 本次完成

- 將 `backend/src/main/resources/application-dev.yml` 加入 `.gitignore`。
- 使用 `git rm --cached` 將 `application-dev.yml` 從 Git index 移除，保留本機檔案。
- 新增 Log 前已檢查保存期限，現有 Log 未超過一個月，無需刪除。

### 新增

- 無

### 修改

- `.gitignore`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- `backend/src/main/resources/application-dev.yml`（僅停止 Git 追蹤，本機檔案保留）

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- `git status --short --ignored -- backend/src/main/resources/application-dev.yml`
- `git diff --check`

### Commit 建議

```text
chore(config): 停止追蹤 dev application 設定
```

### 備註 / 待確認事項

- 本機 `application-dev.yml` 已被 `.gitignore` 忽略，可保留本機資料庫帳密。

---

## 2026-07-01 14:48

Task
TASK-010 建立 CORS 設定

修改人
Codex

### 本次完成

- 新增後端 `CorsConfig`，將 CORS 設定套用於 `/api/**`。
- 新增 `CorsProperties`，由 `app.cors.*` 與環境變數集中管理允許來源、methods、headers、credentials 與 max age。
- 新增 `CorsConfigTest`，驗證設定綁定、允許本機來源與拒絕未授權來源。
- 更新 `application.yml` 加入 CORS 預設設定。
- 更新 README、Backend README 與 `docs/API_SPEC.md` 補充 CORS 設定方式。
- 更新 `docs/TASKS.md` 標示本 Task 完成。
- 新增 Log 前已檢查保存期限，現有 Log 未超過一個月，無需刪除。

### 新增

- `backend/src/main/java/com/monsters/common/config/CorsConfig.java`
- `backend/src/main/java/com/monsters/common/config/CorsProperties.java`
- `backend/src/test/java/com/monsters/common/config/CorsConfigTest.java`

### 修改

- `README.md`
- `backend/README.md`
- `backend/src/main/resources/application.yml`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 新增 `/api/**` CORS 設定，未新增業務 API endpoint。

### Database

- 無

### 測試

- `.\gradlew.bat test`
- `.\gradlew.bat build`
- `git diff --check`

### Commit 建議

```text
feat(api): 建立 cors 設定
```

### 備註 / 待確認事項

- 正式環境需設定 `CORS_ALLOWED_ORIGIN_PATTERNS` 為可信任前端網域。

---

## 2026-07-01 14:40

Task
TASK-009 建立 Base Entity

修改人
Codex

### 本次完成

- 新增後端共用 `BaseEntity`，統一 `id`、`createdAt`、`updatedAt` 欄位與 JPA lifecycle callback。
- 新增 `BaseEntityTest`，驗證 JPA annotation、欄位命名與時間戳更新行為。
- 更新 `docs/DATABASE_SPEC.md` 補充 Base Entity 對應規範。
- 更新 `docs/TASKS.md` 標示本 Task 完成。
- 新增 Log 前已檢查保存期限，現有 Log 未超過一個月，無需刪除。

### 新增

- `backend/src/main/java/com/monsters/common/entity/BaseEntity.java`
- `backend/src/test/java/com/monsters/common/entity/BaseEntityTest.java`

### 修改

- `docs/DATABASE_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 新增後端 Entity 共用欄位規範，未新增資料表或 Migration。

### 測試

- `.\gradlew.bat test`
- `.\gradlew.bat build`
- `git diff --check`

### Commit 建議

```text
feat(database): 建立 base entity
```

### 備註 / 待確認事項

- 無

---

## 2026-07-01 14:29

Task
TASK-008 建立全域 Exception Handler

修改人
Codex

### 本次完成

- 新增後端共用 Exception 類別，集中定義 400、401、403、404、409 錯誤。
- 新增 `GlobalExceptionHandler`，以 `RestControllerAdvice` 統一處理 Business、Validation 與未預期 Exception。
- 新增 `GlobalExceptionHandlerTest`，驗證 HTTP Status 與 `ApiResponse<Void>` 錯誤格式。
- 更新 `docs/API_SPEC.md` 補充全域 Exception Handler 與 Exception 對應 Status。
- 更新 `docs/TASKS.md` 標示本 Task 完成。
- 新增 Log 前已檢查保存期限，現有 Log 未超過一個月，無需刪除。

### 新增

- `backend/src/main/java/com/monsters/common/exception/BusinessException.java`
- `backend/src/main/java/com/monsters/common/exception/ValidationException.java`
- `backend/src/main/java/com/monsters/common/exception/ResourceNotFoundException.java`
- `backend/src/main/java/com/monsters/common/exception/ConflictException.java`
- `backend/src/main/java/com/monsters/common/exception/UnauthorizedException.java`
- `backend/src/main/java/com/monsters/common/exception/ForbiddenException.java`
- `backend/src/main/java/com/monsters/common/exception/GlobalExceptionHandler.java`
- `backend/src/test/java/com/monsters/common/exception/GlobalExceptionHandlerTest.java`

### 修改

- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 補充後端全域 Exception Handler 與錯誤 Response 規範，未新增業務 API endpoint。

### Database

- 無

### 測試

- `.\gradlew.bat test`
- `.\gradlew.bat build`
- `git diff --check`

### Commit 建議

```text
feat(api): 建立全域 exception handler
```

### 備註 / 待確認事項

- 無

---

## 2026-07-01 11:02

Task
DOC-005 建立 Log 保存期限規範

修改人
Codex

### 本次完成

- 新增 Log 保存政策：Log 僅保存一個月。
- 規範新增 Log 前必須先檢查 `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv` 是否有超過一個月的紀錄。
- 將 Log 保存政策記錄於 `AGENTS.md` 文件資訊。
- 本次檢查現有 Log 最早日期為 `2026-06-29`，未超過一個月，無需刪除。

### 新增

- 無

### 修改

- `AGENTS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- `git diff --check`
- 確認現有 Log 日期皆未超過一個月。

### Commit 建議

```text
docs(log): 新增 log 保存期限規範
```

### 備註 / 待確認事項

- 無

---

## 2026-07-01 10:54

Task
TASK-007 建立統一 API Response

修改人
Codex

### 本次完成

- 新增後端共用 `ApiResponse<T>` DTO，統一 API 回傳格式。
- 新增 `ApiResponseTest`，驗證成功、失敗與 JSON 序列化欄位。
- 更新 `docs/API_SPEC.md` 補充後端共用 Response DTO 規範。
- 更新 `docs/TASKS.md` 標示本 Task 完成。
- 更新 `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv`。

### 新增

- `backend/src/main/java/com/monsters/common/dto/ApiResponse.java`
- `backend/src/test/java/com/monsters/common/dto/ApiResponseTest.java`

### 修改

- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 補充後端 API Response 共用 DTO 規範，未新增業務 API endpoint。

### Database

- 無

### 測試

- `.\gradlew.bat test`
- `git diff --check`

### Commit 建議

```text
feat(api): 建立統一 response dto
```

### 備註 / 待確認事項

- 無

---

## 2026-07-01 10:02

Task
TASK-006 建立 README 執行說明

修改人
Codex

### 本次完成

- 補充根目錄 README 的必要環境、前端執行、後端執行、Docker Compose、環境變數、測試與提交流程。
- 更新 `docs/TASKS.md` 標示 README 執行說明 Task 完成。
- 更新 `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv`。

### 新增

- 無

### 修改

- `README.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- `git diff --check`

### Commit 建議

```text
docs(readme): 補充專案執行說明
```

### 備註 / 待確認事項

- `docs/DECISIONS.md` 既有未提交修改非本次 Task 內容，未納入提交。

---

## 2026-06-30 11:16

Task
TASK-005 建立 Docker Compose（MySQL + Backend）

修改人
Codex

### 本次完成

- 新增 Docker Compose，包含 MySQL 與 Backend service。
- 新增後端 Dockerfile，使用 JDK 18 建置與執行 Spring Boot jar。
- 新增 `database/init/` 初始化 SQL 目錄說明。
- 更新 README 的 Docker Compose 啟動方式。
- 更新 `DATABASE_SPEC.md` 與 `DECISIONS.md` 的容器環境說明。
- 更新 `docs/TASKS.md` 標示本 Task 完成。

### 新增

- `docker-compose.yml`
- `backend/Dockerfile`
- `database/init/README.md`

### 修改

- `README.md`
- `backend/README.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 新增 MySQL Docker Compose service，未建立資料表或 Migration。

### 測試

- `docker compose config`
- 使用 JDK 18 執行 `.\gradlew.bat test`

### Commit 建議

```text
chore(docker): 建立 mysql 與 backend compose
```

### 備註 / 待確認事項

- 尚未建立實際資料表 migration。
- Docker image 需在有 Docker 與網路環境時下載。

---

## 2026-06-30 11:07

Task
DOC-004 建立 GitHub Actions 分支清理自動化

修改人
Codex

### 本次完成

- 新增 GitHub Actions workflow，每週一自動檢查遠端分支。
- 僅刪除已合併到 `origin/main` 的工作分支。
- 保留 `main`、`develop`、只合併到 `develop` 的分支，以及尚未合併到 `develop` 的分支。
- 支援手動觸發 `workflow_dispatch`。
- 更新 `docs/GIT_RULE.md` 補充分支清理自動化規則。

### 新增

- `.github/workflows/cleanup-merged-branches.yml`

### 修改

- `docs/GIT_RULE.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- `.github/.gitkeep`

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- 檢查 workflow YAML 內容與 Git 分支判斷規則。
- 執行 `git diff --check` 檢查格式。

### Commit 建議

```text
ci(github): 建立分支清理 workflow
```

### 備註 / 待確認事項

- GitHub Actions 需 workflow 被合併到 GitHub 預設分支後才會按排程執行。

---

## 2026-06-30 10:47

Task
TASK-004 調整 MySQL Profile 設定

修改人
Codex

### 本次完成

- 將後端 Spring Boot 設定拆分為共用、dev、prod 三份。
- `application.yml` 保留共用設定與預設 `dev` profile。
- 新增 `application-dev.yml` 作為本機開發 MySQL 連線設定。
- 新增 `application-prod.yml` 作為正式環境 MySQL 連線設定，必須使用環境變數。
- 移除重複用途的 `application-example.yml`。
- 調整 `.gitignore`，允許追蹤 `application-dev.yml`。
- 更新 `backend/README.md` 與 `docs/DATABASE_SPEC.md`。

### 新增

- `backend/src/main/resources/application-dev.yml`
- `backend/src/main/resources/application-prod.yml`

### 修改

- `.gitignore`
- `backend/README.md`
- `backend/src/main/resources/application.yml`
- `docs/DATABASE_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- `backend/src/main/resources/application-example.yml`

### Migration

- 無

### API

- 無

### Database

- 文件補充 Spring Boot Profile 與 MySQL 連線設定，未建立資料表或 Migration。

### 測試

- 使用 JDK 18 執行 `.\gradlew.bat test`

### Commit 建議

```text
chore(database): 拆分 spring profile 設定
```

### 備註 / 待確認事項

- `prod` profile 不提供預設帳密，正式環境需設定 `DB_URL`、`DB_USERNAME`、`DB_PASSWORD`。

---

## 2026-06-30 10:41

Task
TASK-004 建立 MySQL 連線設定

修改人
Codex

### 本次完成

- 新增 Spring Data JPA 與 MySQL Connector 依賴。
- 於 `application.yml` 加入 MySQL datasource 與 JPA 基本設定。
- 新增 `application-example.yml` 作為 MySQL 連線範例。
- 調整後端 context load 測試，避免測試環境依賴本機 MySQL。
- 更新 `DATABASE_SPEC.md` 與 `backend/README.md` 的連線設定說明。
- 更新 `docs/TASKS.md` 標示本 Task 完成。

### 新增

- `backend/src/main/resources/application-example.yml`

### 修改

- `backend/build.gradle`
- `backend/README.md`
- `backend/src/main/resources/application.yml`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `docs/DATABASE_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 新增 MySQL 連線設定文件，未建立資料表或 Migration。

### 測試

- 使用 JDK 18 執行 `.\gradlew.bat test`

### Commit 建議

```text
feat(database): 建立 mysql 連線設定
```

### 備註 / 待確認事項

- 尚未建立 Docker Compose，下一個 Task 將補上 MySQL + Backend 執行環境。
- 預設帳密僅供本機開發使用，正式環境需改用環境變數。

---

## 2026-06-30 10:27

Task
DOC-003 文件一致性與精簡

修改人
Codex

### 本次完成

- 新增 `docs/DECISIONS.md`，集中管理已定案技術選型與待確認事項。
- 統一 `CODING_STANDARD.md` 版本資訊與 Gradle 說明。
- 更新 `GIT_RULE.md` 最後更新日期。
- 補齊 `DATABASE_SPEC.md` 中日記社群愛心與留言資料表欄位。
- 明確定義 `API_SPEC.md` 社群 `postId` 格式。
- 將 `API_SPEC.md` 待確認事項集中引用至 `DECISIONS.md`。
- 將 `TASKS.md` 中 Docker Compose 任務由可選調整為必做，避免與不得跳過 Phase 衝突。

### 新增

- `docs/DECISIONS.md`

### 修改

- `docs/API_SPEC.md`
- `docs/CODING_STANDARD.md`
- `docs/DATABASE_SPEC.md`
- `docs/GIT_RULE.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 文件補充：定義社群 `postId` 格式為 `{type}:{id}`。

### Database

- 文件補充：補齊 `diary_social_like` 與 `diary_social_comment` 欄位規格。

### 測試

- 使用 `rg` 掃描 Maven、Java 21、YYYY-MM-DD、待確認事項與欄位缺漏。
- 使用 `git diff --check` 檢查文件格式。

### Commit 建議

```text
docs(spec): 整理文件一致性與決策紀錄
```

### 備註 / 待確認事項

- `docs/DECISIONS.md` 中仍保留需使用者後續決策的項目。

---

## 2026-06-30 10:17

Task
TASK-003 建立 Spring Boot 專案

修改人
Codex

### 本次完成

- 依使用者確認改用 Gradle 建立後端 Spring Boot 專案。
- 將 `docs/CODING_STANDARD.md` 後端 Build Tool 由 `Maven` 調整為 `Gradle`。
- 建立 `backend/` Gradle 專案、Spring Boot 入口類別、基本 `application.yml` 與 context load 測試。
- 產生 Gradle wrapper，後續後端可用 `backend/gradlew.bat` 執行建置與測試。
- 移除 `backend/.gitkeep`。
- 更新 `docs/TASKS.md` 標示本 Task 完成。

### 新增

- `backend/README.md`
- `backend/build.gradle`
- `backend/settings.gradle`
- `backend/gradlew`
- `backend/gradlew.bat`
- `backend/gradle/wrapper/gradle-wrapper.jar`
- `backend/gradle/wrapper/gradle-wrapper.properties`
- `backend/src/main/java/com/monsters/MonstersApplication.java`
- `backend/src/main/resources/application.yml`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`

### 修改

- `docs/CODING_STANDARD.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- `backend/.gitkeep`

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- 使用 JDK 18 執行 `gradle wrapper --gradle-version 8.7`
- 使用 JDK 18 執行 `.\gradlew.bat test`

### Commit 建議

```text
feat(backend): 建立 spring boot 專案
```

### 備註 / 待確認事項

- 本 Task 未加入 MySQL / JPA 設定，避免提前實作下一個 Task。
- 建立後端時以暫時環境變數指定 `JAVA_HOME=C:\Program Files\Java\jdk-18.0.2`。

---

## 2026-06-30 09:54

Task
TASK-002 建立 Flutter 專案

修改人
Codex

### 本次完成

- 使用 Flutter CLI 在 `frontend/` 建立 `monsters` 前端專案。
- 建立 Android、iOS、Web 平台骨架。
- 移除 Flutter template 預設 hosted 直接依賴，保留 SDK 依賴。
- 調整根目錄 `.gitignore`，允許追蹤 Flutter app 必要檔案 `frontend/pubspec.lock` 與 `frontend/.metadata`。
- 更新 `frontend/README.md` 為貘nsters 前端說明。
- 更新 `docs/TASKS.md` 標示本 Task 完成。

### 新增

- `frontend/.gitignore`
- `frontend/.metadata`
- `frontend/README.md`
- `frontend/analysis_options.yaml`
- `frontend/android/`
- `frontend/ios/`
- `frontend/lib/`
- `frontend/pubspec.lock`
- `frontend/pubspec.yaml`
- `frontend/test/`
- `frontend/web/`

### 修改

- `.gitignore`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- `frontend/.gitkeep`

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- `flutter pub get`
- `flutter analyze`
- `flutter test`

### Commit 建議

```text
feat(frontend): 建立 flutter 專案
```

### 備註 / 待確認事項

- `flutter_test` 仍會帶入 SDK 測試所需傳遞套件，未新增非必要直接 hosted 依賴。
- 目前功能仍為 Flutter template smoke test，後續 Phase 1 再建立 Router、Theme 與共用元件。

---

## 2026-06-30 09:44

Task
DOC-002 調整後端 Java 版本規範

修改人
Codex

### 本次完成

- 將後端 Java 版本規範由 `Java 21 LTS（建議）` 調整為 `JDK 18`。
- 後續 Spring Boot 專案建立與 Java 指令應以本機可用的 `C:\Program Files\Java\jdk-18.0.2` 為準。

### 新增

- 無

### 修改

- `docs/CODING_STANDARD.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- 確認 `docs/CODING_STANDARD.md` 已改為 `JDK 18`。
- 已於前次環境檢查確認 `C:\Program Files\Java\jdk-18.0.2\bin\java.exe` 與 `javac.exe` 可執行。

### Commit 建議

```text
docs(java): 調整後端 java 版本規範
```

### 備註 / 待確認事項

- 目前系統 PATH 仍優先使用 Java 8，建立 Spring Boot 專案時需暫時設定 `JAVA_HOME` 與 PATH 指向 JDK 18，或由使用者永久調整系統環境變數。

---

## 2026-06-30 09:36

Task
TASK-001 建立 Monorepo 結構

修改人
Codex

### 本次完成

- 建立 `frontend/`、`backend/`、`database/`、`.github/` Monorepo 基礎目錄。
- 新增 `.gitkeep` 保留檔，確保空目錄可被 Git 追蹤。
- 更新 `README.md` Repository 結構，使文件與實際目錄一致。
- 更新 `docs/TASKS.md` 標示本 Task 執行狀態。

### 新增

- `.github/.gitkeep`
- `frontend/.gitkeep`
- `backend/.gitkeep`
- `database/.gitkeep`

### 修改

- `README.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- 確認 `frontend/`、`backend/`、`database/`、`.github/` 目錄已建立。
- 確認新增目錄內含 `.gitkeep`，可被 Git 追蹤。

### Commit 建議

```text
chore(project): 建立 monorepo 基礎結構
```

### 備註 / 待確認事項

- Flutter SDK 指令逾時，下一項「建立 Flutter 專案」前需再次確認 Flutter 環境。
- 目前 Java 版本為 1.8，低於 `docs/CODING_STANDARD.md` 建議的 Java 21；建立 Spring Boot 專案前需確認是否升級或調整規範。

---

## 2026-06-29 17:10

Task
DOC-001 建立異動紀錄檔並更新 README 使用指令

修改人
ChatGPT

### 本次完成

- 新增 `CHANGE_LOG.md`，作為專案文字版異動紀錄。
- 新增 `CHANGE_HISTORY.csv`，作為專案表格版異動歷程。
- 新增 `CHANGE_HISTORY.xlsx`，作為 Excel 版異動歷程。
- 更新 `README.md` 的 AI 使用指令，使文件閱讀順序與 `docs/` 路徑一致。

### 新增

- CHANGE_LOG.md
- CHANGE_HISTORY.csv
- CHANGE_HISTORY.xlsx

### 修改

- README.md
- AGENTS.md

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- 確認根目錄已包含 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv`、`CHANGE_HISTORY.xlsx`。
- 確認 `README.md` 已明確要求 AI 依序閱讀 `AGENTS.md` 與 `docs/` 內規格文件。

### Commit 建議

```text
docs(project): 新增異動紀錄檔並更新 README 使用指令
```

### 備註 / 待確認事項

- 無
