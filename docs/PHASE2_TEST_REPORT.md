# Phase 2 Test Report

> Historical report：本文件只證明 Phase 2 當時實作與測試結果。Account 登入、公開頭貼上傳、JWT／SharedPreferences session 與伺服器密碼鎖已列入 Phase 4.5 Migration，不能視為目前目標契約。

## Scope

Phase 2 covers member authentication and user profile features:

- Register API
- Login API
- Google login API
- Forgot password API
- Logout API
- User profile query API
- User profile update API
- Avatar update API
- Password lock API
- Flutter login page
- Flutter register page
- Flutter profile page
- Flutter password lock page

## Test Matrix

| Area | Test File / Command | Coverage |
|---|---|---|
| Backend auth controller | `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java` | Auth endpoint success response wrapping and controller behavior |
| Backend auth service | `backend/src/test/java/com/monsters/auth/service/AuthServiceTest.java` | Register, login, Google login, forgot/reset password, logout service logic |
| Backend token revocation | `backend/src/test/java/com/monsters/auth/service/TokenRevocationServiceTest.java` | Logout token revocation behavior |
| Backend user controller | `backend/src/test/java/com/monsters/user/controller/UserControllerTest.java` | Profile, avatar, and password lock endpoint response wrapping |
| Backend user service | `backend/src/test/java/com/monsters/user/service/UserServiceTest.java` | Profile query/update, avatar update, password lock set/verify |
| Backend security | `backend/src/test/java/com/monsters/common/security/*Test.java` | JWT, Google ID token, password reset token, security config |
| Backend storage | `backend/src/test/java/com/monsters/common/storage/R2AvatarStorageServiceTest.java` | R2 avatar upload validation and key handling |
| Frontend network | `frontend/test/core/network/*_test.dart` | `ApiClient` and `ApiErrorHandler` response/error conversion |
| Frontend auth pages | `frontend/test/login_page_test.dart`, `frontend/test/register_page_test.dart` | Form validation, repository calls, success navigation, API error messages |
| Frontend profile page | `frontend/test/profile_page_test.dart` | Profile load, edit validation, update success, error state, home navigation |
| Frontend password lock page | `frontend/test/password_lock_page_test.dart` | PIN validation, mismatch handling, set, verify, failed verify, home navigation |
| Frontend route/theme/state widgets | `frontend/test/routes/*`, `frontend/test/theme/*`, `frontend/test/widgets/*` | Router, theme, common loading/error/empty states |

## Verification Commands

| Command | Result |
|---|---|
| `cd backend && ./gradlew test` | Passed |
| `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub` | Passed |
| `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter test --no-pub` | Passed |
| `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter build web --no-pub` | Passed |
| `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub` | Passed |
| `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub` | Passed |
| `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub` | Passed |

## Notes

- `backend/gradlew` needed executable permission before backend tests could run.
- Android build currently emits a Kotlin version future-deprecation warning for `1.8.22`; this does not block Phase 2 tests.
- Web build may emit Flutter's Wasm dry-run informational message; this does not block Phase 2 tests.
- iOS device build was run with `--no-codesign`, so manual code signing is still required for device deployment.
