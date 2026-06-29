# CODING_STANDARD.md

# 貘nsters 程式撰寫規範

## 一、共通原則

- 保持可讀性優先。
- 不寫重複程式碼。
- 不把商業邏輯寫進 UI 或 Controller。
- 所有輸入必須驗證。
- 所有錯誤必須處理。
- 所有重要功能必須測試。

## 二、Dart / Flutter 規範

### 2.1 檔案命名

使用 `snake_case.dart`。

範例：

```text
login_screen.dart
annoyance_repository.dart
monster_card.dart
```

### 2.2 Class 命名

使用 `UpperCamelCase`。

```dart
class LoginScreen {}
class AnnoyanceRepository {}
```

### 2.3 變數命名

使用 `lowerCamelCase`。

```dart
final userName = '';
final monsterId = 1;
```

### 2.4 Widget 規範

- Widget 只負責畫面。
- API 呼叫放在 Repository。
- 狀態放在 Provider。
- 複雜元件需拆成小 Widget。

### 2.5 Riverpod 規範

Provider 命名：

```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {});
```

State 必須能表示：

- initial
- loading
- success
- error

## 三、Java / Spring Boot 規範

### 3.1 Package 分層

```text
controller
service
repository
entity
dto
config
exception
util
```

### 3.2 Controller

- 僅處理 HTTP request / response。
- 不寫商業邏輯。
- 不直接呼叫 Repository。

### 3.3 Service

- 實作商業邏輯。
- 處理 Transaction。
- 驗證資料狀態。

### 3.4 Repository

- 使用 Spring Data JPA。
- 僅處理資料庫存取。

### 3.5 DTO

- Request DTO 負責接收輸入。
- Response DTO 負責回傳資料。
- 不得直接回傳 Entity。

## 四、API 命名

使用複數資源名稱。

```text
/api/users
/api/annoyances
/api/diaries
/api/monsters
/api/community/posts
```

狀態變更可用語意化路徑：

```text
PATCH /api/annoyances/{id}/solve
PATCH /api/annoyances/{id}/share
```

## 五、錯誤處理

後端應建立全域例外處理：

- `GlobalExceptionHandler`
- `BusinessException`
- `ResourceNotFoundException`
- `UnauthorizedException`
- `ValidationException`

前端應建立：

- API Error Parser
- Error View
- Snackbar / Dialog 顯示錯誤

## 六、測試命名

後端：

```text
AuthServiceTest
AnnoyanceControllerTest
DiaryRepositoryTest
```

前端：

```text
login_screen_test.dart
annoyance_provider_test.dart
monster_card_test.dart
```

## 七、註解規範

只在必要時加入註解：

- 複雜商業邏輯
- 非直覺流程
- 外部服務整合
- 跨平台限制

不得加入無意義註解。
