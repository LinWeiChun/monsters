# API_SPEC.md

# 貘nsters REST API 規格

> Phase 4.5 的跨平台 E2E、OpenAPI Contract 與 Session／Entry／Data Rights 驗收範圍以 [`PHASE4_5_FOUNDATION_SPEC.md`](PHASE4_5_FOUNDATION_SPEC.md) 為準；註冊、登入、會員管理、公開暱稱及其 Status／error matrix 以 [`REGISTRATION_LOGIN_MEMBER_MANAGEMENT_SPEC.md`](REGISTRATION_LOGIN_MEMBER_MANAGEMENT_SPEC.md) 為準；本文件保存正式 API 契約。

> 狀態說明：本文件以「零、已核准 v1 目標契約」為正式目標。第二章以後仍包含 `develop` 目前無版本 API 的實作細節，供 Phase 4 整合與相容 Migration 使用；凡涉及 `/api`、`account`、公開頭貼上傳、JWT Refresh Token、伺服器密碼鎖、`isShared`、分數／分類必填、隨機怪獸或深度心理測驗者，均屬待淘汰基線，不得新增依賴。

## 零、已核准 v1 目標契約

### 0.1 API 邊界

- 正式 Base URL 固定為 `/api/v1`。
- Client 可引用的 Entry、媒體、Community Post、留言、案件與工作使用 UUID `publicId`，不得回傳內部自增 ID。
- 會員 owner 一律由 Access Token 的工作階段取得，Client 不得傳入 `userId`、`account` 或 owner。
- 不存在、已刪除、無權查看或不屬於父資源時，以一致 404 避免洩漏。
- 建立、分享、刪除申請、匯出等可重試操作接受 `Idempotency-Key`。
- 更新 Aggregate 必須帶版本或 `If-Match`；版本衝突回傳 409，不得最後寫入者無聲覆蓋。
- OpenAPI 為可執行契約，CI 必須驗證實作與規格未漂移。

### 0.2 身分與工作階段

| 能力 | v1 契約 |
|---|---|
| Email 註冊 | 不接受 `account`；建立 `PENDING_EMAIL_VERIFICATION` 會員並寄送一次性驗證連結 |
| Email 驗證 | Token 短效、單次使用、Backend 只保存 hash |
| Login Continuation | 憑證正確但流程未完成時回 `200 AUTH_CONTINUATION_REQUIRED`、`nextAction`、10 分鐘用途受限 credential；不回 Access／Refresh Token |
| Google 登入 | 只接受已驗證 Email；同 Email 不自動合併，回傳需連結狀態 |
| 年齡資格 | Email 驗證後提交生日、服務地區與條款版本；13–17 歲進入監護人同意流程 |
| Guardian Consent | 一次性 Email 連結；核准／撤回特定條款版本，不授予內容存取 |
| Access Token | 10 分鐘短效 JWT，只含最少聲明與工作階段 ID |
| Refresh Token | 高強度不透明值，每次換發 rotation；Backend 只保存 hash 與 Token family |
| Web Session | Refresh Token 使用 `__Host-` HttpOnly、Secure、SameSite Cookie；Access Token 只放記憶體 |
| App Session | Refresh Token 存 Keychain／Keystore；Access Token 只放記憶體 |
| Session Expiry | 一般會員閒置 30 天、絕對 90 天；特權後台閒置 30 分鐘、絕對 8 小時 |
| Reauthentication | 敏感操作需五分鐘內取得、用途受限且不可延長的 reauth credential |
| Password Reset | 對外統一回應，Email reset link 15 分鐘單次使用；成功後撤銷所有工作階段 |
| Privileged MFA | Moderator、Admin、Content Reviewer 必須完成 TOTP 與備援碼才能使用後台 |
| Public Nickname | 2–30 Unicode code points、NFC、非唯一且不可登入；首次社群公開前明確確認，禁止官方冒充名稱 |

Web 使用 Cookie 的 Auth endpoint 必須驗證可信任 Origin／CSRF 防護；SameSite 不能作為唯一防護。任何 Token、Cookie、Authorization Header 或驗證連結不得寫入 Log。

#### 0.2.1 已實作的註冊與 Email 驗證垂直接縫

| Method | Path | 成功結果 |
|---|---|---|
| `GET` | `/api/v1/auth/registration-policy` | `200 REGISTRATION_POLICY_AVAILABLE`，回目前 Terms／Privacy version 與 HTTPS URL |
| `POST` | `/api/v1/auth/register` | 新會員與既有 Email 一律 `202 REGISTRATION_ACCEPTED`，不回會員資料 |
| `POST` | `/api/v1/auth/email-verification-requests` | 已知與未知 Email 一律 `202 EMAIL_VERIFICATION_REQUEST_ACCEPTED` |
| `POST` | `/api/v1/auth/email-verifications` | `200 EMAIL_VERIFIED`，回 `COMPLETE_ELIGIBILITY` 與 10 分鐘 Continuation Credential |

- 初始註冊只收 `email`、`password`、`acceptedTermsVersion`、`acceptedPrivacyVersion`；拒絕未知欄位，不收 `account`、生日、服務地區、暱稱、Guardian Email 或頭貼。
- 新密碼先做 NFC 且不 trim，以 15–128 Unicode code points 驗證，再對版本化本機 blocklist 做完整值比對；違反時回 `400 VALIDATION_FAILED`，`fieldErrors.password` 使用 `PASSWORD_REQUIRED`、`PASSWORD_TOO_SHORT`、`PASSWORD_TOO_LONG` 或 `PASSWORD_TOO_WEAK`。
- 新密碼保存為 `$argon2id$` PHC hash，參數為 `m=19456,t=2,p=1`；既有 BCrypt 只在成功登入後於同一交易升級，失敗登入不得改寫 hash。
- Email Token 有效 24 小時、單次使用且只保存 SHA-256 hash；重寄成功寄送新信前後均不將 Email、Token 或密碼寫入 Outbox payload／Log。
- 初次註冊與重寄共用 MySQL 持久化 HMAC 限流桶：Email 60 秒冷卻、每 15 分鐘最多 5 次；IP 每 15 分鐘最多 20 次。受限時回 `429 RATE_LIMITED`、`Retry-After` Header 與安全 `data.retryAfter`。
- 條款版本或 URL、限流 HMAC key 未設定時安全失敗為 `503 SERVICE_TEMPORARILY_UNAVAILABLE`，不得使用程式內 placeholder。
- SMTP 透過 Spring Mail 的通用 Adapter；SMTP 未啟用或寄送失敗時由 Transactional Outbox 重試，最多五次後為 `FAILED`。

#### 0.2.2 Eligibility、Guardian Consent 與公開暱稱垂直接縫

| Method | Path | Auth | 成功結果 |
|---|---|---|---|
| `GET` | `/api/v1/auth/eligibility-policy` | Public | `200 ELIGIBILITY_POLICY_AVAILABLE`，回台灣地區、13／18 歲邊界及目前文件版本／HTTPS URL |
| `POST` | `/api/v1/auth/eligibility-completions` | `Authorization: Continuation <credential>` | 成人 `200 ELIGIBILITY_COMPLETED`；13–17 歲 `202 GUARDIAN_CONSENT_PENDING`；非台灣／未滿 13 歲 `200 ELIGIBILITY_RESTRICTED` |
| `POST` | `/api/v1/auth/guardian-consent-actions` | Public token body | `200 GUARDIAN_CONSENT_ACTION_AVAILABLE`，只回文件版本／URL與動作，不回會員資料 |
| `POST` | `/api/v1/auth/guardian-consents` | Public token body | `200 GUARDIAN_CONSENT_GRANTED`；Guardian 只建立特定版本同意，不取得會員 Session |
| `POST` | `/api/v1/auth/guardian-consent-withdrawal-requests` | Public | 永遠 `202 GUARDIAN_CONSENT_WITHDRAWAL_REQUEST_ACCEPTED`，不得揭露 consent reference／Email 是否匹配 |
| `POST` | `/api/v1/auth/guardian-consent-withdrawals` | Public token body | `200 GUARDIAN_CONSENT_WITHDRAWN`，立即停止會員一般功能並撤銷資格相關憑證 |

`POST /eligibility-completions` request：

```json
{
  "serviceRegion": "TW",
  "birthday": "2010-08-01",
  "publicNickname": "小貘 ✨",
  "guardianEmail": "guardian@example.com",
  "acceptedMinorNoticeVersion": "minor-notice-2026-01",
  "guardianConsentVersion": "guardian-consent-2026-01",
  "confirmPublicNicknameDisclosure": false,
  "publicNicknameDisclosureVersion": "public-nickname-2026-01"
}
```

- Backend 以 `Asia/Taipei` 當日計算完整年齡；Client 計算只供畫面分流，不具授權效果。
- 非台灣或未滿 13 歲只保存地區、生日與受限狀態，不保存 `publicNickname`、Guardian Email 或公開確認。
- 成年會員必須提供合規公開暱稱；是否先確認公開揭露不影響私人核心，但未確認時 Community Eligibility 維持 `PENDING_NICKNAME_CONFIRMATION`。
- 13–17 歲必須提供 Guardian Email、目前 Minor Notice／Guardian Consent 版本；Guardian 完成同意前維持 `PENDING_ELIGIBILITY`，不得取得一般 Session或存取私人 API。
- 公開暱稱儲存前 NFC、移除首尾空白，長度 2–30 Unicode code points；拒絕控制字元、換行、雙向控制、純空白、不可見字元與官方冒充名稱。暱稱不唯一，不可登入或作 owner key。
- Guardian 核准 Token 有效 24 小時；撤回 Token 有效 15 分鐘。兩者皆為 32-byte、單次使用且 Server 只保存 SHA-256 hash；新要求撤銷同用途舊 Token。
- Guardian 撤回要求使用 opaque `consentReference` 加 Guardian Email，公開回應一律相同；Email、生日、Token、Guardian資料不得進入 Log、Audit、Outbox payload或錯誤訊息。
- 同意 Email 只含安全文件連結與 opaque action link，不含生日、公開暱稱、會員 Email、私人內容或會員 UUID。
- `ELIGIBILITY_CONTINUATION_INVALID`、`GUARDIAN_CONSENT_TOKEN_INVALID` 與 `GUARDIAN_CONSENT_TOKEN_EXPIRED` 使用穩定錯誤碼；欄位錯誤使用 `VALIDATION_FAILED` 與安全 `fieldErrors`。
- 成人完成或 Guardian 核准後回 `nextAction = SIGN_IN`，由會員重新登入建立新的裝置 Session Family；Eligibility endpoint 本身不核發一般 Session。

#### 0.2.3 Opaque Refresh Session Family 垂直接縫

| Method | Path | Auth | 成功結果 |
|---|---|---|---|
| `POST` | `/api/v1/auth/login` | Public credential body；Web Cookie transport需額外Header與可信Origin | `200 AUTHENTICATED`，建立獨立 `user_sessions` family；App回opaque Refresh Credential，Web改設HttpOnly Cookie |
| `POST` | `/api/v1/auth/session-refreshes` | App使用opaque credential body；Web使用Cookie transport | `200 AUTHENTICATED`，輪替Credential；同一輪替10秒內回相同結果 |

- App refresh request只接受`refreshCredential`；Credential為32-byte高強度opaque值，Backend只保存SHA-256 hash，不保存明文或可還原密文。
- Web在登入與refresh時送`X-Session-Transport: COOKIE`、`X-CSRF-Protection: 1`及瀏覽器`Origin`；Backend只接受`WEB_SESSION_TRUSTED_ORIGIN_PATTERNS`白名單，且SameSite不得取代Origin與CSRF檢查。
- Web Refresh Credential只由Backend以`__Host-monsters-refresh` Cookie設定；屬性固定`Path=/`、`HttpOnly`、`Secure`、`SameSite=None`，最長90天。`None`用於Cloudflare Pages至Railway的跨站HTTPS Request，不能取代可信Origin、CORS及`X-CSRF-Protection`檢查。Web成功回應不含`refreshToken`欄位，無效或reuse的`401`回應會清除Cookie。
- Android／iOS以`flutter_secure_storage 10.3.1`保存Refresh Credential至Keystore／Keychain；Access Token只保存在Dio記憶體Header，SharedPreferences不得保存Token或完整`LoginResult`。
- 初始Credential使用CSPRNG；後續Credential以獨立`SESSION_REFRESH_DERIVATION_KEY`、上一Credential、Session UUID及sequence透過HMAC-SHA256推導，使Server在不保存明文下可於10秒內重建完全相同的輪替結果。
- 一般Session閒置期限30天、絕對期限90天；每次有效輪替只延長idle期限且不得超過absolute期限。
- 10秒後再次提交已輪替Credential視為reuse，於同一交易撤銷該family並寫入安全Audit與Outbox；其他裝置family不受影響。
- 無效、過期或已撤銷回`401 AUTH_SESSION_INVALID`；reuse回`401 AUTH_REFRESH_REUSE_DETECTED`。
- Access JWT只包含`iss`、`sub`、`sid`、`iat`、`exp`；不得包含Email、Refresh值或會員私人資料。Security Filter每次以`sid`確認Session及會員仍可用。
- 並行Access `401`由`ApiClient`共用單一refresh future；成功後每個原request最多重試一次。暫時性網路錯誤保留Credential並在Splash顯示重試，不導向登入或撤銷server session。

#### 0.2.4 裝置工作階段管理

| Method | Path | Auth／Header | 成功結果 |
|---|---|---|---|
| `GET` | `/api/v1/auth/sessions?page=0&size=3` | Bearer Access | `200 DEVICE_SESSIONS_RETRIEVED`，只回owner仍有效的裝置類型、約略摘要、最後活動與目前標記 |
| `POST` | `/api/v1/auth/reauthentications/password` | Bearer Access＋密碼body | `200 SESSION_REAUTHENTICATED`，回一次性傳輸的`SESSION_MANAGEMENT` opaque credential，固定300秒 |
| `POST` | `/api/v1/auth/logout` | Bearer Access；Web另帶Cookie transport防護 | `200 CURRENT_SESSION_REVOKED`，只撤銷目前family |
| `POST` | `/api/v1/auth/sessions/{sessionId}/revocations` | Bearer Access＋`X-Reauthentication-Credential` | `200 DEVICE_SESSION_REVOKED`，只撤銷owner指定的其他family |
| `POST` | `/api/v1/auth/session-revocations/others` | Bearer Access＋`X-Reauthentication-Credential` | `200 OTHER_SESSIONS_REVOKED`，保留目前family |
| `POST` | `/api/v1/auth/session-revocations/all` | Bearer Access＋`X-Reauthentication-Credential` | `200 ALL_SESSIONS_REVOKED`，包含目前family |

- 完整登入以`X-Client-Platform: WEB|ANDROID|IOS`傳平台白名單；Backend只從白名單平台與User-Agent推導粗略摘要，不保存IP、完整User-Agent、裝置型號或持久指紋。無效值降級為`UNKNOWN`。
- 清單固定`page >= 0`、`size = 1..5`；Client預設每頁3筆，以分頁直接顯示全部目前頁內容，不以主畫面捲動承載裝置數量。
- reauth credential使用32-byte CSPRNG opaque值，Backend只保存SHA-256 hash，綁定目前Session與`SESSION_MANAGEMENT`用途，300秒後失效；密碼、credential、hash、Email不得進Log／Audit／Outbox。
- 單一、其他及全部撤銷都以owner與目前`sid`強制界定；不得接受Client傳入`userId`或Refresh Credential。重複撤銷不新增副作用或重複安全事件。
- 撤銷在同一交易更新Session並寫`SESSION_REVOKED` Audit／Outbox；後續Access由Security Filter拒絕，Refresh由rotation服務拒絕。Web目前／全部登出成功時清除`__Host-monsters-refresh` Cookie。
- Web所有裝置管理mutation須沿用可信Origin、`X-Session-Transport: COOKIE`與`X-CSRF-Protection: 1`；CORS另允許`X-Client-Platform`與`X-Reauthentication-Credential`。

### 0.3 核心資源契約

| 資源 | v1 行為 |
|---|---|
| Entry | Diary／Annoyance 共用核心，建立／修改命令分離；私人分類與 1–5 情緒負荷皆選填 |
| Emotional Trace | 最近 30 個本地日曆日，同日多筆取平均、缺值留白，可依 Entry type 篩選 |
| Entry Search | 本人主動關鍵字與 metadata 篩選；不保存查詢、不做向量或 AI 搜尋 |
| Media | 先建立隔離工作，完成真實格式、重新處理、中繼資料移除與掃描後才可下載 |
| Community Post | 由 Entry 建立獨立公開快照；更新產生版本，私人原文修改不得自動同步 |
| Unshare | 立即隱藏 Post、留言與支持，七天內清除；重新分享產生新 Post |
| Monster | 查詢圖鑑、已取得項目、固定里程碑進度與選定頭貼；不提供 random API |
| Self Exploration | 結果完全私人、版本化、可逐筆刪除，不提供分享 |
| Educational Quiz | 有答案、說明、來源與適用年齡；不排名、不因答錯扣獎勵進度 |
| Data Export | 重新驗證後建立背景工作，回傳狀態與短效下載連結 |
| Account Deletion | 重新驗證後立即停用與取消分享，七天內可取消，之後永久清除 |

### 0.4 社群與後台契約

- Community API 只接受具 Community Eligibility 的成年會員。
- 社群提供時間／公開主題查詢、公開暱稱、單層留言、單一支持、檢舉、封鎖、取消分享及申訴。
- 公開暱稱可跨貼文辨識但不能用於登入、owner 判斷或查詢私人 Profile；不提供公開支持數、排行榜、私訊、追蹤、標記、使用者搜尋、社群全文搜尋或永久媒體 URL。
- Report 建立後只對檢舉者隱藏內容，不因檢舉數自動下架；自傷／傷人疑慮進入人工優先佇列。
- Moderator 只處理已檢舉公開內容；Admin 管理角色、設定與正式停權；Content Reviewer 只審閱版本化內容。
- 所有特權操作須 MFA、最小權限與不可修改稽核；任何角色都不得查詢私人 Entry 或模擬會員登入。

### 0.5 錯誤與工作狀態

v1 錯誤 Response 必須包含：

```json
{
  "success": false,
  "code": "ENTRY_VERSION_CONFLICT",
  "message": "資料已在其他裝置更新",
  "requestId": "opaque-request-id",
  "data": null
}
```

- `code` 為穩定機器代碼；Client 不得解析自由文字決定流程。
- `requestId` 不可包含 user、Email、Token 或資源內部 ID。
- 背景工作回傳明確 `pending`、`processing`、`completed`、`failed`、`expired` 等狀態。
- 媒體、Email、匯出、刪除、通知與獎勵透過 Transactional Outbox 與 idempotent Worker 執行；一次性 best-effort 不符合契約。

## 一、共通規範

Base URL：

```text
/api/v1
```

Flutter API Client：

```text
frontend/lib/core/network/ApiClient
```

前端 API Host Base URL 預設值：

```text
http://localhost:8080/api
```

前端可透過 dart-define 覆寫：

```text
API_BASE_URL
```

Flutter UI 不得直接呼叫 Dio。API 存取必須經由 Provider / Repository 使用 `ApiClient`。

Railway 與 Flutter build 對照：

| Git 分支 | Railway Backend | Flutter `API_BASE_URL` |
|---|---|---|
| `develop` | `https://monsters-staging.up.railway.app` | `https://monsters-staging.up.railway.app/api` |
| `main` | `https://monsters-production-9535.up.railway.app` | `https://monsters-production-9535.up.railway.app/api` |

`EMAIL_VERIFICATION_PUBLIC_URL` 必須另設為同環境 Flutter Web 的 `/verify-email` 公開頁，不得填 Railway Backend URL；驗證頁再以 `POST /api/v1/auth/email-verifications` 消耗 Token。
Flutter API 錯誤處理：

```text
frontend/lib/core/network/ApiErrorHandler
frontend/lib/core/network/ApiException
frontend/lib/core/network/ApiErrorType
```

`ApiClient` 必須將 `DioException`、逾時、網路錯誤、非標準 Response 轉換為 `ApiException`。UI / Repository 不直接處理 `DioException`，應依 `ApiErrorType` 判斷錯誤類型。

錯誤類型對應：

| HTTP / 狀態 | ApiErrorType |
|---|---|
| network error | network |
| timeout | timeout |
| 400 | validation |
| 401 | unauthorized |
| 403 | forbidden |
| 404 | notFound |
| 409 | conflict |
| 500+ | server |
| cancelled | cancelled |
| other | unknown |

成功 Response：

```json
{
  "success": true,
  "message": "操作成功",
  "data": {}
}
```

失敗 Response：

```json
{
  "success": false,
  "code": "VALIDATION_ERROR",
  "message": "錯誤訊息",
  "data": null,
  "fieldErrors": {
    "email": "Email 格式錯誤"
  },
  "requestId": "opaque-request-id"
}
```

後端共用 Response DTO：

```text
com.monsters.dto.common.ApiResponse<T>
```

Controller 回傳資料時必須使用 `ApiResponse<T>` 包裝；v1 欄位為：

| 欄位 | 型別 | 說明 |
|---|---|---|
| success | boolean | 是否成功 |
| code | string | 穩定機器代碼；成功預設為 `SUCCESS` |
| message | string | 成功或錯誤訊息 |
| data | object / array / null | 回傳資料，失敗時為 null |
| fieldErrors | object | 欄位驗證錯誤；沒有錯誤時為空 object，不得包含被拒絕的原始值 |
| requestId | string | 每次回應的 opaque ID；不得含個資或內部資源 ID |

成功預設訊息：

```text
操作成功
```

全域 Exception Handler：

```text
com.monsters.exception.common.GlobalExceptionHandler
```

Exception 回傳格式固定使用 `ApiResponse<Void>`：

```json
{
  "success": false,
  "code": "UNEXPECTED_ERROR",
  "message": "錯誤訊息",
  "data": null,
  "fieldErrors": {},
  "requestId": "opaque-request-id"
}
```

後端共用 Exception 與 HTTP Status：

| Exception | HTTP Status | 用途 |
|---|---:|---|
| BusinessException | 400 | 一般商業邏輯錯誤 |
| ValidationException | 400 | 請求資料驗證錯誤 |
| UnauthorizedException | 401 | 尚未登入或 Token 無效 |
| ForbiddenException | 403 | 權限不足 |
| ResourceNotFoundException | 404 | 查無資料 |
| ConflictException | 409 | 資料衝突或重複 |
| Exception | 500 | 未預期系統錯誤 |

需要登入的 API 必須帶入：

```text
Authorization: Bearer <token>
```

CORS 設定：

```text
com.monsters.config.common.CorsConfig
```

CORS 僅套用於：

```text
/api/v1/**
```

允許來源不得使用 `*`，需透過環境變數或設定檔指定可信任來源。

| 設定 | 環境變數 | 預設值 |
|---|---|---|
| app.cors.allowed-origin-patterns | CORS_ALLOWED_ORIGIN_PATTERNS | http://localhost:*,http://127.0.0.1:* |
| app.cors.allowed-methods | CORS_ALLOWED_METHODS | GET,POST,PUT,PATCH,DELETE,OPTIONS |
| app.cors.allowed-headers | CORS_ALLOWED_HEADERS | Authorization,Content-Type,Range,X-Session-Transport,X-CSRF-Protection,X-Client-Platform,X-Reauthentication-Credential |
| app.cors.exposed-headers | CORS_EXPOSED_HEADERS | Authorization,Accept-Ranges,Content-Length,Content-Range |
| app.cors.allow-credentials | CORS_ALLOW_CREDENTIALS | true |
| app.cors.max-age | CORS_MAX_AGE | 3600 |

Security / JWT 基礎設定：

```text
com.monsters.security.common.SecurityConfig
```

安全規則：

| Path | Method | 規則 |
|---|---|---|
| /api/v1/auth/register | POST | 允許匿名 |
| /api/v1/auth/login | POST | 允許匿名 |
| /api/v1/auth/session-refreshes | POST | 允許匿名 |
| /api/v1/auth/google-login | POST | 允許匿名 |
| /api/v1/auth/forgot-password | POST | 允許匿名 |
| /api/v1/auth/reset-password | POST | 允許匿名 |
| /api/v1/auth/logout | POST | 需驗證 |
| /api/v1/** | ALL | 需驗證 |
| 其他路徑 | ALL | 拒絕 |

Security 錯誤回應固定使用 `ApiResponse<Void>`，並包含穩定 `code`、空 `fieldErrors` 與 opaque `requestId`：

| 狀態 | code | message |
|---:|---|---|
| 401 | `AUTHENTICATION_REQUIRED` | 尚未登入或 Token 無效 |
| 403 | `PERMISSION_DENIED` | 權限不足 |

JWT 基礎設定：

| 設定 | 環境變數 | 預設值 |
|---|---|---|
| app.security.jwt.issuer | JWT_ISSUER | monsters |
| app.security.jwt.signing-key | JWT_SIGNING_KEY | 空字串，正式環境必須由 Secret Manager／KMS 提供並支援 `kid` 輪替 |
| app.security.jwt.access-token-expiration-seconds | JWT_ACCESS_TOKEN_EXPIRATION_SECONDS | 600 |
| app.security.session.idle-expiration-seconds | SESSION_IDLE_EXPIRATION_SECONDS | 2592000 |
| app.security.session.absolute-expiration-seconds | SESSION_ABSOLUTE_EXPIRATION_SECONDS | 7776000 |
| app.security.session.refresh-concurrency-grace-seconds | SESSION_REFRESH_CONCURRENCY_GRACE_SECONDS | 10 |
| app.security.session.refresh-derivation-key | SESSION_REFRESH_DERIVATION_KEY | 空字串；啟用v1完整Session前必須提供至少32-byte獨立Secret |
| app.security.web-session.trusted-origin-patterns | WEB_SESSION_TRUSTED_ORIGIN_PATTERNS | http://localhost:*,http://127.0.0.1:*；正式環境只列Web前端Origin |
| app.security.web-session.cookie-max-age-seconds | WEB_SESSION_COOKIE_MAX_AGE_SECONDS | 7776000 |

Google 登入設定：

| 設定 | 環境變數 | 預設值 |
|---|---|---|
| app.security.google.client-ids | GOOGLE_CLIENT_IDS | 空字串，啟用 Google 登入前必須提供 |

Flutter Google 登入設定：

| Dart Define | 用途 | 預設值 |
|---|---|---|
| GOOGLE_CLIENT_ID | 前端 Google Sign-In 初始化用 Client ID，Web 必填，App 可依平台設定搭配使用 | 空字串 |
| GOOGLE_SERVER_CLIENT_ID | Android / iOS 前端要求 ID Token 時使用的 Server / Web Client ID，需包含於後端 `GOOGLE_CLIENT_IDS`；Web 不傳此值給 Google SDK | 空字串 |

Web 本機 Google 登入測試固定使用：

| 項目 | 值 |
|---|---|
| Local origin | http://localhost:5050 |
| Frontend script | `frontend/tool/run_web_local.sh`、`frontend/tool/run_web_local.ps1` |

Google Cloud OAuth Client 的 Authorized JavaScript origins 必須加入 `http://localhost:5050`。

Cloudflare R2 檔案上傳設定：

| 設定 | 環境變數 | 預設值 |
|---|---|---|
| app.storage.r2.account-id | R2_ACCOUNT_ID | 空字串，啟用私人媒體前必須提供 |
| app.storage.r2.access-key-id | R2_ACCESS_KEY_ID | 空字串，啟用私人媒體前必須提供 |
| app.storage.r2.secret-access-key | R2_SECRET_ACCESS_KEY | 空字串，啟用私人媒體前必須提供 |
| app.storage.r2.entry-media-bucket | R2_ENTRY_MEDIA_BUCKET | 空字串，必須為 private bucket |
| app.storage.r2.quarantine-bucket | R2_QUARANTINE_BUCKET | 空字串，必須與正式媒體隔離 |

使用者頭貼不接受上傳；既有 public avatar bucket、`R2_PUBLIC_BASE_URL`、avatar prefix 與 avatar upload endpoint 均列入移除清單。

---

## 一之一、舊系統 API 參考原則

`system_data/` 內的舊 API、Controller、Service 或前端呼叫方式，僅作為新版 API 設計參考。

可參考項目：

- 舊功能流程
- Request 欄位意義
- Response 資料需求
- 錯誤情境
- 使用者操作順序
- 舊資料表與 API 的關聯

不得直接沿用項目：

- 舊 API path
- 不一致的 HTTP method
- 拼字錯誤的欄位名稱
- 不符合 RESTful 原則的設計
- 混合中文、英文或縮寫不一致的參數
- 舊系統未標準化的 Response 格式
- 舊系統缺少錯誤處理或驗證的行為

新版 API 應以本文件為準。  
若舊系統行為與本文件不同，應記錄差異，並依新版 API 規格實作。

### `system_data/` API 參考紀錄格式

| 項目 | 說明 |
|---|---|
| 舊系統參考位置 | `system_data/...` |
| 可參考內容 | 功能流程 / 欄位 / Response 需求 / 錯誤情境 |
| 不可沿用內容 | 舊 API path / 舊 DTO / 未標準化 Response / 硬編碼 |
| 新版調整方式 | 依新版 REST API、DTO、Exception 與 `ApiResponse<T>` 規範重新設計 |
| 是否需更新正式規格 | 是 / 否 |

---

## 二、目前無版本 Auth API（待遷移）

本章以下 Request／Response 用於描述 `develop` 現況，不是新功能契約。目標 Auth API 依 0.2 實作；不得再新增 `account`、JWT Refresh Token 明文 Response、開發 reset Token Response 或 Google 同 Email 自動連結。

### 2.1 註冊

`POST /api/auth/register`

Request：

```json
{
  "account": "wei_account",
  "email": "user@example.com",
  "password": "password123",
  "userName": "使用者名稱"
}
```

Response：

```json
{
  "success": true,
  "message": "Register success",
  "data": {
    "userId": 1,
    "account": "wei_account",
    "email": "user@example.com",
    "userName": "使用者名稱"
  }
}
```

規則：

- `account` 必填，長度 4 到 50，必須英文開頭，且只能包含英文、數字、底線；後端需轉為小寫保存。
- `email` 必填，必須符合 Email 格式。
- `password` 必填，NFC 後長度為 15 到 128 Unicode code points，不 trim，並套用版本化本機弱密碼 blocklist。
- `userName` 必填，最大長度 80。
- 註冊成功後建立 `users` 與 `user_credentials`。
- 新密碼必須以 Argon2id PHC hash 保存；既有 BCrypt 只供成功登入時漸進升級。不得保存或記錄明文、hash 或 blocklist 命中內容。
- Account 已被註冊時回傳 409。
- Email 已被註冊時回傳 409。

### 2.2 登入

正式 v1 endpoint：

`POST /api/v1/auth/login`

Request：

```json
{
  "email": "user@example.com",
  "password": "password"
}
```

Response：

```json
{
  "success": true,
  "message": "Login success",
  "data": {
    "accessToken": "jwt_access_token",
    "refreshToken": "jwt_refresh_token",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "publicId": "00000000-0000-0000-0000-000000000001",
      "email": "user@example.com",
      "userName": "使用者名稱"
    }
  }
}
```

會員流程未完成的 Response：

```json
{
  "success": true,
  "code": "AUTH_CONTINUATION_REQUIRED",
  "message": "Additional member verification is required",
  "data": {
    "nextAction": "COMPLETE_ELIGIBILITY",
    "continuationCredential": "opaque-one-time-response-value",
    "expiresIn": 600
  },
  "fieldErrors": {},
  "requestId": "opaque-request-id"
}
```

規則：

- v1 `email` 只接受 Email 格式，必填且最大長度 255；未知欄位（包含 `account`）回 `400 REQUEST_BODY_INVALID`。
- Email 只做前後空白移除與 locale-independent 小寫正規化後精確查詢；不得套用 Gmail 點號消除或 `+tag` 合併。
- 登入依 hash 前綴使用 Argon2id 或既有 BCrypt 比對；BCrypt 只在成功後原子升級為 Argon2id，不得將密碼或 hash 寫入 log。
- Email 不存在、帳號為不可揭露狀態、憑證不存在或密碼錯誤時，統一回 `401 AUTH_INVALID_CREDENTIALS`。
- `accessToken` 與 `refreshToken` 使用 HMAC-SHA256 JWT 產生。
- `JWT_SECRET` 必須設定，否則不得產生 JWT。
- `ACTIVE` 回 `200 AUTHENTICATED` 與完整 Session；`PENDING_EMAIL_VERIFICATION`、`PENDING_ELIGIBILITY`、`USER_DEACTIVATED`、`ADMIN_SUSPENDED`、`DELETION_PENDING` 回 `200 AUTH_CONTINUATION_REQUIRED`。
- v1 `user` 只回公開 UUID、Email 與顯示名稱，不得包含 `account` 或內部 `userId`。
- `nextAction` 僅允許 `VERIFY_EMAIL`、`COMPLETE_ELIGIBILITY`、`REACTIVATE_ACCOUNT`、`REVIEW_SUSPENSION`、`REVIEW_DELETION`。
- Continuation Credential 使用 32-byte 安全隨機值、URL-safe Base64、10 分鐘有效，Backend 只保存 SHA-256 hash；新核發、會員狀態或 version 改變時撤銷舊值。
- Continuation Credential 不是 Access Token，不得存取一般會員 API；Flutter 不得把它放入 Authorization Header、SharedPreferences 或一般 Session。
- `DELETED` 不核發任何 Credential，使用與無效憑證一致的公開錯誤。

Account expand migration 期間暫留 deprecated `POST /api/auth/login`：

- Request key 仍為 `email`，但可傳入既有 Email 或 legacy `account`，供已部署舊 Client 與既有會員過渡。
- 新 Flutter 與所有新 Client 不得呼叫此 endpoint，也不得顯示、送出或保存 `account`。
- 舊 endpoint 暫維持 historical response 相容；Task 18 完成使用觀測與 contract migration 後才移除 endpoint 與 `users.account`。
- 新舊 endpoint 共用相同密碼驗證、成功 BCrypt rehash、會員狀態 continuation 與 `AUTH_INVALID_CREDENTIALS` 安全邊界。

### 2.3 Google 登入

`POST /api/auth/google-login`

Request：

```json
{
  "idToken": "google_id_token"
}
```

Response：

```json
{
  "success": true,
  "message": "Google login success",
  "data": {
    "accessToken": "jwt_access_token",
    "refreshToken": "jwt_refresh_token",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "userId": 1,
      "account": "wei_account",
      "email": "user@example.com",
      "userName": "Wei",
      "avatarUrl": null
    }
  }
}
```

規則：

- 後端必須驗證 Google ID Token，不接受前端自行驗證後傳入的使用者資料。
- Flutter 端僅負責透過 Google Sign-In SDK 取得 Google ID Token，並呼叫本 API；不得傳入 Google 使用者資料取代 token。
- `idToken` 必填。
- Google ID Token 必須符合 RS256 簽章、有效 `kid`、Google issuer、未過期、`email_verified = true`。
- `aud` 必須存在於 `GOOGLE_CLIENT_IDS` 設定，可用逗號設定多組 Web / App Client ID。
- 驗證成功後，以 Google `sub` 對應 `user_oauth_accounts.provider_user_id`。
- 若 OAuth 帳號已存在，使用既有使用者產生 JWT。
- 若 OAuth 帳號不存在但 email 已有未刪除使用者，建立 OAuth 連結後產生 JWT。
- 若 OAuth 帳號不存在且 email 尚未註冊，由 email 前綴產生唯一 `account`，建立 `users` 與 `user_oauth_accounts` 後產生 JWT。
- ID Token 無效、email 未驗證、對應使用者已刪除或 `GOOGLE_CLIENT_IDS` 未設定時，回傳 401。
- 不得將 Google ID Token、JWT、Google 公鑰 response 或敏感驗證細節寫入 log。

### 2.4 Token 換發

`POST /api/auth/refresh`

Request：

```json
{
  "refreshToken": "current_refresh_token"
}
```

Response：

```json
{
  "success": true,
  "message": "Token refresh success",
  "data": {
    "accessToken": "new_access_token",
    "refreshToken": "new_refresh_token",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "userId": 1,
      "account": "wei_account",
      "email": "user@example.com",
      "userName": "Wei",
      "avatarUrl": null
    }
  }
}
```

規則：

- Refresh API 允許未帶 access token 呼叫，但 `refreshToken` 必填。
- 後端必須驗證 JWT 簽章、issuer、`type = refresh`、有效期限與對應使用者未刪除。
- Refresh token 預設有效時間為 2592000 秒（30 天）。
- 每次成功換發都必須 rotation：舊 refresh token hash 寫入 `revoked_tokens`，並回傳新的 access token 與 refresh token。
- 舊 refresh token、已撤銷 token、過期 token、access token 或格式錯誤 token 不得換發，回傳 401。
- 同一舊 refresh token 遭並行使用時只允許一次成功；其餘 request 回傳 401。
- Response 與登入 API 使用相同 `LoginResponse` contract，前端成功後必須以新資料覆蓋本地 session。
- 不得記錄 refresh token 明文或 token hash。

### 2.5 忘記密碼

`POST /api/auth/forgot-password`

Request：

```json
{
  "email": "user@example.com"
}
```

Response：

```json
{
  "success": true,
  "message": "Password reset token issued",
  "data": {
    "resetToken": "password_reset_token",
    "expiresIn": 900
  }
}
```

規則：

- `email` 必須轉為小寫並去除前後空白後查詢。
- 若 email 對應未刪除使用者，後端產生一次性 reset token。
- reset token 明文只回傳一次；資料庫僅保存 token hash。
- reset token 有效時間為 900 秒。
- 同一使用者重新申請時，未使用的舊 reset token 需失效。
- 若 email 不存在或使用者已刪除，仍回傳 200，`resetToken` 為 `null`，避免暴露帳號是否存在。
- 不得將 email 對應結果、reset token 明文或 token hash 寫入 log。
- 目前 response 回傳 `resetToken` 供開發與前端串接；正式寄信服務定案後，應改為由後端寄送 reset link 或驗證碼。

### 2.6 重設密碼

`POST /api/auth/reset-password`

Request：

```json
{
  "resetToken": "password_reset_token",
  "newPassword": "password123"
}
```

Response：

```json
{
  "success": true,
  "message": "Password reset success",
  "data": null
}
```

規則：

- `resetToken` 必填。
- `newPassword` 必填，NFC 後長度為 15 到 128 Unicode code points，不 trim，並套用版本化本機弱密碼 blocklist。
- 後端必須先 hash `resetToken` 後查詢，不得以明文 token 查詢資料庫。
- reset token 不存在、已使用、已過期或對應使用者已刪除時，回傳 401。
- 新密碼需套用正式密碼政策並使用 Argon2id 重新雜湊。
- 使用者已有 Email / Password 憑證時，更新既有 `user_credentials.password_hash`。
- 僅有 Google 登入的使用者若完成 reset token 驗證，可建立新的 `user_credentials`。
- 密碼重設成功後，reset token 必須標記為已使用。
- 不得將新密碼、reset token 明文或 token hash 寫入 log。

### 2.7 登出

`POST /api/auth/logout`

Header：

```text
Authorization: Bearer <access_token>
```

Optional Request：

```json
{
  "refreshToken": "current_refresh_token"
}
```

Response：

```json
{
  "success": true,
  "message": "Logout success",
  "data": null
}
```

規則：

- 登出 API 需登入。
- 後端必須驗證 access token 簽章、issuer、type 與 exp。
- 登出時不得保存 token 明文；access token 與 optional refresh token 僅保存 hash 至 `revoked_tokens`。
- token 撤銷紀錄需保存至原 token 過期時間。
- JWT 驗證流程需拒絕已撤銷 token。
- 無 Authorization header、非 Bearer token、token 無效、token 已過期或 token 已撤銷時，回傳 401。
- 不得將 JWT 明文或 token hash 寫入 log。

---

## 三、目前無版本 User API（待遷移）

`PUT /api/users/me/avatar`、伺服器密碼鎖 endpoint 與公開 `avatarUrl` 為待移除基線。目標 User API 改為選擇已取得貘怪頭貼、裝置本機隱私鎖、Email 變更、工作階段管理、匯出與刪除流程。

### 3.1 查詢個人資料

`GET /api/users/me`

Header：

```text
Authorization: Bearer <access_token>
```

Response：

```json
{
  "success": true,
  "message": "Profile query success",
  "data": {
    "userId": 1,
    "account": "old-account",
    "email": "user@example.com",
    "userName": "使用者名稱",
    "birthday": "2000-01-02",
    "avatarUrl": "https://example.com/avatar.png"
  }
}
```

規則：

- 需登入。
- 後端必須從 JWT 驗證後的 `userId` 查詢目前使用者，不得由前端傳入 user id 或 account。
- 只查詢未刪除使用者。
- 查無使用者時回傳 404。
- 回傳欄位以新版 `users` 表為準；舊系統 `lock`、`dailyTest` 不放入本 API。

### 3.2 修改個人資料

`PUT /api/users/me`

Header：

```text
Authorization: Bearer <access_token>
```

Request：

```json
{
  "userName": "新的使用者名稱",
  "birthday": "2000-01-02"
}
```

Response：

```json
{
  "success": true,
  "message": "Profile update success",
  "data": {
    "userId": 1,
    "account": "old-account",
    "email": "user@example.com",
    "userName": "新的使用者名稱",
    "birthday": "2000-01-02",
    "avatarUrl": "https://example.com/avatar.png"
  }
}
```

規則：

- 需登入。
- 後端必須從 JWT 驗證後的 `userId` 更新目前使用者，不得由前端傳入 user id 或 account。
- 只更新未刪除使用者。
- `userName` 必填，最大長度 80，後端儲存前會移除前後空白。
- `birthday` 可為 `null`；傳入日期時格式為 `yyyy-MM-dd`。
- 本 API 僅更新 `userName` 與 `birthday`；`email`、`account`、`avatarUrl` 與密碼鎖不由本 API 修改。
- 查無使用者時回傳 404。
- 更新成功後回傳最新個人資料，欄位格式與查詢個人資料 API 相同。

### 3.3 更改頭貼（Deprecated）

本 endpoint 只描述 `develop` 現有實作，Phase 4.5 必須移除。v1 頭貼只能選擇已取得的貘怪素材，不接受任何使用者檔案。

`PUT /api/users/me/avatar`

Header：

```text
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

Request：

| 欄位 | 型別 | 必填 | 說明 |
|---|---|---|---|
| file | file | 是 | 頭貼圖片 |

Response：

```json
{
  "success": true,
  "message": "Avatar update success",
  "data": {
    "userId": 1,
    "account": "old-account",
    "email": "user@example.com",
    "userName": "使用者名稱",
    "birthday": "2000-01-02",
    "avatarUrl": "https://cdn.example.com/users/avatars/1/avatar.png"
  }
}
```

規則：

- 需登入。
- 後端必須從 JWT 驗證後的 `userId` 更新目前使用者，不得由前端傳入 user id 或 account。
- 只更新未刪除使用者。
- 歷史實作將圖片上傳至 Cloudflare R2 並保存公開 `avatarUrl`；此行為已禁止新增使用，待 Migration 移除。
- 檔案欄位名稱固定為 `file`。
- 僅接受 `image/jpeg`、`image/png`、`image/webp`。
- 預設檔案大小上限為 5 MB，可透過 `R2_MAX_AVATAR_SIZE_BYTES` 調整。
- R2 object key 預設格式為 `users/avatars/{userId}/{uuid}.{ext}`。
- 查無使用者時回傳 404。
- R2 設定缺漏或上傳失敗時回傳 500。
- 更新成功後回傳最新個人資料，欄位格式與查詢個人資料 API 相同。

### 3.4 設定密碼鎖（Deprecated）

本 endpoint 只描述 `develop` 現有實作，Phase 4.5 必須移除。v1 PIN 只存在 Android／iOS 本機安全儲存區。

`PUT /api/users/me/password-lock`

Header：

```text
Authorization: Bearer <access_token>
```

Request：

```json
{
  "lockPassword": "1234"
}
```

Response：

```json
{
  "success": true,
  "message": "Password lock update success",
  "data": {
    "enabled": true
  }
}
```

規則：

- 需登入。
- 後端必須從 JWT 驗證後的 `userId` 設定目前使用者的密碼鎖，不得由前端傳入 user id 或 account。
- `lockPassword` 必填，格式固定為 4 位數字。
- 歷史實作使用 BCrypt hash 保存至 `user_password_locks.lock_password_hash`；v1 Backend 不得接收、保存或驗證本機 PIN。
- 同一使用者重複設定時更新既有密碼鎖 hash，並保持 `enabled = true`。
- 查無使用者時回傳 404。
- 不得將密碼鎖明文或 hash 寫入 log。

### 3.5 驗證密碼鎖（Deprecated）

`POST /api/users/me/password-lock/verify`

Header：

```text
Authorization: Bearer <access_token>
```

Request：

```json
{
  "lockPassword": "1234"
}
```

Response：

```json
{
  "success": true,
  "message": "Password lock verify success",
  "data": {
    "verified": true
  }
}
```

規則：

- 需登入。
- 後端必須從 JWT 驗證後的 `userId` 驗證目前使用者的密碼鎖，不得由前端傳入 user id 或 account。
- `lockPassword` 必填，格式固定為 4 位數字。
- 後端以 `PasswordEncoder.matches` 比對，不得以明文查詢資料庫。
- 密碼鎖不存在或未啟用時回傳 404。
- 密碼鎖錯誤時回傳 200，`verified = false`，由前端決定是否提示重試。
- 查無使用者時回傳 404。
- 不得將密碼鎖明文或 hash 寫入 log。

---

## 四、目前無版本 Annoyance API（待遷移）

本章 `isShared` 與 score／category 必填規則由 0.3 取代；Community Post 建立／更新／取消分享不得繼續修改 Entry 分享 boolean。

共同規則：

- 全部 endpoint 均需登入；`userId` 只取自 JWT principal，Client 不得傳入 owner 或 user id。
- 分類使用穩定的 `categoryCode`，情緒使用 1 至 5 的 `score`，後端解析對應 lookup ID。
- 一筆煩惱只能選擇 TEXT、IMAGE、AUDIO、VIDEO 其中一種主要記錄方式，另可選擇一張 drawing。
- 預設 `isShared = false`、`isSolved = false`；建立時間未傳時由後端使用目前時間。
- 不存在、已刪除或不屬於目前使用者的資料一律回傳 404，避免洩漏 owner 資訊；媒體下載 endpoint 另允許目前為分享狀態的 entry。
- Entry media 使用獨立且不可公開存取的 R2 bucket；Response 不得包含 bucket、object key 或 R2 credential。媒體只回傳需帶 JWT 的 Backend download URL。

媒體限制：

| 用途 | 數量 | MIME type | 副檔名 | 大小／長度 |
|---|---:|---|---|---|
| IMAGE 主要內容 | 1 | `image/jpeg`、`image/png`、`image/webp` | `.jpg`、`.jpeg`、`.png`、`.webp` | 5 MB |
| AUDIO 主要內容 | 1 | `audio/mp4`、`audio/aac`、`audio/mpeg`、`audio/wav` | `.m4a`、`.mp4`、`.aac`、`.mp3`、`.wav` | 10 MB／5 分鐘 |
| VIDEO 主要內容 | 1 | `video/mp4`、`video/quicktime`、`video/webm` | `.mp4`、`.mov`、`.webm` | 50 MB／60 秒 |
| drawing | 1 | `image/png`、`image/webp` | `.png`、`.webp` | 5 MB |

前後端皆需驗證數量、MIME type、副檔名、檔案大小與可取得的媒體長度。檔案由後端上傳 Cloudflare R2，Database 只保存 private object key；若 R2 成功但 Database transaction 失敗，後端需 best-effort 清理該 request 已上傳的所有 object，cleanup 失敗不得覆蓋原始錯誤。

### 4.1 新增煩惱

`POST /api/annoyances`

Content-Type：`multipart/form-data`

Parts：

| Part | 型別 | 必填 | 說明 |
|---|---|---|---|
| `request` | `application/json` | 是 | 建立資料 |
| `contentFile` | binary | 條件必填 | IMAGE／AUDIO／VIDEO 時必填；TEXT 時不得傳 |
| `drawingFile` | binary | 否 | 可選心情圖 |

`request`：

```json
{
  "categoryCode": "ACADEMIC",
  "recordMethod": "TEXT",
  "content": "最近考試讓我很焦慮",
  "score": 4,
  "isShared": false,
  "occurredAt": "2026-07-11T12:00:00+08:00"
}
```

規則：

- `categoryCode` 必須為已啟用的 annoyance type code。
- `recordMethod = TEXT` 時 `content` 必填且不得傳 `contentFile`；其餘方式 `content` 必須為 null，並需傳入相符 MIME type 的 `contentFile`。
- 歷史 Phase 3 contract 要求 `score` 為 1 至 5、`isShared` 未傳時為 false，且 `occurredAt` 未傳時由後端設定；v1 目標改為 nullable Emotional Load 與獨立 Community Post。
- Phase 3 建立成功不發放怪獸；`reward` 固定回傳 null，Phase 6 再串接真實獎勵。Response JSON 必須保留 `"reward": null`，不得因值為 null 而省略欄位。

Response data：

```json
{
  "id": 101,
  "category": { "code": "ACADEMIC", "name": "課業" },
  "recordMethod": "TEXT",
  "content": "最近考試讓我很焦慮",
  "score": 4,
  "isShared": false,
  "isSolved": false,
  "occurredAt": "2026-07-11T12:00:00+08:00",
  "media": [
    {
      "id": 201,
      "type": "drawing",
      "contentType": "image/png",
      "sizeBytes": 20480,
      "durationSeconds": null,
      "downloadUrl": "/api/annoyances/101/media/201"
    }
  ],
  "reward": null
}
```

### 4.2 查詢煩惱列表

`GET /api/annoyances`

Query：

| 參數 | 必填 | 預設 | 規則 |
|---|---|---|---|
| `page` | 否 | 0 | 從 0 開始 |
| `size` | 否 | 20 | 1 至 100 |
| `sort` | 否 | `occurredAt,desc` | 可排序欄位：`occurredAt`、`createdAt`、`score`；方向為 `asc` 或 `desc` |
| `isSolved` | 否 | 全部 | boolean filter |
| `isShared` | 否 | 全部 | boolean filter |

後端以 `LIMIT`／`OFFSET` 與排序查詢；`page` 是 request 參數，不是 Database 欄位。
只查詢目前登入使用者未刪除的 ANNOYANCE entry；相同排序值以 entry id 由大至小作為穩定的次排序。
無效的 page、size、sort 或 boolean query parameter 回傳 400。

Response data：

```json
{
  "content": [],
  "page": 0,
  "size": 20,
  "totalElements": 0,
  "totalPages": 0,
  "first": true,
  "last": true
}
```

### 4.3 查詢單筆煩惱

`GET /api/annoyances/{id}`

回傳與新增成功相同的 Annoyance data；`reward` 在 Phase 3 為 null。

### 4.4 修改煩惱

`PUT /api/annoyances/{id}`

Content-Type 與驗證規則同新增 API。`request` 需傳完整可編輯資料，並可加上：

```json
{
  "categoryCode": "ACADEMIC",
  "recordMethod": "IMAGE",
  "content": null,
  "score": 3,
  "isShared": false,
  "occurredAt": "2026-07-12T12:00:00+08:00",
  "existingContentMediaId": 201,
  "existingDrawingMediaId": 202
}
```

- 保留既有主要媒體或心情圖時傳入對應 media id；id 必須屬於該 entry 且 media type 相符。
- 傳入新檔案時不得同時傳同用途的 existing media id，新檔案成功後取代舊檔案。
- 未傳新檔案與 existing drawing id 代表移除心情圖。
- `isSolved`、`monsterId` 與 `reward` 不屬於此完整內容修改 API 的可編輯欄位。
- 修改成功回傳 200 與更新後 Annoyance data；R2 舊 object 僅在 transaction 成功後 best-effort 清理，清理失敗不得回滾已成功的 Database transaction。

### 4.5 解決煩惱

`PATCH /api/annoyances/{id}/solve`

Request：

```json
{ "isSolved": true }
```

Phase 3 只允許未解決改為已解決；重複傳 true 應維持 idempotent success，傳 false 回傳 400。
修改成功回傳 200 與更新後 Annoyance data；不存在、已刪除或不屬於目前使用者的 entry 回傳 404。

### 4.6 分享或取消分享煩惱

`PATCH /api/annoyances/{id}/share`

Request：

```json
{ "isShared": true }
```

使用明確 boolean 目標狀態，不提供無參數 toggle；重複傳相同狀態應維持 idempotent success。
分享與取消分享成功皆回傳 200 與更新後 Annoyance data；不存在、已刪除或不屬於目前使用者的 entry 回傳 404。

### 4.7 下載煩惱媒體

`GET /api/annoyances/{id}/media/{mediaId}`

- 需登入；entry owner 可讀取，非 owner 僅能在 entry 目前為分享狀態時讀取，否則回傳 404。
- `mediaId` 必須屬於 path 中的 entry 且未刪除。
- Backend 驗證權限後從 private R2 串流，不以 redirect 洩漏 R2 URL 或 object key。
- 支援單一 HTTP `Range` request 以供錄音／影片 seek；完整回應為 200，range 回應為 206，並回傳正確 `Content-Type`、`Content-Length`、`Accept-Ranges` 與 `Content-Range`。

### 4.8 煩惱草稿

| Method | Path | 說明 |
|---|---|---|
| GET | `/api/annoyances/draft` | 取得目前使用者尚未到期的煩惱草稿 |
| PUT | `/api/annoyances/draft` | 建立或覆寫煩惱草稿 |
| DELETE | `/api/annoyances/draft` | 明確捨棄草稿與暫存媒體；不存在時仍回傳成功 |
| POST | `/api/annoyances/draft/submit` | 驗證完整草稿並轉為正式煩惱 |
| GET | `/api/annoyances/draft/media/{mediaId}` | 下載目前使用者的草稿媒體 |

`PUT` 使用 `multipart/form-data`，parts 與正式建立 API 相同；`request` 改使用可部分完成的草稿欄位：

```json
{
  "step": "CONTENT",
  "categoryCode": "ACADEMIC",
  "recordMethod": "TEXT",
  "content": "最近考試讓我很焦慮",
  "wantsDrawing": null,
  "score": null,
  "isShared": null,
  "existingContentMediaId": null,
  "existingDrawingMediaId": null
}
```

- `step` 僅允許 `INTRO`、`CATEGORY`、`RECORD_METHOD`、`CONTENT`、`DRAWING_DECISION`、`DRAWING`、`SCORE`、`SHARING`、`REVIEW`；不得保存 `SUBMITTING` 或 `COMPLETED`。
- 儲存草稿採部分驗證；`POST /draft/submit` 才執行與正式建立 API 相同的完整組合驗證。
- submit 時 `wantsDrawing` 必須已選擇；true 時需有 drawing 暫存媒體，false 時不得保留 drawing 暫存媒體。
- 每位使用者只保留一筆煩惱草稿；每次有效儲存將到期時間延長 30 天。
- 新 `contentFile`／`drawingFile` 與同用途 `existing...MediaId` 不得同時傳入；existing id 必須屬於目前草稿且用途相符。兩者皆未傳代表移除該用途媒體。
- 草稿與媒體只允許 owner 存取，即使 `isShared = true` 仍不得供其他使用者讀取。
- 媒體使用既有 private R2 驗證與大小／長度限制；取代、捨棄或到期時清理 object。
- 儲存、送出、捨棄與到期清理會鎖定同一使用者／類型的草稿；到期清理取得鎖後須再次確認 `expiresAt`，不得刪除等待期間已被續存的草稿。
- 明確捨棄或到期清理若無法刪除 R2 object，不得先刪除草稿 metadata；排程保留該筆資料供下次重試。
- 送出在同一 Database transaction 建立 `entries`／`entry_media` 並刪除草稿 metadata；沿用既有 object key，不重新上傳檔案。

GET／PUT response data：

```json
{
  "draft": {
    "id": 501,
    "entryType": "ANNOYANCE",
    "step": "CONTENT",
    "category": { "code": "ACADEMIC", "name": "學業" },
    "recordMethod": "TEXT",
    "content": "最近考試讓我很焦慮",
    "wantsDrawing": null,
    "score": null,
    "isShared": null,
    "expiresAt": "2026-08-23T12:00:00+08:00",
    "contentMedia": null,
    "drawingMedia": null
  }
}
```

無草稿時仍回傳 200，`data = { "draft": null }`。草稿媒體 response 另包含 `id`、`role`、`type`、`fileName`、`contentType`、`sizeBytes`、`durationSeconds` 與需帶 JWT 的 Backend `downloadUrl`，不得包含 object key。送出成功回傳 201 與既有 Annoyance response data。

### 4.9 Annoyance 錯誤處理

- 400：欄位、主要記錄方式組合、分頁、MIME type、大小或長度驗證失敗。
- 401：未登入或 token 無效。
- 404：lookup 不存在，或 entry 不存在／不屬於目前使用者。
- 413：上傳檔案超過限制。
- 416：媒體 `Range` 超出 object 範圍。
- 500：R2、`ffprobe` 或資料儲存失敗；不得回傳 bucket credential、內部 object key、暫存檔路徑或 stack trace。

---

## 五、目前無版本 Diary API（Phase 4 候選契約）

本章尚未整合至 `develop`。本次文件更新不執行 Phase 4 整合；整合後仍須依 0.3 遷移至選填情緒負荷、選填分類與獨立 Community Post。

共同規則：

- 全部 endpoint 均需登入；`userId` 只取自 JWT principal，Client 不得傳入 owner、account 或 user id。
- Diary 使用共用 `entries`／`entry_media` 模型，`entryType = DIARY`、`annoyanceTypeId = null`、`isSolved = false`；Phase 4 的 `monsterId` 與 `reward` 為 null。
- 一筆日記只能選擇 TEXT、IMAGE、AUDIO、VIDEO 其中一種主要記錄方式，另可選擇一張 drawing；drawing 不是必填。
- 預設 `isShared = false`；`occurredAt` 未傳時由後端使用目前時間。
- 媒體數量、MIME type、副檔名、大小、影音長度、`ffprobe` 驗證、private R2 與 transaction cleanup 規則全部沿用 Annoyance API。
- 不存在、已刪除或不屬於目前使用者的資料一律回傳 404，避免洩漏 owner 資訊；媒體下載 endpoint 另允許目前為分享狀態的 entry。
- Response 不得包含 bucket、object key、R2 credential 或暫存檔路徑；媒體只回傳需帶 JWT 的 Backend download URL。

### 5.1 新增日記

`POST /api/diaries`

Content-Type：`multipart/form-data`

Parts：

| Part | 型別 | 必填 | 說明 |
|---|---|---|---|
| `request` | `application/json` | 是 | 建立資料 |
| `contentFile` | binary | 條件必填 | IMAGE／AUDIO／VIDEO 時必填；TEXT 時不得傳 |
| `drawingFile` | binary | 否 | 可選心情圖 |

`request`：

```json
{
  "recordMethod": "TEXT",
  "content": "今天完成了一件很有成就感的事",
  "score": 2,
  "isShared": false,
  "occurredAt": "2026-07-18T20:00:00+08:00"
}
```

規則：

- `recordMethod = TEXT` 時 `content` 必填且不得傳 `contentFile`；其餘方式 `content` 必須為 null，並需傳入相符 MIME type 的 `contentFile`。
- `score` 必須為 1 至 5；`isShared` 未傳時為 false；`occurredAt` 未傳時由後端設定。
- 建立成功回傳 201。Phase 4 不發放怪獸或其他獎勵，`reward` 固定回傳 null；Phase 6 再串接真實獎勵。Response JSON 必須保留 `"reward": null`，不得因值為 null 而省略欄位。

Response data：

```json
{
  "id": 301,
  "recordMethod": "TEXT",
  "content": "今天完成了一件很有成就感的事",
  "score": 2,
  "isShared": false,
  "occurredAt": "2026-07-18T20:00:00+08:00",
  "media": [
    {
      "id": 401,
      "type": "drawing",
      "contentType": "image/png",
      "sizeBytes": 20480,
      "durationSeconds": null,
      "downloadUrl": "/api/diaries/301/media/401"
    }
  ],
  "reward": null
}
```

### 5.2 查詢日記列表

`GET /api/diaries`

Query：

| 參數 | 必填 | 預設 | 規則 |
|---|---|---|---|
| `page` | 否 | 0 | 從 0 開始 |
| `size` | 否 | 20 | 1 至 100 |
| `sort` | 否 | `occurredAt,desc` | 可排序欄位：`occurredAt`、`createdAt`、`score`；方向為 `asc` 或 `desc` |
| `isShared` | 否 | 全部 | boolean filter |

後端以 `LIMIT`／`OFFSET` 與排序查詢，只查詢目前登入使用者未刪除的 DIARY entry；相同排序值以 entry id 由大至小作為穩定次排序。無效的 page、size、sort 或 boolean query parameter 回傳 400。

Response data：

```json
{
  "content": [],
  "page": 0,
  "size": 20,
  "totalElements": 0,
  "totalPages": 0,
  "first": true,
  "last": true
}
```

### 5.3 查詢單筆日記

`GET /api/diaries/{id}`

回傳與新增成功相同的 Diary data；`reward` 在 Phase 4 為 null。

### 5.4 修改日記

`PUT /api/diaries/{id}`

Content-Type、parts 與驗證規則同新增 API。`request` 需傳完整可編輯資料，並可加上：

```json
{
  "recordMethod": "IMAGE",
  "content": null,
  "score": 3,
  "isShared": false,
  "occurredAt": "2026-07-18T21:00:00+08:00",
  "existingContentMediaId": 401,
  "existingDrawingMediaId": 402
}
```

- 保留既有主要媒體或心情圖時傳入對應 media id；id 必須屬於該 entry 且 media type 相符。
- 傳入新檔案時不得同時傳同用途的 existing media id；新檔案成功後取代舊檔案。
- 未傳新檔案與 `existingDrawingMediaId` 代表移除心情圖。
- `entryType`、`isSolved`、`monsterId` 與 `reward` 不屬於此 API 的可編輯欄位。
- 修改成功回傳 200 與更新後 Diary data；R2 舊 object 僅在 transaction 成功後 best-effort 清理，清理失敗不得回滾已成功的 Database transaction。

### 5.5 分享或取消分享日記

`PATCH /api/diaries/{id}/share`

Request：

```json
{ "isShared": true }
```

使用明確 boolean 目標狀態，不提供無參數 toggle；重複傳相同狀態應維持 idempotent success。分享與取消分享成功皆回傳 200 與更新後 Diary data；不存在、已刪除或不屬於目前使用者的 entry 回傳 404。

### 5.6 下載日記媒體

`GET /api/diaries/{id}/media/{mediaId}`

- 需登入；entry owner 可讀取，非 owner 僅能在 entry 目前為分享狀態時讀取，否則回傳 404。
- `mediaId` 必須屬於 path 中的 entry 且未刪除。
- Backend 驗證權限後從 private R2 串流，不以 redirect 洩漏 R2 URL 或 object key。
- 支援單一 HTTP `Range` request 以供錄音／影片 seek；完整回應為 200，range 回應為 206，並回傳正確 `Content-Type`、`Content-Length`、`Accept-Ranges` 與 `Content-Range`。

### 5.7 日記草稿

| Method | Path | 說明 |
|---|---|---|
| GET | `/api/diaries/draft` | 取得目前使用者尚未到期的日記草稿 |
| PUT | `/api/diaries/draft` | 建立或覆寫日記草稿 |
| DELETE | `/api/diaries/draft` | 明確捨棄草稿與暫存媒體；不存在時仍回傳成功 |
| POST | `/api/diaries/draft/submit` | 驗證完整草稿並轉為正式日記 |
| GET | `/api/diaries/draft/media/{mediaId}` | 下載目前使用者的草稿媒體 |

日記草稿 contract、30 天期限、owner-only 權限、private R2、媒體取代／移除、到期清理與 transaction 送出規則全部沿用 4.8；`categoryCode` 固定不得傳入，`step` 不接受 Annoyance 專用的 `CATEGORY`。

日記草稿 `PUT` request 範例：

```json
{
  "step": "CONTENT",
  "recordMethod": "TEXT",
  "content": "今天完成了一件重要的事",
  "wantsDrawing": null,
  "score": null,
  "isShared": null,
  "existingContentMediaId": null,
  "existingDrawingMediaId": null
}
```

GET／PUT response data 使用 `{ "draft": ... }` envelope，`entryType = DIARY`、`category = null`；無草稿時 `draft = null`。送出成功回傳 201 與既有 Diary response data。

### 5.8 Diary 錯誤處理

- 400：欄位、主要記錄方式組合、分頁、MIME type、大小或長度驗證失敗。
- 401：未登入或 token 無效。
- 404：entry 或 media 不存在，或目前使用者無權存取。
- 413：上傳檔案超過限制。
- 416：媒體 `Range` 超出 object 範圍。
- 500：R2、`ffprobe` 或資料儲存失敗；不得回傳 bucket credential、內部 object key、暫存檔路徑或 stack trace。

---

## 六、History API（目標改為 30 日 Emotional Trace）

### 6.1 查詢歷史記錄

`GET /api/history`

### 6.2 查詢心的軌跡

`GET /api/history/mood-trace`

規則：

- 回傳最近 30 個本地日曆日的 Diary／Annoyance 情緒負荷；同日多筆取平均，缺值留白，並可查詢當日原始分數。
- 依建立時間排序。

---

## 七、Monster API

### 7.1 查詢全部怪獸

`GET /api/monsters`

### 7.2 查詢我的怪獸

`GET /api/users/me/monsters`

### 7.3 固定解鎖進度

隨機取得怪獸 endpoint 已廢止。v1 提供里程碑進度、已達成獎勵與防重領取契約，不接受任意 `monsterId` 或 random request。

### 7.4 更換怪獸造型

`PATCH /api/users/me/monsters/{id}/skin`

---

## 八、Community API

社群文章為獨立 Community Post 快照，不直接聚合或公開私人 Entry。

`postId` 格式：

```text
{type}:{id}
```

範例：

```text
annoyance:1
diary:1
```

### 8.1 查詢社群文章

`GET /api/community/posts`

### 8.2 社群按愛心

`POST /api/community/posts/{postId}/like`

### 8.3 取消愛心

`DELETE /api/community/posts/{postId}/like`

### 8.4 新增留言

`POST /api/community/posts/{postId}/comments`

### 8.5 查詢留言

`GET /api/community/posts/{postId}/comments`

---

## 九、Interactive API

### 9.1 解答之書

`GET /api/interactive/answer-book/random`

### 9.2 每日測驗題目

`GET /api/interactive/daily-test/today`

### 9.3 送出每日測驗答案

`POST /api/interactive/daily-test/answer`

### 9.4 自我探索

`GET /api/interactive/psychological-tests`

### 9.5 心理小遊戲

`GET /api/interactive/mind-games`

### 9.6 紓壓方法

`GET /api/interactive/stress-relief-methods`

---

## 十、Feedback API

### 10.1 新增使用回饋

`POST /api/feedback`

---

## 十一、待確認事項

跨文件決策與待確認事項集中於：

- docs/DECISIONS.md

---

## Auth API Implementation Notes

### Register

`POST /api/auth/register`

Request:

```json
{
  "email": "user@example.com",
  "password": "password123",
  "userName": "Wei"
}
```

Validation:

| Field | Rule |
|---|---|
| email | Required, valid email format |
| password | Required, 15 to 128 Unicode code points after NFC; not trimmed; exact blocklist match rejected |
| userName | Required, max 80 characters |

Success response: `201 Created`

```json
{
  "success": true,
  "message": "Register success",
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "userName": "Wei"
  }
}
```

Error response:

| Status | Condition |
|---:|---|
| 400 | Request validation failed |
| 409 | Email already registered |
