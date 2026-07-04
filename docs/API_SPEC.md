# API_SPEC.md

# 貘nsters REST API 規格

## 一、共通規範

Base URL：

```text
/api
```

Flutter API Client：

```text
frontend/lib/core/network/ApiClient
```

前端 API Base URL 預設值：

```text
http://localhost:8080/api
```

前端可透過 dart-define 覆寫：

```text
API_BASE_URL
```

Flutter UI 不得直接呼叫 Dio。API 存取必須經由 Provider / Repository 使用 `ApiClient`。
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
  "message": "錯誤訊息",
  "data": null
}
```

後端共用 Response DTO：

```text
com.monsters.common.dto.ApiResponse<T>
```

Controller 回傳資料時必須使用 `ApiResponse<T>` 包裝，欄位固定為：

| 欄位 | 型別 | 說明 |
|---|---|---|
| success | boolean | 是否成功 |
| message | string | 成功或錯誤訊息 |
| data | object / array / null | 回傳資料，失敗時為 null |

成功預設訊息：

```text
操作成功
```

全域 Exception Handler：

```text
com.monsters.common.exception.GlobalExceptionHandler
```

Exception 回傳格式固定使用 `ApiResponse<Void>`：

```json
{
  "success": false,
  "message": "錯誤訊息",
  "data": null
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
com.monsters.common.config.CorsConfig
```

CORS 僅套用於：

```text
/api/**
```

允許來源不得使用 `*`，需透過環境變數或設定檔指定可信任來源。

| 設定 | 環境變數 | 預設值 |
|---|---|---|
| app.cors.allowed-origin-patterns | CORS_ALLOWED_ORIGIN_PATTERNS | http://localhost:*,http://127.0.0.1:* |
| app.cors.allowed-methods | CORS_ALLOWED_METHODS | GET,POST,PUT,PATCH,DELETE,OPTIONS |
| app.cors.allowed-headers | CORS_ALLOWED_HEADERS | Authorization,Content-Type |
| app.cors.exposed-headers | CORS_EXPOSED_HEADERS | Authorization |
| app.cors.allow-credentials | CORS_ALLOW_CREDENTIALS | true |
| app.cors.max-age | CORS_MAX_AGE | 3600 |

Security / JWT 基礎設定：

```text
com.monsters.common.security.SecurityConfig
```

安全規則：

| Path | Method | 規則 |
|---|---|---|
| /api/auth/register | POST | 允許匿名 |
| /api/auth/login | POST | 允許匿名 |
| /api/auth/google-login | POST | 允許匿名 |
| /api/auth/forgot-password | POST | 允許匿名 |
| /api/auth/reset-password | POST | 允許匿名 |
| /api/auth/logout | POST | 需驗證 |
| /api/** | ALL | 需驗證 |
| 其他路徑 | ALL | 拒絕 |

Security 錯誤回應固定使用 `ApiResponse<Void>`：

| 狀態 | message |
|---:|---|
| 401 | 尚未登入或 Token 無效 |
| 403 | 權限不足 |

JWT 基礎設定：

| 設定 | 環境變數 | 預設值 |
|---|---|---|
| app.security.jwt.issuer | JWT_ISSUER | monsters |
| app.security.jwt.secret | JWT_SECRET | 空字串，正式環境必須提供 |
| app.security.jwt.access-token-expiration-seconds | JWT_ACCESS_TOKEN_EXPIRATION_SECONDS | 3600 |
| app.security.jwt.refresh-token-expiration-seconds | JWT_REFRESH_TOKEN_EXPIRATION_SECONDS | 1209600 |

Google 登入設定：

| 設定 | 環境變數 | 預設值 |
|---|---|---|
| app.security.google.client-ids | GOOGLE_CLIENT_IDS | 空字串，啟用 Google 登入前必須提供 |

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

## 二、Auth API

### 2.1 註冊

`POST /api/auth/register`

Request：

```json
{
  "email": "user@example.com",
  "password": "password",
  "userName": "使用者名稱"
}
```

### 2.2 登入

`POST /api/auth/login`

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
      "userId": 1,
      "email": "user@example.com",
      "userName": "使用者名稱",
      "avatarUrl": null
    }
  }
}
```

規則：

- `email` 必須轉為小寫並去除前後空白後查詢。
- 密碼以 BCrypt `PasswordEncoder.matches` 比對，不得明文保存或寫入 log。
- Email 不存在、帳號已刪除、憑證不存在或密碼錯誤時，回傳 401。
- `accessToken` 與 `refreshToken` 使用 HMAC-SHA256 JWT 產生。
- `JWT_SECRET` 必須設定，否則不得產生 JWT。

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
      "email": "user@example.com",
      "userName": "Wei",
      "avatarUrl": null
    }
  }
}
```

規則：

- 後端必須驗證 Google ID Token，不接受前端自行驗證後傳入的使用者資料。
- `idToken` 必填。
- Google ID Token 必須符合 RS256 簽章、有效 `kid`、Google issuer、未過期、`email_verified = true`。
- `aud` 必須存在於 `GOOGLE_CLIENT_IDS` 設定，可用逗號設定多組 Web / App Client ID。
- 驗證成功後，以 Google `sub` 對應 `user_oauth_accounts.provider_user_id`。
- 若 OAuth 帳號已存在，使用既有使用者產生 JWT。
- 若 OAuth 帳號不存在但 email 已有未刪除使用者，建立 OAuth 連結後產生 JWT。
- 若 OAuth 帳號不存在且 email 尚未註冊，建立 `users` 與 `user_oauth_accounts` 後產生 JWT。
- ID Token 無效、email 未驗證、對應使用者已刪除或 `GOOGLE_CLIENT_IDS` 未設定時，回傳 401。
- 不得將 Google ID Token、JWT、Google 公鑰 response 或敏感驗證細節寫入 log。

### 2.4 忘記密碼

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

### 2.5 重設密碼

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
- `newPassword` 必填，長度 8 到 72 字元。
- 後端必須先 hash `resetToken` 後查詢，不得以明文 token 查詢資料庫。
- reset token 不存在、已使用、已過期或對應使用者已刪除時，回傳 401。
- 密碼需使用 BCrypt 重新雜湊。
- 使用者已有 Email / Password 憑證時，更新既有 `user_credentials.password_hash`。
- 僅有 Google 登入的使用者若完成 reset token 驗證，可建立新的 `user_credentials`。
- 密碼重設成功後，reset token 必須標記為已使用。
- 不得將新密碼、reset token 明文或 token hash 寫入 log。

### 2.6 登出

`POST /api/auth/logout`

Header：

```text
Authorization: Bearer <access_token>
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
- 登出時不得保存 token 明文，僅保存 token hash 至 `revoked_tokens`。
- token 撤銷紀錄需保存至原 token 過期時間。
- JWT 驗證流程需拒絕已撤銷 token。
- 無 Authorization header、非 Bearer token、token 無效、token 已過期或 token 已撤銷時，回傳 401。
- 不得將 JWT 明文或 token hash 寫入 log。

---

## 三、User API

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

### 3.3 更改頭貼

`PUT /api/users/me/avatar`

### 3.4 設定密碼鎖

`PUT /api/users/me/password-lock`

### 3.5 驗證密碼鎖

`POST /api/users/me/password-lock/verify`

---

## 四、Annoyance API

### 4.1 新增煩惱

`POST /api/annoyances`

### 4.2 查詢煩惱列表

`GET /api/annoyances`

### 4.3 查詢單筆煩惱

`GET /api/annoyances/{id}`

### 4.4 修改煩惱

`PUT /api/annoyances/{id}`

### 4.5 解決煩惱

`PATCH /api/annoyances/{id}/solve`

### 4.6 分享或取消分享煩惱

`PATCH /api/annoyances/{id}/share`

---

## 五、Diary API

### 5.1 新增日記

`POST /api/diaries`

### 5.2 查詢日記列表

`GET /api/diaries`

### 5.3 查詢單筆日記

`GET /api/diaries/{id}`

### 5.4 修改日記

`PUT /api/diaries/{id}`

### 5.5 分享或取消分享日記

`PATCH /api/diaries/{id}/share`

---

## 六、History API

### 6.1 查詢歷史記錄

`GET /api/history`

### 6.2 查詢心的軌跡

`GET /api/history/mood-trace`

規則：

- 回傳最近七次煩惱或日記的心情分數。
- 依建立時間排序。

---

## 七、Monster API

### 7.1 查詢全部怪獸

`GET /api/monsters`

### 7.2 查詢我的怪獸

`GET /api/users/me/monsters`

### 7.3 隨機取得怪獸

`POST /api/users/me/monsters/random`

### 7.4 更換怪獸造型

`PATCH /api/users/me/monsters/{id}/skin`

---

## 八、Community API

社群文章為煩惱與日記分享內容的聚合顯示。

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

### 9.4 深度心理測驗

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
| password | Required, 8 to 72 characters |
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
