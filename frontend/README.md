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
