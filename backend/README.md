# 貘nsters Backend

貘nsters 的 Spring Boot 後端專案。

## 技術

- JDK 18
- Spring Boot
- Gradle
- MySQL

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
| `CORS_ALLOWED_HEADERS` | `Authorization,Content-Type` |
| `CORS_EXPOSED_HEADERS` | `Authorization` |
| `CORS_ALLOW_CREDENTIALS` | `true` |
| `CORS_MAX_AGE` | `3600` |

正式環境必須將 `CORS_ALLOWED_ORIGIN_PATTERNS` 設為可信任前端網域，不得使用 `*`。

## Security / JWT 設定

後端使用 Spring Security，預設規則：

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/google-login`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password`

上述 API 允許匿名，其餘 `/api/**` 需驗證。

JWT 基礎環境變數：

| 環境變數 | 預設值 |
|----------|--------|
| `JWT_ISSUER` | `monsters` |
| `JWT_SECRET` | 空字串，正式環境必須提供 |
| `JWT_ACCESS_TOKEN_EXPIRATION_SECONDS` | `3600` |
| `JWT_REFRESH_TOKEN_EXPIRATION_SECONDS` | `1209600` |

Google 登入環境變數：

| 環境變數 | 預設值 |
|----------|--------|
| `GOOGLE_CLIENT_IDS` | 空字串，啟用 Google 登入前必須提供 |

`GOOGLE_CLIENT_IDS` 可用逗號設定多組 Web / Android / iOS Client ID。後端會以此檢查 Google ID Token 的 `aud`。

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

`POST /api/auth/login`

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
      "userId": 1,
      "email": "user@example.com",
      "userName": "Wei",
      "avatarUrl": null
    }
  }
}
```

Login normalizes email before lookup, verifies the stored BCrypt password hash, and returns JWT access and refresh tokens. `JWT_SECRET` must be configured before login can issue tokens.

### Google Login

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

Google login verifies the ID token on the backend with Google's signing keys, checks issuer, audience, expiration, and verified email, then links or creates a local user through `user_oauth_accounts`. `JWT_SECRET` and `GOOGLE_CLIENT_IDS` must be configured before Google login can issue tokens.

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
