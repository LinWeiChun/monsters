# 貘nsters Frontend

貘nsters 的 Flutter 前端專案。

## 技術

- Flutter
- Dart

## 支援平台

- Android
- iOS
- Web

前端功能預設以 Flutter 共用程式支援三平台。新增頁面或互動流程時，需同步確認 Web、Android、iOS 皆有可執行入口；若有平台限制，需在對應 Task 文件中記錄替代處理。

## 專案規範

前端開發需遵守：

- `../AGENTS.md`
- `../docs/CODING_STANDARD.md`
- `../docs/UI_SPEC.md`

## API Client

前端 REST API 存取統一透過 Dio Client：

- `lib/config/app_config.dart`
- `lib/core/network/api_client.dart`
- `lib/core/network/api_error_handler.dart`
- `lib/core/network/api_error_type.dart`
- `lib/core/network/api_exception.dart`
- `lib/core/network/api_response.dart`
- `lib/providers/api_client_provider.dart`

預設 API Base URL：

```text
http://localhost:8080/api
```

可於執行時使用 dart-define 覆寫：

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api
```

UI 不得直接呼叫 Dio，後續功能需透過 Provider / Repository 使用 `ApiClient`。
## Auth

登入頁與登入狀態邏輯：

- `lib/pages/login_page.dart`
- `lib/pages/register_page.dart`
- `lib/providers/auth_provider.dart`
- `lib/repositories/auth_repository.dart`
- `lib/models/auth_user.dart`
- `lib/models/auth_user.g.dart`
- `lib/models/login_result.dart`
- `lib/models/login_result.g.dart`
- `lib/models/register_result.dart`

登入流程使用 `AuthRepository` 呼叫 `POST /api/auth/login`，成功後由 `ApiClient.setAccessToken()` 將 access token 套用到目前執行階段的 Authorization header。Auth model 使用 `json_serializable` 產生 JSON mapping。

註冊流程使用 `AuthRepository` 呼叫 `POST /api/auth/register`，成功後導回登入頁，不自動登入，也不保存密碼或 token。

目前不將 JWT、Refresh Token 或密碼寫入 SharedPreferences。Google 登入入口已保留，但需後續 Google Sign-In SDK 與 ID Token 流程完成後才能正式啟用。
## User Profile

個人資料頁與資料流：

- `lib/pages/profile_page.dart`
- `lib/providers/user_profile_provider.dart`
- `lib/repositories/user_repository.dart`
- `lib/models/user_profile.dart`
- `lib/models/user_profile.g.dart`

個人資料流程使用 `UserRepository` 呼叫 `GET /api/users/me` 與 `PUT /api/users/me`，由後端依目前 Authorization token 判斷使用者；前端不傳入 user id 或 account。頁面支援載入、錯誤重試、暱稱與生日編輯、儲存成功提示。頭貼目前支援顯示 `avatarUrl`，三平台檔案選取與上傳會於更改頭貼 UI Task 定案後補齊。
## Routing

前端路由統一使用 go_router：

- `lib/app.dart`
- `lib/routes/app_router.dart`
- `lib/routes/app_routes.dart`

App 入口使用 `MaterialApp.router`，路由由 `appRouterProvider` 提供。

目前基礎路由：

| Path | Name | Page |
|---|---|---|
| `/` | `splash` | `SplashPage` |
| `/home` | `home` | `HomePage` |
| `/login` | `login` | `LoginPage` |
| `/register` | `register` | `RegisterPage` |
| `/profile` | `profile` | `ProfilePage` |

UI 不得直接使用 `Navigator.push`，頁面切換應透過 `context.goNamed()` 或集中路由設定。
## Theme

前端 Theme 統一由下列檔案管理：

- `lib/theme/app_theme.dart`
- `lib/theme/app_colors.dart`
- `lib/theme/app_spacing.dart`

App 入口在 `lib/app.dart` 套用 `AppTheme.light()`、`AppTheme.dark()` 與 `ThemeMode.system`。

頁面不得自行 hard code 共用顏色、圓角與間距；應優先使用 `Theme.of(context)`、`AppColors`、`AppSpacing`、`AppRadius`。
## Common State Widgets

共用狀態元件位於：

- `lib/widgets/state/loading_view.dart`
- `lib/widgets/state/error_view.dart`
- `lib/widgets/state/empty_view.dart`

頁面與 feature widget 應使用 `LoadingView`、`ErrorView`、`EmptyView` 呈現載入、錯誤與空資料狀態。狀態元件只負責 UI 呈現，API 呼叫、錯誤轉換與重試邏輯應放在 Provider / Repository / Service。
