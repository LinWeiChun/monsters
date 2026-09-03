# 專案異動紀錄

本文件用於記錄貘nsters 專案每次由 AI Coding Agent 或開發者完成的檔案異動。

AI 每次完成任務後，必須新增一筆紀錄，並同步更新 `CHANGE_HISTORY.csv` 或 `CHANGE_HISTORY.xlsx`。

新增 Log 紀錄前，必須先檢查既有 Log 日期；若存在超過一個月的紀錄，需先刪除過期紀錄，再新增本次紀錄。

---

## 2026-09-03 09:15

Task
Registration Login 12 會員資料分離修改、停用與恢復（REVIEW）

Agent
Codex

### Completed

- 採方案1完成owner限定會員read model，公開暱稱、Email變更、生日更正、本人停用與恢復各自使用獨立Command，新Flutter不再呼叫deprecated `PUT /api/users/me`；依2026-09-03使用者核准，舊PUT保留路徑但回409 CLIENT_UPGRADE_REQUIRED，不能寫入。
- Email與生日使用5分鐘、綁定Session與用途的密碼／Google reauth credential；Email驗證前保留舊Email，完成後原子切換、撤銷其他Session並通知新舊Email。
- 生日跨13／18歲邊界只進入待審；若降低資格立即套用保守限制、取消公開及登出全部裝置。本人恢復只使用版本綁定Continuation Credential，成功後仍需重新登入且不恢復分享。
- Penpot Web／Mobile各完成8個狀態畫板與匯出檢視，520個visible descendants均在parent內；Flutter依畫板完成Profile、Email連結、受限、已停用與恢復狀態。

### Modified / Added / Deleted

- Backend新增Member Data Controller／DTO／Entity／Repository／Service／Token／Outbox Worker，修改Session、Security、User、SMTP與測試。
- Database新增Flyway V10，不改寫舊Migration。
- Flutter新增Member Data models／repository／provider、4個畫面與測試，修改Login分流與Router；舊Profile檔案保留但已不由正式route使用。
- 新增舊寫法清理清單並同步API／Database／UI／Decision／Task／OpenAPI及Log。未刪除產品檔案；Flutter migrator自動加入的Android設定已排除。

### system_data Reference

- 舊Flutter以同一Member model同時承載account、password、birthday、mail、nickname與photo，並以account path直接modify個人資料；舊Backend也缺少欄位白名單、reauth、optimistic version與資格workflow。
- 只參考「查看與修改個人資料」的流程意圖；未沿用account owner、敏感欄位混寫、前端儲存生日或直接HTTP寫法，且`system_data/`全程唯讀。

### API / Database

- 涵蓋9組v1資源端點：Profile read、公開暱稱、密碼／Google reauth、Email申請／完成、生日更正、停用與恢復。恢復request只含`confirmed: true`，不依賴無法在停用畫面讀取的Client version。
- V10建立`member_email_change_requests`、`birthday_correction_requests`並擴充reauth用途約束；Token只存SHA-256 hash，Outbox payload不含Email、生日或Token。

### Verification

- Backend單元／契約共343項，339項通過、4項既有ffprobe OS條件在Windows跳過，0失敗。
- 真實MySQL 8.4整合44項全部通過，包含Security Filter、owner、Session撤銷、Token、版本綁定、空庫與上版升級至V10。
- Flutter完整262項測試通過，Analyze無問題；Web release與Android debug APK建置成功。RWD專項覆蓋390／599／600／1199／1200／1440px；Mobile無主畫面捲動，Tablet／Desktop為flow layout且無overflow。
- 補齊共用導覽、生日日期選擇器、Google Web官方按鈕及事件隔離、取消後忽略回應與Email連結切換隔離測試。
- 本機Flutter版本較CI 3.29.2新；新Dropdown已依現有相容模式使用`value`並附限定ignore，尚待PR上CI確認。

### Log Retention / Pending

- 依2026-09-03一個月保存政策，保留2026-08-03起紀錄；已移除Markdown 6段、CSV 39筆與XLSX 8筆過期紀錄，可由Git歷史取回。
- CSV／XLSX各保留40筆歷史紀錄並新增8筆；既有10筆歷史文字差異原樣保留，本次新增8筆逐欄一致。Excel保留欄寬與表格配色，重新調整列高避免文字裁切。
- Task由IN PROGRESS轉REVIEW；本Task分支將推送並建立目標`feature/phase4.5`的PR。CI、使用者Review與合併前不轉DONE，不自動合併。

---

## 2026-08-31 15:00

Task
Registration Login 11 Penpot Logo驗收校正（REVIEW）

Agent
Codex

### Implementation / Verification

- 三個PasswordReset共用元件將表單／狀態Logo固定為150×47、品牌Logo固定為160×50並使用BoxFit.fill，對齊Penpot；未修改既有600×300素材檔。
- 新增Mobile／Desktop Logo尺寸斷言；27項PasswordReset專項測試全部通過，Web release重新建置通過。前輪完整236項Flutter、Analyze、Android debug、Backend單元與42項MySQL整合驗證保留。
- 更新UI_SPEC與REGISTRATION_LOGIN_TASKS；沒有API／Database或system_data異動。

### Git / Log

- 功能與首輪Log提交`0829f5d`／`e65ab29`已Push；[Draft PR #102](https://github.com/LinWeiChun/monsters/pull/102)已建立，目標feature/phase4.5，未合併。
- 本次視覺校正另提交至相同PR；CI以最新head為準，先前提交通過的檢查不得代替新提交。Task維持REVIEW。
- 三份Log再次檢查，沒有新增過期紀錄；新增1筆Review紀錄後，XLSX共48筆、CSV共79筆資料列。既有樣式保留，完成影像與公式錯誤檢查。

---

## 2026-08-31 14:40

Task
Registration Login 11 Forgot／Reset Password正式流程（REVIEW）

Agent
Codex

### Implemented / Pending Acceptance

- 依使用者方案1實作通用202密碼重設申請與正式重設API，不回傳reset Token；Email與IP限流套用用途分離HMAC key。
- Token有效15分鐘、單次使用、Server只保存SHA-256 hash；新申請撤銷舊Token，Outbox Worker於寄信時產生明文，並具重試、FAILED及無PII告警。
- 重設套用Task04的NFC密碼政策與Argon2id，成功撤銷全部Session Family，使用者需重新登入。
- Penpot Web／Mobile各8個狀態畫板已建立並經Chrome實際檢視；180個descendant containment通過。Flutter依設計校正申請、通用受理、Token失效、成功與重新登入，補齊鍵盤避讓、矮視窗與非同步舊回應隔離。
- 依使用者要求整理WEB 18與APP 17個主畫板，按流程分為每列4個區塊；35個主畫板無重疊，466個直屬元件相對座標及尺寸保持不變。未刪除舊畫板、未修改Assets / Monsters素材頁。
- 已確認Task10 PR #101於2026-08-21合併，將Task10標記DONE，修正過時Frontier；未開始Task12。

### Modified / Added / Deleted

- Backend新增PasswordReset Controller／Service／Worker／Scheduler／限流設定與DTO；修改SMTP、Security、Token Repository及Session撤銷，新增對應測試。
- 新增Flyway V9；修改AuthMemberHttpIntegrationTest、MemberStateFlywayIntegrationTest及RegistrationMigrationIntegrationTest。
- Flutter新增兩個重設頁面、Provider、共用RWD容器、品牌區／表單標題元件與測試；修改登入入口、Auth Repository與Router。
- 刪除ForgotPasswordRequest、ForgotPasswordResponse、ResetPasswordRequest三個舊DTO與AuthService／AuthController舊重設方法；保留安全deprecated路徑別名。
- 更新正式規格、OpenAPI、README、Task及舊寫法清理清單，同步Markdown／CSV／XLSX Log。所有產品刪除均可由Git原版本取回。

### system_data Reference

- 查閱系統手冊、系統簡介及舊註冊／忘記密碼實作；僅參考透過Email取回登入權限的流程意圖。
- 舊Client產生驗證碼、account登入識別及直接存取資料的寫法不符合正式安全與分層規格，未沿用；system_data全程唯讀。

### API

- 新增POST /api/v1/auth/password-reset-requests：已知與未知Email均回202 PASSWORD_RESET_REQUEST_ACCEPTED，不含Token。
- 新增POST /api/v1/auth/password-resets：token／newPassword完成重設，提供INVALID、EXPIRED、USED穩定錯誤碼。
- 舊/api/auth/forgot-password與/api/auth/reset-password改為同一安全服務的deprecated別名，Task18確認三平台遷移與E2E後移除。

### Database

- V9將password_reset_tokens.token_hash上限調整為64，新增revoked_at及active查詢索引；不新增平行資料表、不改寫舊Migration。
- 沿用registration_rate_limit_buckets與outbox_events，使用用途前綴區分限流，不保存Email／IP原文或明文Token。

### Documents

- 同步PROJECT_SPEC、API_SPEC、DATABASE_SPEC、UI_SPEC、DECISIONS、REGISTRATION_LOGIN_MEMBER_MANAGEMENT_SPEC、REGISTRATION_LOGIN_TASKS、TASKS、OpenAPI及兩份README。
- 新增PASSWORD_RESET_LEGACY_CLEANUP.md，列出已刪除、Task18可刪除及本Task不可刪除項目。

### Verification

- Backend單元／契約共328項：324通過、4項ffprobe測試依既有OS條件在Windows跳過，0失敗；OpenAPI契約包含在內。
- 完整MySQL 8.4整合42項全部通過，含真實Security Filter、寄信失敗重試／告警、Token生命週期、全部Session撤銷，以及空資料庫／V2基礎升級至V9。
- 完整整合測試首次發現2項斷言仍預期V8；只修改預期版本及測試名稱。今日Docker起初未啟動，啟動後重跑成功。
- Flutter完整236項測試通過，Analyze無問題；Web release及Android debug APK建置成功。新增25項專項回歸包含390／599／600／900／1024／1199／1200／1440／1920寬度、300px鍵盤、矮視窗、Token切換、NFC前長度與非同步舊回應隔離。
- Penpot匯出兩度HTTP 504，Chrome初次DOM檢查也逾時；改用新分頁handle與viewport截圖後，已檢視Web／Mobile總覽及表單細節，不以資料結構檢查替代實際畫面。
- 本機Flutter 3.44.6／Dart 3.12.2／Java21；CI固定Flutter3.29.2，尚未送出PR或執行本Task CI。未升級專案框架或依賴；排除Flutter migrator自動加入的Android設定。
- 不宣告正式SMTP、部署環境或跨平台真人E2E已完成。

### Log Retention

- 依2026-08-31的一個月保存政策，保留2026-07-31起紀錄。
- 已移除20段過期Markdown紀錄及124筆過期CSV紀錄；XLSX沒有過期列。過期Log可由Git歷史取回。
- XLSX保留既有單表與帶狀配色，新增9筆實作／檢查與1筆Git同步紀錄；僅調整表頭高度及新增列的換行與高度，經影像與公式錯誤檢查。CSV保留13欄；最終XLSX共47筆、CSV共78筆資料列。

### Git / Pending

- 2026-08-31 14:48功能提交`0829f5d92dfa7d6565f8bc0b274dc0101064447d`（feat(auth): complete secure password reset flow）完成，共60個程式／規格檔案；本次另以docs提交同步三份Log。
- 分支feature/phase4.5-password-reset，PR目標feature/phase4.5；Log同步後一併Push並建立Draft PR，不合併。
- Task由IN PROGRESS轉REVIEW；CI、使用者Review及合併為獨立門檻，未經合併不轉DONE。
- 正式環境需配置HTTPS重設連結、寄信Adapter／SMTP、限流Secret與Worker開關。

---

## 2026-08-21 11:54

Task
Registration Login 10 Google 既有會員明確連結（REVIEW）

Agent
Codex

### Completed

- 新增v1 Google登入與明確連結流程；已連結帳號只以`provider + sub`登入，相同Email未連結時只回`GOOGLE_ACCOUNT_LINK_REQUIRED`，不建立關聯或一般Session。
- 既有會員需先以Email／密碼建立目前Session，再取得300秒、綁定目前Session與`LOGIN_METHOD_LINK`用途的reauth credential，最後以新Google ID Token明確確認。
- 連結成功保留目前Session、撤銷其他Session，並以不含Token、Email或驗證細節的`LOGIN_METHOD_LINKED` Audit／Outbox留下安全事件。
- Flutter完成需連結、既有帳號登入、重新驗證、確認、成功、衝突與取消；Web確認沿用Google官方按鈕，App重新取得ID Token。
- Penpot Web／Mobile各完成需連結、重新驗證、確認、成功與衝突五個畫板，共10個畫板且containment全部通過。

### Modified / Added / Deleted

- Backend新增`GoogleAccountController`、`GoogleAccountService`、連結DTO與`ReauthenticationPurpose`；修改Session reauth、OAuth Repository、安全設定、Legacy Google自動連結行為與測試。
- Database新增Flyway V8，只擴充reauth purpose與安全事件CHECK，未修改既有Migration。
- Flutter新增`GoogleAccountLinkPage`與測試；修改Auth Repository／Provider、Login結果、Login導頁與Router。
- 更新PROJECT／API／DATABASE／UI／DECISIONS／OpenAPI／Registration Task與三種Log；未修改`system_data/`。
- 刪除一個月保存期限外的2026-07-16、2026-07-18及2026-07-19 Markdown／CSV Log；未刪除產品程式。

### system_data Reference

- 舊Flutter只提供Google SDK登入與disconnect；舊Backend會以相同Email自動連結，並由舊流程產生帳號，與正式規格衝突。
- 只保留Google SDK取得ID Token的流程意圖；未沿用自動合併、空密碼、response body logging或敏感資料保存作法，`system_data/`全程唯讀。

### API

- 新增`POST /api/v1/auth/google-logins`：Backend驗證Google ID Token；已連結者登入，新Google會員進入Eligibility continuation，相同Email既有會員回需連結狀態。
- 新增`POST /api/v1/auth/google-account-links`：要求Bearer Session、`X-Reauthentication-Credential`、新ID Token與`confirmed: true`。
- `POST /api/v1/auth/reauthentications/password`新增選填`purpose`；預設仍為`SESSION_MANAGEMENT`，Google連結固定使用`LOGIN_METHOD_LINK`且不同用途不可互換。
- 舊`/api/auth/google-login`不再對相同Email自動建立OAuth關聯；新Flutter只呼叫v1端點。

### Database

- V8將`session_reauthentication_credentials.purpose`白名單擴充為`SESSION_MANAGEMENT`與`LOGIN_METHOD_LINK`。
- `session_security_audits.event_type`新增`LOGIN_METHOD_LINKED`；事件只綁目前Session與opaque event ID，Outbox payload固定`{}`。
- `user_oauth_accounts`仍以`provider, provider_user_id`唯一，Google `sub`不與Email混用，ID Token不落庫。

### Documentation

- OpenAPI升至0.7.0，新增Google登入、需明確連結、連結Command與用途限定reauth契約。
- 正式API、Database、UI與Decision同步方案1的Session-first明確連結、安全Session處理與Penpot畫板ID。
- Task09依已合併PR #100及四項CI全綠由`REVIEW`轉`DONE`；Task10完成實作並轉`REVIEW`，Draft PR #101四項CI全綠，等待使用者審查。

### Tests

- Backend完整321項單元／契約測試通過；Google verifier涵蓋issuer、audience、expiration、RS256 signature與verified Email。
- Backend完整39項真實HTTP／MySQL 8.4整合測試通過，驗證不自動連結、不核發Session、reauth用途隔離、目前Session保留、其他Session撤銷、`provider + sub`登入及敏感值不進Log；Flyway空庫與V2升級皆到V8。
- Flutter完整209項測試、Analyze、Web release build與Android debug APK build通過，涵蓋完整連結、衝突、取消、v1路徑／Header及390／600／1199／1440寬度。
- Draft PR #101的Backend unit、MySQL integration、Flutter及OpenAPI四項GitHub CI全部通過。

### Log Retention

- 保存期限截止日為2026-07-21；已刪除Markdown 1,206行與CSV 155筆過期紀錄，保留2026-07-22以後資料。
- XLSX最早資料為2026-08-01，沒有過期列；新增7筆並完成值、公式錯誤與視覺檢查。

### Pending

- Draft PR #101已建立且四項CI全綠；使用者審查與合併前Task10維持`REVIEW`。
- Task11 Forgot／Reset Password在Task10審查完成後再接續，不在本次範圍。

---

## 2026-08-16 09:19

Task
Registration Login 09 裝置工作階段管理（REVIEW）

Agent
Codex

### Completed

- 完成owner限定的分頁裝置清單、五分鐘密碼reauth，以及目前、單一、其他與全部Session Family撤銷；所有Command不接收Refresh Credential。
- 裝置資料只保存`WEB`／`ANDROID`／`IOS`／`UNKNOWN`與白名單化粗略摘要，不保存IP、完整User-Agent、型號或持久裝置指紋。
- Flutter新增`/profile/sessions`、個人資料入口、每頁3筆、密碼彈窗、成功／錯誤／網路重試與本地Session清理；主畫面不使用捲動容器。
- Penpot完成Web／Mobile預設與reauth四個畫板並通過containment；Task由`IN PROGRESS`轉為`REVIEW`。

### Modified / Added / Deleted

- Backend新增裝置metadata、reauth entity／repository／service、清單與撤銷controllers／DTOs，以及Flyway V6／V7；修改登入metadata傳遞、CORS與測試。
- Flutter新增device session model、repository、provider、page與測試；修改Auth登出、platform header、Profile入口與route。
- 更新PROJECT／API／DATABASE／UI／DECISIONS／OpenAPI／Registration Task與三種Log；未刪除產品檔案，未修改`system_data/`。

### system_data Reference

- 舊手冊只提供清除目前App本地資料的單一登出，沒有多裝置、opaque family、reauth或owner撤銷契約；只保留其「登出後回登入」意圖，未沿用舊Token與SharedPreferences作法。
- `system_data/`全程唯讀，沒有可安全直接重用的多裝置程式。

### API

- 新增`GET /api/v1/auth/sessions`、`POST /api/v1/auth/reauthentications/password`、`POST /api/v1/auth/logout`、單一／其他／全部撤銷端點及穩定成功／錯誤碼。
- 新增`X-Client-Platform`與`X-Reauthentication-Credential`；Web mutation沿用可信Origin、Cookie transport與CSRF proof。

### Database

- V6為`user_sessions`新增非敏感`device_type`與`device_summary`。
- V7新增只存SHA-256 hash、綁定Session與`SESSION_MANAGEMENT`用途、300秒到期的reauth資料表，並擴充`SESSION_REAUTHENTICATED`／`SESSION_REVOKED`安全事件。

### Documentation

- 正式文件同步方案1的分離API、資料最小化、五分鐘reauth、Penpot畫板ID、每頁3筆及無主畫面捲動規格。
- OpenAPI升至0.6.0；Task 09驗收項目完成並轉`REVIEW`，等待PR CI與使用者審查才轉`DONE`。

### Tests

- TDD先確認裝置清單與reauth／撤銷端點為Red，再完成Green；Backend 316項unit及38項真實MySQL integration通過。
- Flutter 200項完整測試、Analyze、Web release build及Android debug APK通過；390／600／1199／1200／1440寬度無主畫面捲動或overflow。
- 驗證被撤銷Access／Refresh皆拒絕、重複登出其他裝置仍成功且不產生新副作用、Web目前登出清除HttpOnly Cookie。

### Log Retention

- 保存期限截止日為2026-07-16；Markdown與CSV最早紀錄皆為2026-07-16，沒有早於截止日的過期紀錄，未刪除Log。
- XLSX最早資料為2026-08-01；新增7筆、公式錯誤掃描為0，並完成全表值與視覺檢查。

### Pending

- Commit `a221ff9`已推送，Draft PR #100已建立並指向`feature/phase4.5`；CI全綠與使用者審查前不合併、不轉`DONE`。
- 特權Session期限及其他敏感操作用途的reauth仍依後續Task處理，本Task credential不得跨用途使用。

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
