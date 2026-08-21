# 貘nsters Backend

貘nsters 的 Spring Boot 後端專案。

## 技術

- JDK 18
- Spring Boot
- Gradle
- MySQL

## Package 結構

Backend 使用 layer-first package layout：

```text
com.monsters.<layer>.<module>
```

例如 `com.monsters.controller.annoyance`、`com.monsters.service.auth`、`com.monsters.entity.user` 與 `com.monsters.security.common`。新程式不得回到 `com.monsters.<module>.<layer>`。`MonstersApplication` 維持在 root package `com.monsters`，以保留 Spring component 與 JPA scan 範圍。

## Profile 設定

後端使用 Spring Boot Profile：

| Profile | 設定檔 | 用途 |
|---------|--------|------|
| 共用 | `src/main/resources/application.yml` | App 名稱、預設 profile、JPA 共用設定 |
| dev | `src/main/resources/application-dev.yml` | 本機開發 MySQL 預設連線 |
| prod | `src/main/resources/application-prod.yml` | 正式環境，必須由環境變數提供連線資訊 |

預設 profile：

```text
dev
```

可用 `SPRING_PROFILES_ACTIVE` 切換。

## MySQL 連線設定

後端透過環境變數讀取 MySQL 連線資訊：

| 環境變數 | 預設值 |
|----------|--------|
| `DB_URL` | `jdbc:mysql://localhost:3306/monsters?useSSL=false&serverTimezone=Asia/Taipei&allowPublicKeyRetrieval=true` |
| `DB_USERNAME` | `monsters` |
| `DB_PASSWORD` | `monsters` |

Docker Compose 會使用 `mysql` 作為 MySQL service hostname。

## CORS 設定

後端 CORS 僅套用於 `/api/**`。

| 環境變數 | 預設值 |
|----------|--------|
| `CORS_ALLOWED_ORIGIN_PATTERNS` | `http://localhost:*,http://127.0.0.1:*` |
| `CORS_ALLOWED_METHODS` | `GET,POST,PUT,PATCH,DELETE,OPTIONS` |
| `CORS_ALLOWED_HEADERS` | `Authorization,Content-Type,Range,X-Session-Transport,X-CSRF-Protection` |
| `CORS_EXPOSED_HEADERS` | `Authorization,Accept-Ranges,Content-Length,Content-Range` |
| `CORS_ALLOW_CREDENTIALS` | `true` |
| `CORS_MAX_AGE` | `3600` |

正式環境必須將 `CORS_ALLOWED_ORIGIN_PATTERNS` 設為可信任前端網域，不得使用 `*`。

## Security / JWT 設定

後端使用 Spring Security，預設規則：

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/google-logins`
- `POST /api/v1/auth/google-account-links`
- `POST /api/v1/auth/session-refreshes`
- `POST /api/auth/google-login`
- `POST /api/auth/refresh`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password`
- `GET /api/v1/auth/registration-policy`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/email-verification-requests`
- `POST /api/v1/auth/email-verifications`

上述 API 允許匿名，其餘 `/api/**` 需驗證。

JWT 基礎環境變數：

| 環境變數 | 預設值 |
|----------|--------|
| `JWT_ISSUER` | `monsters` |
| `JWT_SECRET` | 空字串，正式環境必須提供 |
| `JWT_ACCESS_TOKEN_EXPIRATION_SECONDS` | `600` |
| `JWT_REFRESH_TOKEN_EXPIRATION_SECONDS` | `2592000` |
| `SESSION_IDLE_EXPIRATION_SECONDS` | `2592000` |
| `SESSION_ABSOLUTE_EXPIRATION_SECONDS` | `7776000` |
| `SESSION_REFRESH_CONCURRENCY_GRACE_SECONDS` | `10` |
| `SESSION_REFRESH_DERIVATION_KEY` | 空字串；v1完整登入前須提供至少32-byte獨立Secret |
| `WEB_SESSION_TRUSTED_ORIGIN_PATTERNS` | `http://localhost:*,http://127.0.0.1:*`；正式環境只允許Web前端Origin |
| `WEB_SESSION_COOKIE_MAX_AGE_SECONDS` | `7776000`（90天） |

v1 Refresh Credential採opaque Session Family rotation，Backend只保存SHA-256 hash。每次成功換發都建立下一個sequence；同一舊Credential在10秒內回相同結果，逾期reuse撤銷該family。一般Session閒置30天、絕對90天。Web使用`__Host-monsters-refresh` HttpOnly／Secure／SameSite=None Cookie支援Cloudflare Pages至Railway跨站HTTPS請求，且Cookie Auth endpoint另驗證可信Origin與`X-CSRF-Protection: 1`；App仍使用request body Credential。Legacy JWT Refresh與`revoked_tokens`僅供舊API Migration相容。

Google 登入環境變數：

| 環境變數 | 預設值 |
|----------|--------|
| `GOOGLE_CLIENT_IDS` | 空字串，啟用 Google 登入前必須提供 |

`GOOGLE_CLIENT_IDS` 可用逗號設定多組 Web / Android / iOS Client ID。後端會以此檢查 Google ID Token 的 `aud`。

## Registration / Email 驗證設定

Task 03 不提供程式內正式預設值；Railway `develop` 與 `main` service 必須分別設定：

| 環境變數 | 說明 |
|---|---|
| `REGISTRATION_TERMS_VERSION` | 目前服務條款版本 |
| `REGISTRATION_TERMS_URL` | 目前服務條款 HTTPS URL |
| `REGISTRATION_PRIVACY_VERSION` | 目前隱私權政策版本 |
| `REGISTRATION_PRIVACY_URL` | 目前隱私權政策 HTTPS URL |
| `REGISTRATION_RATE_LIMIT_HASH_KEY` | Email／IP 限流 HMAC secret |
| `EMAIL_VERIFICATION_PUBLIC_URL` | 對應環境 Flutter Web `/verify-email` 完整 HTTPS URL |
| `SMTP_HOST`、`SMTP_PORT` | Resend SMTP 主機與 STARTTLS port；預設 `smtp.resend.com`、`587` |
| `SMTP_USERNAME` | Resend SMTP 帳號；預設 `resend` |
| `RESEND_API_KEY` | Resend API Key，作為 SMTP password；不得提交至 Repository |
| `SMTP_PASSWORD` | 舊版相容備援；未設定 `RESEND_API_KEY` 時才讀取 |
| `SMTP_AUTH`、`SMTP_STARTTLS_ENABLED` | SMTP 驗證與 STARTTLS 開關 |
| `REGISTRATION_SMTP_FROM` | 已在 Resend 驗證網域的寄件者 |
| `REGISTRATION_SMTP_ENABLED` | 完成上述設定後才設為 `true` |
| `EMAIL_VERIFICATION_WORKER_ENABLED` | SMTP 可用後設為 `true` |
| `UNVERIFIED_MEMBER_CLEANUP_ENABLED` | 確認 V3 migration 後設為 `true` |
| `MINOR_NOTICE_VERSION`、`MINOR_NOTICE_URL` | 未成年人說明版本與 HTTPS URL |
| `GUARDIAN_CONSENT_VERSION`、`GUARDIAN_CONSENT_URL` | 監護人同意文件版本與 HTTPS URL |
| `PUBLIC_NICKNAME_DISCLOSURE_VERSION`、`PUBLIC_NICKNAME_DISCLOSURE_URL` | 公開暱稱揭露版本與 HTTPS URL |
| `GUARDIAN_ACTION_PUBLIC_URL` | Flutter Web 監護人單次連結頁的 HTTPS URL |
| `GUARDIAN_GRANT_TOKEN_TTL_HOURS` | 同意連結有效小時，預設 `24` |
| `GUARDIAN_WITHDRAW_TOKEN_TTL_MINUTES` | 撤回連結有效分鐘，預設 `15` |

SMTP 寄送最多重試五次；七日空會員清理預設每日 03:45 執行。正式環境不得把 Email、IP、密碼或 Token 寫入設定、Log 或 Outbox payload。

SMTP 供應商固定為 Resend。啟用前須在 Resend 完成寄件網域驗證並建立權限最小化的 API Key；正式環境以 Secret 管理 `RESEND_API_KEY`，不得使用 `onboarding@resend.dev` 作為正式寄件者。

## 專案規範

後端開發需遵守：

- `../AGENTS.md`
- `../docs/CODING_STANDARD.md`
- `../docs/API_SPEC.md`
- `../docs/DATABASE_SPEC.md`

## Auth API

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

Response:

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

The register flow creates `users` and `user_credentials` records. Passwords are stored only as BCrypt hashes.

### Login

`POST /api/v1/auth/login`

Request:

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

Response:

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
      "userName": "Wei"
    }
  }
}
```

Login trims and lowercases Email before an exact lookup, verifies Argon2id or historical BCrypt, and returns JWT access and refresh tokens. Gmail dot and `+tag` forms are not merged. Unknown Email, invalid password, missing credential and non-disclosable state return the same `401 AUTH_INVALID_CREDENTIALS`. `JWT_SECRET` must be configured before login can issue tokens.

Deprecated `POST /api/auth/login` remains temporarily available for existing Email／legacy account clients during expand migration. New clients must not use it; Task 18 removes it only after migration observation and contract cleanup.

### Google Login 與明確連結

新Client使用`POST /api/v1/auth/google-logins`。Backend完整驗證Google ID Token後，只有已連結的`provider = google`與`sub`可登入；相同Email既有會員只回`GOOGLE_ACCOUNT_LINK_REQUIRED`，不建立OAuth關聯或一般Session。會員需先以Email／密碼登入，再呼叫`POST /api/v1/auth/reauthentications/password`取得`LOGIN_METHOD_LINK`用途、300秒且綁定目前Session的credential，最後以新ID Token、`confirmed: true`及`X-Reauthentication-Credential`呼叫`POST /api/v1/auth/google-account-links`。成功保留目前Session並撤銷其他Session。

Deprecated Migration endpoint：

`POST /api/auth/google-login`

Request:

```json
{
  "idToken": "google_id_token"
}
```

Response:

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

Google login verifies the ID token on the backend with Google's signing keys, checks issuer, audience, expiration, signature, and verified email. Deprecated endpoint不再對相同Email自動連結；新Flutter不得呼叫。`JWT_SECRET` and `GOOGLE_CLIENT_IDS` must be configured before Google login can issue tokens.

### Forgot Password

`POST /api/auth/forgot-password`

Request:

```json
{
  "email": "user@example.com"
}
```

Response:

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

The forgot password flow normalizes email, creates a 15-minute one-time reset token for existing active users, stores only the token hash in `password_reset_tokens`, and invalidates previous unused tokens for the same user. Unknown emails still return 200 with a null `resetToken`.

### Reset Password

`POST /api/auth/reset-password`

Request:

```json
{
  "resetToken": "password_reset_token",
  "newPassword": "password123"
}
```

Response:

```json
{
  "success": true,
  "message": "Password reset success",
  "data": null
}
```

Reset password hashes the submitted token before lookup, rejects invalid, expired, used, or deleted-user tokens, stores the new password as a BCrypt hash, and marks the reset token as used.

### Logout

`POST /api/auth/logout`

Header:

```text
Authorization: Bearer <access_token>
```

Response:

```json
{
  "success": true,
  "message": "Logout success",
  "data": null
}
```

Logout verifies the access token and stores only its SHA-256 hash in `revoked_tokens` until the original token expiration. JWT authentication rejects revoked tokens for protected APIs.

## User API

### Get My Profile

`GET /api/users/me`

Header:

```text
Authorization: Bearer <access_token>
```

Response:

```json
{
  "success": true,
  "message": "Profile query success",
  "data": {
    "userId": 1,
    "account": "old-account",
    "email": "user@example.com",
    "userName": "Wei",
    "birthday": "2000-01-02",
    "avatarUrl": "https://example.com/avatar.png"
  }
}
```

The profile query uses the authenticated JWT principal and reads the current undeleted `users` record. The client does not submit user id or account for this API.

### Update My Profile

`PUT /api/users/me`

Header:

```text
Authorization: Bearer <access_token>
```

Request:

```json
{
  "userName": "Lin",
  "birthday": "2001-03-04"
}
```

Response:

```json
{
  "success": true,
  "message": "Profile update success",
  "data": {
    "userId": 1,
    "account": "old-account",
    "email": "user@example.com",
    "userName": "Lin",
    "birthday": "2001-03-04",
    "avatarUrl": "https://example.com/avatar.png"
  }
}
```

The profile update uses the authenticated JWT principal and updates only `userName` and `birthday`. Avatar, account, email, and password lock changes use separate flows.

### Update My Avatar

`PUT /api/users/me/avatar`

Header:

```text
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

Form data:

| Field | Type | Required |
|---|---|---|
| file | image/jpeg, image/png, image/webp | yes |

Response:

```json
{
  "success": true,
  "message": "Avatar update success",
  "data": {
    "userId": 1,
    "account": "old-account",
    "email": "user@example.com",
    "userName": "Wei",
    "birthday": "2000-01-02",
    "avatarUrl": "https://cdn.example.com/users/avatars/1/avatar.png"
  }
}
```

Avatar upload stores the image in Cloudflare R2 and writes only the public URL to `users.avatar_url`.

Entry media uses a separate private R2 bucket. Database records store only an internal object key, and clients must download media through an authenticated Backend endpoint after owner or sharing permission validation. Do not enable public access for the entry media bucket.

R2 settings:

| Setting | Environment variable |
|---|---|
| app.storage.r2.account-id | R2_ACCOUNT_ID |
| app.storage.r2.access-key-id | R2_ACCESS_KEY_ID |
| app.storage.r2.secret-access-key | R2_SECRET_ACCESS_KEY |
| app.storage.r2.bucket | R2_BUCKET |
| app.storage.r2.public-base-url | R2_PUBLIC_BASE_URL |
| app.storage.r2.avatar-key-prefix | R2_AVATAR_KEY_PREFIX |
| app.storage.r2.max-avatar-size-bytes | R2_MAX_AVATAR_SIZE_BYTES |
| app.storage.r2.entry-media-bucket | R2_ENTRY_MEDIA_BUCKET |
| app.storage.r2.entry-media-key-prefix | R2_ENTRY_MEDIA_KEY_PREFIX |
| app.storage.r2.max-entry-image-size-bytes | R2_MAX_ENTRY_IMAGE_SIZE_BYTES |
| app.storage.r2.max-entry-audio-size-bytes | R2_MAX_ENTRY_AUDIO_SIZE_BYTES |
| app.storage.r2.max-entry-video-size-bytes | R2_MAX_ENTRY_VIDEO_SIZE_BYTES |
| app.storage.r2.max-entry-drawing-size-bytes | R2_MAX_ENTRY_DRAWING_SIZE_BYTES |
| app.storage.r2.max-entry-audio-duration-seconds | R2_MAX_ENTRY_AUDIO_DURATION_SECONDS |
| app.storage.r2.max-entry-video-duration-seconds | R2_MAX_ENTRY_VIDEO_DURATION_SECONDS |
| app.storage.r2.ffprobe-path | FFPROBE_PATH |
| app.storage.r2.ffprobe-timeout-seconds | FFPROBE_TIMEOUT_SECONDS |

Spring multipart settings:

| Setting | Environment variable | Default |
|---|---|---|
| spring.servlet.multipart.max-file-size | MULTIPART_MAX_FILE_SIZE | 50MB |
| spring.servlet.multipart.max-request-size | MULTIPART_MAX_REQUEST_SIZE | 60MB |

The R2 token used by Backend requires Object Read & Write permission scoped only to the required avatar and private entry media buckets. Bucket administration permission is not required.

Audio and video duration validation requires `ffprobe`:

- The Backend Docker runtime installs FFmpeg automatically.
- Local non-Docker development must install FFmpeg and ensure `ffprobe` is available on `PATH`, or set `FFPROBE_PATH` to the executable path.
- Do not log uploaded content, object keys, probe output, or temporary file paths.
- Entry media validates both MIME type and filename extension. If R2 upload succeeds but the Database transaction fails, Backend attempts to delete every object uploaded by that request without replacing the original error when cleanup also fails.

### Set My Password Lock

`PUT /api/users/me/password-lock`

Header:

```text
Authorization: Bearer <access_token>
```

Request:

```json
{
  "lockPassword": "1234"
}
```

Response:

```json
{
  "success": true,
  "message": "Password lock update success",
  "data": {
    "enabled": true
  }
}
```

The lock password must be exactly 4 digits. The backend stores only a BCrypt hash in `user_password_locks.lock_password_hash`.

### Verify My Password Lock

`POST /api/users/me/password-lock/verify`

Header:

```text
Authorization: Bearer <access_token>
```

Request:

```json
{
  "lockPassword": "1234"
}
```

Response:

```json
{
  "success": true,
  "message": "Password lock verify success",
  "data": {
    "verified": true
  }
}
```

Wrong lock passwords return `verified: false`; missing or disabled password locks return 404.
