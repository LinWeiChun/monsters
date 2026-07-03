# 貘nsters Frontend

貘nsters 的 Flutter 前端專案。

## 技術

- Flutter
- Dart

## 支援平台

- Android
- iOS
- Web

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

UI 不得直接使用 `Navigator.push`，頁面切換應透過 `context.goNamed()` 或集中路由設定。
## Theme

前端 Theme 統一由下列檔案管理：

- `lib/theme/app_theme.dart`
- `lib/theme/app_colors.dart`
- `lib/theme/app_spacing.dart`

App 入口在 `lib/app.dart` 套用 `AppTheme.light()`、`AppTheme.dark()` 與 `ThemeMode.system`。

頁面不得自行 hard code 共用顏色、圓角與間距；應優先使用 `Theme.of(context)`、`AppColors`、`AppSpacing`、`AppRadius`。
