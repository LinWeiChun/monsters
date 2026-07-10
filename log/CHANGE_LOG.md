# 專案異動紀錄

本文件用於記錄貘nsters 專案每次由 AI Coding Agent 或開發者完成的檔案異動。

AI 每次完成任務後，必須新增一筆紀錄，並同步更新 `CHANGE_HISTORY.csv` 或 `CHANGE_HISTORY.xlsx`。

新增 Log 紀錄前，必須先檢查既有 Log 日期；若存在超過一個月的紀錄，需先刪除過期紀錄，再新增本次紀錄。

---

## 2026-07-10 13:19

Task
TASK-041 正式啟用帳號欄位（REVIEW）

Agent
Codex

### Completed

- Enabled `account` as a formal required unique user field for registration.
- Added backend account validation, normalization, duplicate checking, and response fields.
- Updated Google first-login user creation to generate a unique account from the email prefix.
- Updated Flutter registration page to collect and validate account.
- Updated Flutter auth models and session test data so login users include account.
- Updated API, database, project, UI, task, and README documentation.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `backend/src/main/java/com/monsters/auth/dto/AuthUserResponse.java`
- `backend/src/main/java/com/monsters/auth/dto/RegisterRequest.java`
- `backend/src/main/java/com/monsters/auth/dto/RegisterResponse.java`
- `backend/src/main/java/com/monsters/auth/service/AuthService.java`
- `backend/src/main/java/com/monsters/user/entity/User.java`
- `backend/src/main/java/com/monsters/user/repository/UserRepository.java`
- `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/auth/service/AuthServiceTest.java`
- `backend/src/test/java/com/monsters/common/security/JwtTokenServiceTest.java`
- `backend/src/test/java/com/monsters/common/security/SecurityConfigTest.java`
- `backend/src/test/java/com/monsters/user/service/UserServiceTest.java`
- `database/init/01_schema.sql`
- `frontend/lib/models/auth_user.dart`
- `frontend/lib/models/auth_user.g.dart`
- `frontend/lib/models/register_result.dart`
- `frontend/lib/pages/register_page.dart`
- `frontend/lib/providers/auth_provider.dart`
- `frontend/lib/repositories/auth_repository.dart`
- `frontend/test/auth_session_store_test.dart`
- `frontend/test/login_page_test.dart`
- `frontend/test/register_page_test.dart`
- `docs/PROJECT_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- `database/init/01_schema.sql` now creates `users.account` as `NOT NULL`.
- Existing local databases created before this change may need manual migration if they contain users with null account.

### API

- `POST /api/auth/register` request now requires `account`.
- Register response includes `account`.
- Login and Google login user response includes `account`.

### Database

- `users.account` changed from compatibility-only nullable field to formal required unique field.

### Tests

- `./gradlew test`
- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub --dart-define=GOOGLE_CLIENT_ID=test-web-client.apps.googleusercontent.com`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub --dart-define=GOOGLE_CLIENT_ID=test-android-client.apps.googleusercontent.com --dart-define=GOOGLE_SERVER_CLIENT_ID=test-server-client.apps.googleusercontent.com`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --debug --no-codesign --no-pub --dart-define=GOOGLE_CLIENT_ID=test-ios-client.apps.googleusercontent.com --dart-define=GOOGLE_SERVER_CLIENT_ID=test-server-client.apps.googleusercontent.com`

### Notes

- `system_data/` reference: checked old account-based login and account-linked data flow.
- Reused only the intent of a stable user account identifier.
- Not reused: old account-as-cross-table-foreign-key pattern, old API paths, and page-level persistence.
- Existing unrelated `backend/src/main/resources/application.yml` changes were left untouched and are not part of this task.

## 2026-07-10 13:03

Task
TASK-040 Flutter Web Google 登入固定本機 port（REVIEW）

Agent
Codex

### Completed

- Added a macOS-friendly Flutter Web local launch script that fixes the local origin at `http://localhost:5050`.
- Updated Google login local testing documentation so Google Cloud OAuth only needs `http://localhost:5050` in Authorized JavaScript origins.
- Kept Google Web local testing on `GOOGLE_CLIENT_ID` only; no real Client ID is committed.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/tool/run_web_local.sh`

### Modified

- `frontend/README.md`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- No API contract change.

### Database

- None

### Tests

- `bash -n frontend/tool/run_web_local.sh`
- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`

### Notes

- `system_data/` reference: not needed for this local development startup fix.
- Google Cloud OAuth Client should add `http://localhost:5050` to Authorized JavaScript origins.
- Existing unrelated `backend/src/main/resources/application.yml` changes were left untouched and are not part of this task.

## 2026-07-10 12:51

Task
TASK-039 修正 Web Google 登入按鈕 Getting ready（REVIEW）

Agent
Codex

### Completed

- Fixed Web Google Sign-In initialization so `serverClientId` is only passed on Android / iOS.
- Updated README and specs to clarify Web local testing should pass only `GOOGLE_CLIENT_ID`.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `frontend/lib/services/google_sign_in_service.dart`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- No API contract change.

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub --dart-define=GOOGLE_CLIENT_ID=test-web-client.apps.googleusercontent.com`

### Notes

- `system_data/` reference: not needed for this SDK compatibility fix.
- Cause: `google_sign_in_web` does not support `serverClientId`; passing it in debug mode can leave the Web official button at `Getting ready`.
- Existing unrelated `backend/src/main/resources/application.yml` changes were left untouched and are not part of this task.

## 2026-07-10 12:20

Task
TASK-038 Flutter Google 登入（REVIEW）

Agent
Codex

### Completed

- Implemented approved option 1 for Flutter Google login using `google_sign_in` and `google_sign_in_web`.
- Added a Google Sign-In service that initializes SDK client IDs from dart-define values and returns Google ID Tokens.
- Updated login UI so Web uses the Google Identity Services official button, while Android and iOS use the shared Flutter Google login action.
- Updated Auth repository and controller to call existing `POST /api/auth/google-login`, save the returned session, and navigate to home.
- Updated logout to clear local session and attempt Google SDK sign-out.
- Added widget tests for Google ID Token login, Google backend error handling, Web authentication-event login, and Google sign-out during logout.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/lib/services/google_sign_in_service.dart`
- `frontend/lib/widgets/auth/google_sign_in_web_button.dart`
- `frontend/lib/widgets/auth/google_sign_in_web_button_stub.dart`
- `frontend/lib/widgets/auth/google_sign_in_web_button_web.dart`

### Modified

- `frontend/lib/config/app_config.dart`
- `frontend/lib/pages/login_page.dart`
- `frontend/lib/providers/auth_provider.dart`
- `frontend/lib/repositories/auth_repository.dart`
- `frontend/test/login_page_test.dart`
- `frontend/pubspec.yaml`
- `frontend/pubspec.lock`
- `frontend/ios/Runner.xcodeproj/project.pbxproj`
- `docs/DECISIONS.md`
- `docs/PROJECT_SPEC.md`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Uses existing `POST /api/auth/google-login`.
- No backend endpoint contract change.

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub --dart-define=GOOGLE_CLIENT_ID=test-web-client.apps.googleusercontent.com --dart-define=GOOGLE_SERVER_CLIENT_ID=test-server-client.apps.googleusercontent.com`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub --dart-define=GOOGLE_CLIENT_ID=test-android-client.apps.googleusercontent.com --dart-define=GOOGLE_SERVER_CLIENT_ID=test-server-client.apps.googleusercontent.com`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --debug --no-codesign --no-pub --dart-define=GOOGLE_CLIENT_ID=test-ios-client.apps.googleusercontent.com --dart-define=GOOGLE_SERVER_CLIENT_ID=test-server-client.apps.googleusercontent.com`

### Commit Message

```text
feat(frontend): 完成 Google 登入
```

### Notes

- `system_data/` reference: checked old Flutter login code and `google_sign_in_API.dart`.
- Reused only the intent of using Google Sign-In as the entry point.
- Not reused: old empty-password API login flow, direct Google user-data trust, direct page-level API code, and old global navigation/state patterns.
- Real Google OAuth Client IDs are intentionally not committed. Runtime must provide `GOOGLE_CLIENT_ID` and `GOOGLE_SERVER_CLIENT_ID`; backend `GOOGLE_CLIENT_IDS` must include the accepted audiences.
- iOS CocoaPods added the Google Sign-In resources copy build phase to the Runner Xcode project.
- Existing unrelated `backend/src/main/resources/application.yml` changes were left untouched and are not part of this task.

## 2026-07-10 08:17

Task
TASK-037 Flutter 30 天登入狀態保存（REVIEW）

Agent
Codex

### Completed

- Added shared Flutter session persistence for Web, Android, and iOS using the approved SharedPreferences package.
- Added `AuthSessionStore` to save `LoginResult` and last-opened time.
- Updated login flow to save session after successful login.
- Updated splash flow to restore valid sessions and navigate directly to home when the user has not logged out and opened the app within 30 days.
- Added logout flow from home to call logout, clear Authorization header, clear local session, and return to login.
- Added tests for session restore, session expiry, splash auto-navigation, and logout navigation.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/ios/Podfile`
- `frontend/lib/repositories/auth_session_store.dart`
- `frontend/test/auth_session_store_test.dart`

### Modified

- `frontend/lib/repositories/auth_repository.dart`
- `frontend/lib/providers/auth_provider.dart`
- `frontend/lib/pages/splash_page.dart`
- `frontend/lib/pages/home_page.dart`
- `frontend/test/login_page_test.dart`
- `frontend/test/widget_test.dart`
- `frontend/pubspec.yaml`
- `frontend/pubspec.lock`
- `frontend/ios/Flutter/Debug.xcconfig`
- `frontend/ios/Flutter/Release.xcconfig`
- `frontend/android/settings.gradle.kts`
- `frontend/ios/Runner.xcodeproj/project.pbxproj`
- `frontend/ios/Runner.xcworkspace/contents.xcworkspacedata`
- `docs/PROJECT_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Uses existing `POST /api/auth/login`.
- Uses existing `POST /api/auth/logout`.

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub`

### Commit Message

```text
feat(frontend): 保存三平台登入狀態
```

### Notes

- `system_data/` reference: checked old Flutter login pages that used SharedPreferences to remember self login.
- Reused only the intent of remembering login state.
- Not reused: old account-only persistence, direct page-level SharedPreferences access, `Navigator` routing, and missing expiry policy.
- Android Kotlin Gradle plugin was updated from 1.8.22 to 2.1.0 so the approved `shared_preferences` Android plugin can compile.
- Existing unrelated `backend/src/main/resources/application.yml` changes were left untouched and are not part of this task.

## 2026-07-10 08:00

Task
TASK-036 Flutter App Icon 三平台替換（REVIEW）

Agent
Codex

### Completed

- Replaced default Flutter launcher icons for Android, iOS, and Web with icons generated from root `icon/icon.png`.
- Generated Android mipmap launcher icons for all existing densities.
- Generated iOS AppIcon image set including the 1024px marketing icon without transparency.
- Generated Web favicon, PWA icons, and maskable icons.
- Updated Web manifest theme and background colors from Flutter default blue to the legacy warm yellow / brown palette.
- Updated UI spec, frontend README, and task status for the shared app icon source and generation rules.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `frontend/android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `frontend/android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `frontend/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `frontend/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `frontend/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`
- `frontend/web/favicon.png`
- `frontend/web/icons/*.png`
- `frontend/web/manifest.json`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub`

### Commit Message

```text
style(frontend): 替換三平台 app icon
```

### Notes

- `system_data/` reference: checked available files. No direct old app icon implementation was needed for this asset-only task.
- Used `icon/icon.png` as the icon source. `icon/標題.png` was not used because it is a title image with a non-square ratio.
- Existing unrelated `backend/src/main/resources/application.yml` changes were left untouched and are not part of this task.

## 2026-07-10 07:28

Task
TASK-035 Phase 2 測試與 Task 標示整理（REVIEW）

Agent
Codex

### Completed

- Updated previous Flutter Phase 2 task labels from `REVIEW` to `DONE` because they are now merged into `develop`.
- Added Phase 2 test report and test matrix.
- Fixed `backend/gradlew` executable permission so backend tests can run through the project wrapper.
- Ran backend tests, frontend analyze, frontend tests, and Web / Android / iOS builds.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `docs/PHASE2_TEST_REPORT.md`

### Modified

- `backend/gradlew`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- `cd backend && ./gradlew test`
- `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter build web --no-pub`
- `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub`
- `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub`
- `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub`

### Commit Message

```text
test(phase2): 補齊會員功能測試報告
```

### Notes

- `system_data/` reference: no additional old-system code was needed for this test-summary task; previous Phase 2 feature tasks already recorded their references.
- Existing untracked `backend/bin/` was left untouched.
- Android build still reports a Kotlin version future-deprecation warning; it does not block the build.

## 2026-07-10 07:16

Task
TASK-034 Flutter 密碼鎖頁（REVIEW）

Agent
Codex

### Completed

- Added shared Flutter password lock page for Web, Android, and iOS.
- Added password lock status and verification models.
- Added `UserRepository` calls for `PUT /api/users/me/password-lock` and `POST /api/users/me/password-lock/verify`.
- Added Riverpod password lock controller for setting and verifying lock password.
- Added `/password-lock` route and home-page entry action.
- Added widget tests for required validation, mismatch validation, successful set, successful verify, failed verify, and home navigation.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/lib/models/password_lock_status.dart`
- `frontend/lib/models/password_lock_status.g.dart`
- `frontend/lib/models/password_lock_verification.dart`
- `frontend/lib/models/password_lock_verification.g.dart`
- `frontend/lib/pages/password_lock_page.dart`
- `frontend/lib/providers/password_lock_provider.dart`
- `frontend/test/password_lock_page_test.dart`

### Modified

- `frontend/lib/repositories/user_repository.dart`
- `frontend/lib/pages/home_page.dart`
- `frontend/lib/routes/app_router.dart`
- `frontend/lib/routes/app_routes.dart`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Uses existing `PUT /api/users/me/password-lock`.
- Uses existing `POST /api/users/me/password-lock/verify`.

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub test/password_lock_page_test.dart`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub`

### Commit Message

```text
feat(frontend): 新增密碼鎖頁
```

### Notes

- `system_data/` reference: checked old `setting_lock_page.dart`, `check_lock_page.dart`, `lock_page.dart`, `lock_widget.dart`, and member repository lock-related methods.
- Reused the set / confirm / verify interaction flow only.
- Not reused: old SharedPreferences PIN storage, local lock state, `Navigator` routing, direct old repository calls, and hard-coded page colors.
- Forgot password lock flow is not implemented in this task because no formal API is defined yet.

## 2026-07-10 07:07

Task
TASK-033 前端色調調整為舊版暖黃色 / 棕色

Agent
Codex

### Completed

- Cleaned local branch state by deleting local branches already merged into `origin/main`.
- Kept `main`, `develop`, `feature/flutter-register-page`, and `feature/profile-page`; then created `feature/frontend-legacy-colors` for this UI color task.
- Updated centralized Flutter theme colors to match old system warm yellow and brown palette.
- Updated UI spec and frontend README with legacy color token mapping.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `frontend/lib/theme/app_colors.dart`
- `docs/UI_SPEC.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub`

### Commit Message

```text
style(frontend): 調整前端為舊版暖色調
```

### Notes

- `system_data/` reference: checked `system_data/front-end/monsters_front_end/lib/pages/settings/style.dart`.
- Reused old color intent and values only; did not copy old widget structure or page-level hard-coded styling.
- Branch cleanup used safe local branch deletion for branches already merged to `origin/main`.

## 2026-07-09 20:58

Task
TASK-032 Flutter 個人資料頁（REVIEW）

Agent
Codex

### Completed

- Added shared Flutter profile page for Web, Android, and iOS.
- Added `UserProfile` model, `UserRepository`, and Riverpod `UserProfileController`.
- Connected `/profile` go_router route and added a home-page entry action.
- Implemented profile loading, API error retry, user name validation, birthday validation, and profile update success feedback.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/lib/models/user_profile.dart`
- `frontend/lib/models/user_profile.g.dart`
- `frontend/lib/pages/profile_page.dart`
- `frontend/lib/providers/user_profile_provider.dart`
- `frontend/lib/repositories/user_repository.dart`
- `frontend/test/profile_page_test.dart`

### Modified

- `frontend/lib/pages/home_page.dart`
- `frontend/lib/routes/app_router.dart`
- `frontend/lib/routes/app_routes.dart`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Uses existing `GET /api/users/me`.
- Uses existing `PUT /api/users/me`.

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub test/profile_page_test.dart`

### Commit Message

```text
feat(frontend): 新增個人資料頁
```

### Notes

- `system_data/` reference: checked old `drawer_personalInfo.dart`, `edit_personalInfo.dart`, `memberRepo.dart`, and `memberModel.dart`; reused the profile display/edit flow only.
- Not reused: old global account state, direct HTTP calls, old API paths, `Navigator` routing, hard-coded colors, and avatar monster-index logic.
- Avatar file upload UI is deferred because cross-platform file picking requires a separate approved package or platform strategy.

## 2026-07-09 20:29

Task
TASK-031 Flutter 註冊頁三平台補齊

Agent
Codex

### Completed

- Confirmed the Flutter app already has Web, Android, and iOS platform project folders.
- Confirmed current Flutter pages are implemented in shared `frontend/lib/` code and therefore target Web, Android, and iOS together.
- Updated Android, iOS, and Web app metadata from Flutter defaults to `貘nsters`.
- Updated UI spec and frontend README to make Web / Android / iOS support the default expectation for future frontend tasks.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `frontend/android/app/src/main/AndroidManifest.xml`
- `frontend/ios/Runner/Info.plist`
- `frontend/web/index.html`
- `frontend/web/manifest.json`
- `docs/UI_SPEC.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub`（blocked：local Xcode is missing iOS 26.2 platform）
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub`（blocked：local Xcode is missing iOS 26.2 platform）

### Commit Message

```text
chore(frontend): 補齊三平台 metadata
```

### Notes

- Future frontend tasks must be implemented as cross-platform Flutter code by default, with platform-specific handling documented when needed.
- Web and Android builds passed. iOS build is blocked by local Xcode platform installation, not by a Dart or Flutter compile error.

## 2026-07-09 20:20

Task
TASK-031 Flutter 註冊頁（REVIEW）

Agent
Codex

### Completed

- Replaced the placeholder Flutter register route with a complete registration form.
- Added register flow to `AuthRepository` and Riverpod `AuthController` using the existing `ApiClient`.
- Added register result model for the current Auth API response shape.
- Added Email, nickname, password length, and confirm-password validation.
- Added loading, API error, success navigation, and login navigation states.
- Added register page widget tests and updated router test for the new register UI.
- Updated API spec, UI spec, frontend README, task, and log documents.
- Completed local commit. Remote push remains blocked by external GitHub egress safety review.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/lib/models/register_result.dart`
- `frontend/test/register_page_test.dart`

### Modified

- `frontend/README.md`
- `frontend/lib/pages/register_page.dart`
- `frontend/lib/providers/auth_provider.dart`
- `frontend/lib/repositories/auth_repository.dart`
- `frontend/test/routes/app_router_test.dart`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- No backend endpoint change. Frontend now calls existing `POST /api/auth/register`.

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/dart format lib/pages/register_page.dart lib/providers/auth_provider.dart lib/repositories/auth_repository.dart lib/models/register_result.dart test/register_page_test.dart test/routes/app_router_test.dart`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`

### Commit Message

```text
feat(frontend): 建立註冊頁
```

### Notes

- Task remains in REVIEW until remote push completes.
- Register success returns to the login route; it does not persist password or token and does not auto-login.

## 2026-07-09 14:59

Task
TASK-030 Flutter 登入頁

Agent
Codex

### Completed

- Replaced the placeholder Flutter login route with a complete Email / password login form.
- Added Auth Repository and Riverpod Auth Controller flow using the existing `ApiClient`.
- Added login response models for the current Auth API response shape using `json_serializable`.
- Added loading, validation, API error, register navigation, forgot-password hint, and Google-login pending states.
- Kept JWT out of SharedPreferences; access token is applied only to the current `ApiClient` runtime header.
- Added login page widget tests and updated router / app tests for the new login UI.
- Updated UI spec, frontend README, task, and log documents.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/lib/models/auth_user.dart`
- `frontend/lib/models/auth_user.g.dart`
- `frontend/lib/models/login_result.dart`
- `frontend/lib/models/login_result.g.dart`
- `frontend/lib/providers/auth_provider.dart`
- `frontend/lib/repositories/auth_repository.dart`
- `frontend/test/login_page_test.dart`

### Modified

- `frontend/README.md`
- `frontend/pubspec.yaml`
- `frontend/pubspec.lock`
- `frontend/lib/pages/login_page.dart`
- `frontend/test/routes/app_router_test.dart`
- `frontend/test/widget_test.dart`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- No backend endpoint change. Frontend now calls existing `POST /api/auth/login`.

### Database

- None

### Tests

- `flutter pub add json_annotation dev:build_runner dev:json_serializable`
- `dart run build_runner build --delete-conflicting-outputs`
- `dart format lib test`
- `flutter test`
- `flutter analyze`

### Commit Message

```text
feat(frontend): 建立登入頁
```

### Notes

- Google login UI entry is present, but Google Sign-In SDK is not introduced in this task to avoid adding an unapproved dependency. It shows a pending message until the dedicated Google Sign-In frontend task is defined.

---

## 2026-07-09 14:40

Task
TASK-029 密碼鎖 API

Agent
Codex

### Completed

- Added password lock APIs for the authenticated current user.
- Added `UserPasswordLock` entity and repository for existing `user_password_locks` schema.
- Added request and response DTOs for password lock update and verification.
- Stored password locks with BCrypt hash only; no raw lock password is persisted.
- Added service and controller tests for create/update/verify/missing user/missing lock flows.
- Updated API spec, database mapping, backend README, task, and log documents.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/user/dto/PasswordLockRequest.java`
- `backend/src/main/java/com/monsters/user/dto/PasswordLockStatusResponse.java`
- `backend/src/main/java/com/monsters/user/dto/PasswordLockVerificationResponse.java`
- `backend/src/main/java/com/monsters/user/entity/UserPasswordLock.java`
- `backend/src/main/java/com/monsters/user/repository/UserPasswordLockRepository.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/user/controller/UserController.java`
- `backend/src/main/java/com/monsters/user/service/UserService.java`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `backend/src/test/java/com/monsters/user/controller/UserControllerTest.java`
- `backend/src/test/java/com/monsters/user/service/UserServiceTest.java`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None. The existing `database/init/01_schema.sql` already contains `user_password_locks`.

### API

- Added `PUT /api/users/me/password-lock`.
- Added `POST /api/users/me/password-lock/verify`.

### Database

- No schema change. Password lock API uses existing `user_password_locks`.

### Tests

- `$env:JAVA_HOME='C:\Program Files\Java\jdk-18.0.2'; $env:Path="$env:JAVA_HOME\bin;$env:Path"; .\gradlew.bat test`
- `$env:JAVA_HOME='C:\Program Files\Java\jdk-18.0.2'; $env:Path="$env:JAVA_HOME\bin;$env:Path"; .\gradlew.bat build`
- `git diff --check`

### Commit Message

```text
feat(user): 建立密碼鎖 API
```

### Notes

- The old system stored a 4-digit lock value in user profile data and frontend local state. The new implementation stores only a backend BCrypt hash and verifies by authenticated user id.

---

## 2026-07-06 11:16

Task
TASK-028 Phase 2 會員規格一致性檢查

Agent
Codex

### Completed

- Confirmed Phase 0 and Phase 1 tasks are complete.
- Confirmed current Phase 2 member API implementation has reached avatar update and is present on remote `develop`.
- Cross-checked implemented User APIs against `docs/API_SPEC.md`, `docs/DATABASE_SPEC.md`, `docs/CODING_STANDARD.md`, backend controller, service, R2 storage settings, and tests.
- Added missing User API database mapping for profile query, profile update, and avatar update.
- Updated `docs/TASKS.md` to mark the Phase 2 implementation alignment item as DONE.
- Updated the stale avatar API REVIEW status to DONE because `origin/develop` already contains the avatar API commit.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `docs/DATABASE_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- No endpoint change. This task only verified and documented existing User APIs.

### Database

- No schema change. Added documentation mapping for existing `users` columns used by User APIs.

### Tests

- `$env:JAVA_HOME='C:\Program Files\Java\jdk-18.0.2'; $env:Path="$env:JAVA_HOME\bin;$env:Path"; .\gradlew.bat test`
- `$env:JAVA_HOME='C:\Program Files\Java\jdk-18.0.2'; $env:Path="$env:JAVA_HOME\bin;$env:Path"; .\gradlew.bat build`
- `git diff --check`

### Commit Message

```text
docs(phase2): 同步會員規格狀態
```

### Notes

- Next executable task after this alignment is `密碼鎖 API`.

---

## 2026-07-04 12:13

Task
TASK-027 更改頭貼 API（REVIEW）

Agent
Codex

### Completed

- Added `PUT /api/users/me/avatar`.
- Added Cloudflare R2 S3-compatible storage settings and avatar storage service.
- Added AWS SDK S3 dependency with user-approved package addition.
- Added avatar file validation for required file, supported image MIME types, and file size.
- Added user avatar update flow that uploads the file to R2 and stores only the public avatar URL.
- Added controller, service, and storage tests.
- Updated API spec, backend README, decision, task, and log documents.
- Confirmed the previous `PUT /api/users/me` task is on remote `develop` and corrected its stale REVIEW status to DONE.
- Completed local commit. Remote push remains blocked by external GitHub egress safety review.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/common/storage/AvatarStorageService.java`
- `backend/src/main/java/com/monsters/common/storage/R2AvatarStorageService.java`
- `backend/src/main/java/com/monsters/common/storage/R2Properties.java`
- `backend/src/main/java/com/monsters/common/storage/R2StorageConfig.java`
- `backend/src/test/java/com/monsters/common/storage/R2AvatarStorageServiceTest.java`

### Modified

- `backend/README.md`
- `backend/build.gradle`
- `backend/src/main/java/com/monsters/user/controller/UserController.java`
- `backend/src/main/java/com/monsters/user/entity/User.java`
- `backend/src/main/java/com/monsters/user/service/UserService.java`
- `backend/src/main/resources/application.yml`
- `backend/src/test/java/com/monsters/user/controller/UserControllerTest.java`
- `backend/src/test/java/com/monsters/user/service/UserServiceTest.java`
- `docs/API_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Added `PUT /api/users/me/avatar`.

### Database

- No schema change. Avatar update writes existing `users.avatar_url`.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`
- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew build`

### Commit Message

```text
feat(user): 建立更改頭貼 API
```

### Notes

- Task remains in REVIEW until remote push completes.
- R2 credentials and bucket values must be provided through environment variables before using avatar upload in runtime.

## 2026-07-04 12:01

Task
TASK-026 修改個人資料 API

Agent
Codex

### Completed

- Added `PUT /api/users/me`.
- Added profile update request DTO with `userName` validation.
- Added user profile update service logic using authenticated JWT principal user id.
- Added controller and service tests for profile update success and missing user cases.
- Updated API spec, backend README, task, and log documents.
- Confirmed the previous `GET /api/users/me` task is on remote `develop` and corrected its stale REVIEW status to DONE.
- Confirmed remote `develop` contains the profile update API commit and updated task state to DONE.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/user/dto/UpdateUserProfileRequest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/user/controller/UserController.java`
- `backend/src/main/java/com/monsters/user/entity/User.java`
- `backend/src/main/java/com/monsters/user/service/UserService.java`
- `backend/src/test/java/com/monsters/user/controller/UserControllerTest.java`
- `backend/src/test/java/com/monsters/user/service/UserServiceTest.java`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Added `PUT /api/users/me`.

### Database

- No schema change. Profile update writes existing `users.user_name` and `users.birthday`.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`
- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew build`

### Commit Message

```text
feat(user): 建立修改個人資料 API
```

### Notes

- This API updates only `userName` and `birthday`; avatar, account, email, and password lock remain separate flows.

## 2026-07-04 11:45

Task
TASK-024 登出 API

Agent
Codex

### Completed

- Added `POST /api/auth/logout`.
- Added JWT access token verification for protected APIs.
- Added revoked token persistence with token hash and original token expiration.
- Added JWT authentication filter that rejects revoked tokens and invalid tokens.
- Extended JWT service with access token verification and SHA-256 token hashing.
- Added controller, service, JWT, and security tests.
- Updated API, database, backend README, decision, task, schema, and log documents.
- Confirmed remote `develop` contains the logout API commit and updated task state to DONE.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/auth/service/TokenRevocationService.java`
- `backend/src/main/java/com/monsters/common/security/AuthenticatedUser.java`
- `backend/src/main/java/com/monsters/common/security/JwtAuthenticationFilter.java`
- `backend/src/main/java/com/monsters/common/security/JwtTokenPayload.java`
- `backend/src/main/java/com/monsters/user/entity/RevokedToken.java`
- `backend/src/main/java/com/monsters/user/repository/RevokedTokenRepository.java`
- `backend/src/test/java/com/monsters/auth/service/TokenRevocationServiceTest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/auth/controller/AuthController.java`
- `backend/src/main/java/com/monsters/common/security/JwtTokenService.java`
- `backend/src/main/java/com/monsters/common/security/SecurityConfig.java`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/common/config/CorsConfigTest.java`
- `backend/src/test/java/com/monsters/common/security/JwtTokenServiceTest.java`
- `backend/src/test/java/com/monsters/common/security/SecurityConfigTest.java`
- `database/init/01_schema.sql`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- Added `revoked_tokens` to `database/init/01_schema.sql`.

### API

- Added `POST /api/auth/logout`.

### Database

- Added `revoked_tokens`.
- JWT plaintext is not stored; only token hash is persisted.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`

### Commit Message

```text
feat(auth): 建立登出 API
```

### Notes

- Logout uses JWT revocation, not only frontend token cleanup.

## 2026-07-04 11:53

Task
TASK-025 查詢個人資料 API

Agent
Codex

### Completed

- Added `GET /api/users/me`.
- Added user profile response DTO.
- Added user service query by authenticated JWT principal user id.
- Added user controller and service tests.
- Updated API spec, backend README, task, and log documents.
- Confirmed remote `develop` contains the profile query API commit and updated task state to DONE.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/user/controller/UserController.java`
- `backend/src/main/java/com/monsters/user/dto/UserProfileResponse.java`
- `backend/src/main/java/com/monsters/user/service/UserService.java`
- `backend/src/test/java/com/monsters/user/controller/UserControllerTest.java`
- `backend/src/test/java/com/monsters/user/service/UserServiceTest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/user/repository/UserRepository.java`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Added `GET /api/users/me`.

### Database

- No schema change. Profile API reads existing `users` table.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`

### Commit Message

```text
feat(user): 建立查詢個人資料 API
```

### Notes

- The API uses authenticated JWT principal data and does not accept user id or account from the client.

## 2026-07-04 11:36

Task
TASK-023 整理 DECISIONS 決策狀態

Agent
Codex

### Completed

- Reviewed `docs/DECISIONS.md`.
- Moved already-decided items from pending confirmation into the confirmed decision table.
- Confirmed Cloudflare R2 as the file upload storage direction.
- Confirmed SMTP as the formal email delivery direction for forgot password.
- Confirmed Web admin backend is needed.
- Clarified old database, old API, old Flutter UI, and old material reuse decisions.
- Replaced the pending confirmation table with a pending-detail table for implementation details.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `docs/DECISIONS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- `git diff --check`

### Commit Message

```text
docs(decisions): 整理已定案事項
```

### Notes

- R2 credentials, SMTP credentials, Web admin permission model, old API mapping, old UI mapping, and material inventory remain implementation details for later tasks.

## 2026-07-04 11:21

Task
TASK-022 忘記密碼 API

Agent
Codex

### Completed

- Added `POST /api/auth/forgot-password`.
- Added `POST /api/auth/reset-password`.
- Added one-time password reset token generation with 15-minute expiration.
- Stored only reset token hashes in `password_reset_tokens`.
- Invalidated previous unused reset tokens when a new token is issued for the same user.
- Added password reset flow to update existing credentials or create credentials for OAuth-only users after token verification.
- Added controller, service, and token hashing tests.
- Updated API, database, backend README, decision, task, schema, and log documents.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/auth/dto/ForgotPasswordRequest.java`
- `backend/src/main/java/com/monsters/auth/dto/ForgotPasswordResponse.java`
- `backend/src/main/java/com/monsters/auth/dto/ResetPasswordRequest.java`
- `backend/src/main/java/com/monsters/common/security/PasswordResetTokenService.java`
- `backend/src/main/java/com/monsters/user/entity/PasswordResetToken.java`
- `backend/src/main/java/com/monsters/user/repository/PasswordResetTokenRepository.java`
- `backend/src/test/java/com/monsters/common/security/PasswordResetTokenServiceTest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/auth/controller/AuthController.java`
- `backend/src/main/java/com/monsters/auth/service/AuthService.java`
- `backend/src/main/java/com/monsters/user/entity/UserCredential.java`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/auth/service/AuthServiceTest.java`
- `database/init/01_schema.sql`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- Added `password_reset_tokens` to `database/init/01_schema.sql`.

### API

- Added `POST /api/auth/forgot-password`.
- Added `POST /api/auth/reset-password`.

### Database

- Added `password_reset_tokens`.
- Reset token plaintext is not stored; only token hash is persisted.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`

### Commit Message

```text
feat(auth): 建立忘記密碼 API
```

### Notes

- Current forgot-password response returns `resetToken` for development and frontend integration. Formal email delivery remains pending in `docs/DECISIONS.md`.

## 2026-07-04 06:42

Task
TASK-021 Google 登入 API

Agent
Codex

### Completed

- Added backend Google login endpoint implementation for `POST /api/auth/google-login`.
- Added backend Google ID Token verification with Google's JWKS, RS256 signature validation, issuer validation, audience validation, expiration validation, and verified-email validation.
- Added `GOOGLE_CLIENT_IDS` configuration to allow one or more Web / App Google Client IDs.
- Added `user_oauth_accounts` JPA entity and repository for Google account linking.
- Added Google login service flow to reuse an existing OAuth account, link an existing email user, or create a new user.
- Added controller, service, and token verifier tests.
- Updated API, database, backend README, decision, task, and log documents.
- Completed full backend test and build verification after fixing Spring constructor injection selection.
- Confirmed remote branch status now includes the Google login commit and updated task state to DONE.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/auth/dto/GoogleLoginRequest.java`
- `backend/src/main/java/com/monsters/common/security/GoogleIdTokenVerifier.java`
- `backend/src/main/java/com/monsters/common/security/GoogleJwkProvider.java`
- `backend/src/main/java/com/monsters/common/security/GoogleJwkProviderImpl.java`
- `backend/src/main/java/com/monsters/common/security/GoogleProperties.java`
- `backend/src/main/java/com/monsters/common/security/GoogleUserInfo.java`
- `backend/src/main/java/com/monsters/user/entity/UserOAuthAccount.java`
- `backend/src/main/java/com/monsters/user/repository/UserOAuthAccountRepository.java`
- `backend/src/test/java/com/monsters/common/security/GoogleIdTokenVerifierTest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/auth/controller/AuthController.java`
- `backend/src/main/java/com/monsters/auth/service/AuthService.java`
- `backend/src/main/java/com/monsters/common/security/SecurityConfig.java`
- `backend/src/main/resources/application.yml`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/auth/service/AuthServiceTest.java`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Added `POST /api/auth/google-login`.

### Database

- Added JPA mapping for existing spec table `user_oauth_accounts`.
- Google login reads and writes `users` and `user_oauth_accounts`.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`
- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew build`
- `git diff --check`
- First rerun found Spring constructor injection selection issues in `GoogleIdTokenVerifier` and `GoogleJwkProviderImpl`; both were fixed with explicit `@Autowired` constructors.

### Commit Message

```text
feat(auth): 建立 Google 登入 API
```

### Notes

- `GOOGLE_CLIENT_IDS` and `JWT_SECRET` must be configured before Google login can issue JWT tokens.

## 2026-07-03 20:58

Task
TASK-020 遮罩 system_data 敏感字串

Agent
Codex

### Completed

- Masked old database host, database name, username, and password in `system_data/back-end/src/main/resources/application.yml`.
- Masked old database name constant in `system_data/back-end/src/main/java/com/example/demo/config/DatabaseConfig.java`.
- Masked Android debug signing passwords in `system_data/front-end/monsters_front_end/android/app/build.gradle`.
- Masked hardcoded accessToken strings in four old Flutter reference pages.
- Re-scanned `system_data/` and confirmed the original sensitive values were no longer present.
- Confirmed no checked build artifact or credential file extension was found.
- Updated `docs/SYSTEM_DATA_REFERENCE.md`, `docs/TASKS.md`, and logs.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `docs/SYSTEM_DATA_REFERENCE.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`
- `system_data/back-end/src/main/java/com/example/demo/config/DatabaseConfig.java`
- `system_data/back-end/src/main/resources/application.yml`
- `system_data/front-end/monsters_front_end/android/app/build.gradle`
- `system_data/front-end/monsters_front_end/lib/pages/account/forgetPassword/forget_psw_auth.dart`
- `system_data/front-end/monsters_front_end/lib/pages/account/lock/forget_lock_auth.dart`
- `system_data/front-end/monsters_front_end/lib/pages/drawer/user_Feedback.dart`
- `system_data/front-end/monsters_front_end/lib/pages/social.dart`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- Searched for original sensitive values in `system_data/`.
- Checked common build artifact and credential file extensions.
- Checked common generated dependency/build directories.
- `git diff --check`

### Commit Message

```text
docs(system-data): 遮罩舊系統敏感字串
```

### Notes

- `system_data/` reference files were preserved; only sensitive literal values were replaced with placeholders.

## 2026-07-03 20:51

Task
TASK-019 補齊 system_data 參考任務

Agent
Codex

### Completed

- Added `docs/SYSTEM_DATA_REFERENCE.md` to record the `system_data/` inventory, PDF summary, old code/material organization, feature mapping, shared pattern conversion, and member/auth reference notes.
- Confirmed `system_data/` contains old manuals, old backend code, old Flutter code, and assets.
- Confirmed no obvious build artifact file or directory was found in the checked patterns.
- Updated `docs/TASKS.md` for completed Phase 0, Phase 1, and Phase 2 reference-check tasks.
- Kept the Phase 0 sensitive-data cleanup task in REVIEW because old database credentials, Android signing password strings, and hardcoded accessToken strings were found.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `docs/SYSTEM_DATA_REFERENCE.md`

### Modified

- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- Checked `system_data/` file and directory counts.
- Checked common build artifact and credential file extensions.
- Scanned text files for sensitive keyword patterns.
- Reviewed old backend common layers, member controller, member service, and old Flutter member repository/API.
- `git diff --check`

### Commit Message

```text
docs(system-data): 補齊舊系統參考任務
```

### Notes

- `system_data/` was not modified.
- The remaining Phase 0 sensitive-data task requires user confirmation before masking, removing, or relocating old reference files.

## 2026-07-03 20:36

Task
TASK-018 Login API

Agent
Codex

### Completed

- Added `POST /api/auth/login`.
- Added login request and response DTOs.
- Added JWT access and refresh token generation with JDK HMAC-SHA256 APIs, without adding a third-party dependency.
- Added login service logic for normalized email lookup, BCrypt password matching, deleted-user rejection, and 401 invalid credential handling.
- Added service, controller, and JWT token tests.
- Updated API, database, backend README, task, and log documents.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/auth/dto/AuthUserResponse.java`
- `backend/src/main/java/com/monsters/auth/dto/LoginRequest.java`
- `backend/src/main/java/com/monsters/auth/dto/LoginResponse.java`
- `backend/src/main/java/com/monsters/common/security/JwtTokenService.java`
- `backend/src/test/java/com/monsters/common/security/JwtTokenServiceTest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/auth/controller/AuthController.java`
- `backend/src/main/java/com/monsters/auth/service/AuthService.java`
- `backend/src/main/java/com/monsters/user/repository/UserCredentialRepository.java`
- `backend/src/main/java/com/monsters/user/repository/UserRepository.java`
- `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/auth/service/AuthServiceTest.java`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Added `POST /api/auth/login`.

### Database

- No schema change. Login API reads existing `users` and `user_credentials` tables.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`
- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew build`
- `git diff --check`

### Commit Message

```text
feat(auth): 建立登入 API
```

### Notes

- `JWT_SECRET` must be configured before login can issue JWT tokens.

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

## 2026-07-03 14:55

Task
TASK-017 Register API

Agent
Codex

### Completed

- Added `POST /api/auth/register`.
- Added User and UserCredential JPA entities mapped to `users` and `user_credentials`.
- Added repositories, DTOs, AuthService, and AuthController.
- Added service and controller tests for successful registration, validation, and duplicate email behavior.
- Fixed existing common exception handler/test mojibake string syntax so backend tests can compile.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/auth/controller/AuthController.java`
- `backend/src/main/java/com/monsters/auth/dto/RegisterRequest.java`
- `backend/src/main/java/com/monsters/auth/dto/RegisterResponse.java`
- `backend/src/main/java/com/monsters/auth/service/AuthService.java`
- `backend/src/main/java/com/monsters/user/entity/User.java`
- `backend/src/main/java/com/monsters/user/entity/UserCredential.java`
- `backend/src/main/java/com/monsters/user/repository/UserRepository.java`
- `backend/src/main/java/com/monsters/user/repository/UserCredentialRepository.java`
- `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/auth/service/AuthServiceTest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/common/exception/GlobalExceptionHandler.java`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `backend/src/test/java/com/monsters/common/exception/GlobalExceptionHandlerTest.java`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Added `POST /api/auth/register`.

### Database

- No schema change. Register API writes to existing `users` and `user_credentials` tables.

### Tests

- `.\gradlew.bat test`
- `.\gradlew.bat build`
- `git diff --check`

### Commit Message

```text
feat(auth): 建立註冊 API
```

### Notes

- Passwords are stored only as BCrypt hashes.

---

## 2026-07-03 14:23

Task
TASK-016 建立 Loading / Error / Empty 共用元件

變更者
Codex

### 本次完成

- 新增 Flutter 共用狀態元件 `LoadingView`、`ErrorView`、`EmptyView`。
- 狀態元件集中放置於 `frontend/lib/widgets/state/`。
- 元件使用 `Theme.of(context)` 與 `AppSpacing`，避免 hard code 共用樣式。
- 新增 widget tests，覆蓋 loading indicator、error retry action、empty action。
- 更新 frontend README 與 UI_SPEC，補充共用狀態元件規範。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限，未發現超過一個月的紀錄，未刪除過期 Log。

### 新增

- `frontend/lib/widgets/state/loading_view.dart`
- `frontend/lib/widgets/state/error_view.dart`
- `frontend/lib/widgets/state/empty_view.dart`
- `frontend/test/widgets/state_views_test.dart`

### 修改

- `frontend/README.md`
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

- `dart format lib/widgets/state test/widgets/state_views_test.dart`
- `flutter analyze`
- `flutter test`
- `flutter build web`

### Commit 撱箄降

```text
feat(frontend): 建立共用狀態元件
```

### 註記 / 待確認事項

- 後續頁面應使用共用狀態元件呈現 loading / error / empty 狀態。

---

## 2026-07-03 14:17

Task
DOC-011 merge feature/theme into develop

變更者
Codex

### 本次完成

- 將 `feature/theme` 合併至 `develop`。
- 解決 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 的 merge conflict，保留 DOC-010 與 TASK-015 紀錄。
- 修正 `frontend/lib/theme/app_theme.dart` 使用 deprecated `ColorScheme.background` 導致 `flutter analyze` 失敗的問題。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限，未發現超過一個月的紀錄，未刪除過期 Log。

### 新增

- 無

### 修改

- `frontend/lib/theme/app_theme.dart`
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

- `flutter analyze`
- `flutter test`
- `flutter build web`
- `git diff --check`

### Commit 撱箄降

```text
merge: feature theme into develop
docs(log): 補充 theme merge 紀錄
```

### 註記 / 待確認事項

- `feature/theme` commit 已包含於 `develop`。

---

## 2026-07-03 09:31

Task
DOC-010 資料庫架構正規化重構

變更者
Codex

### 本次完成

- 依照 `system_data` 舊後端 Entity 與現有 API 規格重構資料庫架構。
- 將使用者關聯統一改用 `users.id`，不再以 `account` 作為跨表關聯鍵。
- 拆分使用者認證、OAuth、隱私鎖、怪物資產、紀錄媒體、每日測驗選項。
- 將 diary / annoyance 正規化為共用 `entries`，並以 `entry_type` 區分。
- 將 diary / annoyance 社群按讚與留言整合為 `entry_likes`、`entry_comments`。
- 新增 MySQL 初始化 schema `database/init/01_schema.sql`。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限，未發現超過一個月的紀錄，未刪除過期 Log。

### 新增

- `database/init/01_schema.sql`

### 修改

- `docs/DATABASE_SPEC.md`
- `database/init/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 新增 Docker MySQL 首次初始化用 schema。
- 既有資料庫 volume 不會自動套用，若已有資料需另行撰寫資料搬遷 script。

### API

- 無 endpoint 異動。
- Community API 的資料底層將由共用 `entries` / `entry_likes` / `entry_comments` 支援。

### Database

- 重構為正規化 schema，新增 users、credentials、OAuth、monster asset、entries、entry media、daily test options 等資料表。

### 測試

- `git diff --check`
- `docker compose config`

### Commit 撱箄降

```text
refactor(database): 正規化資料庫架構
```

### 註記 / 待確認事項

- 後續實作 Auth / Diary / Annoyance / Community Entity 時需依此 schema 建立 JPA Entity 與 DTO。

---

## 2026-07-03 09:19

Task
TASK-015 建立 Theme

修改來源
Codex

### 本次完成

- 新增 Flutter Theme 基礎層，集中建立 light / dark ThemeData。
- 新增 AppColors、AppSpacing、AppRadius 作為共用設計 token。
- App 入口套用 AppTheme.light()、AppTheme.dark() 與 ThemeMode.system。
- 新增 Theme 單元測試，驗證 light / dark theme、Material 3、背景色與共用元件 theme 設定。
- 更新 frontend README 與 UI_SPEC，記錄 Theme 檔案位置與禁止頁面 hard code 共用樣式。
- 新增 Log 前已檢查 log/CHANGE_LOG.md 與 log/CHANGE_HISTORY.csv 保存期限，未發現超過一個月紀錄，未刪除紀錄。

### 新增

- `frontend/lib/theme/app_theme.dart`
- `frontend/lib/theme/app_colors.dart`
- `frontend/lib/theme/app_spacing.dart`
- `frontend/test/theme/app_theme_test.dart`

### 修改

- `frontend/lib/app.dart`
- `frontend/README.md`
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

- `flutter analyze`
- `flutter test`
- `flutter build web`

### Commit 建議

```text
feat(frontend): 建立 theme
```

### 備註 / 待確認事項

- Theme 為基礎視覺設定，後續共用元件 Task 應優先使用 ThemeData 與 theme token。
---

## 2026-07-03 09:08

Task
TASK-014 建立 go_router

修改來源
Codex

### 本次完成

- 新增 Flutter go_router 依賴並更新 pubspec.lock。
- 將 App 入口改為 Riverpod ProviderScope + MaterialApp.router。
- 新增集中式路由設定 appRouterProvider、AppRoute、AppPath。
- 新增基礎路由頁面 SplashPage、HomePage、LoginPage、RegisterPage。
- 移除 Flutter template counter app 與 counter widget test。
- 新增 route widget tests，驗證初始路由、登入路由與註冊轉登入流程。
- 更新 frontend README 與 UI_SPEC，記錄 go_router 基礎路由與 Navigator 使用限制。
- 新增 Log 前已檢查 log/CHANGE_LOG.md 與 log/CHANGE_HISTORY.csv 保存期限，未發現超過一個月紀錄，未刪除紀錄。

### 新增

- `frontend/lib/app.dart`
- `frontend/lib/routes/app_router.dart`
- `frontend/lib/routes/app_routes.dart`
- `frontend/lib/pages/splash_page.dart`
- `frontend/lib/pages/home_page.dart`
- `frontend/lib/pages/login_page.dart`
- `frontend/lib/pages/register_page.dart`
- `frontend/test/routes/app_router_test.dart`

### 修改

- `frontend/lib/main.dart`
- `frontend/test/widget_test.dart`
- `frontend/README.md`
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

- `flutter analyze`
- `flutter test`
- `flutter build web`

### Commit 建議

```text
feat(frontend): 建立 go_router
```

### 備註 / 待確認事項

- 目前頁面為路由容器骨架，實際登入、註冊與首頁功能將依後續 Task 補齊。
---

## 2026-07-02 14:33

Task
TASK-013 建立 API Error Handler

修改來源
Codex

### 本次完成

- 新增 Flutter API Error Handler，將 DioException、timeout、network、cancel、HTTP error 與非標準 response 統一轉換為 ApiException。
- 新增 ApiErrorType，供 Repository / UI 依錯誤類型判斷 unauthorized、forbidden、notFound、conflict、validation、server 等狀態。
- 更新 ApiClient，所有 request 統一透過 ApiErrorHandler 處理例外，不再直接向上拋出 DioException 或 FormatException。
- 新增 API Error Handler 與 ApiClient 錯誤處理測試。
- 修正 docs/TASKS.md 前端 Dio Client 與 API Error Handler 清單斷行問題，並依序推進 IN PROGRESS、REVIEW、DONE。
- 更新 API 文件與 frontend README，記錄前端錯誤處理合約。
- 新增 Log 前已檢查 log/CHANGE_LOG.md 與 log/CHANGE_HISTORY.csv 保存期限，未發現超過一個月紀錄，未刪除紀錄。

### 新增

- `frontend/lib/core/network/api_error_handler.dart`
- `frontend/lib/core/network/api_error_type.dart`
- `frontend/lib/core/network/api_exception.dart`
- `frontend/test/core/network/api_error_handler_test.dart`

### 修改

- `frontend/lib/core/network/api_client.dart`
- `frontend/lib/providers/api_client_provider.dart`
- `frontend/test/core/network/api_client_test.dart`
- `frontend/README.md`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 未新增或修改後端 API endpoint。
- 前端新增 API 錯誤處理合約：ApiClient 統一拋出 ApiException。

### Database

- 無

### 測試

- `flutter analyze`
- `flutter test`
- `flutter build web`

### Commit 建議

```text
feat(frontend): 建立 api error handler
```

### 備註 / 待確認事項

- 本分支 `feature/dio-client` 目前包含 TASK-012 Dio Client 與 TASK-013 API Error Handler，尚待合併至 develop。
---

## 2026-07-02 09:49

Task
TASK-012 建立 Dio Client

修改來源
Codex

### 本次完成

- 新增 Flutter Dio Client 基礎層，統一設定 API Base URL、timeout、JSON header 與標準 API response parsing。
- 新增 `AppConfig`，支援 `API_BASE_URL` dart-define 覆寫，預設為 `http://localhost:8080/api`。
- 新增 Riverpod Provider，後續 Repository 可透過 `apiClientProvider` 注入 `ApiClient`。
- 新增 Dio Client 單元測試，涵蓋 base options、Bearer token 設定與標準 API response parsing。
- 更新 `docs/TASKS.md`，依流程將 Dio Client Task 完成為 DONE。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限，未發現超過一個月紀錄。

### 新增

- `frontend/lib/config/app_config.dart`
- `frontend/lib/core/network/api_client.dart`
- `frontend/lib/core/network/api_response.dart`
- `frontend/lib/providers/api_client_provider.dart`
- `frontend/test/core/network/api_client_test.dart`

### 修改

- `frontend/README.md`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 無新增後端 API endpoint。
- 前端新增 API Client 設定與呼叫入口。

### Database

- 無

### 測試

- `flutter pub get`
- `flutter analyze`
- `flutter test`

### Commit 建議

```text
feat(frontend): 建立 dio client
```

### 備註 / 待確認事項

- 下一個 Task 為 `建立 API Error Handler`，可接續擴充 Dio interceptor 與錯誤轉換。

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
