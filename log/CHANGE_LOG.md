# 專案異動紀錄

本文件用於記錄貘nsters 專案每次由 AI Coding Agent 或開發者完成的檔案異動。

AI 每次完成任務後，必須新增一筆紀錄，並同步更新 `CHANGE_HISTORY.csv` 或 `CHANGE_HISTORY.xlsx`。

新增 Log 紀錄前，必須先檢查既有 Log 日期；若存在超過一個月的紀錄，需先刪除過期紀錄，再新增本次紀錄。

---

## 2026-08-16 07:43

Task
Registration Login 08 跨站Web Session與Git基底修正（DONE）

Agent
Codex

### Completed

- 同步遠端後確認Task08已由PR #97合併且CI全綠，保留其真實HTTP／MySQL測試、Android API 24設定及PR #98 UI展示成果，未以舊基底重複覆蓋。
- 修正Cloudflare Pages至Railway屬跨站HTTPS：`__Host-monsters-refresh`由`SameSite=Strict`改為`SameSite=None; Secure`，仍強制可信Origin、CORS與`X-CSRF-Protection: 1`。
- 補上每個401原Request換發後最多重試一次的明確Flutter測試；既有single-flight行為保持不變。
- Task08依已合併PR #97由`REVIEW`轉為`DONE`。

### Modified / Added / Deleted

- 修改`WebSessionCookieService`與真實HTTP/MySQL Cookie assertions。
- 修改Flutter `api_client_test.dart`；沒有修改正式Flutter runtime程式。
- 更新Backend README、API／Decision／Registration Task與三種Log。
- 未新增、刪除或修改Database Migration；未修改`system_data/`。

### system_data Reference

- 本次為現行跨站部署Cookie與Git基底修正；舊系統沒有HttpOnly Cookie、Origin／CSRF或Cloudflare Pages至Railway接縫可沿用。
- 未沿用舊SharedPreferences Token或JWT Refresh模式，`system_data/`保持唯讀。

### API

- Endpoint、request body與response schema不變；Web Refresh Cookie屬性由`SameSite=Strict`改為`SameSite=None; Secure`。
- `X-Session-Transport: COOKIE`、可信Origin與`X-CSRF-Protection: 1`仍為必要防護。

### Database

- 無Database或Migration異動。

### Tests

- TDD先以真實HTTP/MySQL assertion確認`Strict`為Red，再改為`None`轉Green。
- Backend 316項unit／contract與36項真實MySQL integration通過。
- Flutter ApiClient 9項定向及191項完整測試通過，Analyze無問題，涵蓋single-flight及每個原Request最多重試一次。
- Draft PR #99的Backend unit、MySQL integration、Flutter test＋Android Build及OpenAPI四項CI全部通過；本修正未改正式Flutter runtime。

### Log Retention

- 保存期限截止日為2026-07-16；已刪除39個早於期限的Markdown區段與479筆CSV紀錄。
- XLSX最早資料為2026-08-01，沒有過期紀錄；本次依既有13欄表格新增4筆並完成值與視覺檢查。

### Pending

- Draft PR #99已建立且四項CI全綠，等待使用者審查與合併；不自動合併。
- Railway正式環境需將`WEB_SESSION_TRUSTED_ORIGIN_PATTERNS`與`CORS_ALLOWED_ORIGIN_PATTERNS`設為實際Cloudflare Pages HTTPS Origin。

---

## 2026-08-10 10:16

Task
已完成 UI 純 HTML／RWD 靜態展示（REVIEW）

Agent
Codex

### Completed

- 新增單一 `docs/ui-showcase/index.html`，展示啟動、登入、註冊、Email 驗證、Eligibility、Guardian Consent、首頁、個人資料、密碼鎖、新增煩惱與新增日記畫面。
- 全部色票、元件樣式與 Mobile／Tablet／Desktop RWD 直接寫入 HTML `<style>`；未建立外部 CSS 或 JavaScript。
- 所有按鈕與導覽使用頁面內 `<a href="#...">` 連結；不串接 API、Database、登入判斷、本機儲存或動畫。
- 排除尚未完成的歷史記錄、心的軌跡、社群、圖鑑與互動區，不以靜態畫面假裝功能已可用。

### Modified / Added / Deleted

- 新增 `docs/ui-showcase/index.html`。
- 修改 `docs/UI_SPEC.md` 與 `docs/TASKS.md`。
- 更新 `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 及 `log/CHANGE_HISTORY.xlsx`。
- 未刪除產品檔案；僅使用工作區外的檢查暫存檔。

### system_data Reference

- 閱讀舊系統手冊的登入、註冊、首頁、個人資料、密碼鎖、煩惱與日記流程，並檢查舊 Flutter 頁面及素材；只參考資訊架構與陪伴視覺。
- 未沿用舊 account 登入、使用者上傳頭貼、隨機怪獸獎勵、未治理社群、固定手機座標或直接資料存取；未修改、搬移或刪除 `system_data/`。

### API

- 無 Endpoint、request、response、錯誤碼或 API 呼叫異動。

### Database

- 無 Schema、欄位、SQL 或 Migration 異動。

### Documentation

- `UI_SPEC.md` 新增純 HTML 靜態展示範圍、RWD、連結、隱私與禁止項目規格。
- `TASKS.md` 新增本插隊任務，完成至 `REVIEW`；Git Push／PR 未授權，因此不標記 `DONE`。

### Tests

- HTML parser 驗證 120 個連結、29 個唯一錨點與 30 張圖片；失效內部連結、缺少圖片、重複 ID 均為 0。
- 確認 `script`、`button`、`form`、`onclick` 與 `fetch` 均為 0；三組 RWD `@media` 規則及 viewport meta 存在。
- `CHANGE_HISTORY.xlsx` A17:M20 檢查通過，公式錯誤掃描為 0，新增兩列後完整表格視覺檢查通過。

### Log Retention

- 2026-08-10 保存期限截止日為 2026-07-10；`CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv` 均無早於截止日的紀錄，未刪除 Log。
- `CHANGE_HISTORY.xlsx` 原有資料最早為 2026-08-01，無過期資料；新增 Frontend 與 Documentation 兩列並保留既有 13 欄表格樣式。

### Pending

- Task 維持 `REVIEW`，等待使用者確認是否提交、推送並建立 PR。
- 本次未執行瀏覽器視覺 QA；依網站技能規則，使用者未明確要求瀏覽器測試時不進行截圖、點擊或 viewport resize。

---

## 2026-08-10 09:40

Task
Registration Login 08 Android API 24與CI修正（REVIEW）

Agent
Codex

### Completed

- 依使用者核准方案A，在PR #97的Flutter Job加入`flutter build apk --debug --no-pub`，以釘選Flutter 3.29.2驗證Android實際建置。
- 第一輪Android Build確認`audio_session 0.2.4`最低要求API 24，現有Plugin另要求compileSdk 36及NDK 27.0.12077973；未使用`overrideLibrary`強制繞過相容性檢查。
- Android設定調整為最低API 24、compileSdk 36及NDK 27.0.12077973；本機Flutter 3.44.6 Android debug APK與PR #97 Flutter 3.29.2 Android Build皆通過。
- PR #97修正後Backend unit、MySQL integration、Flutter test＋Android Build及OpenAPI四項CI全綠；Task08維持`REVIEW`等待使用者審查與合併。

### Modified / Added / Deleted

- 修改`.github/workflows/registration-login-ci.yml`，在Flutter test後建置Android debug APK。
- 修改`frontend/android/app/build.gradle.kts`、`docs/DECISIONS.md`、`docs/UI_SPEC.md`與`docs/REGISTRATION_LOGIN_TASKS.md`。
- 更新`log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`及`log/CHANGE_HISTORY.xlsx`；刪除的內容僅為超過一個月保存期限的Log。

### system_data Reference

- 本次為Task08 CI相容性修正，沿用Task08已完成的舊系統參考結論；未修改、搬移或刪除`system_data/`。

### API

- 無Endpoint、request、response或錯誤碼異動。

### Database

- 無Schema、欄位、SQL或Migration異動。

### Documentation

- 正式決策與UI規格改為Android最低API 24、compileSdk 36及NDK 27.0.12077973。
- Task08補上PR #97失敗根因、使用者核准方案A、本機APK與修正後四項CI全綠證據。

### Tests

- 本機Flutter 3.44.6：`flutter build apk --debug --no-pub`通過。
- PR #97 Run 31347345810：Backend unit、MySQL integration、Flutter test＋Android Build及OpenAPI四項CI通過；Flutter Job以Flutter 3.29.2完成APK建置。
- 既有Task08驗證維持Backend 316項、MySQL 36項、Flutter 190項、Analyze及Web Build通過。

### Log Retention

- 2026-08-10保存期限截止日為2026-07-10；從`CHANGE_LOG.md`移除22個2026-07-03、07-04、07-06及07-09區段，從`CHANGE_HISTORY.csv`移除278筆同期紀錄，最早保留日為2026-07-10。
- `CHANGE_HISTORY.xlsx`只含Task07與Task08紀錄，沒有過期資料；新增本次CI與文件紀錄並保留既有13欄表格格式。

### Pending

- Task08維持`REVIEW`，等待PR #97使用者審查與合併；完成前不得開始Task09。
- iOS原生Keychain Build與實機驗證仍需在macOS Review環境執行。

---

## 2026-08-03 16:57

Task
Registration Login 08 三平台 Credential Store與Single-flight Refresh（REVIEW）

Agent
Codex

### Completed

- 依使用者核准方案1，Web沿用`POST /api/v1/auth/login`與`POST /api/v1/auth/session-refreshes`，以`X-Session-Transport: COOKIE`分流；Backend驗證可信Origin及`X-CSRF-Protection: 1`。
- Web Refresh Credential改由`__Host-monsters-refresh` HttpOnly／Secure／SameSite=Strict／Path=/ Cookie管理；成功回應不再暴露Refresh值，無效或reuse的401會清除Cookie。
- Android／iOS新增共用`SessionCredentialStore`契約；使用`flutter_secure_storage 10.3.1`保存Refresh Credential，Android最低API 23並停用App備份，iOS Keychain不啟用同步且不可跨裝置遷移。
- 移除Auth Session以SharedPreferences序列化完整`LoginResult`的舊實作；Access Token只保存在Dio記憶體Authorization Header。
- Web auth request啟用瀏覽器credentials；App維持request body Credential。既有並行401共用單一refresh future且每個原request最多重試一次。
- Session確定失效時清除Credential並導向登入；暫時性網路錯誤保留Credential與server session，Splash停留原頁並提供重試。

### Modified / Added / Deleted

- Backend新增Web Session Properties與Cookie Service，修改登入／refresh Controller、response DTO、Security Config、CORS與環境設定。
- Frontend重建`auth_session_store.dart`為Web／Android／iOS Adapter，修改Auth Repository、Provider、Splash、登入結果判定、Android設定及套件lockfile。
- 新增或修改Backend HTTP／OpenAPI及Flutter Credential Store／Repository／Splash／App啟動測試。
- 更新README、Backend README、正式API／UI／Decision規格、OpenAPI與Task文件。
- 未修改或刪除`system_data/`；清除本次PDF／試算表檢查與Flutter Build的可重建暫存產物。

### system_data Reference

- 檢查舊系統手冊、系統簡介與Flutter登入參考程式；舊版只有本機SharedPreferences Token／完整登入資料及單一登入流程，沒有Web HttpOnly Cookie、Origin／CSRF或三平台安全Credential Store契約可沿用。
- 正式Phase 4.5規格優先；未沿用舊Token保存、帳密或硬編碼設定。

### API

- `/api/v1/auth/login`與`/api/v1/auth/session-refreshes`新增可選Web transport headers；Cookie模式要求可信Origin及CSRF proof。
- Web login／refresh以Set-Cookie回傳並省略`refreshToken`；App response與refresh body contract維持相容。
- 新增穩定`403 WEB_SESSION_REQUEST_REJECTED`；Web Session invalid／reuse的401同時送出過期Cookie。

### Database

- 無Schema、SQL、欄位或Migration異動；沿用Task07的`user_sessions`與opaque Credential資料表。

### Documentation

- 同步`API_SPEC.md`、`UI_SPEC.md`、`DECISIONS.md`、OpenAPI、README、Backend README及`REGISTRATION_LOGIN_TASKS.md`。
- Task07依PR #96合併及CI全綠證據轉`DONE`；Task08由`IN PROGRESS`轉`REVIEW`。

### Tests

- TDD逐條確認Web Cookie登入、Origin／CSRF拒絕、Cookie refresh rotation／清除、三平台Store、Web／App Repository及Splash暫時錯誤行為先Red後Green。
- Backend完整316項單元／契約測試與36項MySQL/Testcontainers整合測試通過；OpenAPI contract通過。
- Flutter Analyze無問題，完整190項測試通過；Web release build與Android debug APK build通過。
- Android首次Build因跨磁碟Kotlin incremental cache逾時；停止daemon並`flutter clean`後，乾淨Build由非增量fallback成功。本機Flutter 3.44.6建置時會強制最低API 24，來源仍依專案釘選Flutter 3.29.2維持API 23，待PR CI驗證；iOS因Windows環境未執行原生Build，Keychain Adapter由contract test覆蓋。

### Log Retention

- 保存期限截止日為2026-07-03；已從`CHANGE_LOG.md`移除13個2026-07-01／07-02區段，並從`CHANGE_HISTORY.csv`移除99筆同期紀錄，最早保留日為2026-07-03。
- 保留期內另有41筆2026-07-16舊版9欄CSV紀錄；已保留原內容，將新增的API／Database／UI／Migration四欄補為空值，使全檔統一為13欄且不推測歷史影響範圍。
- `CHANGE_HISTORY.xlsx`原有Task07的8筆資料且無過期紀錄；本次依既有13欄表格樣式同步Task08並完成值與視覺檢查。

### Pending

- Task08維持`REVIEW`，待Push、Pull Request、GitHub CI及使用者審查；完成合併前不得轉`DONE`或開始Task09。
- PR CI必須以釘選Flutter 3.29.2確認Android最低API 23設定可建置。
- iOS原生Keychain Build／實機驗證需在macOS Review環境執行。

---

## 2026-08-01 20:31

Task
Registration Login 07 Opaque Refresh Session Family（REVIEW）

Agent
Codex

### Completed

- 依使用者核准的方案1，以32-byte初始CSPRNG Credential及獨立HMAC Secret推導後續Credential；Backend只保存SHA-256 hash。
- v1完整登入為每次登入建立獨立`user_sessions` family，保存建立、最後活動、30天idle、90天absolute與撤銷狀態。
- 新增`POST /api/v1/auth/session-refreshes`；每次成功輪替Credential，同一舊Credential在10秒內回傳完全相同的Access／Refresh結果。
- 逾期reuse於同一交易撤銷被影響family並寫入不含Token、hash或Email的Audit／Outbox；其他登入family維持可用。
- Access JWT改為10分鐘並只包含`iss`、`sub`、`sid`、`iat`、`exp`；Security Filter以`sid`即時檢查Session與會員狀態。
- Flutter暫時換發路徑切至v1 endpoint；Web Cookie、App Keychain／Keystore及SharedPreferences移除明確留待Task08。
- 使用者回報Spring Mail import提示後，以重新整理dependencies的乾淨編譯確認既有`spring-boot-starter-mail`、`SimpleMailMessage`及`JavaMailSender`均可解析，未加入重複套件。

### Modified / Added / Deleted

- 新增Session Family Controller、DTO、Service、Properties、Credential Generator、Entity、Repository、Audit及穩定例外。
- 新增`backend/src/main/resources/db/migration/V5__add_refresh_session_families.sql`。
- 修改JWT核發／驗證、Security Filter、v1登入Session核發、Security Config及Flutter Auth Repository。
- 新增或修改Backend unit、OpenAPI、真實Security Filter／MySQL、Flyway及Flutter Repository測試。
- 更新`README.md`、Backend／Frontend README、正式API／Database／Project／UI規格、OpenAPI、Task與Log。
- 未刪除檔案，未修改`system_data/`。

### system_data Reference

- 舊系統手冊與程式只有單一登入Token及本機清除登出，沒有opaque family、rotation、reuse detection、裝置隔離或Server Session期限可沿用。
- 未沿用舊系統記錄帳密、完整會員資料或本機SharedPreferences Token的不安全模式；`system_data/`保持唯讀。

### API

- 新增`POST /api/v1/auth/session-refreshes`，request為`refreshCredential`。
- 成功回`200 AUTHENTICATED`；無效、過期或撤銷回`401 AUTH_SESSION_INVALID`；逾期reuse回`401 AUTH_REFRESH_REUSE_DETECTED`。
- 既有legacy JWT Refresh API只保留Migration相容，不作為v1 Client新依賴。

### Database

- Flyway V5新增`user_sessions`、`refresh_session_credentials`、`session_security_audits`。
- Credential表只保存64字元SHA-256 hex、sequence、rotation／grace／reuse時間，不保存明文或可還原密文。

### Tests

- TDD先確認新HTTP／MySQL與OpenAPI契約為Red，再完成實作轉Green。
- 已通過Task07 targeted Backend、真實MySQL、Migration、OpenAPI、Credential Generator、JWT及Flutter Repository測試。
- 已以`./gradlew clean compileJava --refresh-dependencies`確認Spring Mail imports乾淨編譯成功。
- Backend 316項單元／契約測試與31項真實MySQL整合測試、Flutter Analyze、185項完整測試及Web Build全部通過。
- Draft PR #96 的 Backend unit、MySQL integration、Flutter 與 OpenAPI 四個GitHub CI job全部通過。

### Log Retention

- 保存期限截止日為2026-07-01；Markdown與CSV最早紀錄為2026-07-01，沒有超過一個月的紀錄，不需刪除。
- XLSX原本只有13欄表頭；本次依相同表格格式同步Task07紀錄並進行值、錯誤及視覺檢查。

### Pending

- Draft PR #96 已建立且四個CI job全綠；Task07維持`REVIEW`，待使用者審查並合併後才能轉`DONE`。
- Task08才處理Web HttpOnly Cookie、App Keychain／Keystore、Credential Store與移除SharedPreferences Token。

---

## 2026-08-01 19:48

Task
Registration Login 06 Flutter 3.29.2 Eligibility CI 相容修正（REVIEW）

Agent
Codex

### Completed

- 確認 PR #94 的 Backend unit、MySQL integration 與 OpenAPI CI 通過，只有 Flutter job 失敗。
- 根因為 CI 固定 Flutter 3.29.2，而 `DropdownButtonFormField.initialValue` 尚未存在；失敗造成 9 個測試檔無法編譯載入。
- 依使用者核准的方案 1 改用 Flutter 3.29.2 支援的 `value`，並以範圍化棄用說明保持本機 Flutter 3.35.5 Analyze 無警告。
- UI、預設台灣地區、選擇行為與無主畫面捲動規則皆未改變。

### Modified

- 修改 `frontend/lib/pages/eligibility_page.dart`。
- 更新 `docs/REGISTRATION_LOGIN_TASKS.md`、`log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv`。

### system_data Reference

- 本次為新版 Flutter SDK 相容性修正，舊系統未使用相同 Widget API，沒有可直接採用的參考實作。
- 未修改 `system_data/`。

### API

- 無異動。

### Database

- 無異動，無 Migration。

### Tests

- Eligibility targeted test 1 項通過。
- Flutter 完整 185 項測試通過。
- Flutter 3.35.5 Analyze 無問題；Draft PR #95 的 Flutter 3.29.2、Backend、MySQL integration 與 OpenAPI 四個 CI job 全部通過。
- `git diff --check` 通過。

### Log Retention

- 保存期限截止日為 2026-07-01；Markdown 與 CSV 均無 2026-06 或更早紀錄，不需刪除。
- XLSX 經試算表工具讀取與視覺檢查，仍只有 13 欄表頭且無資料，本次未修改。

### Pending

- Draft PR #95 已建立且四個 CI job 全綠；Task 06 維持 `REVIEW`，待修復 PR 合併後才能轉 `DONE`。

---

## 2026-08-01 18:19

Task
Registration Login 06 Eligibility、Guardian Consent、公開暱稱 Onboarding 與 Resend SMTP（REVIEW）

Agent
Codex

### Completed

- 完成台灣服務地區與 12／13／17／18 歲 Asia/Taipei 日期邊界分類；非台灣與未滿 13 歲只保存資格必要資料，不保存公開暱稱或 Guardian Email。
- 完成 2–30 Unicode code points、NFC、strip、控制字元／雙向控制／不可見字元／純空白與官方冒充名稱阻擋；暱稱非唯一且不作登入或 owner 判斷。
- Email 驗證後以 10 分鐘 purpose-limited continuation Security Filter 進入 Eligibility；成人完成後回登入，未確認暱稱揭露者維持 Community pending。
- 13–17 歲建立版本化 Guardian Consent；同意 24 小時、撤回 15 分鐘，皆採 32-byte 單次 Token 且只存 SHA-256 hash，新要求撤銷舊 Token。
- Guardian Email 不授予私人內容權限；撤回後會員立即回 `PENDING_ELIGIBILITY`，現有 JWT 也會經即時會員狀態檢查拒絕一般 API，並可重新取得同意。
- SMTP 供應商固定為 Resend；沿用 Spring Boot Mail，不新增 SDK，預設 `smtp.resend.com:587` STARTTLS、帳號 `resend`、密碼由 `RESEND_API_KEY` Secret 注入。
- Flutter 完成 Eligibility、等待／受限結果、Guardian 同意與撤回要求路由；主畫面使用固定畫布縮放、無 scrollbar，長文件只在彈窗內容區捲動。
- Penpot APP／WEB Account 09–12 八個畫板完成並確認 390×844、1440×900 直接顯示。

### Modified

- Backend 新增 Eligibility／Guardian Controller、Service、Security Filter、DTO、Entity、Repository、V4 Flyway migration、Outbox worker 與測試。
- Frontend 新增 Eligibility／Guardian Page、Repository、Provider、Model、Router 與測試；更新 Login、Email Verification 導流。
- Documentation 更新 README、API／Database／UI／Decision、OpenAPI 與 Registration Login Task。
- Log 更新 Markdown／CSV；XLSX 仍只有 13 欄表頭，唯讀檢查後未修改。

### system_data Reference

- 已檢查舊系統手冊、系統簡介、Spring／Flutter 參考程式與舊 users schema；只參考欄位與畫面流程意圖。
- 舊系統沒有 Eligibility、Guardian Consent、撤回或公開暱稱資格模型，未複製舊 account／生日自由修改流程。
- 未修改 `system_data/`。

### API

- 新增 Eligibility Policy／Completion 與 Guardian action／grant／withdrawal request／withdrawal 六個 v1 endpoint。
- continuation 使用獨立 Authorization scheme，不能存取一般 API；Guardian 公開要求維持不可列舉回應。
- Guardian Email、生日與 Token 不寫入 Log、Audit 或 Outbox payload。

### Database

- 新增 V4：users 資格／社群資格／暱稱揭露欄位、`guardian_consents`、`guardian_consent_tokens` 與狀態約束。
- 既有 ACTIVE 會員安全回填 `ELIGIBLE_ADULT`，Community 維持 `INELIGIBLE`，避免未確認即公開。

### Tests

- Backend `check` 通過：311 項 unit／OpenAPI 與 29 項 MySQL 8.4 integration，含真實 Security Filter、V4 migration 與 Eligibility 原子交易。
- Flutter Analyze 無問題，完整 185 項測試通過；Web release 與 Android debug APK build 通過。
- `git diff --check` 通過。

### Log Retention

- 保存期限截止日為 2026-07-01；已刪除 9 個 2026-06 Markdown 區段與 65 筆 2026-06 CSV 紀錄。
- XLSX 經試算表工具讀取與視覺檢查，只有 13 欄表頭且無過期資料，本次未修改。

### Pending

- Draft PR #94 已建立；Task 06 維持 `REVIEW`，待 CI 通過並合併至 `feature/phase4.5` 後轉 `DONE`。
- Resend 正式啟用前，Railway 各環境仍需設定 `RESEND_API_KEY`、已驗證寄件者、文件版本／URL與 Guardian action URL。

---

## 2026-07-31 16:32

Task
Registration Login 05 CI Review 修正（REVIEW）

Agent
Codex

### Completed

- 修正 Flutter Linux 字型度量下，900×700 平板版登入按鈕被縮放至 46.14px 的問題。
- 僅將平板 viewport 的垂直留白由 `lg` 縮為 `xs`，保留主畫面無捲動、完整直接顯示及按鈕至少 48px 的規則。
- 登入頁 20 項 targeted tests 全數通過，包含 600×700 至 1920×1080 的 responsive／overflow／點擊高度檢查。
- `flutter analyze --no-pub` 無問題。

### Modified

- 修改 `frontend/lib/pages/login_page.dart`。
- 修改 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv`。
- 無 API、Database、Migration 或 `system_data/` 異動。

### CI

- Flutter CI 原失敗已在本機以同一測試案例重現範圍並修正。
- Backend unit 原失敗發生於 `actions/setup-java@v4`、尚未執行專案測試；同次 MySQL integration 與 OpenAPI 工作均已通過，推送後重跑確認。

### Log Retention

- 沿用本 Task 16:22 新增紀錄前的完整檢查：截止日 2026-06-30，未發現早於截止日的過期紀錄，未刪除 Log，XLSX 未修改。

### Pending

- Task 05 維持 `REVIEW`；待 PR CI 通過並合併至 `feature/phase4.5` 後轉 `DONE`。

---

## 2026-07-31 16:22

Task
Registration Login 05 Verified Email 登入與 Account expand migration（REVIEW）

Agent
Codex

### Completed

- 新增正式 `POST /api/v1/auth/login`，只接受 Email 格式與 password；未知欄位（含 `account`）直接拒絕。
- v1 只以 trim＋lowercase 後的完整 Email 精確查詢，不套用 Gmail 點號消除或 `+tag` 合併。
- v1 登入成功只回 public UUID、Email 與顯示名稱，不回 legacy `account` 或內部 `userId`。
- 不存在 Email、密碼錯誤、缺少憑證與不可揭露狀態統一使用 `401 AUTH_INVALID_CREDENTIALS`；未完成流程依會員狀態回用途受限 continuation。
- Deprecated `POST /api/auth/login` 保留既有 Email／account 查詢，讓新舊 Client 與資料在 expand 階段安全共存；新註冊維持 `account = NULL`。
- Flutter 改呼叫 v1，只顯示與驗證 Email；穩定錯誤碼映射為「Email 或密碼不正確」。
- Penpot Web 1440×900 與 Mobile 390×844 登入畫板已改為 Email-only，並匯出確認所有內容直接位於 viewport 內。
- Flutter 登入頁移除三種 window class 的整頁 `SingleChildScrollView`，使用 responsive viewport fit 直接呈現全部必要內容。

### Modified

- Backend 新增：Verified Email Login Controller、Request／Response DTO 與公開 Member response。
- Backend 修改：`AuthService`、Security allowlist、單元／Controller／Security／OpenAPI／MySQL HTTP integration tests。
- Frontend 修改：Auth Repository／Provider、Login Page、AuthUser migration model 與相關測試。
- Documentation：Backend／Frontend README、API／Database／UI、OpenAPI 與 Registration Login Task。
- 外部設計：Penpot APP／WEB 登入畫板文案與 Email 範例。

### system_data Reference

- 已檢查舊系統手冊、系統簡介，以及 Spring／Flutter account＋password 登入流程；只參考登入導向、欄位與分層意圖。
- 舊 account 主登入、直接 HTTP、SharedPreferences account 與敏感登入 Log 不符合正式 v1 契約，未沿用。
- 未修改 `system_data/`。

### API

- 新增正式 `POST /api/v1/auth/login`；Request 只允許 `email`、`password`。
- v1 authenticated user response 為 `publicId`、`email`、`userName`，不含 `account`、`userId`。
- `/api/auth/login` 標記為 deprecated migration endpoint，暫時維持 legacy account 相容。
- 成功、continuation 與 `AUTH_INVALID_CREDENTIALS` 皆維持統一 ApiResponse envelope。

### Database

- 無 schema 或 Flyway Migration 異動。
- V3 已是 expand schema：新註冊不建立 account，既有 account column 暫留至 Task 18 contract migration。
- 真實 MySQL 驗證新 Email 與舊 account 登入可同時運作。

### UI

- 登入欄位與驗證訊息改為 Email-only，不再顯示或送出 account。
- 390×844、600×700、900×700、1024×768、1199×800、1440×900、1920×1080 皆無整頁捲動或 overflow。
- 同步全域文件：主畫面不得改成垂直捲動；長篇條款／隱私等只允許在彈跳視窗內容區捲動。

### Tests

- Backend 完整單元測試：301 項通過，0 failure／error。
- Backend MySQL 8.4 完整整合測試：28 項通過，包含真實 Security Filter 與新舊登入共存。
- Flutter 完整測試：184 項通過；`flutter analyze --no-pub` 無問題。
- Flutter Web release build 與 Android debug APK build通過。
- `git diff --check` 通過。

### Log Retention

- 以試算表工具唯讀檢查 `CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`，並檢查 `CHANGE_LOG.md`。
- 保存期限截止日為 2026-06-30；CSV 與 Markdown 最早紀錄為 2026-06-30，XLSX 只含 13 欄表頭，未發現早於截止日的過期紀錄。
- 本次未刪除過期 Log，未修改 XLSX。

### Pending

- Task 05 已進入 `REVIEW`；待 PR 合併至 `feature/phase4.5` 後轉 `DONE`。
- Task 07 將以 opaque Refresh Session 取代目前 historical JWT Refresh；Task 18 才移除 legacy endpoint 與 `users.account`。

---

## 2026-07-31 14:40

Task
Registration Login 04 新密碼政策與 BCrypt 漸進遷移（REVIEW）

Agent
Codex

### Completed

- 導入 15–128 Unicode code points、NFC、不 trim 與完整值弱密碼 blocklist；不要求固定大小寫、數字或特殊字元組合。
- 新密碼使用 Argon2id PHC hash，固定核准參數 `m=19456 KiB`、`t=2`、`p=1`，並加入 Bouncy Castle 1.84。
- 版本化本機 blocklist 由 SecLists 2026.1 的 10,000 筆常見密碼加一筆產品回歸值產生；Repository 只保存 SHA-256，來源、授權、checksum 與轉換方式保存在 NOTICE。
- 登入依 hash 前綴相容既有 BCrypt；錯誤密碼不修改憑證，正確登入才在同一資料庫交易升級為 Argon2id。
- 登入端在進入高成本雜湊比對前以 Unicode code point 拒絕超過 128 的輸入，並保留 128 個 Emoji 的合法邊界。
- Flutter 與 Backend 共用 `VALIDATION_FAILED` 及穩定 password field error key；NFC／長度／blocklist 由 Backend 唯一判定，Flutter 顯示對應繁體中文訊息。
- 依使用者新增的全域 UI 規則，註冊主畫面移除整頁捲動，矮視窗／鍵盤狀態收合非必要說明；Terms／Privacy 改由有獨立 scrollbar 的彈跳視窗呈現。

### Modified

- Backend：Auth／Registration Service、登入／註冊／重設密碼 DTO、Global Exception Handler 與 Bouncy Castle build dependency。
- Backend 新增：`security/password` 政策與雜湊模組、版本化 blocklist resource／NOTICE、單元與 MySQL HTTP 整合測試。
- Frontend：API field error parsing、Auth error localization、無主畫面捲動的註冊頁與文件彈窗、Widget tests。
- Documentation：API／Database／UI／Coding Standard／Decision／Registration Login 規格、Task 與 OpenAPI。

### system_data Reference

- 已檢查舊 Spring Member registration/login 與 Flutter login/signup/repository 流程；只參考分層與登入流程。
- 舊 SHA-256／BCrypt 基線、account 登入、8–72 長度與 Server PIN 不符合正式規格，未沿用至新會員密碼模組。
- 未修改 `system_data/`。

### API

- Endpoint 路徑與成功 response 不變。
- 新密碼契約改為 NFC 後 15–128 Unicode code points、不 trim、完整值 blocklist；違反時回 `400 VALIDATION_FAILED` 與安全 password field error key。
- 登入支援 Argon2id 與歷史 BCrypt；成功 BCrypt 登入後透明升級。

### Database

- 無 schema 或 Flyway Migration 異動；`user_credentials.password_hash VARCHAR(255)` 已可保存 Argon2id PHC 參數。
- 真實 MySQL 測試確認成功登入的 rehash 與 Session 核發在同一交易完成，失敗登入保持原 hash。

### UI

- 註冊頁不再使用主畫面 `SingleChildScrollView`，390、600、900、1024、1200、1440、1920 寬度皆直接呈現且無 overflow。
- 主畫面無 scrollbar；服務條款與隱私權政策由彈跳視窗呈現，只有彈窗內容區有 scrollbar。
- 弱密碼及長度錯誤使用穩定錯誤鍵映射繁體中文，不顯示 Backend 內部訊息。

### Tests

- Backend unit／OpenAPI：294 項通過，0 failure／error。
- MySQL 8.4 integration：27 項通過，包含 24 項真實 Security Filter Auth／Member HTTP、Flyway 與註冊 Migration。
- Flutter：`flutter analyze --no-pub` 無問題；完整 181 項測試通過；14／15／128／129 Emoji、NFC 與保留前後空白由 Widget／HTTP integration test 驗證。
- Flutter Web release build 與 Android debug APK build 通過；APK 壓縮結構檢查無錯誤。
- `git diff --check` 通過。

### Review

- Backend 審查缺口已修正：登入在高成本 hash 比對前拒絕超長輸入、NFC 正規化只執行一次，且不重複執行同一個 BCrypt 比對。
- API／Database／NOTICE 審查缺口已修正：移除過期的 8–72 與 BCrypt-only 敘述，補上產出 blocklist 的 checksum。
- Flutter 審查缺口已修正：Backend 成為 Unicode 政策唯一判定者，補齊 390–1920 寬度驗收、48px 操作高度、具體條款按鈕名稱與主畫面無捲動測試。

### Log Retention

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-30。
- 最早正式紀錄為 2026-06-30，未發現早於截止日的過期紀錄，本次未刪除 Log。
- 本次使用 CSV；XLSX 僅檢查且未修改。

### Pending

- Task 04 已進入 `REVIEW`；待本 Task PR 合併至 `feature/phase4.5` 後才可轉 `DONE`。
- 目前公開 Registration Policy API 只提供文件名稱、版本與正式 URL，彈窗先呈現這些正式參照；若要在彈窗內顯示完整法律本文，需由後續 Task 提供已核准的本文內容契約或可信來源。

---

## 2026-07-30 09:41

Task
Registration Login 03 合併後雙軸審查修正（REVIEW）

Agent
Codex

### Completed

- 以 `feature/phase4.5` 合併前固定點審查 Task 03；PR #90 已合併至 Phase 分支，但 GitHub 未回報該提交的 CI status 或 workflow run。
- 補上註冊受理與 Email 驗證寄送失敗的安全操作 Log；使用穩定錯誤碼與移除敏感訊息的完整 stack trace，不記錄 Email、密碼、Token、hash 或 payload。
- 將七日空會員清理的 SQL 從 Service 移至 Repository，維持原交易、鎖定與刪除條件。
- 移除 Email 驗證完成後返回登入造成的 continuation 迴圈；Eligibility 尚未完成時顯示安全提示並保留記憶體中的 verification result。
- 將註冊表單輸入樣式抽為檔案內 helper，使 `_RegisterForm` 回到 Widget 行數上限內。

### Modified

- Backend：`RegistrationService`、`EmailVerificationOutboxWorker`、`UnverifiedMemberCleanupService`。
- Backend 新增：`UnverifiedMemberCleanupRepository`。
- Frontend：`email_verification_page.dart`、`register_page.dart`。
- Test：`AuthMemberHttpIntegrationTest`、`email_verification_page_test.dart`。
- Documentation：`REGISTRATION_LOGIN_TASKS.md`、`CHANGE_LOG.md`、`CHANGE_HISTORY.csv`、`CHANGE_HISTORY.xlsx`。

### system_data Reference

- 已檢查系統手冊的註冊、登入、忘記密碼與舊 SHA-256 密碼保護流程；只保留流程理解，不沿用舊 account 登入、SHA-256 密碼雜湊或 Server 密碼鎖。
- 系統簡介只提供舊四位數 App 密碼鎖定位；Task 03／04 仍以正式規格、ADR 與現有新版程式為準。
- 未修改 `system_data/`。

### API

- 無 endpoint、request、response、error code 或 OpenAPI 異動。

### Database

- 無 schema、資料、SQL 語意或 Flyway Migration 異動；只將既有清理 SQL 移至 Repository 分層。

### UI

- Email 驗證成功頁在 Task 06 Eligibility 尚未完成前不再導回登入；顯示安全下一步提示。
- 註冊表單功能與版面不變。

### Tests

- Backend 完整單元測試：282 項通過、4 項 skipped、0 failure／error。
- Backend MySQL 8.4 `AuthMemberHttpIntegrationTest`：通過。
- Flutter 目標測試：`email_verification_page_test.dart` 4 項通過。
- Flutter 完整測試：169 項通過；`flutter analyze --no-pub` 無問題。

### Review Result

- Standards 軸原有 4 項硬性缺口已修正；2 項重複程式 smell 為 judgement call，本次不做無關重構。
- Spec 軸提出的非待驗證會員分流屬 Task 05／06／12／14；完整 Eligibility UI 屬 Task 06，本次未提前擴張。
- Task 03 維持 `REVIEW`，待本修正分支整合後才能轉 `DONE` 並開始 Task 04。

### Log Retention

- 保存期限截止日為 2026-06-30。
- 已刪除 `CHANGE_LOG.md` 的 2026-06-29 條目、`CHANGE_HISTORY.csv` 的 5 筆 2026-06-29 紀錄，以及 `CHANGE_HISTORY.xlsx` 的 5 筆 2026-06-29 紀錄。
- CSV 與 XLSX 均維持 13 欄結構；XLSX 僅保留表頭。

### Pending

- 本分支尚未推送或建立 PR；依交接權限邊界，需使用者明確要求發布。
- Task 04 尚未開始。

---

## 2026-07-29 16:14

Task
Registration Login 03 註冊與 Email 驗證流程（REVIEW）

Agent
Codex

### Completed

- 建立目前條款／隱私版本查詢、只收 Email 與密碼的初始註冊，以及新舊 Email 不可列舉的統一 `202 REGISTRATION_ACCEPTED` 回應。
- 建立 24 小時單次 Email 驗證 Token；Server 只保存 SHA-256 hash，完成驗證後原子轉為 `PENDING_ELIGIBILITY` 並建立用途受限 Continuation Credential。
- 建立重寄驗證信、舊 Token 撤銷、Email 60 秒冷卻、Email／IP 15 分鐘多維度限流與 `Retry-After`。
- 建立 provider-neutral SMTP Adapter、Transactional Outbox 寄信 Worker、最多五次指數退避，以及七日空會員批次清理。
- Flutter 完成註冊、條款／隱私版本提交、已受理、待驗證、重寄冷卻、Token 過期／無效與重新開始流程。
- Railway 公開 Backend 環境已文件化：develop 對應 `https://monsters-staging.up.railway.app`，main 對應 `https://monsters-production-9535.up.railway.app`；Flutter 使用各自 `/api` Base URL。

### Modified

- Backend：Registration Controller／Service／DTO、驗證 Token／條款接受／限流 Entity 與 Repository、SMTP Adapter、Outbox Worker、清理工作、例外處理、Security 與測試。
- Database：新增 Flyway V3 註冊、Email 驗證、條款接受與限流結構；既有 `users.account`／`user_name` 改為可空。
- Frontend：Registration Policy model、Auth Repository／Provider、註冊頁、待驗證頁、驗證結果頁、Route、錯誤處理與測試。
- Documentation：README、Backend／Frontend README、Project／API／Database／UI／Decision、OpenAPI、Migration README 與獨立 Registration Login Task 文件。
- 未修改 `docs/TASKS.md`、`system_data/` 或管理者功能。

### system_data Reference

- 已檢查舊系統註冊、登入與 Email 流程；可參考既有 Spring／Flutter 分層，但舊流程沒有不可列舉回應、用途受限 Continuation Credential、持久化多維度限流或 Outbox 寄信保證可直接沿用。
- 正式 Registration Login 規格、決策與 ADR 優先；未修改 `system_data/`。

### API

- 新增 `GET /api/v1/auth/registration-policy`。
- 新增 `POST /api/v1/auth/register`、`POST /api/v1/auth/email-verification-requests` 與 `POST /api/v1/auth/email-verifications`。
- 新增穩定 `REGISTRATION_ACCEPTED`、`EMAIL_VERIFIED`、Token 錯誤與 `RATE_LIMITED` 回應；限流回傳 `Retry-After` 及 `data.retryAfter`。
- 所有 Email 存在性相關公開回應維持不可列舉，驗證前不發一般 Session。

### Database

- 新增 `member_document_acceptances`、`email_verification_tokens`、`registration_rate_limit_buckets`。
- V3 Migration 支援空庫及既有 V2 schema 升級；Email／IP 限流識別只保存 HMAC hash。
- 七日清理只刪除未驗證且沒有私人資料或關聯資料的空會員，使用批次鎖避免競爭。

### UI

- 初始註冊不再要求帳號或暱稱，只提交 Email、密碼與目前條款／隱私版本。
- 待驗證頁使用一般化已受理文案，重寄後顯示 60 秒冷卻。
- `/verify-email?token=...` 依穩定 code 顯示完成、過期、無效或重新開始流程。
- 條款與隱私 URL 以可選取文字呈現；未新增未授權的外部連結套件。

### Tests

- Backend 完整單元測試：282 項通過、4 項 skipped。
- Backend MySQL 8.4 完整整合測試：通過。
- Flutter 完整測試：169 項通過；`flutter analyze --no-pub` 無問題。
- Flutter Web staging build：使用 `API_BASE_URL=https://monsters-staging.up.railway.app/api` 通過；僅有既存 CupertinoIcons font 警告。
- OpenAPI 契約測試、Flyway 空庫與 V2→V3 升級測試：通過。

### Log Retention

- 已檢查 `CHANGE_LOG.md`、以試算表工具唯讀檢查 `CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`。
- 保存期限截止日為 2026-06-29；CSV 與 XLSX 最早紀錄皆為 2026-06-29，未發現早於截止日的紀錄，本次未刪除 Log。
- CSV 與 XLSX 使用範圍皆為 13 欄；XLSX 未修改。

### Deployment

- Railway Backend URL 不寫死於應用程式碼；Flutter 由各分支建置時的 `API_BASE_URL` 注入。
- Railway 尚需依環境設定條款／隱私版本與 URL、Frontend 驗證 URL、CORS、限流 HMAC secret、SMTP 及 Worker／Cleanup 開關。

### Pending

- Task 03 維持 REVIEW；本地提交已完成，待使用者決定是否推送並建立 PR，再由 GitHub CI 與 PR review 驗證。
- 未取得各環境 Flutter Web 公開 URL 與 SMTP provider 設定，因此寄信 Worker 預設維持停用；不影響程式碼與契約驗收。

---

## 2026-07-29 12:32

Task
Registration Login 02 會員狀態機與 Continuation Credential（REVIEW）

Agent
Codex

### Completed

- 建立七態會員生命週期、安全優先序與 `DELETED` terminal 規則；外部不提供泛用 `targetState` API。
- 建立 `completeEligibility` 專用 Command，合法轉移在同一交易更新 optimistic version、撤銷舊 Continuation Credential、寫入 Audit 與 Transactional Outbox。
- Continuation Credential 使用 32-byte 安全隨機值、10 分鐘到期、Server 只保存 SHA-256 hash；一般 Security Filter 不接受此憑證。
- 登入與 Google 登入依會員狀態回 `AUTHENTICATED` 或 `AUTH_CONTINUATION_REQUIRED`；Refresh 只允許 `ACTIVE`。
- Flutter 可解析 continuation 回應，但不設定 Authorization、不保存 credential、不建立 Session或導向首頁。
- 導入 Flyway V1 baseline 與 V2 會員狀態 migration，驗證空庫建立及既有會員升級。
- 將 Auth／Member 整合測試改為 Flyway schema＋JPA `validate`，並修正既有 `entry_drafts.score`、`moods.score` 的 `TINYINT` Entity mapping 漂移。

### Modified

- Backend：Auth Controller／Service／DTO、會員狀態與 Continuation Entity／Repository／Service、會員生命週期 Command、Audit、Outbox、錯誤碼、既有 `TINYINT` mapping 與測試。
- Database：`backend/src/main/resources/db/migration/`、`database/init/README.md`；`database/init/01_schema.sql` 保持 V1 baseline，避免與 V2 重複。
- Frontend：登入結果模型、Auth Repository／Session Store／Provider、登入頁、首頁 nullable member 顯示與測試。
- Documentation：`CONTEXT.md`、Project／API／Database／UI／Decision、ADR 0003／0008、OpenAPI 及獨立 Registration Login Task 文件。
- 未修改 `docs/TASKS.md` 或 `system_data/`。

### system_data Reference

- 檢查舊系統註冊、登入、Google 登入與個人資料流程；舊系統沒有七態會員狀態機、用途受限 Continuation Credential 或 Transactional Outbox 可直接沿用。
- 正式 Registration Login 規格、決策與 ADR 優先；未修改 `system_data/`。

### API

- `POST /api/auth/login` 與 `POST /api/auth/google-login` 新增穩定 `AUTHENTICATED`／`AUTH_CONTINUATION_REQUIRED` code。
- 未完成流程回 `nextAction`、`continuationCredential`、`expiresIn: 600`，且不回 Access／Refresh Token。
- 不合法狀態與 version 衝突分別使用 `409 MEMBER_STATE_CONFLICT`、`409 VERSION_CONFLICT`。
- OpenAPI 明確分離完整 Session 與 Continuation Response。

### Database

- `users` 新增唯一 `public_id`、`member_state` 與 optimistic `version`。
- 新增 `member_continuation_credentials`、`member_state_audits`、`outbox_events`。
- Flyway V1 固定現況 baseline；V2 回填既有會員 UUID、`ACTIVE` 與 version 0，再建立 Task 02 結構。

### UI

- Continuation 回應停留登入頁，依 `nextAction` 顯示安全下一步提示。
- Continuation Credential 不顯示、不放入 Authorization Header、不寫入 SharedPreferences 或一般 Session。

### Tests

- TDD 紅綠循環：Continuation HTTP／Security Filter、狀態交易、非法狀態、version 衝突、公開錯誤碼、Flyway V1→V2、Flutter Repository／Widget、狀態優先序與 OpenAPI。
- Backend 完整單元測試：通過。
- Backend MySQL 8.4 完整整合測試：通過。
- Flutter 完整測試：168 項通過；`flutter analyze --no-pub` 無問題。
- 本機 Flutter 為 3.44.6；為避免改寫專案 Flutter 3.29.2／Dart 3.7.2 lockfile，完整測試使用 `--no-pub`。正式版本門檻待 GitHub CI 3.29.2 驗證。

### Log Retention

- 已檢查 `CHANGE_LOG.md`、以原始 CSV parser 檢查 `CHANGE_HISTORY.csv`，並讀取 `CHANGE_HISTORY.xlsx`。
- 保存期限截止日為 2026-06-29；CSV 與 XLSX 最早紀錄皆為 2026-06-29，未發現早於截止日的紀錄，本次未刪除 Log。
- CSV 既有 41 筆 9 欄舊格式及 4 個空列未修改；本次新增資料維持 13 欄格式。XLSX 未作為本次紀錄來源且未修改。

### Pending

- Task 02 維持 REVIEW，待推送、GitHub CI 及 PR review；未取得推送或建立 PR 授權。
- Task 03 必須在 Task 02 合併並轉為 DONE 後才能開始。

---

## 2026-07-29 10:54

Task
Flutter CI Google Sign-In 相依相容性修正（REVIEW）

Agent
Codex

### Completed

- 將直接使用的 `google_sign_in_web` 固定為 `1.1.0`，維持既有 Google Web 登入實作，不更換套件或框架。
- 使用 GitHub Actions 相同的 Flutter 3.29.2／Dart 3.7.2 重新解析鎖檔，避免新版相依將最低 Dart 版本提高至 3.9。
- 鎖定 Flutter 3.29.2 可解析的間接相依版本，確保 CI 執行 `flutter pub get` 可重現。

### Modified

- `frontend/pubspec.yaml`
- `frontend/pubspec.lock`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- Flutter 3.29.2／Dart 3.7.2 `pub get`：通過。
- Flutter 3.29.2／Dart 3.7.2 `test --no-pub`：166 項通過。
- Flutter 3.29.2／Dart 3.7.2 `build web --no-pub`：成功。

### system_data Reference

- 本次為 CI 相依版本修正，無需採用舊系統流程。
- 未修改 `system_data/`。

### API

- 無異動。

### Database

- 無異動，無 Migration。

### UI

- 無功能或版面異動。

### Log Retention

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與既有 `CHANGE_HISTORY.xlsx`。
- 保存期限截止日為 2026-06-29；最早紀錄為 2026-06-29，未發現早於截止日的紀錄，本次未刪除 Log。
- `CHANGE_HISTORY.csv` 既有第 974 至 1014 筆資料為 9 欄舊格式；本次未修改該既有紀錄，新增資料維持目前 13 欄格式。

### Pending

- 等待此修正分支推送並由 GitHub Actions 驗證；未取得推送或建立 PR 授權，本次僅建立本機提交。
- Registration Login Task 01 在修正合併前維持 REVIEW；Task 02 依已確認的 7 狀態方案接續處理。

---

## 2026-07-29 10:10

Task
Registration Login 01 Auth／Member 真實驗收骨架（REVIEW）

Agent
Codex

### Completed

- 建立獨立 `integrationTest` 測試層，以 Testcontainers 1.21.4 啟動 MySQL 8.4，不使用 H2 作主要驗收。
- 建立 Auth／Member 真實 HTTP 整合測試，啟用正式 Security Filter，驗證未授權 Member 請求、Auth 資料庫查詢及 Google 登入接縫。
- 將應用程式時間改由 `Clock` Bean 注入；建立正式 Email Delivery／Async Job port，整合測試提供固定時間及 Email、Google、非同步工作的替代 Bean。
- 擴充共用 API envelope，加入穩定 `code`、安全 `fieldErrors` 與 UUID 格式 opaque `requestId`。
- 預期錯誤 Log 不再輸出 Exception 內容或被拒絕的欄位值，只記錄狀態、類型或欄位名稱。
- 建立 Backend unit、Backend MySQL integration、Flutter 與 OpenAPI contract 四層 CI。
- Task 01 依 `TODO → IN PROGRESS → REVIEW` 更新，未修改 `docs/TASKS.md`。

### Added

- `.github/workflows/registration-login-ci.yml`
- `backend/src/integrationTest/java/com/monsters/auth/AuthMemberHttpIntegrationTest.java`
- `backend/src/integrationTest/java/com/monsters/support/AuthMemberControlledDependencies.java`
- `backend/src/main/java/com/monsters/config/common/TimeConfig.java`
- `backend/src/main/java/com/monsters/job/AsyncJob.java`
- `backend/src/main/java/com/monsters/job/AsyncJobDispatcher.java`
- `backend/src/main/java/com/monsters/notification/email/EmailDeliveryPort.java`
- `backend/src/main/java/com/monsters/notification/email/EmailDeliveryRequest.java`
- `backend/src/test/java/com/monsters/contract/RegistrationLoginOpenApiContractTest.java`
- `docs/openapi/registration-login.yaml`

### Modified

- `backend/build.gradle`
- `backend/src/main/java/com/monsters/dto/common/ApiResponse.java`
- `backend/src/main/java/com/monsters/exception/common/GlobalExceptionHandler.java`
- `backend/src/main/java/com/monsters/security/common/SecurityExceptionHandler.java`
- `backend/src/main/java/com/monsters/service/auth/AuthService.java`
- `backend/src/test/java/com/monsters/dto/common/ApiResponseTest.java`
- `docs/API_SPEC.md`
- `docs/REGISTRATION_LOGIN_TASKS.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- Backend `test`：通過。
- Backend `compileIntegrationTestJava`：通過。
- Backend `integrationTest`：以 Docker Desktop 29.6.2 與 MySQL 8.4 通過。
- Flutter `test --no-pub`：166 項通過。
- OpenAPI YAML parse、envelope schema contract 與 Git whitespace 檢查：通過。

### system_data Reference

- 參考舊系統註冊、登入、Google、忘記密碼與會員資料流程，只作 Migration baseline。
- 未沿用舊 `account` 主鍵、空密碼 Google 登入、server PIN、舊暱稱／頭貼契約或敏感設定。
- 未修改 `system_data/`。

### API

- 共用 `ApiResponse<T>` 新增 `code`、`fieldErrors` 與 `requestId`。
- Security 401 使用 `AUTHENTICATION_REQUIRED`，403 使用 `PERMISSION_DENIED`。
- 既有 Endpoint path 與 Request DTO 未修改。

### Database

- 正式 Schema 與 Migration 無異動。
- 整合測試由 Hibernate 在一次性 MySQL 8.4 container 建立並清除測試 Schema。

### Log Retention

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與既有 `CHANGE_HISTORY.xlsx`。
- 保存期限截止日為 2026-06-29，未發現早於截止日的紀錄，本次未刪除 Log。

### Pending

- Email／Async port 本 Task 只建立可替換邊界；正式 Outbox、Worker、重試與供應商 Adapter 由後續對應 Task 實作。
- 等待 Task PR review 與合併至 `feature/phase4.5`；合併前不標記 DONE。

---

## 2026-07-29 09:26

Task
DOC-016 Registration Login Task 拆解（REVIEW）

Agent
Codex

### Completed

- 依使用者指定的 `to-tickets` 流程，將註冊、登入與會員管理規格拆為 18 張 tracer-bullet Task。
- 每張 Task 都包含使用者可驗證的完整交付行為、明確阻擋關係、`ready-for-agent` 狀態及驗收條件。
- 依使用者要求，先完成會員本人註冊、登入、Session、資料匯出與刪除，再於最後階段處理特權角色、Admin管理與Legal Hold。
- 建立獨立Task文件，未修改或加入既有`docs/TASKS.md`。
- 檢查Log保存期限；最早紀錄為2026-06-29，未超過一個月，因此未刪除Log。

### Added

- `docs/REGISTRATION_LOGIN_TASKS.md`

### Modified

- `log/CHANGE_HISTORY.csv`

### Tests

- 文件工作，不執行程式Compile／Test。
- 驗證18張Task編號連續，且每張都有`Blocked by`、`Status`與Acceptance Criteria。
- 驗證依賴圖無循環、frontier只有Task 01、Markdown code fence與Git whitespace正常。
- 驗證`docs/TASKS.md`沒有異動。

### system_data Reference

- 本次沿用已核准規格中的現況差距，不另外修改或複製`system_data/`內容。
- 舊`account`、JWT Refresh、SharedPreferences Credential、server PIN與public avatar只作Migration Task輸入。

### API

- Task描述未來Auth、Member、Admin及Data Rights API交付與驗收，未修改任何Endpoint。

### Database

- Task描述未來MySQL、Flyway、Session、State、Export與Deletion Migration，未修改Schema。

### UI

- Task描述未來Flutter Web／Android／iOS流程與測試，未修改Flutter或Penpot。

### Pending

- DOC-016文件Review與Git／PR流程。
- 目前可立即開始的frontier只有Task 01。

---

## 2026-07-28 17:36

Task
DOC-015 註冊、登入與會員管理完整需求規格（REVIEW）

Agent
Codex

### Completed

- 接續需求訪談第 26–38 題，使用者確認已達成共同理解。
- 建立註冊、登入、會員生命週期、公開暱稱、Admin、匯出與刪除的完整需求文件。
- 整理 20 項功能驗收條件、32 類測試矩陣、`develop` 現況差距及六階段實作順序。
- 依使用者決策將匿名社群調整為受治理的公開暱稱社群；ADR-0009 取代 ADR-0006 的跨貼文匿名身分。
- 同步 AGENTS、README、共同語言、ADR、Project、Database、API、UI、Decisions、Phase 4.5 與 Tasks。
- 檢查 Log 保存期限；最早紀錄為 2026-06-29，未早於 2026-06-28，因此未刪除 Log。

### Added

- `docs/REGISTRATION_LOGIN_MEMBER_MANAGEMENT_SPEC.md`
- `docs/adr/0009-public-nickname-governed-community.md`

### Modified

- `AGENTS.md`
- `CONTEXT.md`
- `README.md`
- `docs/adr/0004-entry-and-community-post-boundary.md`
- `docs/adr/0006-governed-closed-community.md`
- `docs/DECISIONS.md`
- `docs/PROJECT_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/PHASE4_5_FOUNDATION_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- 文件工作，不執行程式 Compile／Test。
- 執行 Markdown 連結、標題、關鍵決策、CSV 欄數、Git whitespace 與文件 diff 檢查。

### system_data Reference

- 只讀參考舊註冊、登入與會員 API／Repository 流程。
- 舊 `account`、空密碼 Google 登入、SharedPreferences 登入狀態與 server PIN 只作差距證據，不沿用為目標規格。
- 未修改、搬移、刪除或格式化 `system_data/`。

### API

- 文件定義 Auth、Member、Admin 與 Data Rights 的 Status／error matrix、continuation credential、opaque Session family 與受控 PII lookup。
- 本次未修改 Backend endpoint。

### Database

- 文件定義會員狀態、Eligibility、公開暱稱、Session、Permission、Export、Deletion 與 Legal Hold 目標資料需求。
- 本次未修改 Schema 或執行 Migration。

### UI

- 文件定義註冊、登入、Eligibility、公開暱稱確認、Session 管理、受限狀態與 Data Rights UI 要求。
- 本次未修改 Flutter 或 Penpot。

### Pending

- DOC-015 文件 Review 與 Git／PR 流程。
- 所有程式、Schema、OpenAPI 與 UI 實作需另行拆 Task。

---

## 2026-07-28 15:32

Task
DOC-014 Phase 4.5 `to-spec` 規格化（REVIEW）

Agent
Codex

### Completed

- 依 `to-spec` 將 2026-07-26 Grilling 核准基線整理為可交付 Phase 4.5 規格。
- 使用者確認最高驗收接縫為私人核心跨平台 E2E：註冊／資格、Session、Entry／Media、Export／Deletion。
- 建立 Problem、Solution、52 項 User Stories、Implementation Decisions、Testing Decisions、Out of Scope 與 Further Notes。
- 同步 Project、Database、API、UI、Coding Standard、Decisions 與 Tasks 的規格索引。
- 檢查 Log 保存期限；最早紀錄為 2026-06-29，未早於 2026-06-28，因此未刪除 Log。

### Added

- `docs/PHASE4_5_FOUNDATION_SPEC.md`

### Modified

- `docs/PROJECT_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/CODING_STANDARD.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- 文件工作，不執行程式 Compile／Test。
- 執行 Markdown 連結、User Story 數量、關鍵邊界、CSV 欄數、Git whitespace 與文件 diff 檢查。

### system_data Reference

- 沿用 DOC-013 對舊會員、日記、煩惱、媒體、社群及互動流程的盤點結果。
- 未沿用 Account、SharedPreferences Token、公開頭貼、server PIN、`isShared`、隨機怪獸與未治理社群。
- 未修改、搬移、刪除或格式化 `system_data/`。

### API

- 文件規格化 `/api/v1`、OpenAPI、UUID public ID、opaque Refresh Session、optimistic version 與 idempotency 驗收。
- 本次未修改 Backend endpoint。

### Database

- 文件規格化 Flyway、Outbox、資料生命週期、Restore marker 與真實 MySQL 測試接縫。
- 本次未修改 Schema 或執行 Migration。

### UI

- 文件規格化 Web／Android／iOS Session、資格、Privacy Lock 與私人核心 E2E 行為。
- 本次未修改 Flutter 或 Penpot。

### Pending

- DOC-014 文件 Review 與 Git／PR 流程。
- Issue Tracker 發布需使用者另行授權。

## 2026-07-28 15:58 PHASE4-DEVELOP-SYNC

Task

Phase 4 同步 `develop` 與任務狀態稽核（REVIEW）

執行者

Codex

### 完成內容

- 確認 `origin/develop` 比 `origin/feature/phase4` 多 4 個文件契約 Commit，將 PR #79／#82 的 grilling 決策、Phase 4 contract、`CONTEXT.md` 與 8 份 ADR 合併至 `feature/phase4`。
- 解決 `API_SPEC`、`DATABASE_SPEC`、`PROJECT_SPEC`、`UI_SPEC` 與 `CHANGE_LOG` 衝突；以 `/api/v1`、UUID、optional Emotional Load、獨立 Community Post 等新契約為正式目標，保留 Phase 4 既有程式與持久草稿為 Migration baseline。
- 明確區分未同步本機草稿與 owner-scoped 伺服器草稿：前者不持久化，後者依已核准方案保留 30 天。
- 即時查核 GitHub：Phase 4 Task PR #66～#78、#81 全部已合併至 `feature/phase4`；DOC-013 的 PR #79 與 Phase 4 contract PR #82 已合併至 `develop`。
- 將 DOC-013、PR #81 持久草稿 Task 與 Phase 4 整合測試轉為 DONE；Phase 4 整體保留 REVIEW，等待 Phase PR 合併至 `develop`。
- 保留「依已核准 v1 Entry 架構與 API 規格重新實作」為 Phase 4.5 TODO，未將現有 `/api`、`isShared` 與必填分數實作誤標為完成。
- 建立正式 Phase PR #83（`feature/phase4 → develop`）；PR 為 OPEN、非 Draft，GitHub merge state 為 CLEAN。

### 修改檔案

- `AGENTS.md`、`CONTEXT.md`、`README.md`
- `docs/API_SPEC.md`、`docs/DATABASE_SPEC.md`、`docs/PROJECT_SPEC.md`、`docs/UI_SPEC.md`
- `docs/CODING_STANDARD.md`、`docs/DECISIONS.md`、`docs/TASKS.md`
- `docs/PHASE2_TEST_REPORT.md`、`docs/PHASE3_ANNOYANCE_DESIGN_PROPOSAL.md`、`docs/SYSTEM_DATA_REFERENCE.md`
- `docs/adr/0001`～`0008`
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`

### system_data 參考結果

- 本次為分支同步與狀態稽核，未修改、搬移、刪除或格式化 `system_data/`。
- 沿用 Phase 4 各 Task 已完成的舊系統流程與素材查核結果；新契約明確標示舊 Account、server PIN、boolean 分享與隨機獎勵僅為歷史基線。

### API 異動

- 合併文件中的 `/api/v1`、UUID public ID、OpenAPI、穩定 error code、optimistic version 與 idempotency 目標契約。
- 保留 Phase 4 既有 `/api` endpoint 與持久草稿 API 為 Migration baseline；本次未修改 Backend endpoint。

### Database 異動

- 合併 Flyway、Community Post、Session、資料生命週期與 Transactional Outbox 目標模型。
- 保留 `entry_drafts`／`entry_draft_media` 現況與 30 天保存規則；本次未修改 Schema、Migration 或資料。

### UI 異動

- 合併 optional Emotional Load、獨立公開快照、隱私遮罩與本機鎖目標規格。
- 保留 owner-scoped 伺服器草稿的恢復與失敗重試流程；本次未修改 Flutter UI。

### 測試方式與結果

- Backend `gradlew test`：BUILD SUCCESSFUL，275 tests、0 failures、0 errors、4 skipped，76.7 秒。
- Flutter Analyze：PASS，無問題，16.1 秒。
- Flutter完整測試：PASS，166 tests，67.9 秒。
- Flutter Web build：PASS，114.6 秒。
- `git diff --cached --check` 與衝突標記檢查：通過。

### Log 保存期限檢查結果

- 以 2026-07-28 為基準檢查 `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv`；最早紀錄均為 2026-06-29，未早於 2026-06-28。
- 未發現超過一個月的 Log，未刪除紀錄；`CHANGE_HISTORY.xlsx` 本次未作為紀錄來源且未修改。

### 待確認事項

- Phase PR #83 已建立，等待 Review 與合併至 `develop`；合併完成前 Phase 4 維持 REVIEW。
- Phase 4.5 必須先完成 v1 契約 Migration，Phase 5 以後功能維持 BLOCKED。

---

## 2026-07-28 15:01 PHASE4-ENTRY-DURABLE-DRAFTS

Task
Phase 4 日記／煩惱持久草稿與媒體暫存機制（REVIEW）

執行者
Codex

### 完成內容

- 確認首頁日記入口 PR #78 已合併至 `feature/phase4`，將前一個 Task 轉為 DONE。
- 依使用者選定方案一，將日記與煩惱的本機記憶體草稿改為 owner-scoped 伺服器持久草稿；每位使用者每種類型只保留一份，儲存後續期 30 天。
- 新增 restore、save、discard、submit 與草稿媒體下載 API；媒體沿用 private R2 驗證與 object key，送出時在同一 Database transaction 轉為正式 Entry，不重複上傳。
- Flutter 進入頁面時自動還原步驟、文字、選項與暫存媒體；狀態變更自動暫存、文字採 debounce，送出前等待最後一次同步。
- 「重新開始」改為先確認再刪除伺服器草稿；一般返回、重新整理或重新登入不刪除草稿。
- 定期清理採每批 100 筆的 keyset 批次與 30 天期限；單次排程會持續處理後續批次，失敗項目留待下次排程，不會阻塞較新的到期草稿。
- 儲存、送出、捨棄與清理共用 row lock，清理取得鎖後再次確認到期時間，避免刪除剛被續存的草稿。
- 明確捨棄或到期清理若刪除 R2 object 失敗，保留 Database metadata 供下次重試。
- Penpot Diary／Annoyance Web／Mobile 已同步「暫存並繼續」及 30 天跨裝置草稿文案。

### 修改／新增／刪除檔案

- 新增 Backend Entry Draft Entity、DTO、Repository、Persistence／Deletion／Cleanup／Domain Service 與對應單元測試。
- 修改 Diary、Annoyance 與 Entry Media Controller，新增日記／煩惱草稿與 owner-only 草稿媒體 endpoint。
- 新增 `frontend/lib/models/entry_draft_snapshot.dart` 與 generated JSON parser；修改 Diary／Annoyance Repository、Provider、頁面及 Entry 共用媒體預覽。
- 修改 Diary／Annoyance page、provider、repository 測試，涵蓋草稿還原、媒體 metadata 與 durable endpoint。
- 新增 `database/migrations/20260724_01_add_entry_drafts.sql`，並同步 `database/init/01_schema.sql`。
- 修改 `docs/PROJECT_SPEC.md`、`docs/API_SPEC.md`、`docs/DATABASE_SPEC.md`、`docs/UI_SPEC.md`、`docs/DECISIONS.md`、`docs/TASKS.md`。
- 未修改 `system_data/` 或 `log/CHANGE_HISTORY.xlsx`。
- 既有未提交的 `frontend/pubspec.lock`、`frontend/tool/run_web_local.ps1` 與本 Task 無關的 `.agents/`、`skills-lock.json` 均保留且不納入 Commit。
- 本機 `frontend/tool/verify.ps1` 繼續由 `.git/info/exclude` 忽略，不納入 Git。

### system_data/ 參考結果

- 參考舊日記／煩惱聊天室的步驟、內容、心情圖、分數與分享流程，確認返回新增頁時應回到原紀錄的業務意圖。
- 舊系統只有正式新增流程，沒有持久草稿 API、草稿資料表或 private R2 暫存媒體機制。
- 未沿用舊系統的畫面記憶體狀態、直接 HTTP、account-based owner、Base64／public media 或硬編碼設定。

### API 異動

- 新增 `/api/diaries/draft` 與 `/api/annoyances/draft` 的 GET、multipart PUT、DELETE，以及 `/draft/submit` POST。
- 新增 `/api/diaries/draft/media/{mediaId}` 與 `/api/annoyances/draft/media/{mediaId}`，只允許目前 owner 以 JWT 下載。
- 草稿 PUT 接受部分完成狀態及既有暫存媒體 ID；完整記錄組合只在 submit 驗證。
- 無草稿時 GET 仍回傳 200 與 `{ "draft": null }`；submit 成功沿用既有 Diary／Annoyance 201 response。

### Database 異動

- 新增 `entry_drafts`，以 `(user_id, entry_type)` unique 限制每位使用者每種類型一份草稿，保存步驟、部分欄位與 `expires_at`。
- 新增 `entry_draft_media`，每個草稿的 CONTENT／DRAWING 各最多一筆，保存 private R2 object metadata。
- Migration 使用 `CREATE TABLE IF NOT EXISTS`，可重複執行；送出時沿用 object key 建立正式 `entry_media`。

### 文件更新

- Project、API、Database、UI、Decision 已同步 30 天期限、owner-only、跨裝置恢復、submit transaction、R2 清理重試與並行鎖定規則。
- `docs/TASKS.md` 將 PR #78 首頁 Task 轉為 DONE，並將持久草稿 Task 推進至 REVIEW。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 記錄本次實作與驗證。

### 測試方式與結果

- Backend `gradlew test`：275 tests，0 failures，4 skipped，BUILD SUCCESSFUL。
- Flutter Analyze：PASS，31.3 秒。
- Flutter完整測試：166 tests passed，50.1 秒。
- Flutter Web Build：PASS，132.7 秒；既有 CupertinoIcons 字型提示與 Wasm 建議未造成失敗。
- 草稿 Provider／Repository 定向測試：24 tests passed；Backend 草稿 Service、Deletion 與 Controller 定向測試通過。
- Docker Desktop 未執行，因此未執行真實 MySQL／R2 端到端；Schema、Migration、transaction、storage cleanup 與 API 行為由靜態檢查及隔離測試涵蓋。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；2026-07-28 的保存期限截止日為 2026-06-28。
- 三者最早正式紀錄皆為 2026-06-29，無超過一個月的紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 維持只讀且未修改。

### 待確認事項

- 本 Task 維持 REVIEW；Commit、Push 與 Draft PR #81 已完成，待轉 Ready 並合併至 `feature/phase4` 後才能標記 DONE。
- 部署前需在實際 MySQL 先套用 `database/migrations/20260724_01_add_entry_drafts.sql`，並確認 Backend 的 private R2 設定可用。

---

## 2026-07-24 10:48 PHASE4-HOME-DIARY-ENTRY

Task
Phase 4 Flutter 首頁導入紀錄日記（REVIEW）

執行者
Codex

### 完成內容

- 確認前一個 Reward Task PR #77 已合併至 `feature/phase4`，將該 Task 轉為 DONE。
- 比對正式 UI／Project 規格、既有 `AppRoute.diaryChat` 與舊系統首頁流程，確認首頁應直接導向 `/diaries/new`。
- 將 Desktop、Tablet、Mobile 首頁日記行動統一接至 `context.pushNamed(AppRoute.diaryChat)`。
- 新增共用 `homeDiaryChatButton` 測試 key，並將 Mobile 日記卡片的「即將開放」改為「開始記錄」。
- 補齊 390px Mobile、900px Tablet、1440px Desktop 的首頁日記導向回歸測試；Tablet 測試會先將可捲動區中的卡片移入可視範圍再點擊。

### 修改／新增／刪除檔案

- 修改 `frontend/lib/pages/home_page.dart`、`frontend/test/home_page_test.dart`。
- 修改 `docs/UI_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`。
- 未新增或刪除檔案，未修改 `system_data/`、API、Database、Penpot 或 `log/CHANGE_HISTORY.xlsx`。
- 既有未提交的 `frontend/pubspec.lock`、`frontend/tool/run_web_local.ps1` 已保留，不納入本 Task。
- 本機 `frontend/tool/verify.ps1` 仍未由 Git 追蹤。

### system_data/ 參考結果

- 舊 `system_data/front-end/monsters_front_end/lib/pages/home.dart` 的日記按鈕使用 `Navigator.push` 直接建立 `diaryChat`，確認舊流程同樣由首頁進入日記。
- 新版未沿用舊 `MaterialPageRoute` 與舊 Widget 命名，改用正式的 GoRouter named route。

### API 異動

- 無 API endpoint、request、response 或驗證規則異動；本 Task 只啟用既有 `/diaries/new` 前端入口。

### Database 異動

- 無 schema、SQL、Migration 或資料異動。

### 文件更新

- `docs/UI_SPEC.md` 將首頁日記入口由「即將開放」更新為 Desktop／Tablet／Mobile 可操作，並記錄 named route contract。
- `docs/TASKS.md` 將 PR #77 Reward Task 轉為 DONE，記錄本 Task 的 TODO → IN PROGRESS → REVIEW。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 記錄本次首頁導向與驗證。

### 測試方式與結果

- `home_page_test.dart`：17 tests passed，包含三種 window class 的日記導向。
- Flutter Analyze：No issues found，4.9 秒。
- Flutter 完整測試：162 tests passed。
- Flutter Web Build：成功，122.7 秒；既有 CupertinoIcons 字型提示與 Wasm 建議未造成失敗。
- 現有 Web 開發伺服器持有 Flutter 啟動器鎖；驗證改用同一 Flutter SDK 的 tool snapshot 並設定 reentrant lock，未停止或干擾現有伺服器。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv`；2026-07-24 的保存期限截止日為 2026-06-24。
- 最早正式紀錄為 2026-06-29，無超過一個月的紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- 本 Task 維持 REVIEW；Draft PR #78 已建立，待轉 Ready 並合併至 `feature/phase4` 後才能標記 DONE。
- Phase 4 最後的整合「測試」Task 仍待執行。

---

## 2026-07-24 10:08 PHASE4-ENTRY-REWARD-NULL

Task
Phase 4 日記與 Phase 3 煩惱完成頁保持 `reward = null`（REVIEW）

執行者
Codex

### 完成內容

- 確認 Reward 前一個 Task PR #76 已合併至 `feature/phase4`，將日記分數 Task 轉為 DONE。
- 比對正式 Project／API／UI／Decision 與舊系統手冊，確認煩惱 Phase 3、日記 Phase 4 都不得發放怪獸或顯示舊獎勵彈窗，真實獎勵延至 Phase 6。
- 發現既有 Mapper 雖回傳 null，但 Jackson 會忽略 `Void reward`，導致實際 JSON 缺少 `reward` key。
- 將 Annoyance／Diary Response 的 Reward 改為明確永遠序列化，並在 compact constructor 拒絕任何 Phase 6 前的非 null 值。
- 補強 Flutter Repository、Provider、Web／Mobile 完成頁測試，確認 `reward` 保持 null，且不顯示「獎勵」、「恭喜你獲得」或「查看圖鑑」。

### 修改／新增／刪除檔案

- 修改 `backend/src/main/java/com/monsters/dto/annoyance/AnnoyanceResponse.java`、`backend/src/main/java/com/monsters/dto/diary/DiaryResponse.java`。
- 新增 `backend/src/test/java/com/monsters/dto/entry/EntryRewardContractTest.java`。
- 修改 `frontend/test/annoyance_chat_page_test.dart`、`frontend/test/diary_chat_page_test.dart`。
- 修改 `frontend/test/providers/annoyance_chat_provider_test.dart`、`frontend/test/repositories/annoyance_repository_test.dart`。
- 修改 `docs/API_SPEC.md`、`docs/UI_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`。
- 未刪除檔案，未修改 `system_data/`、Database 檔案、Penpot 或 `log/CHANGE_HISTORY.xlsx`。
- 本機 `frontend/tool/verify.ps1` 仍由 `.git/info/exclude` 忽略，未納入本次 Commit。

### system_data/ 參考結果

- 系統手冊第 124 頁與第 128 頁分別顯示舊煩惱、舊日記新增後可能立即出現「恭喜你獲得一隻怪獸」與「查看圖鑑」彈窗。
- 參考舊 `annoyanceChat.dart`、`diaryChat.dart` 的 `newMonster`、`newMonsterGroup` 與 `PresentWidget` 流程，確認新版正式規格刻意延後此功能。
- 未沿用舊系統立即抽怪獸、直接 HTTP、全域帳號或硬編碼設定。

### API 異動

- Endpoint 與 request contract 無異動。
- 修正 Annoyance／Diary response serialization，使 Phase 3／4 JSON 明確包含 `"reward": null`，不再省略欄位。
- DTO 在 Phase 6 前拒絕任何非 null Reward，避免提早發放假獎勵。

### Database 異動

- 無 schema、SQL 或 Migration 異動；本 Task 不新增獎勵資料或使用者怪獸關聯。

### 文件更新

- `docs/API_SPEC.md` 明確要求 null Reward key 不得省略。
- `docs/UI_SPEC.md` 明確禁止煩惱／日記完成頁顯示舊獎勵文案與圖鑑操作。
- `docs/TASKS.md` 將 PR #76 日記分數 Task 轉為 DONE，記錄本 Task 的 TODO → IN PROGRESS → REVIEW。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 記錄本次修正與驗證。

### 測試方式與結果

- Backend Reward contract 定向測試：3 tests passed。
- Backend `gradlew test --no-daemon`：262 tests passed。
- Flutter Annoyance／Diary Reward 定向測試：44 tests passed。
- Flutter Analyze：No issues found，10.9 秒。
- Flutter完整測試：159 tests passed，57.4 秒。
- Flutter Web Build：成功，95.6 秒；僅有既有 CupertinoIcons 字型提示與 Wasm 建議，未造成失敗。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；2026-07-24 的保存期限截止日為 2026-06-24。
- `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv` 最早正式紀錄皆為 2026-06-29，無超過一個月的紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- 本 Task 維持 REVIEW；Draft PR #77 已建立，待轉 Ready 並合併至 `feature/phase4` 後才能標記 DONE。
- Phase 6 實作真實 Reward 時，需明確調整 DTO guard、API contract、Database 關聯與完成頁 UI，不得只移除 null。

---

## 2026-07-24 09:13 PHASE4-DIARY-SCORE

Task
Phase 4 Flutter 日記分數選擇（REVIEW）

執行者
Codex

### 完成內容

- 確認 Diary Mobile Task PR #75 已合併至 `feature/phase4`，將前一個 Task 轉為 DONE。
- 稽核既有 Diary Web／Tablet 共用 `MoodScoreSelector` 與 Mobile 分數流程，確認皆使用 `moodPoint_1.png`～`moodPoint_5.png`、1 至 5 分及中性分數文案。
- 確認 Web／Tablet 選擇後直接前進，Mobile 選擇後需明確確認，三種 window class 共用同一個 Diary state 與 1-based 整數。
- 既有正式功能已符合規格，本次未重寫 Widget、Provider 或 Repository；改以獨立測試補齊 1／5 邊界、0／6 拒絕、五個選項、語意標籤及 multipart 實際內容。

### 修改／新增／刪除檔案

- 修改 `frontend/test/widgets/mood_score_selector_test.dart`、`frontend/test/providers/diary_chat_provider_test.dart`、`frontend/test/repositories/diary_repository_test.dart`。
- 修改 `docs/UI_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`。
- 未新增或刪除檔案，未修改正式功能程式、`system_data/` 或 `log/CHANGE_HISTORY.xlsx`。

### system_data/ 參考結果

- 參考舊 `diaryChat.dart` 的 `emotionGradeMembers` 與 `indexOf` 流程，確認舊系統顯示的 1 至 5 分會對應為 1-based 整數，並沿用 `moodPoint_1.png`～`moodPoint_5.png` 的設計意圖。
- 未沿用舊系統大型 `setState`、直接 HTTP、Base64 JSON 媒體、全域帳號或硬編碼環境設定。

### API 異動

- 無 endpoint 或 API contract 異動。
- 新增測試直接檢查 multipart `request.json`，確認邊界值 1 與 5 會原值寫入 `score`，不轉為 0-based index 或 mood lookup ID。

### Database 異動

- 無 schema、SQL 或 Migration 異動；沿用 `moods.score` 的 1 至 5 唯一值規格。

### 文件更新

- `docs/UI_SPEC.md` 補充日記分數圖片、無障礙名稱、Web／Mobile 互動差異及 1-based multipart 規則。
- `docs/TASKS.md` 將 PR #75 Mobile Task 轉為 DONE，並記錄本 Task 的 TODO → IN PROGRESS → REVIEW。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 記錄本次驗收與保存期限檢查。

### 測試方式與結果

- 日記分數 Widget／Provider／Repository 定向測試：12 tests passed。
- `flutter analyze --no-pub`：No issues found。
- `flutter test --no-pub`：159 tests passed。
- `flutter build web --no-pub`：成功，產出 `build/web`；僅有既有 CupertinoIcons 字型提示與 Wasm 建議，未造成 build 失敗。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；2026-07-24 的保存期限截止日為 2026-06-24。
- `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv` 最早正式紀錄皆為 2026-06-29，無超過一個月的紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- Task PR #76 已建立且無合併衝突；合併至 `feature/phase4` 後才能將本 Task 標記 DONE。
- 下一個 Task 為確認 Phase 4 完成頁持續保持 `reward = null`，Phase 6 再串接真實獎勵。

---

## 2026-07-22 14:49 PHASE4-DIARY-MOBILE-CHAT

Task
Phase 4 依 Penpot `Diary Flow / Mobile` 適配 Flutter Mobile 日記聊天室（REVIEW）

執行者
Codex

### 完成內容

- 確認 Diary Web Task PR #74 已合併至 `feature/phase4`，將前一個 Task 轉為 DONE。
- 依使用者確認維持「一種主要記錄方式＋一張 optional 心情圖」，並將 Penpot `Diary / Mobile / 02 記錄方式` 的衝突文案同步為正式規格。
- 新增 390×844 Diary Mobile 專屬畫布，完成引導、記錄方式、內容、繪圖決定、畫布、分數、分享、確認、送出與 Phase 4 完成頁。
- Mobile 320px 至 599px 使用 `ResponsiveFixedCanvas` 等比例填滿 viewport，縮放高度超過 viewport 時可垂直捲動；Tablet／Desktop 仍使用既有 Responsive flow。
- 沿用既有 Diary draft、Riverpod Controller、Repository、媒體 Adapter 與 `POST /api/diaries` contract；Mobile 記錄方式、分數與分享採選擇後明確確認，Web／Tablet 行為保持相容。
- Phase 4 Mobile 完成頁只顯示安全保存、心情分數與分享狀態，未顯示假獎勵。

### 修改／新增／刪除檔案

- 新增 `frontend/lib/widgets/diary/diary_mobile_flow.dart`。
- 修改 `frontend/lib/pages/diary_chat_page.dart`、`frontend/lib/providers/diary_chat_provider.dart`。
- 修改 `frontend/lib/widgets/diary/diary_review_card.dart`、`frontend/lib/widgets/entry/entry_content_input.dart`，加入不影響既有呼叫端的 optional 標題控制。
- 修改 `frontend/test/diary_chat_page_test.dart`、`frontend/test/providers/diary_chat_provider_test.dart`。
- 修改 `docs/UI_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`。
- 未刪除檔案，未修改 `system_data/` 或 `log/CHANGE_HISTORY.xlsx`。
- `frontend/pubspec.lock` 與 `frontend/tool/run_web_local.ps1` 為 Task 開始前既有未提交修改，本次完整保留且不納入 Commit。

### system_data/ 參考結果

- 參考舊 `diaryChat.dart` 的聊天引導、單一文字／圖片／錄音／影片、optional 心情圖、分數與分享流程。
- 未沿用舊系統大型 `setState`、直接 HTTP、Base64 JSON 媒體、全域帳號或硬編碼環境設定。
- 正式 Project／API／Database／UI／Coding Standard 與 Penpot contract 優先；舊系統僅保留流程意圖。

### API 異動

- Backend endpoint 與 API contract 無異動。
- Flutter Mobile 沿用既有 `POST /api/diaries` multipart contract；每篇日記只送一種主要內容與 optional `drawingFile`，Phase 4 response `reward` 保持 null。

### Database 異動

- 無 schema、SQL 或 Migration 異動。

### 文件更新

- `docs/UI_SPEC.md` 補充 Diary Mobile 390×844 畫布、320px 至 599px 縮放、逐步確認與單一主要記錄方式。
- `docs/TASKS.md` 將 PR #74 Web Task 轉為 DONE，並記錄 Mobile Task 的 TODO → IN PROGRESS → REVIEW。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 記錄本次實作與驗證。

### 測試方式與結果

- `dart analyze`：No issues found。
- Diary Mobile Provider／Widget 與 Web 回歸定向測試：18 tests passed。
- Mobile viewport：320×700、390×844、500×900、599×900 通過；Web 1200×800、1440×900、1920×1080 回歸通過。
- `flutter test --no-pub`：156 tests passed。
- `flutter build web --no-pub`：成功，產出 `build/web`；僅有既有 CupertinoIcons 字型提示與 Wasm 建議，未造成 build 失敗。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；2026-07-22 的保存期限截止日為 2026-06-22。
- `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv` 最早正式紀錄皆為 2026-06-29，無超過一個月的紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- Task PR #75 已建立並等待 review；合併至 `feature/phase4` 後，才能將 Diary Mobile Task 標記 DONE。
- Flutter 日記分數選擇、Phase 4 `reward = null` 最終確認、首頁入口開放與 Phase 4 整合驗收仍依後續 Task 處理。

---

## 2026-07-22 11:47 PHASE4-DIARY-WEB-CHAT

Task
Phase 4 依 Penpot `Diary Flow / Web` 實作 Flutter Web 日記聊天室（REVIEW）

執行者
Codex

### 完成內容

- 確認 Entry 共用前端 Task PR #73 已合併至 `feature/phase4`，將前一個 Task 轉為 DONE。
- 依 Penpot `WEB / Diary Flow / Web` 的 9 個 Phase 4 狀態建立 `/diaries/new` Web 日記流程，完成引導、記錄方式、內容、optional 繪圖、分數、分享、確認、送出與安全保存畫面。
- 建立 Diary 獨立 draft state、Riverpod controller、Dio Repository、response DTO、review 與 completed 元件；未匯入 Annoyance 專屬 Widget 或型別。
- 重用 Entry 共用媒體、畫布、分數、分享與 Responsive flow shell，並為共用內容輸入及繪圖選擇元件加入可參數化文案與 2000 字上限。
- 串接 `POST /api/diaries` multipart request；文字只送 content，媒體送 contentFile，optional 心情圖送 drawingFile，失敗時保留草稿。
- Phase 4 完成頁只顯示安全保存、分數與分享狀態，不顯示假獎勵或假怪獸。

### 修改／新增／刪除檔案

- 新增 `frontend/lib/models/diary_draft.dart`、`diary_response.dart`。
- 新增 `frontend/lib/providers/diary_chat_provider.dart`、`diary_media_provider.dart` 與 `frontend/lib/repositories/diary_repository.dart`。
- 新增 `frontend/lib/pages/diary_chat_page.dart`、`frontend/lib/widgets/diary/` 與 `frontend/lib/widgets/entry/entry_chat_bubble.dart`。
- 修改 Entry 共用內容輸入、繪圖選擇、Navigation destination 與 go_router 路由。
- 新增 Diary Provider／Repository／Page 測試並更新 Router 測試。
- 修改 `docs/UI_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv`。
- 未刪除檔案，未修改 `system_data/` 或 `log/CHANGE_HISTORY.xlsx`。

### system_data/ 參考結果

- 參考舊 `diaryChat.dart` 的聊天式引導、文字／圖片／錄音／影片、optional 心情圖、分數與分享流程。
- 保留舊系統的使用者流程意圖；未沿用大型 `setState` 頁面、全域帳號、直接 HTTP Repository、Base64 JSON 媒體、硬編碼 URL 或送出後假獎勵。
- 正式 Project／API／Database／UI／Coding Standard 與 Penpot contract 優先，採 Riverpod、Dio Repository、go_router 與共用 Entry Responsive 架構。

### API 異動

- 未修改 Backend endpoint 或 API contract。
- Flutter 新增既有 `POST /api/diaries` multipart contract 串接；Phase 4 response `reward` 保持 null。

### Database 異動

- 無 schema、SQL 或 Migration 異動。

### 文件更新

- `docs/UI_SPEC.md` 補充 Diary Web 實作路徑、獨立資料層、Responsive 驗收與首頁入口開放時機。
- `docs/TASKS.md` 將 PR #73 共用前端 Task 轉為 DONE，並記錄 Diary Web Task 的 TODO → IN PROGRESS → REVIEW。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 記錄本次實作與驗證。

### 測試方式與結果

- `dart analyze`：No issues found。
- Diary Provider／Repository／Web RWD／路由定向測試：15 tests passed。
- `flutter test --no-pub`：148 tests passed。
- `flutter build web --no-pub`：成功，產出 `build/web`；僅有既有 CupertinoIcons 字型提示與 Wasm 建議，未造成 build 失敗。
- `git diff --check`：通過。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；2026-07-22 的保存期限截止日為 2026-06-22。
- `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv` 最早正式紀錄皆為 2026-06-29，無超過一個月的紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- 等待 Task PR 建立與 review；合併至 `feature/phase4` 後，才能將 Diary Web Task 標記 DONE。
- Diary Mobile Penpot 適配、首頁入口解除「即將開放」與 Phase 4 最終整合驗收仍屬後續 Task。

---

## 2026-07-22 11:04 PHASE4-ENTRY-FRONTEND-FOUNDATION

Task
Phase 4 Entry 共用前端元件、Responsive flow shell 與媒體 Adapter（REVIEW）

執行者
Codex

### 完成內容

- 將記錄方式、媒體檔案、心情繪圖等跨 Entry 型別抽至 `entry_record.dart`、`entry_media.dart` 與 `entry_drawing.dart`，Annoyance 草稿保留相容別名。
- 建立 Entry 共用 media service、validator 與 Web／IO／unsupported platform adapter；以 `recordingFilePrefix` 區分 Annoyance／Diary 錄音暫存檔。
- 將內容輸入、記錄方式、媒體預覽、繪圖、分數、分享與 Responsive flow shell 移至 `widgets/entry/`。
- 共用元件以 `keyPrefix`、標題與語意文案支援不同 Entry flow；Annoyance 改用共用元件並保留既有測試 key 與操作行為。
- 新增 Entry 共用 selector 與 Mobile／Tablet／Desktop shell 測試，並將媒體 validator 與共用 Widget 測試改為 Entry contract。
- 依狀態稽核結果將 LoginRequest、註冊排版、煩惱／日記媒體下載、媒體 Task closeout 與 App icon／Logo 共 6 項標記 DONE；登入頁排版維持 REVIEW。

### 修改／新增／刪除檔案

- 新增 `frontend/lib/models/entry_*.dart` 與 `frontend/lib/services/entry_media_*.dart`。
- 將可共用 Widget 從 `frontend/lib/widgets/annoyance/` 移至 `frontend/lib/widgets/entry/`，並參數化 flow-specific key 與文案。
- 修改 `frontend/lib/pages/annoyance_chat_page.dart`、Annoyance media Provider、相容模型／Service 與 `frontend/lib/theme/app_colors.dart`。
- 新增 `frontend/test/widgets/entry_shared_components_test.dart`，移轉 Entry media validator 測試並更新共用 Widget 測試。
- 修改 `docs/UI_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv`。
- 未修改 `system_data/` 或 `log/CHANGE_HISTORY.xlsx`。

### system_data/ 參考結果

- 參考舊 `diaryChat.dart` 的聊天式引導、文字／圖片／錄音／影片、optional 心情圖、分數與分享流程。
- 保留可重用的使用者流程與媒體選擇意圖；未沿用舊版 `setState` 大型頁面、全域登入狀態、直接 Repository 呼叫、硬編碼路徑或 `Navigator.push` 分散路由。
- 正式 Project／API／Database／UI／Coding Standard 優先，Entry 共用層採 Riverpod、Dio Repository、go_router 與 Responsive flow 架構。

### API 異動

- 無 API contract 或 endpoint 異動。
- 共用媒體前端限制仍與既有 Annoyance／Diary multipart contract 一致。

### Database 異動

- 無 schema、SQL 或 Migration 異動。

### 文件更新

- `docs/UI_SPEC.md` 補充 Entry 共用模型、媒體 Adapter、Widget 路徑與 Diary 不得依賴 Annoyance 專屬層的規則。
- `docs/TASKS.md` 同步 6 項 DONE、1 項保留 REVIEW，並記錄本 Task 的 TODO → IN PROGRESS → REVIEW。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 記錄本次實作與驗證。

### 測試方式與結果

- `flutter analyze --no-pub`：No issues found。
- Entry 共用元件、媒體 validator 與 Annoyance Page／Provider／Repository 定向回歸：35 tests passed。
- `flutter test --no-pub`：136 tests passed。
- `flutter build web --no-pub`：成功，產出 `build/web`；僅有既有 CupertinoIcons 字型提示與 Wasm 建議，未造成 build 失敗。
- `git diff --check`：通過。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；2026-07-22 的保存期限截止日為 2026-06-22。
- `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv` 最早正式紀錄皆為 2026-06-29，無超過一個月的紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- 等待 Task PR 建立與 review；合併至 `feature/phase4` 後，才能將 Entry 共用前端基礎 Task 標記 DONE，並開始 Diary Web 聊天室實作。
- 登入頁 Web／Chrome 視覺驗證仍未完成，因此該項維持 REVIEW。

---

## 2026-07-22 10:04 PHASE4-ENTRY-MEDIA-DOWNLOAD

Task
Phase 4 下載煩惱／日記媒體 API（REVIEW）

執行者
Codex

### 完成內容

- 實作 `GET /api/annoyances/{id}/media/{mediaId}` 與 `GET /api/diaries/{id}/media/{mediaId}`，共用 Entry 媒體下載服務。
- 僅允許有效 JWT 使用者下載；owner 可讀取私密 entry，非 owner 僅能讀取目前為分享狀態的 entry，未授權時以 404 隱藏資源存在性。
- 媒體必須屬於 path 指定的未刪除 entry，並使用資料庫保存的 `content_type`；response 不輸出 private R2 URL 或 object key。
- 完整下載回傳 200；單一 Range 下載回傳 206，並設定 `Content-Type`、`Content-Length`、`Accept-Ranges` 與必要的 `Content-Range`。
- 沿用既有 private R2 Range 下載，補測超出範圍 416、R2 物件不存在 404 與儲存失敗 500 的安全錯誤訊息。
- CORS 預設允許 `Range` request header，並公開媒體播放器需要讀取的 response headers。

### 修改／新增／刪除檔案

- 新增 `backend/src/main/java/com/monsters/controller/entry/EntryMediaController.java`。
- 新增 `backend/src/main/java/com/monsters/service/entry/EntryMediaDownloadService.java` 與 `EntryMediaDownloadResult.java`。
- 修改 `backend/src/main/java/com/monsters/repository/entry/EntryRepository.java` 與 `backend/src/main/resources/application.yml`。
- 新增或修改 Entry media Controller／Service、Repository、R2 storage 與 CORS 測試。
- 修改 `README.md`、`backend/README.md`、`docs/API_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv`。
- 未刪除檔案，亦未修改 `system_data/` 或 `log/CHANGE_HISTORY.xlsx`。

### system_data/ 參考結果

- 舊系統沒有 Diary 媒體下載 API；Annoyance 僅有硬編碼本機路徑的圖片／影片 Base64 prototype，History／Social 則把 Base64 媒體包在 JSON。
- 保留登入後讀取已分享內容與顯示圖片／影音的業務意圖；未沿用 Base64 JSON、硬編碼路徑、公開檔案位置、缺少授權或不支援 Range 的舊實作。
- 正式 API、Database、UI 與 Decision 文件優先，採新版 JWT、共用 Entry 與 private R2 串流架構。

### API 異動

- 實作既有 contract 的兩支媒體下載 endpoint；成功回傳 binary stream，而非 `ApiResponse<T>`。
- 支援完整回應 200 與單一 Range 回應 206；未登入為 401、資源或權限不符為 404、Range 超出物件範圍為 416、R2 失敗為 500。
- `docs/API_SPEC.md` 的 endpoint contract 不變；僅同步 CORS 預設 header 設定。

### Database 異動

- 無 schema、SQL 或 Migration 異動。
- 沿用 `entries` 的 owner、entry type、分享與 soft-delete 欄位，以及 `entry_media` 的 entry 關聯、object key、content type 與 soft-delete 欄位。

### 文件更新

- `README.md`、`backend/README.md` 與 `docs/API_SPEC.md` 同步 Range request／response CORS headers。
- `docs/TASKS.md` 將 PR #71 的 Diary 分享 Task 標記 DONE，並記錄本 Task 的 TODO → IN PROGRESS → REVIEW。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 記錄本次實作與驗證。

### 測試方式與結果

- Entry media Service／Controller、Entry Repository、CORS 與 R2 storage targeted Gradle tests：BUILD SUCCESSFUL。
- `./gradlew test`：BUILD SUCCESSFUL，259 tests、0 failures、0 errors、4 skipped。
- `git diff --check`：通過。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；2026-07-22 的保存期限截止日為 2026-06-22。
- 最早正式紀錄為 2026-06-29，未發現超過一個月的紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- 等待 Task PR 建立與 review；核准並合併至 `feature/phase4` 後，才能將兩支媒體下載 API 與本 Task 標記 DONE。
---

## 2026-07-26 10:57

Task
DOC-013 Grilling 決策與領域模型文件化（REVIEW）

Agent
Codex

### Completed

- 依序檢查 AGENTS、system_data、正式規格、Git status／diff／log、主要模組、TODO／FIXME、測試與功能完成狀態。
- 以 grilling 與 domain-modeling 逐項確認產品、年齡、隱私、身分、資料生命週期、匿名社群、內容、怪獸、平台、營運與發布決策。
- 建立 `CONTEXT.md`，統一 Member、Entry、Emotional Load、Community Post、Self Exploration、Community Eligibility 等領域詞彙。
- 建立 8 份 ADR，記錄非醫療私人核心、年齡資格、工作階段、本機隱私鎖、Entry／Community Post、資料生命週期、社群治理、內容審閱、固定獎勵與版本化平台基礎。
- 將核准結果同步至 AGENTS、README、Project、Database、API、UI、Coding Standard、Decisions 與 Tasks。
- 新增 Phase 4.5 基礎安全與領域模型工作清單，並明確阻擋 Phase 5 以後功能。
- 保留 `feature/phase4` 30 個候選 Commit 的現況，不執行 merge、rebase、cherry-pick 或程式修改。
- 檢查 Log 保存期限；最早紀錄為 2026-06-29，未早於 2026-06-26，因此未刪除 Log。

### Added

- `CONTEXT.md`
- `docs/adr/0001-non-medical-private-core.md`
- `docs/adr/0002-age-and-community-eligibility.md`
- `docs/adr/0003-session-and-local-privacy-lock.md`
- `docs/adr/0004-entry-and-community-post-boundary.md`
- `docs/adr/0005-data-lifecycle-and-recovery.md`
- `docs/adr/0006-governed-closed-community.md`
- `docs/adr/0007-reviewed-content-and-deterministic-rewards.md`
- `docs/adr/0008-versioned-platform-foundation.md`

### Modified

- `AGENTS.md`
- `README.md`
- `docs/PROJECT_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/CODING_STANDARD.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `docs/SYSTEM_DATA_REFERENCE.md`
- `docs/PHASE2_TEST_REPORT.md`
- `docs/PHASE3_ANNOYANCE_DESIGN_PROPOSAL.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- 文件工作，未執行程式 Compile／Test。
- 執行 Markdown／Git whitespace、內部連結、目標規格關鍵字與文件交叉一致性檢查。
- 本次新增的 14 筆 `DOC-013` CSV 紀錄皆符合 13 欄現行格式；既有 41 筆 9 欄歷史紀錄與修改前相同，本次未擴大範圍改寫。

### system_data Reference

- 參考系統手冊、系統簡介、舊會員、煩惱、日記、怪獸、社群與互動流程。
- 未沿用舊 Account、空密碼 OAuth、SharedPreferences Token、公開頭貼、server PIN、Base64 媒體、隨機怪獸與未治理社群。
- 未修改、搬移、刪除或格式化 `system_data/`。

### API

- 文件目標改為 `/api/v1`、UUID public ID、OpenAPI、stable error code、optimistic version、idempotency、短效 JWT Access＋opaque Refresh Session。
- 本次未修改 Backend endpoint。

### Database

- 文件核准 Flyway、target schema、Community Post、Session、Guardian Consent、Outbox、Deletion／Export／Audit 等 Migration 方向。
- 本次未修改 Schema 或執行 Migration。

### UI

- 文件核准 Email-only login、年齡／Guardian Consent、本機 Privacy Lock、optional Emotional Load、30 日 Emotional Trace、Monster Avatar、封閉成人社群與無障礙邊界。
- 本次未修改 Flutter 程式或 Penpot。

### Pending

- DOC-013 文件 Review 與 PR。
- 後續另行 Review／整合 `feature/phase4`；本 Task 明確不執行 Phase 4 整合。

---

## 2026-07-16 10:56

Task
TASK-068 登入帳號或 Email 驗證修正（REVIEW）

Agent
Codex

### Completed

- 比對 `bec7bcf` 的登入欄位調整與 `0b3d265` 的 Account / Email 後端查詢邏輯。
- 確認登入 400 的原因為 `LoginRequest.email` 仍套用 `@Email`，使 Account 在進入 `AuthService` 前即被拒絕。
- 保留既有 `email` request key，移除 Email-only 格式限制，改為必填且最大長度 255，讓後端可接收 Account 或 Email。
- 更新登入 Controller 與 Service 測試，涵蓋 Account request validation、Account 正規化查詢、Email 查詢、未知使用者與錯誤密碼。
- 檢查 Log 保存期限；最早紀錄為 2026-06-29，未早於 2026-06-16，因此未刪除 Log。

### Modified

- `backend/src/main/java/com/monsters/dto/auth/LoginRequest.java`
- `backend/src/test/java/com/monsters/controller/auth/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/service/auth/AuthServiceTest.java`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- `gradlew.bat test --tests "com.monsters.controller.auth.AuthControllerTest" --tests "com.monsters.service.auth.AuthServiceTest"`：通過。
- `gradlew.bat test`：BUILD SUCCESSFUL。
- `flutter test --no-pub test/login_page_test.dart`：180 秒內無輸出並逾時；本次未修改前端程式，保留為 REVIEW 待後續環境確認。

### system_data Reference

- 參考舊系統以 Account 登入的流程意圖；未沿用舊系統空密碼 Google 登入、全域狀態或不安全憑證處理方式。

### API

- `POST /api/auth/login` 的 `email` 欄位名稱不變，語意擴充為可輸入已註冊的 Account 或 Email。

### Database

- No Database change.

### UI

- No frontend code changed；UI 規格同步標示登入欄位為「帳號或 Email」。

### Pending

- 待 Code Review 與 Railway 部署後，以 Account 及 Email 各執行一次公開環境登入驗證。
- Flutter 登入頁測試需在 Flutter test runner 可正常輸出的環境重跑。

---

## 2026-07-16 15:49

Task
PENPOT-WEB-REGISTER Web 註冊頁依 Penpot 設計精準修正

執行者
Codex

### 完成內容

- 依 Penpot MCP 選取 board `Account / Web / 03 Register / 註冊` 修正 Web 註冊頁。
- Web 版調整為 620px brand panel、520px 表單寬度，對齊 x=756 的表單起點。
- 調整 Web 版返回登入、標題、副標、欄位提示、規則卡與 `完成註冊` 按鈕順序。
- 新增註冊頁 Web widget test，驗證 Web copy 與主要元素。
- 註冊頁新增顏色皆集中於 `AppColors`。

### 新增

- 無

### 修改

- `frontend/lib/pages/register_page.dart`
- `frontend/lib/theme/app_colors.dart`
- `frontend/test/register_page_test.dart`
- `docs/UI_SPEC.md`
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

- `flutter analyze --no-pub`：通過，No issues found。
- `flutter test --no-pub test/register_page_test.dart`：通過，7 tests passed。

### Log 保存期限檢查

- 已於新增本次 Log 前檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx` 是否存在。
- 目前最早紀錄為 2026-06-29，距 2026-07-16 未超過一個月，未刪除紀錄。

### 待確認事項

- 目前未執行瀏覽器截圖比對；本次以 Penpot MCP 座標與 Flutter widget/analyze 驗證為準。
---

## 2026-07-16 16:12

Task
PENPOT-SPLASH Web / App SplashPage Penpot 畫面對齊

執行者
Codex

### 完成內容

- 使用 Penpot MCP 讀取 Account / Web / 01 Splash / 啟動 與 Account / Mobile / 01 Splash / 啟動。
- 將 SplashPage 改為 Web 1440x900 與 Mobile 390x844 的 responsive layout。
- 保留 AuthController.restoreSession()：有效 session 導向 home；無效 session 顯示登入 / 註冊行動。
- 新增 Splash theme token，避免 page 直接宣告色碼。
- 新增 SplashPage widget tests，驗證 Web / Mobile 位置尺寸與登入 / 註冊導向。

### 新增

- rontend/test/splash_page_test.dart

### 修改

- rontend/lib/pages/splash_page.dart
- rontend/lib/theme/app_colors.dart
- docs/UI_SPEC.md
- docs/TASKS.md
- log/CHANGE_LOG.md
- log/CHANGE_HISTORY.csv

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- lutter analyze --no-pub：通過，No issues found
- lutter test --no-pub test/splash_page_test.dart：通過，4 tests passed

### Log 保存期限檢查

- 已檢查 CHANGE_LOG.md、CHANGE_HISTORY.csv 與 CHANGE_HISTORY.xlsx。
- 截止日為 2026-06-16；CHANGE_LOG.md 最早日期為 2026-06-16，CHANGE_HISTORY.csv 最早日期為 2026-06-29。
- 本次沒有超過一個月的 Log，未刪除既有紀錄。

### 待確認事項

- 無
---

## 2026-07-16 16:22

Task
PENPOT-SPLASH-REDIRECT SplashPage session 失敗自動導向 LoginPage

執行者
Codex

### 完成內容

- 將 SplashPage session restore 失敗流程改為直接導向 login route。
- 移除 Splash 畫面中的登入 / 註冊行動按鈕，避免與 Penpot Splash 畫板不一致。
- 更新 SplashPage widget tests：檢查中狀態仍對齊 Penpot Web / Mobile，restore false 後自動進入 LoginPage。

### 新增

- 無

### 修改

- rontend/lib/pages/splash_page.dart
- rontend/test/splash_page_test.dart
- docs/UI_SPEC.md
- docs/TASKS.md
- log/CHANGE_LOG.md
- log/CHANGE_HISTORY.csv

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- lutter analyze --no-pub：通過，No issues found
- lutter test --no-pub test/splash_page_test.dart：通過，3 tests passed

### Log 保存期限檢查

- 已檢查 CHANGE_LOG.md、CHANGE_HISTORY.csv 與 CHANGE_HISTORY.xlsx。
- 截止日為 2026-06-16；CHANGE_LOG.md 最早日期為 2026-06-16，CHANGE_HISTORY.csv 最早日期為 2026-06-29。
- 本次沒有超過一個月的 Log，未刪除既有紀錄。

### 待確認事項

- 無
---

## 2026-07-16 16:29

Task
PENPOT-SPLASH-EXACT SplashPage 精準修正至 Penpot Page

執行者
Codex

### 完成內容

- 重新讀取 Penpot Splash Web / Mobile shape 資訊。
- 修正 SplashPage 與 Penpot 不一致處：文字改為 left align、Logo 改為 BoxFit.fill、Status card 移除圓角、Status dot/text/hint 改為絕對座標定位。
- 補強 widget tests，新增 status dot、status text、status hint 的 Web / Mobile 座標驗證。

### 新增

- 無

### 修改

- rontend/lib/pages/splash_page.dart
- rontend/test/splash_page_test.dart
- docs/UI_SPEC.md
- docs/TASKS.md
- log/CHANGE_LOG.md
- log/CHANGE_HISTORY.csv

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- lutter analyze --no-pub：通過，No issues found
- lutter test --no-pub test/splash_page_test.dart：通過，3 tests passed

### Log 保存期限檢查

- 已檢查 CHANGE_LOG.md、CHANGE_HISTORY.csv 與 CHANGE_HISTORY.xlsx。
- 截止日為 2026-06-16；CHANGE_LOG.md 最早日期為 2026-06-16，CHANGE_HISTORY.csv 最早日期為 2026-06-29。
- 本次沒有超過一個月的 Log，未刪除既有紀錄。

### 待確認事項

- 無
---

## 2026-07-16 16:46

Task
PENPOT-HOME HomePage Web / App Penpot 畫面對齊

執行者
Codex

### 完成內容

- 使用 Penpot MCP 讀取 Web / Companion Home 與 Mobile / Companion Home。
- 重寫 HomePage 為 Web 1440x900 與 Mobile 390x844 的 Penpot canvas。
- 移除 HomePage 對 Material AppBar / NavigationBar / 舊 quick action layout 的依賴，改為 Penpot 自訂版面。
- 保留主按鈕導向 nnoyanceChat、帳號按鈕導向 profile、怪獸點擊動畫 key 與 reduced motion 行為。
- 新增 Home theme token，避免 page 直接宣告色碼。

### 新增

- 無

### 修改

- rontend/lib/pages/home_page.dart
- rontend/lib/theme/app_colors.dart
- rontend/test/home_page_test.dart
- docs/UI_SPEC.md
- docs/TASKS.md
- log/CHANGE_LOG.md
- log/CHANGE_HISTORY.csv

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- lutter analyze --no-pub：通過，No issues found
- lutter test --no-pub test/home_page_test.dart：通過，5 tests passed
- lutter test --no-pub test/routes/app_router_test.dart --plain-name "supports annoyance chat route and home entry"：通過，1 test passed

### Log 保存期限檢查

- 已檢查 CHANGE_LOG.md、CHANGE_HISTORY.csv 與 CHANGE_HISTORY.xlsx。
- 截止日為 2026-06-16；CHANGE_LOG.md 最早日期為 2026-06-16，CHANGE_HISTORY.csv 最早日期為 2026-06-29。
- 本次沒有超過一個月的 Log，未刪除既有紀錄。

### 待確認事項

- 	est/routes/app_router_test.dart 全檔仍有既有 Register 測試文字定位失敗；本次只驗證 Home route 指定測試。
---

## 2026-07-16 17:26 PENPOT-PROFILE-HOME-FULL

Task
Penpot ProfilePage Web / App 對齊與 HomePage 滿版修正

執行者
Codex

### 完成內容

- 依 Penpot Profile Web / Mobile 設計調整 Flutter ProfilePage。
- 保留既有 UserProfileController / UserRepository / ApiClient 流程與表單驗證。
- 新增 profile theme tokens，ProfilePage 不直接宣告色碼。
- 將 Profile Penpot canvas widgets 拆至 rontend/lib/widgets/profile/profile_penpot_canvas.dart，避免 Page 檔案過長。
- 將 HomePage WEB / Web / Companion Home canvas 外層縮放改為 BoxFit.cover，修正部署寬螢幕非滿版問題。

### 新增

- rontend/lib/widgets/profile/profile_penpot_canvas.dart

### 修改

- rontend/lib/pages/profile_page.dart
- rontend/lib/pages/home_page.dart
- rontend/lib/theme/app_colors.dart
- docs/UI_SPEC.md
- docs/TASKS.md
- log/CHANGE_LOG.md
- log/CHANGE_HISTORY.csv

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- lutter analyze --no-pub：通過，No issues found
- lutter test --no-pub test/profile_page_test.dart：通過，5 tests passed
- lutter test --no-pub test/home_page_test.dart：通過，5 tests passed

### system_data 參考

- 已檢查 system_data/front-end/monsters_front_end/lib/pages/drawer/edit_personalInfo.dart 與 system_data/front-end/monsters_front_end/lib/pages/home.dart。
- 僅參考舊系統個人資料編輯與首頁怪獸互動意圖，未複製舊程式、未沿用舊硬編碼色碼或舊架構。

### Log 保存期限檢查

- 已檢查 CHANGE_LOG.md、CHANGE_HISTORY.csv 與 CHANGE_HISTORY.xlsx 是否存在。
- 保存期限截止日：2026-06-16。
- CHANGE_LOG.md 最早日期為 2026-06-16，CHANGE_HISTORY.csv 最早日期為 2026-06-29，未發現超過一個月紀錄。
- 本次未刪除過期 Log。

### 待確認事項

- 若要進一步精準比對 HomePage，需由使用者在 Penpot 選取正確 WEB / Web / Companion Home board 後再執行尺寸比對。

---

## 2026-07-18 WEB-FIRST-RWD 與 AUTH-REFRESH

Task
整合 Web-first RWD 共用版型、Penpot 頁面相對定位，以及 Profile 401 與 30 天登入狀態 Token Refresh 修正

執行者
Codex

### AUTH-REFRESH 完成內容

- 確認 ProfilePage 本身與 `GET /api/users/me` 路徑正確，根因為本地 session 30 天但 access token 僅 1 小時。
- 新增 `POST /api/auth/refresh`，驗證 refresh token 簽章、issuer、type、期限與使用者狀態。
- Refresh token 預設期限改為 2592000 秒，符合 rolling 30 天登入需求。
- 實作 refresh token rotation；舊 token hash 寫入既有 `revoked_tokens`，重複使用會回傳 401。
- Flutter 啟動恢復 session 時先換發新 Token，不再直接重用保存的 access token。
- `ApiClient` 遇到受保護 API 401 時共用單一 refresh request，成功後只重試原 request 一次。
- Refresh token 驗證失敗時清除 Authorization header 與本地 session，並由 App 導回登入頁；暫時性網路錯誤保留 session。
- 登出 request 可攜帶 refresh token，後端一併撤銷 access 與 refresh token。

### 新增

- `backend/src/main/java/com/monsters/dto/auth/RefreshTokenRequest.java`
- `frontend/test/repositories/auth_repository_test.dart`

### 修改

- Backend Auth Controller／Service、JWT、Security、Token revocation 與相關測試。
- Flutter App、ApiClient、Auth Provider／Repository 與登入、路由相關測試。
- `README.md`、Backend／Frontend README、PROJECT／API／DATABASE／UI／DECISIONS／TASKS 規格。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`。

### system_data 參考

- 已搜尋舊前端 access token 使用方式，未找到 refresh token 或 rotation 流程可重用。
- 舊程式只出現硬編碼 `<ACCESS_TOKEN>` placeholder，本次未沿用，也未修改 `system_data/`。

### API

- 新增 `POST /api/auth/refresh`。
- `POST /api/auth/logout` 新增 optional `refreshToken` request body，未帶 body 的舊 Client 仍相容。
- Refresh 成功沿用既有 `LoginResponse` contract；無效、過期、type 錯誤、已 rotation 或使用者無效回傳 401。

### Database

- 沿用既有 `revoked_tokens` schema 保存 refresh token hash，無欄位與資料表異動。
- 無 Migration。

### 文件更新

- Refresh token 預設有效期由 14 天統一調整為 rolling 30 天。
- 補齊 rotation、並行 401 single-flight、單次 retry、失效導頁與登出撤銷規格。

### 測試

- Backend `./gradlew test`：通過。
- Backend `./gradlew build`：通過。
- Frontend `flutter analyze --no-pub`：通過，No issues found。
- Frontend `flutter test --no-pub`：通過，86 tests passed。
- Frontend `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Web build 顯示既有 Cupertino icon font 提示，不影響建置或 Token Refresh。

### WEB-FIRST-RWD 完成內容

- 盤點 Splash、Login、Register、Home、Profile 的 Penpot 實作與定位方式。
- 新增 Mobile／Tablet／Desktop 共用 breakpoint 與 `ResponsiveLayout`／`ResponsiveContent`。
- 將 Splash、Login、Register、Home、Profile 的 Tablet／Desktop 主版面改為相對 flow layout；Mobile 保留 Penpot 精準畫布。
- 修正 Home 在 900、950、1024px 的負 padding、導覽 overflow 與固定 canvas 問題。
- 補上 Web-first 開發設定、固定本機網址、RWD 驗收寬度與瀏覽器即時 resize 規範。
- 更新既有啟動、路由與密碼鎖測試，使測試契約符合目前路由及頁面入口。

### 新增

- `frontend/lib/layout/responsive_layout.dart`
- `frontend/test/layout/responsive_layout_test.dart`

### 修改

- `frontend/lib/pages/splash_page.dart`
- `frontend/lib/pages/login_page.dart`
- `frontend/lib/pages/register_page.dart`
- `frontend/lib/pages/home_page.dart`
- `frontend/lib/pages/profile_page.dart`
- `frontend/lib/widgets/profile/profile_penpot_canvas.dart`
- `frontend/test/splash_page_test.dart`
- `frontend/test/login_page_test.dart`
- `frontend/test/register_page_test.dart`
- `frontend/test/home_page_test.dart`
- `frontend/test/profile_page_test.dart`
- `frontend/test/widget_test.dart`
- `frontend/test/routes/app_router_test.dart`
- `frontend/test/password_lock_page_test.dart`
- `README.md`
- `frontend/README.md`
- `docs/PROJECT_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/CODING_STANDARD.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### system_data 參考

- 已依本次盤點結果確認舊系統首頁與個人資料流程僅作互動意圖參考。
- 未修改 `system_data/`，未沿用舊系統固定座標 Web 畫面、舊架構、金鑰或環境設定。

### API

- 無異動。

### Database

- 無異動，無 Migration。

### 文件更新

- 明確定義目前前端採 Web-first 開發與驗收，Android／iOS 維持相容。
- 共用 breakpoint 定為 Mobile `< 600px`、Tablet `600px - 1199px`、Desktop `>= 1200px`。
- 補上 Penpot 頁面定位方式盤點、相對 layout 規範與 390 至 1920px RWD 測試矩陣。

### 測試

- `flutter analyze --no-pub`：通過，No issues found。
- `flutter test --no-pub`：通過，107 tests passed。
- `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Web build 顯示既有 Cupertino icon font 提示，不影響建置成功或本次 RWD 功能。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx` 是否存在。
- 保存期限截止日為 2026-06-18；`CHANGE_LOG.md` 最早正式 Task 日期為 2026-06-29，`CHANGE_HISTORY.csv` 最早日期為 2026-06-29。
- 未發現超過一個月的正式紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源，未修改。

### 待確認事項

- 部署時需確認未以環境變數將 `JWT_REFRESH_TOKEN_EXPIRATION_SECONDS` 覆寫回舊值 1209600。

---

## 2026-07-18 14:28 MERGE-PR59-PR60

Task
處理 PR #59 Web-first RWD 合併至 `develop` 後，PR #60 Profile Token Refresh 的合併衝突

執行者
Codex

### 完成內容

- 將 `origin/develop` 合併至 `fix/auth-token-refresh`，逐項解決 5 個衝突檔案。
- `docs/TASKS.md`、`CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv` 均保留 RWD 與 Token Refresh 兩側紀錄。
- `login_page_test.dart` 同時保留 Splash 未登入導頁、登出清除 session 與 Home 帳號入口驗證。
- `widget_test.dart` 同時保留啟動登入頁、Auth 失效導頁與登入前往註冊頁驗證。
- 已確認 Repository 不再存在 conflict marker，且 `git diff --check` 通過。

### 修改

- `docs/TASKS.md`
- `frontend/test/login_page_test.dart`
- `frontend/test/widget_test.dart`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 新增／刪除

- 無；其餘 RWD 新增檔案來自已合併的 PR #59。

### system_data 參考

- RWD 與 Token Refresh 原任務皆已完成 `system_data/` 檢查；本次只處理兩組已驗證變更的 Git 衝突，未發現需再次引用的舊流程。
- 未修改 `system_data/`。

### API

- 本次衝突處理未新增或修改 API；保留 PR #60 已完成的 `POST /api/auth/refresh` 與相容 logout contract。

### Database

- 無異動，無 Migration；保留既有 `revoked_tokens` 使用方式。

### 文件更新

- 更新 Task 狀態並整合 RWD、Token Refresh 與本次 merge 工作報告及歷史紀錄。

### 測試

- Backend `./gradlew test`：通過。
- Backend `./gradlew build`：通過。
- Frontend `flutter analyze --no-pub`：通過，No issues found。
- Frontend `flutter test --no-pub`：通過，115 tests passed。
- Frontend `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Web build 僅顯示既有 Cupertino icon font 提示，不影響建置結果。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-18。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log。

### 待確認事項

- 部署環境仍需確認未將 `JWT_REFRESH_TOKEN_EXPIRATION_SECONDS` 覆寫回舊值 1209600。

---

## 2026-07-18 15:03 PROFILE-ANNOYANCE-PENPOT-RWD

Task
同步 Profile 生日／登出與 Annoyance Penpot 畫面，並修正 Home／Profile Web 右側留白

執行者
Codex

### 完成內容

- Profile 生日欄位改用 Flutter 內建 `showDatePicker`，限制 1900-01-01 至當日並維持 `yyyy-MM-dd` API 格式；未新增第三方套件。
- Profile Web、Tablet、Mobile 加入可見登出按鈕與確認對話框，確認後沿用 `AuthController.logout()` 清除登入狀態並返回登入頁。
- Home／Profile Tablet 與 Desktop 最外層改為 stretch 的滿寬 flow layout，修正 674px 固定內容寬度造成的右側留白。
- Annoyance Page 依 Penpot Web／Mobile Flow 同步導覽、進度、陪伴訊息與操作面板，保留原本結構化狀態機、媒體、繪圖、分數、分享與送出流程。
- Penpot Profile Web／Mobile 個人首頁新增登出入口、編輯頁新增日曆生日欄位；匯出四張畫板完成視覺檢查。
- 依正式規格未實作 Penpot 獎勵延伸畫面，Phase 3 建立成功後仍只顯示完成結果。

### 新增

- `frontend/lib/widgets/annoyance/annoyance_penpot_shell.dart`

### 修改

- `frontend/lib/pages/annoyance_chat_page.dart`
- `frontend/lib/pages/home_page.dart`
- `frontend/lib/pages/profile_page.dart`
- `frontend/lib/theme/app_colors.dart`
- `frontend/lib/widgets/profile/profile_penpot_canvas.dart`
- `frontend/test/annoyance_chat_page_test.dart`
- `frontend/test/home_page_test.dart`
- `frontend/test/profile_page_test.dart`
- `docs/PROJECT_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### system_data 參考

- 參考 `四技第111405組-貘nsters APP-系統手冊.pdf`、系統簡介與舊 Flutter Profile／Home／Annoyance 流程，保留舊系統的個人資料顯示、抽屜登出及聊天式煩惱建立意圖。
- 新版改用 Riverpod、go_router、REST API 與相對 RWD layout；未沿用舊全域狀態、固定 Web 座標、硬編碼登入資料或舊獎勵流程。
- 未修改 `system_data/`。

### API／Database

- API 無異動；Profile 更新、登出與 Annoyance 建立沿用現有 contract。
- Database 無異動，無 Migration。

### 文件更新

- PROJECT_SPEC 補上內建日曆生日輸入及個人資料頁登出需求。
- UI_SPEC 補上滿寬 shell、Profile 日曆／登出、Annoyance Penpot 與 390 至 1920px RWD 規範。
- DECISIONS 記錄使用者選定方案 A，不新增第三方日曆套件。
- TASKS 完整記錄 TODO → IN PROGRESS → REVIEW → DONE。

### 測試

- `flutter analyze --no-pub`：通過，No issues found。
- Home／Profile／Annoyance targeted widget tests：36 tests passed。
- `flutter test --no-pub`：124 tests passed。
- `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Web build 僅顯示既有 Cupertino icon font 提示，不影響建置結果。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-18。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源，未修改。

### 待確認事項

- 無。

---

## 2026-07-19 08:14 PHASE4-DIARY-CREATE

Task
Phase 4 新增日記 API

執行者
Codex

### 完成內容

- 新增 `CreateDiaryRequest`，驗證 record method 與 1 至 5 分 score，並將未提供的分享狀態預設為 false。
- 完成 `POST /api/diaries` multipart endpoint，使用 JWT current user，不接受 Client 傳入 user id。
- 支援 TEXT、IMAGE、AUDIO、VIDEO 四種互斥主要記錄方式及 optional drawing；媒體沿用 private R2 上傳與既有 MIME／大小／影音長度驗證。
- 以獨立 Spring transaction 保存共用 `entries` 與 `entry_media`；上傳或 Database 失敗時補償刪除本次已上傳物件。
- 將 `occurredAt` 正規化為 Asia/Taipei，未提供時使用伺服器目前時間；回應不暴露 R2 object key，Phase 4 `reward` 固定為 null。
- `docs/TASKS.md` 完整記錄 TODO → IN PROGRESS → REVIEW → DONE，並標記新增日記 API 完成。

### 新增

- `backend/src/main/java/com/monsters/dto/diary/CreateDiaryRequest.java`
- `backend/src/main/java/com/monsters/service/diary/CreatedDiary.java`
- `backend/src/main/java/com/monsters/service/diary/DiaryPersistenceService.java`
- `backend/src/main/java/com/monsters/service/diary/NewDiaryMedia.java`
- `backend/src/test/java/com/monsters/dto/diary/CreateDiaryRequestTest.java`
- `backend/src/test/java/com/monsters/service/diary/DiaryPersistenceServiceTest.java`

### 修改

- `backend/src/main/java/com/monsters/controller/diary/DiaryController.java`
- `backend/src/main/java/com/monsters/service/diary/DiaryService.java`
- `backend/src/test/java/com/monsters/controller/diary/DiaryControllerTest.java`
- `backend/src/test/java/com/monsters/service/diary/DiaryServiceTest.java`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### system_data 參考

- 參考舊日記手冊與舊 Backend 的文字、拍照、錄影、錄音、匯入媒體、optional 繪圖、1 至 5 分與分享流程意圖。
- 新版依正式 contract 改為 multipart、JWT owner、共用 Entry 與 private R2；未沿用舊聊天式 API、Base64／字串媒體、硬編碼 Windows 路徑、Controller 獎勵邏輯或不安全帳號參數。
- 未修改或納入本 Task 的 `system_data/` 內容；工作樹中既有素材異動由使用者保留。

### API 異動

- 實作 `POST /api/diaries`，Content-Type 為 `multipart/form-data`，包含 JSON `request`、條件必填 `contentFile` 與 optional `drawingFile`。
- 建立成功回傳 HTTP 201 與 Diary response；正式 API contract 無新增或變更。

### Database 異動

- 無 schema 或 Migration 異動；沿用 `entries`、`entry_media` 與 `moods`。

### 文件更新

- `docs/TASKS.md` 更新 Task 狀態與完成範圍。
- `docs/API_SPEC.md`、`docs/DATABASE_SPEC.md` 與 `docs/UI_SPEC.md` 既有 contract 已涵蓋本次實作，無需改動。

### 測試方式與結果

- Diary／Entry targeted Gradle tests：BUILD SUCCESSFUL。
- `./gradlew test`：BUILD SUCCESSFUL，225 tests、0 failures。
- `git diff --check`：通過。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；2026-07-19 的保存期限截止日為 2026-06-19。
- 最早正式紀錄為 2026-06-29，未發現超過一個月的紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源，未修改。

### 待確認事項

- Task PR 合併至 `feature/phase4` 後，下一個 Task 為查詢日記 API。

---

## 2026-07-19 07:48 PHASE4-DIARY-CORE

Task
Phase 4 Diary 共用 Entry Domain 與 Backend Core 骨架

執行者
Codex

### 完成內容

- 擴充共用 `Entry`，新增 Diary factory 與 update domain operation，固定 `entryType = DIARY`、`annoyanceTypeId = null`、`isSolved = false`，並阻擋 Annoyance／Diary 交叉更新。
- 新增 Diary response DTO、record method、media response 與 Mapper；由文字或 active primary media 推導記錄方式，download URL 指向 Backend，Response 不包含 private R2 object key，Phase 4 `reward` 固定為 null。
- 新增 Diary Service Core，提供 owner-scoped Entry lookup、Mood lookup、active media response 組裝，以及 TEXT／IMAGE／AUDIO／VIDEO 主要內容組合驗證。
- 新增 `/api/diaries` Controller 骨架；本 Task 尚未開放任何 endpoint，新增日記 API 由下一個 Task 實作。
- 沿用共用 `EntryRepository`、`EntryMediaRepository` 與 `MoodRepository`，不建立獨立 Diary Entity、table 或 Repository。
- 完整測試初次發現既有 Mood migration assertion 仍比對未含 timestamp 的舊 seed tuple；僅同步測試 assertion 至目前 migration，未修改 SQL 行為。

### 修改／新增／刪除檔案

- 修改 `backend/src/main/java/com/monsters/entity/entry/Entry.java`。
- 新增 `backend/src/main/java/com/monsters/dto/diary/DiaryMediaResponse.java`。
- 新增 `backend/src/main/java/com/monsters/dto/diary/DiaryRecordMethod.java`。
- 新增 `backend/src/main/java/com/monsters/dto/diary/DiaryResponse.java`。
- 新增 `backend/src/main/java/com/monsters/mapper/diary/DiaryMapper.java`。
- 新增 `backend/src/main/java/com/monsters/service/diary/DiaryService.java`。
- 新增 `backend/src/main/java/com/monsters/controller/diary/DiaryController.java`。
- 修改 `backend/src/test/java/com/monsters/entity/entry/EntryTest.java`。
- 修改 `backend/src/test/java/com/monsters/entity/entry/MoodSchemaTest.java`。
- 新增 Diary Controller／Mapper／Service 單元測試。
- 修改 `docs/DATABASE_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv`。
- 無刪除檔案；未納入使用者的 `frontend/lib/pages/home_page.dart` 工作樹異動。

### system_data 參考結果

- 重讀系統手冊 Diary 資料表與新增日記頁面，確認舊流程包含文字／相機／影音／錄音、optional 心情圖、1 至 5 分與分享設定。
- 參考舊 `DiaryController`、`DiaryServiceImpl`、`DiaryDAOImpl`、`Diary` 與 `DiaryBean` 的欄位意圖。
- 未沿用 account 外鍵、獨立 diary table、Controller 發獎、硬編碼 Windows 路徑、舊 Hibernate DAO、錯誤 null 判斷、自由文字 yes／no 或 monster 發放邏輯。
- 未修改 `system_data/`。

### API 異動

- API contract 無異動；新增 `/api/diaries` Controller 骨架但尚無可呼叫 endpoint。
- 建立 Diary response mapping 基礎，媒體 URL、owner 隔離與 `reward = null` 符合既有 API 規格。

### Database 異動

- 無 schema、SQL 或 Migration 異動。
- 沿用 `entries`、`entry_media` 與 `moods`；DATABASE_SPEC 補充 DIARY 一種主要內容與 optional drawing 規則。

### 文件更新

- DATABASE_SPEC 補充 Diary Entry／Media 與 Mood lookup 規則。
- TASKS 記錄 Diary Core TODO → IN PROGRESS → REVIEW → DONE 狀態。
- CHANGE_LOG 與 CHANGE_HISTORY 記錄本次實作、測試與保存期限檢查。

### 測試方式與結果

- Diary／Entry targeted Gradle tests：通過。
- Backend `./gradlew test`：BUILD SUCCESSFUL，216 tests passed。
- Spring context、Annoyance、Auth、User 與 Entry regression tests 全部通過。
- `git diff --check`：通過；新增 Diary production code 無 TODO、FIXME、`System.out` 或 object key 輸出。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-19。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- 無；下一個 Task 為 `POST /api/diaries` 新增日記 API，會在新的 task branch 實作 request DTO、private media upload 與 transaction cleanup。

---

## 2026-07-18 22:21 PHASE4-DIARY-CONTRACT

Task
Phase 4 日記 contract-first、Penpot design-first 與 Web-first 準備

執行者
Codex

### 完成內容

- 完成 Phase 4 DoR 與舊系統 Diary 流程盤點，採用使用者核准的三項方案 A：獎勵延至 Phase 6、抽出 Entry 共用前端元件、心情繪圖可略過。
- 將 Diary API 從 endpoint 清單補齊為可實作 contract，包含 multipart、新增、分頁查詢、單筆、完整修改、分享、private media download、HTTP Range 與錯誤處理。
- 將 Phase 4 與後續含 UI 的 Phase 定義為 Penpot design-first，並明確採 Web-first 實作與驗收。
- 以 Penpot `Diary Flow / Web` 作第一驗收來源，保留 `Diary Flow / Mobile`；將第 08 確認頁按鈕改為「儲存這篇日記」、Phase 4 完成頁移除假獎勵，未來獎勵畫板標示為 Phase 6。
- 比對已完成的 Penpot `Web / Companion Home` 與 `Annoyance Flow / Web`，確認日記畫板沿用共用 Navbar、1440×900 Desktop 基準、1200px 內容區、雙欄、暖色卡片、字級、間距、圓角、陰影與按鈕層級。

### 修改／新增／刪除檔案

- 修改 `docs/PROJECT_SPEC.md`。
- 修改 `docs/API_SPEC.md`。
- 修改 `docs/UI_SPEC.md`。
- 修改 `docs/DECISIONS.md`。
- 修改 `docs/TASKS.md`。
- 修改 `log/CHANGE_LOG.md`。
- 修改 `log/CHANGE_HISTORY.csv`。
- 無新增或刪除 Repository 檔案；另已更新連線中的 Penpot Web／Mobile Diary 畫板。

### system_data 參考結果

- 參考舊系統手冊與簡介中的日記流程，以及舊 Flutter `diaryChat.dart`、`diaryAPI.dart`、`diaryRepo.dart`、`diaryModel.dart` 和舊 Backend Diary Controller／Service／DAO／Model。
- 保留日記記錄方式、optional 心情圖、分數與分享的業務意圖；未沿用 account path param、Base64 媒體、頁面直呼 HTTP、global state、自由文字 yes／no、硬編碼磁碟路徑、Controller 發獎與舊 DAO 錯誤作法。
- 未修改 `system_data/`。

### API 異動

- 僅更新 Phase 4 Diary API 正式 contract，尚未修改 Backend 程式。
- Diary 使用共用 Entry／EntryMedia，支援 TEXT／IMAGE／AUDIO／VIDEO 一種主要內容與一張 optional drawing；Phase 4 `reward = null`。

### Database 異動

- 無 Database schema 或 Migration 異動。
- 正式規格沿用既有 `entries` 與 `entry_media`；Diary 為 `entry_type = DIARY`、`annoyance_type_id = NULL`、`is_solved = false`。

### 文件更新

- PROJECT_SPEC：補齊 Diary 流程、Phase 4 reward 邊界、Penpot design-first、Web-first 與既有頁面樣式基準。
- API_SPEC：補齊 Diary multipart、response、分頁、更新、分享、媒體與錯誤 contract。
- UI_SPEC：補齊 Penpot 全 Phase 規則、Diary Web／Mobile 畫板來源、狀態機、共用元件、RWD 與完成頁規格。
- DECISIONS：記錄全部方案 A、Penpot design-first、Web-first 與既有樣式重用決策。
- TASKS：記錄 contract-first 狀態與 Phase 4 至 Phase 10 的 Penpot／Web-first 檢查項目。

### 測試方式與結果

- Contract 修改前 Backend `./gradlew test`：BUILD SUCCESSFUL。
- Contract 修改前 Flutter `flutter analyze --no-pub`：No issues found。
- Contract 修改前 Flutter `flutter test --no-pub`：132 tests passed。
- `flutter build web --no-pub`：通過，產出 `frontend/build/web`；僅顯示既有 Cupertino icon font 提示。
- Penpot 已匯出並檢視 Diary Web／Mobile 確認頁與完成頁，以及已完成的 Companion Home／Annoyance Web 畫板；未發現溢位、遮擋或 Phase 4 假獎勵文案。
- 本次僅修改文件與 Penpot，未修改 Backend、Frontend 或 Database 程式。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-18。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- 無；下一個實作 Task 依序為共用 Entry Diary domain／DTO／Service／Controller，再完成 Diary API，最後以 Penpot Web 畫板實作 Flutter Web 日記流程。

---

## 2026-07-18 15:29 MOBILE-FULL-WIDTH-MOOD-SCORE

Task
修正 391 至 599px Mobile 右側留白、加入煩惱分數圖片選擇，並提交 annoyance type／mood migration 時間欄位

執行者
Codex

### 完成內容

- 透過實際 Flutter Web 500px viewport 重現問題，確認 Mobile 分支的 390px Penpot canvas 維持固定寬度靠左，造成右側留白。
- 新增 `ResponsiveFixedCanvas`，讓 390 x 844 canvas 依 viewport 寬度等比例填滿；縮放高度超過 viewport 時改為垂直捲動。
- Home 與 Profile Mobile 套用滿寬 canvas，補上 500px、599px 回歸測試。
- `MoodScoreSelector` 改用 `moodPoint_1.png`～`moodPoint_5.png` 圖片卡片，保留 `1分`～`5分`、既有 key、API 整數值與無障礙語意。
- 分數卡片在窄螢幕自動換行，選取狀態使用品牌色邊框、底色與陰影。
- 納入使用者修改的兩支 Database migration，並將六位短日期字串正規化為 MySQL `CURRENT_TIMESTAMP`。

### 新增

- `frontend/assets/images/moodPoint_1.png`
- `frontend/assets/images/moodPoint_2.png`
- `frontend/assets/images/moodPoint_3.png`
- `frontend/assets/images/moodPoint_4.png`
- `frontend/assets/images/moodPoint_5.png`

### 修改

- `frontend/lib/layout/responsive_layout.dart`
- `frontend/lib/pages/home_page.dart`
- `frontend/lib/pages/profile_page.dart`
- `frontend/lib/widgets/annoyance/mood_score_selector.dart`
- `frontend/test/home_page_test.dart`
- `frontend/test/profile_page_test.dart`
- `frontend/test/widgets/mood_score_selector_test.dart`
- `database/migrations/20260711_01_add_annoyance_type_codes_and_seed.sql`
- `database/migrations/20260711_03_make_mood_score_unique.sql`
- `docs/PROJECT_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### system_data 參考

- 本次為已完成 Home／Profile／Annoyance 流程的精準 follow-up，沿用前一任務對舊 Mobile 固定畫布與煩惱分數流程的參考結果，未新增複製舊程式。
- 未修改 `system_data/`，未沿用舊全域狀態或直接 Database 存取方式。

### API／Database

- API 無異動；煩惱分數仍送出整數 1 至 5。
- Database schema 無異動，無新 Migration；修改既有 `20260711_01`、`20260711_03` seed DML，使 `created_at`／`updated_at` 明確使用 `CURRENT_TIMESTAMP`。

### 文件更新

- PROJECT_SPEC、UI_SPEC 同步分數圖片卡片與 Mobile 等比例滿寬行為。
- DATABASE_SPEC 同步兩支 migration 的 timestamp seed 規則。
- DECISIONS 記錄使用者指定的分數圖片 UI，Database lookup 仍維持中性整數語意。
- TASKS 記錄 TODO → IN PROGRESS → REVIEW → DONE。

### 測試

- `flutter analyze --no-pub`：通過，No issues found。
- Home／Profile／MoodScore／Annoyance targeted tests：42 tests passed。
- `flutter test --no-pub`：129 tests passed。
- `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Flutter Web 瀏覽器 500 x 844 viewport：`body`、`flutter-view` 均為 500px，Home 右側空白已消失。
- 5 張 moodPoint 圖片皆驗證為 156 x 156 RGBA PNG，Flutter asset bundle 載入通過。
- Docker daemon 未啟動，未執行隔離 MySQL migration；已完成 migration diff、短日期殘留與 `CURRENT_TIMESTAMP` 靜態檢查。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-18。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源，未修改。

### 待確認事項

- Docker／MySQL 啟動後可再於隔離測試資料庫實際執行兩支既有 migration；本次未連線或修改任何本機 Database 資料。

---

## 2026-07-18 18:31 SHARED-NAVIGATION-TRANSITION

Task
Web 方案 A 共用完整 Navbar、Mobile 方案 1 改通知，並統一頁面切換效果

執行者
Codex

### 完成內容

- 新增 `AppTopNavigation`，統一 Home／Profile／Annoyance Desktop Navbar 的 Logo、五個主要模組、記下心情 CTA、通知與個人資料入口。
- 新增 `MobileAppBottomNavigation`，統一 Home／Profile 的首頁、社群、怪獸、互動與「我的」；首頁與「我的」使用正式 route，其餘顯示具名即將開放提示。
- 首頁 Mobile 右上角由個人資料改為通知，移除重複 Profile 入口；底部「我的」成為正式個人資料入口。
- Profile Desktop 將儲存與登出移至共用 Navbar 下方的頁面 action bar，保留原驗證、API 與登出確認流程。
- 所有 route 前進進場動畫改為 0 秒；Home→Profile／Annoyance、Login→Register 使用 push 保留導覽堆疊，明確返回按鈕以 220ms 向右退出。
- 補齊 Mobile 通知、底部 Profile 導頁、三頁共用 Navbar、390 至 1920px overflow 與返回方向測試。

### 新增

- `frontend/lib/widgets/navigation/app_navigation.dart`

### 修改

- `frontend/lib/pages/home_page.dart`
- `frontend/lib/pages/profile_page.dart`
- `frontend/lib/pages/annoyance_chat_page.dart`
- `frontend/lib/pages/login_page.dart`
- `frontend/lib/pages/register_page.dart`
- `frontend/lib/routes/app_router.dart`
- `frontend/lib/widgets/profile/profile_penpot_canvas.dart`
- `frontend/lib/widgets/annoyance/annoyance_penpot_shell.dart`
- `frontend/test/home_page_test.dart`
- `frontend/test/profile_page_test.dart`
- `frontend/test/annoyance_chat_page_test.dart`
- `docs/PROJECT_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### system_data 參考

- 參考舊 Flutter `state/drawer.dart` 與 `pages/home.dart` 的個人資料、密碼鎖、使用說明、回饋及登出入口意圖。
- 新版依使用者選定方案改為 Web 共用 Navbar 與 Mobile 底部「我的」，未沿用舊 `endDrawer`、各頁重複選單、`MaterialPageRoute` 或直接操作本地登入資料的作法。
- 未修改 `system_data/`。

### API／Database

- API 無異動；通知與未完成模組目前只顯示 UI 提示，不呼叫假 API。
- Database 無異動，無 Migration。

### 文件更新

- PROJECT_SPEC 同步 Web／Mobile 導覽角色與頁面切換原則。
- UI_SPEC 補上共用 Navbar、Mobile 底部選單、通知入口、route stack 與 220ms 返回動畫規格。
- DECISIONS 記錄使用者選定 Web 方案 A、Mobile 方案 1改通知及頁面切換決策。
- TASKS 完整記錄 TODO → IN PROGRESS → REVIEW → DONE。

### 測試

- `flutter analyze --no-pub`：通過，No issues found。
- Home／Profile／Annoyance／Login／Register targeted tests：70 tests passed。
- `flutter test --no-pub`：131 tests passed。
- `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Web build 僅顯示既有 Cupertino icon font 提示，不影響建置結果。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-18。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源，未修改。

### 待確認事項

- 通知後端與通知中心頁面尚未開發；目前依正式規格顯示「通知即將開放」。

---

## 2026-07-18 18:38 PROFILE-ACTION-BACKGROUND

Task
將個人資料頁操作列底色同步為新增煩惱進度列底色

執行者
Codex

### 完成內容

- 新增 `profileActionBackground` 色票，使用與 `annoyanceBrandBackground` 相同的 `#FFFDD2`。
- 將 Desktop Profile 的個人資料／登出／儲存變更操作列改為淡黃色底色。
- 保留共用 Navbar、Profile 內容背景、表單卡片、按鈕與 Mobile 版型不變。
- 新增 Widget test，驗證 Profile action bar 與 Annoyance brand background 色值一致。

### 修改

- `frontend/lib/theme/app_colors.dart`
- `frontend/lib/widgets/profile/profile_penpot_canvas.dart`
- `frontend/test/profile_page_test.dart`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### system_data 參考

- 本次為現有 Profile／Annoyance 視覺 token 同步，未新增引用或修改 `system_data/`。

### API／Database

- API 無異動。
- Database 無異動，無 Migration。

### 測試

- `flutter analyze --no-pub`：通過，No issues found。
- `flutter test --no-pub`：132 tests passed。
- `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Web build 僅顯示既有 Cupertino icon font 提示，不影響建置結果。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-18。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未修改。

### 待確認事項

- 無。

---

## 2026-07-19 08:31 PHASE4-DIARY-QUERY

Task
Phase 4 查詢日記 API

執行者
Codex

### 完成內容

- 實作 `GET /api/diaries` owner-scoped 列表查詢，支援 `page`、`size`、`sort` 與 optional `isShared` 篩選。
- 實作 `GET /api/diaries/{id}` 單筆查詢，只允許目前 JWT 使用者讀取自己的未刪除 DIARY entry。
- 列表限定 `occurredAt`、`createdAt`、`score` 排序與 `asc`／`desc` 方向，空白 sort 使用 `occurredAt,desc`；相同排序值維持 entry id descending。
- 將共用 Entry Repository 的 `findAnnoyancePage` 更名為 `findEntryPage`，Diary 與 Annoyance 共用同一個 owner、entry type、soft-delete、分享與分數排序 JPQL。
- 列表批次載入 Mood 與 active EntryMedia，避免逐筆 lookup；空列表不執行額外 mood／media 查詢。
- 無效分頁或排序回傳 400；不存在、已刪除、類型錯誤或 owner 不符回傳 404；response 保持 `reward = null` 且不輸出 private R2 object key。

### 修改／新增／刪除檔案

- 修改 `backend/src/main/java/com/monsters/controller/diary/DiaryController.java`。
- 修改 `backend/src/main/java/com/monsters/service/diary/DiaryService.java`。
- 修改 `backend/src/main/java/com/monsters/repository/entry/EntryRepository.java`。
- 修改 `backend/src/main/java/com/monsters/service/annoyance/AnnoyanceService.java` 以沿用更名後的共用 Repository 方法，行為不變。
- 修改 Diary Controller／Service、Entry Repository 與 Annoyance Service 測試。
- 修改 `docs/DATABASE_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv`。
- 無新增或刪除檔案。

### system_data 參考結果

- 參考系統手冊歷史記錄列表、日記篩選與詳細內容流程，以及舊 `HistoryController`、Diary Service／DAO、Flutter History Repository 與日記詳細頁。
- 保留「從歷史列表查看日記詳細內容」的業務意圖；未沿用 account path parameter、記憶體排序、空列表視為失敗、查詢回傳 HTTP 201、Base64 媒體、全域登入資料或 UI 直接呼叫 API。
- 未修改 `system_data/`。

### API 異動

- 實作既有 contract 的 `GET /api/diaries` 與 `GET /api/diaries/{id}`；成功回傳 HTTP 200 與 `ApiResponse<T>`。
- `docs/API_SPEC.md` 既有 contract 已涵蓋本次實作，無新增或修改。

### Database 異動

- 無 schema、SQL 或 Migration 異動。
- `docs/DATABASE_SPEC.md` 補充 Annoyance／Diary 共用 Entry offset pagination 與穩定次排序規則。

### 文件更新

- `docs/DATABASE_SPEC.md` 同步共用列表查詢規則。
- `docs/TASKS.md` 記錄 TODO → IN PROGRESS → REVIEW → DONE 與完成範圍。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 記錄本次實作與驗證。

### 測試方式與結果

- Diary Query／Entry Repository／Annoyance regression targeted Gradle tests：BUILD SUCCESSFUL。
- `./gradlew test`：BUILD SUCCESSFUL，232 tests、0 failures、0 errors、0 skipped。
- `git diff --check`：通過。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；2026-07-19 的保存期限截止日為 2026-06-19。
- 最早正式紀錄為 2026-06-29，未發現超過一個月的紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- Task PR 合併至 `feature/phase4` 後，下一個 Task 為修改日記 API。

---

## 2026-07-22 09:05 PHASE4-DIARY-UPDATE

Task
Phase 4 修改日記 API（REVIEW）

執行者
Codex

### 完成內容

- 實作 `PUT /api/diaries/{id}` multipart 完整修改流程，僅允許目前 JWT 使用者修改自己的未刪除 DIARY entry。
- 主要記錄方式必須是 TEXT、IMAGE、AUDIO、VIDEO 其中一種；文字日記不得附主要媒體，媒體日記必須在新檔與同類型既有媒體 ID 中擇一。
- 可保留既有主要媒體或心情圖；傳入新檔時會取代對應媒體；未傳新心情圖與既有心情圖 ID 時移除心情圖。
- 僅接受屬於該日記且類型正確的既有媒體 ID；資料不存在、已刪除、類型不符或 owner 不符時維持既有的 404／400 行為。
- 新媒體在資料庫交易失敗時會清理；被取代的 private R2 舊物件僅在交易成功後 best-effort 清理，清理失敗不回滾成功的資料庫交易。

### 修改／新增／刪除檔案

- 修改 `backend/src/main/java/com/monsters/controller/diary/DiaryController.java`。
- 新增 `backend/src/main/java/com/monsters/dto/diary/UpdateDiaryRequest.java`。
- 修改 `backend/src/main/java/com/monsters/service/diary/DiaryService.java`、`DiaryPersistenceService.java`，並新增 `UpdatedDiary.java`。
- 新增或修改 Diary DTO、Controller、Service、Persistence 單元測試。
- 修改 `docs/TASKS.md`、`log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv`。
- 未刪除檔案，亦未修改 `system_data/`。

### system_data/ 參考結果

- 參考系統手冊與舊 Diary 流程的文字、圖片、錄音、影片、optional 心情圖、1 至 5 分與分享業務意圖。
- 更新行為沿用新版 Annoyance 的 owner 驗證、媒體替換、資料庫交易與 private R2 補償模式；未沿用舊系統的 account path parameter、公開檔案路徑或舊分層程式。

### API 異動

- 實作既有 contract 的 `PUT /api/diaries/{id}`，成功回傳 HTTP 200 與 `ApiResponse<DiaryResponse>`。
- `docs/API_SPEC.md` 已完整定義 request parts、既有媒體 ID 與替換規則，本次未變更 contract。

### Database 異動

- 無 schema、SQL 或 Migration 異動；沿用共用 `entries` 與 `entry_media` 的 soft-delete 欄位。

### 文件更新

- `docs/TASKS.md` 記錄 TODO → IN PROGRESS → REVIEW。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 記錄本次實作與驗證。

### 測試方式與結果

- Diary DTO／Controller／Service／Persistence targeted Gradle tests：BUILD SUCCESSFUL。
- `./gradlew test`：BUILD SUCCESSFUL。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-22。
- 最早正式紀錄為 2026-06-29，未發現超過一個月的紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- 等待 Task PR 建立與 review；核准並合併至 `feature/phase4` 後，才能將本 Task 標記 DONE 並開始分享／取消分享日記 API。

---

## 2026-07-22 09:29 PHASE4-DIARY-SHARING

Task
Phase 4 分享／取消分享日記 API（REVIEW）

執行者
Codex

### 完成內容

- 實作 `PATCH /api/diaries/{id}/share`，以 request body 的 `isShared` 明確設定分享目標狀態，不使用 toggle。
- 僅允許目前 JWT 使用者更新自己的未刪除 DIARY entry；資料不存在、已刪除或 owner 不符時維持 404。
- 同狀態請求採冪等成功，只有分享狀態實際改變時才寫入資料庫。
- `isShared` 缺漏時以 Bean Validation 拒絕，Service 亦保留 null 防禦驗證。

### 修改／新增／刪除檔案

- 修改 `backend/src/main/java/com/monsters/controller/diary/DiaryController.java`。
- 新增 `backend/src/main/java/com/monsters/dto/diary/ShareDiaryRequest.java`。
- 修改 `backend/src/main/java/com/monsters/service/diary/DiaryService.java`。
- 新增或修改 Diary 分享 DTO、Controller、Service 單元測試。
- 修改 `docs/TASKS.md`、`log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv`。
- 未刪除檔案，亦未修改 `system_data/`。

### system_data/ 參考結果

- 參考舊 Diary controller、service 與 DAO 的分享欄位及公開日記查詢業務意圖。
- 正式 API contract 優先；未沿用舊系統的 account path parameter、廣泛修改 endpoint 或舊分層程式。
- 實作沿用新版 Annoyance 的 owner 驗證、明確 boolean 目標狀態與冪等更新模式。

### API 異動

- 實作既有 contract 的 `PATCH /api/diaries/{id}/share`，成功回傳 HTTP 200 與更新後的 `ApiResponse<DiaryResponse>`。
- Request body 為 `{ "isShared": true | false }`；缺漏欄位為 400，找不到 owner-scoped 日記為 404。
- `docs/API_SPEC.md` 已完整定義本次 contract，未修改規格。

### Database 異動

- 無 schema、SQL 或 Migration 異動；沿用 `entries.is_shared` 欄位。

### 文件更新

- `docs/TASKS.md` 將修改日記 API 標記 DONE，並記錄分享／取消分享日記 API 的 TODO → IN PROGRESS → REVIEW。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 記錄本次實作與驗證。

### 測試方式與結果

- Diary 分享 DTO／Controller／Service targeted Gradle tests：BUILD SUCCESSFUL。
- `./gradlew test`：BUILD SUCCESSFUL。
- `git diff --check`：通過。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-22。
- 最早正式紀錄為 2026-06-29，未發現超過一個月的紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- 等待 Task PR 建立與 review；核准並合併至 `feature/phase4` 後，才能將本 Task 標記 DONE 並開始下載日記媒體 API。
