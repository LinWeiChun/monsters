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

## Web-first 與 RWD 開發設定

目前 UI 開發與驗收以 Web 版本為主要目標，同時保留 Android／iOS 相容性。Web 必須在瀏覽器視窗縮放時即時 reflow，不得要求重新整理，也不得把完整手機或 1440 x 900 Penpot 畫布直接等比放大。

共用設定位於 `lib/layout/responsive_layout.dart`：

| Window class | Viewport width | 版型原則 |
|---|---:|---|
| Mobile | `< 600px` | 保留既有 Mobile Penpot layout，內容可捲動且不可溢位 |
| Tablet | `600px - 1199px` | 單欄或 compact flow layout，內容置中並設定最大寬度 |
| Desktop | `>= 1200px` | Web 專用雙欄／多欄 flow layout，內容寬度受限 |

頁面應使用 `ResponsiveLayout` 判斷 window class，並以 `ResponsiveContent`、`Row`、`Column`、`Wrap`、`Expanded` 與 `ConstrainedBox` 配置相對版面。`Stack`／`Positioned` 僅限 Mobile Penpot 精準畫布或元件內局部疊圖，不得作為 Tablet／Desktop 的主版面定位。

Web 本機開發：

```bash
GOOGLE_CLIENT_ID=your-web-client-id.apps.googleusercontent.com \
  ./tool/run_web_local.sh
```

固定網址為 `http://localhost:5050`。開發時應拖曳 Chrome 視窗跨越 600px 與 1200px，並至少驗證 390、600、900、1024、1200、1440、1920px；切換過程不得出現 overflow、裁切、負 padding 或版面跳回固定 canvas。

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
- `lib/repositories/auth_session_store.dart`
- `lib/models/auth_user.dart`
- `lib/models/auth_user.g.dart`
- `lib/models/login_result.dart`
- `lib/models/login_result.g.dart`
- `lib/models/register_result.dart`

登入流程使用 `AuthRepository` 呼叫 `POST /api/auth/login`，成功後由 `ApiClient.setAccessToken()` 將 access token 套用到目前執行階段的 Authorization header，並透過 `AuthSessionStore` 保存 `LoginResult` 與最後開啟時間。使用者未登出且 30 天內再次開啟 App 時，`SplashPage` 會先以保存的 refresh token 呼叫 `POST /api/auth/refresh` 完成 rotation，再使用新 access token 進入首頁；不得直接重用可能已過期的 access token。

受保護 API 若回傳 401，`ApiClient` 會共用單一 refresh request 換發 Token，成功後只重試原 request 一次，避免並行 API 觸發多次 rotation。Refresh API 本身、登入、Google 登入、註冊與登出不得啟動 401 refresh retry。Refresh token 驗證失敗、超過 30 天、session 格式無效或使用者登出時，必須清除 Authorization header 與本地 session，並回到登入頁；暫時性網路錯誤保留 session 供下次重試。

Google 登入流程使用 `GoogleSignInService` 透過 `google_sign_in` / `google_sign_in_web` 取得 Google ID Token，再由 `AuthRepository` 呼叫 `POST /api/auth/google-login` 交給後端驗證並換發本系統 JWT。Web 版使用 Google Identity Services 官方按鈕，Android / iOS 使用共用 Flutter 登入按鈕；成功後同樣由 `AuthSessionStore` 保存 30 天登入狀態。

註冊流程使用 `AuthRepository` 呼叫 `POST /api/auth/register`，成功後導回登入頁，不自動登入，也不保存密碼或 token。帳號為必填且唯一，需英文開頭，只能包含英文、數字、底線，長度 4 到 50，前端送出前會轉為小寫。

密碼不得寫入 SharedPreferences；登入 session 僅由 `AuthSessionStore` 集中管理，頁面不得直接讀寫 token。Refresh token 每次換發後必須覆蓋舊 session，前端不得重複使用舊 refresh token。Google 登入不得假造 ID Token 或沿用舊系統空密碼登入流程。

Google 登入執行時需提供 dart-define，且後端 `GOOGLE_CLIENT_IDS` 必須包含對應 Client ID：

```bash
# Web
GOOGLE_CLIENT_ID=your-web-client-id.apps.googleusercontent.com \
  ./tool/run_web_local.sh


# Windows PowerShell
.\tool\run_web_local.ps1 -GoogleClientId your-web-client-id.apps.googleusercontent.com
# Android / iOS
/Users/linweijun/fultter/flutter/bin/flutter run \
  --dart-define=GOOGLE_CLIENT_ID=your-platform-client-id.apps.googleusercontent.com \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

`tool/run_web_local.sh` 與 Windows `tool/run_web_local.ps1` 會固定 Web 本機網址為 `http://localhost:5050`，避免 Flutter Web 每次啟動改用不同 port 而被 Google OAuth 擋下。PowerShell 版本可將 Client ID 填入檔案內的 `$DefaultGoogleClientId`，之後只需執行 `./tool/run_web_local.ps1`。Google Cloud OAuth Client 的 Authorized JavaScript origins 請加入：

```text
http://localhost:5050
```

Web 版還需在 Google Cloud OAuth Client 設定 Authorized JavaScript origins，且 Web Google SDK 不支援 `serverClientId`，因此 Web 本機測試不要傳 `GOOGLE_SERVER_CLIENT_ID`。Android / iOS 需依 Google OAuth Client 設定 package name、bundle id 與簽章資訊。

## User Profile

個人資料頁與資料流：

- `lib/pages/profile_page.dart`
- `lib/providers/user_profile_provider.dart`
- `lib/repositories/user_repository.dart`
- `lib/models/user_profile.dart`
- `lib/models/user_profile.g.dart`

個人資料流程使用 `UserRepository` 呼叫 `GET /api/users/me` 與 `PUT /api/users/me`，由後端依目前 Authorization token 判斷使用者；前端不傳入 user id 或 account。頁面支援載入、錯誤重試、暱稱與生日編輯、儲存成功提示。頭貼目前支援顯示 `avatarUrl`，三平台檔案選取與上傳會於更改頭貼 UI Task 定案後補齊。
## Password Lock

密碼鎖頁與資料流：

- `lib/pages/password_lock_page.dart`
- `lib/providers/password_lock_provider.dart`
- `lib/repositories/user_repository.dart`
- `lib/models/password_lock_status.dart`
- `lib/models/password_lock_verification.dart`

密碼鎖流程使用 `UserRepository` 呼叫 `PUT /api/users/me/password-lock` 與 `POST /api/users/me/password-lock/verify`。前端只做 4 位數字格式檢查與設定確認，不保存密碼鎖明文，也不使用 SharedPreferences 保存密碼鎖狀態。忘記密碼鎖流程需待正式 API 定案後補齊。
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
| `/password-lock` | `passwordLock` | `PasswordLockPage` |

UI 不得直接使用 `Navigator.push`，頁面切換應透過 `context.goNamed()` 或集中路由設定。
## Theme

前端 Theme 統一由下列檔案管理：

- `lib/theme/app_theme.dart`
- `lib/theme/app_colors.dart`
- `lib/theme/app_spacing.dart`

App 入口在 `lib/app.dart` 套用 `AppTheme.light()`、`AppTheme.dark()` 與 `ThemeMode.system`。

目前集中色票已承接舊版 Flutter 的暖黃色 / 棕色視覺語彙：

- `#FFFED4`：主要背景
- `#FFED97`：柔黃色輔助色
- `#A0522D`：品牌主棕色與 Theme seed

頁面不得自行 hard code 共用顏色、圓角與間距；應優先使用 `Theme.of(context)`、`AppColors`、`AppSpacing`、`AppRadius`。
## App Icons / Logo

三平台 App Icon 來源為根目錄 `../icon/icon.png`，產出至：

- Android：`android/app/src/main/res/mipmap-*/ic_launcher.png`
- iOS：`ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`
- Web：`web/favicon.png`、`web/icons/*.png`

Flutter 內部品牌圖來源為根目錄 `../icon/標題.png`，匯入至：

- Logo：`assets/images/app_logo.png`
- Icon：`assets/images/app_icon.png`

Logo 目前套用於 splash、login、register 三個頁面。

Web manifest 的 `background_color` 與 `theme_color` 需維持舊版暖黃色 / 棕色視覺，不使用 Flutter 預設藍色。
## Common State Widgets

共用狀態元件位於：

- `lib/widgets/state/loading_view.dart`
- `lib/widgets/state/error_view.dart`
- `lib/widgets/state/empty_view.dart`

頁面與 feature widget 應使用 `LoadingView`、`ErrorView`、`EmptyView` 呈現載入、錯誤與空資料狀態。狀態元件只負責 UI 呈現，API 呼叫、錯誤轉換與重試邏輯應放在 Provider / Repository / Service。
