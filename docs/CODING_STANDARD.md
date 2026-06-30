# CODING_STANDARD.md

# 貘nsters 程式設計規範（Coding Standard）

> Version：v3.0
>
> 本文件規範 **貘nsters** 專案所有程式碼撰寫標準。
>
> 所有 AI Coding Agent（Codex、Cursor Agent、GitHub Copilot Agent、Claude Code、Gemini CLI）及專案開發者皆須遵守本文件。

---

# 第一章、文件目的（Document Purpose）

## 1.1 文件目的

本文件定義本專案所有程式設計規範。

內容包含：

- Java
- Spring Boot
- Flutter
- Dart
- REST API
- Database
- SQL
- Security
- Testing
- Logging
- Exception Handling
- Dependency Management

所有程式碼皆須符合本文件規範。

---

## 1.2 適用對象

本文件適用於：

- Codex
- Cursor Agent
- GitHub Copilot Agent
- Claude Code
- Gemini CLI
- 所有 Repository 開發者

---

## 1.3 文件定位

本文件僅規範：

> **程式如何撰寫**

不包含：

- AI Workflow
- Git Flow
- Release Flow
- Repository 管理

上述內容請參閱：

- AGENTS.md
- GIT_RULE.md

---

## 1.4 文件優先順序

若本文件與其他規格發生衝突，依照以下優先順序：

1. AGENTS.md
2. PROJECT_SPEC.md
3. DATABASE_SPEC.md
4. API_SPEC.md
5. UI_SPEC.md
6. CODING_STANDARD.md

若仍有衝突：

AI 必須停止開發並詢問使用者。

不得自行推測。

---

# 第二章、共通開發原則（General Development Principles）

所有程式皆須遵守下列原則：

- Clean Architecture
- SOLID
- DRY（Don't Repeat Yourself）
- KISS（Keep It Simple）
- YAGNI（You Aren't Gonna Need It）

不得為未來可能發生的需求預先建立未使用的程式碼。

---

## 2.1 Clean Architecture

本專案採用分層架構。

```
Presentation
    ↓
Application
    ↓
Domain
    ↓
Infrastructure
```

各層職責如下：

| Layer | 責任 |
|-------|------|
| Presentation | UI、Controller、API Request/Response |
| Application | Service、Use Case |
| Domain | Entity、Business Rule |
| Infrastructure | Repository、Database、External API |

不得跨層直接存取。

例如：

- Flutter UI 不得直接存取 Database。
- Controller 不得直接操作 Repository。
- UI 不得直接呼叫 SQL。

---

## 2.2 Single Responsibility Principle（SRP）

每一個 Class 僅負責一項職責。

例如：

UserController：

- 接收 Request
- 呼叫 Service
- 回傳 Response

不得：

- 驗證 JWT
- 操作 Database
- 寄送 Email
- 撰寫商業邏輯

上述內容應分別交由：

- Security
- Repository
- Mail Service
- Business Service

負責。

---

## 2.3 Open / Closed Principle（OCP）

功能新增時：

優先採用擴充（Extension）。

避免直接修改既有程式。

若需修改既有程式：

應評估是否會影響其他功能。

---

## 2.4 Dependency Injection（DI）

Spring Boot：

所有 Service 使用 Constructor Injection。

建議：

```java
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
}
```

禁止：

```java
UserRepository repository = new UserRepository();
```

Flutter：

所有依賴由 Riverpod 管理。

不得自行建立 Singleton。

---

## 2.5 DRY（Don't Repeat Yourself）

不得重複撰寫相同商業邏輯。

重複程式：

應抽出為：

- Utility
- Service
- Extension
- Common Widget
- Helper

避免複製貼上修改。

---

## 2.6 KISS（Keep It Simple）

程式應保持：

- 易閱讀
- 易理解
- 易維護

不得：

過度抽象。

不得：

為簡單功能建立過多 Interface。

---

## 2.7 YAGNI（You Aren't Gonna Need It）

不得：

提前建立：

- API
- Entity
- Repository
- Service
- Widget
- Database Table

僅建立目前需求所需內容。

---

## 2.8 可維護性（Maintainability）

所有程式應：

- 易閱讀
- 易修改
- 易測試
- 易擴充

避免：

- Hard Code
- Magic Number
- Duplicate Code
- Long Method
- Long Class

---

## 2.9 可讀性（Readability）

程式命名必須具有語意。

例如：

良好：

```java
calculateTotalScore()
```

避免：

```java
calc()
```

---

## 2.10 程式碼一致性（Consistency）

同一專案：

必須維持：

- 相同命名方式
- 相同架構
- 相同例外處理方式
- 相同 API 回傳格式

不得因個人習慣改變 Coding Style。

---

# 第三章、命名規範（Naming Convention）

所有命名必須保持一致。

不得混用不同命名方式。

---

## 3.1 Java 命名

### Class

使用：

UpperCamelCase

例如：

```text
UserController
UserService
DiaryRepository
MonsterEntity
```

---

### Method

使用：

lowerCamelCase

例如：

```java
login()

createDiary()

deleteMonster()
```

---

### Variable

使用：

lowerCamelCase

例如：

```java
userId

monsterLevel

createdAt
```

---

### Constant

使用：

UPPER_SNAKE_CASE

例如：

```java
MAX_LOGIN_RETRY

DEFAULT_PAGE_SIZE

TOKEN_EXPIRE_TIME
```

---

### Package

全部小寫。

例如：

```text
com.monsters.user.service

com.monsters.community.controller
```

---

## 3.2 Flutter / Dart 命名

### Class

UpperCamelCase

例如：

```dart
LoginPage

DiaryCard

CommunityProvider
```

---

### Variable

lowerCamelCase

例如：

```dart
userName

isLoading

selectedDiary
```

---

### File Name

全部：

snake_case

例如：

```text
login_page.dart

diary_card.dart

community_provider.dart

monster_repository.dart
```

---

## 3.3 Database 命名

### Table

全部：

snake_case

例如：

```text
users

diary_records

annoyances

community_posts
```

---

### Column

全部：

snake_case

例如：

```text
created_at

updated_at

user_id

monster_id
```

---

### Foreign Key

統一：

```
<entity>_id
```

例如：

```text
user_id

diary_id

monster_id
```

不得：

```text
userId

monsterId
```

---

## 3.4 API 命名

遵循 RESTful。

例如：

```text
GET    /api/users

POST   /api/users

PUT    /api/users/{id}

DELETE /api/users/{id}
```

避免：

```text
/getUser

/createDiary

/deletePost

/updateUserInfo
```

---

## 3.5 JSON 命名

JSON 欄位：

全部：

camelCase

例如：

```json
{
    "userId": 1,
    "userName": "WeiChun",
    "createdAt": "2026-01-01"
}
```

---

## 3.6 Git 命名

Git：

- Branch
- Commit
- Pull Request

全部依照：

**GIT_RULE.md**

不得於本文件重複定義。

---

## 3.7 註解規範

註解應說明：

- 商業邏輯
- 特殊演算法
- 外部限制

不得撰寫無意義註解。

例如：

不建議：

```java
// i++
i++;
```

建議：

```java
// 超過三次登入失敗即鎖定帳號
```

---

## 3.8 文件命名

所有 Markdown 文件：

使用：

UPPER_SNAKE_CASE

例如：

```text
PROJECT_SPEC.md

API_SPEC.md

DATABASE_SPEC.md

CODING_STANDARD.md
```

---

# 第四章、Flutter / Dart 開發規範（Flutter / Dart Development Standard）

## 4.1 技術選型

本專案統一使用：

| 項目 | 技術 |
|------|------|
| Framework | Flutter |
| Language | Dart |
| State Management | Riverpod |
| HTTP Client | Dio |
| JSON | json_serializable |
| Routing | go_router |
| Local Storage | SharedPreferences |
| Dependency Injection | Riverpod Provider |

不得自行更換框架。

新增第三方套件必須取得使用者確認。

---

## 4.2 專案目錄結構

建議目錄：

```text
lib/
│
├── core/
│
├── config/
│
├── models/
│
├── repositories/
│
├── services/
│
├── providers/
│
├── pages/
│
├── widgets/
│
├── routes/
│
└── utils/
```

各資料夾職責：

| 資料夾 | 職責 |
|---------|------|
| core | 共用設定 |
| config | App Config |
| models | Data Model |
| repositories | API 存取 |
| services | Business Service |
| providers | Riverpod |
| pages | UI 頁面 |
| widgets | 共用元件 |
| routes | Router |
| utils | 工具類別 |

不得混用。

---

## 4.3 State Management

統一：

Riverpod

不得：

- setState 作為大型狀態管理
- Provider 與 Riverpod 混用
- Bloc 與 Riverpod 混用

所有狀態：

必須透過 Provider 管理。

---

## 4.4 UI 原則

Widget：

僅負責：

- UI
- Event

不得：

- 呼叫 API
- SQL
- Business Logic

例如：

```dart
LoginPage

↓

LoginProvider

↓

UserRepository

↓

REST API
```

不得：

```dart
LoginPage

↓

Dio.post(...)
```

---

## 4.5 Repository Pattern

所有 API：

必須：

經 Repository。

流程：

```text
Page

↓

Provider

↓

Repository

↓

REST API
```

Repository：

不得：

直接操作 UI。

---

## 4.6 Dio

所有 HTTP：

統一：

Dio。

不得：

- HttpClient
- http package
- 自行建立 Socket

所有：

Base URL：

集中：

Config。

不得：

Hard Code。

---

## 4.7 JSON

Model：

全部：

json_serializable。

不得：

手刻：

fromJson。

例如：

```dart
@JsonSerializable()
class UserModel {

}
```

---

## 4.8 Routing

統一：

go_router。

不得：

Navigator.push()

大量混用。

Router：

集中管理。

---

## 4.9 Local Storage

僅允許：

SharedPreferences：

儲存：

- Theme
- Language
- Login Flag
- User Setting

不得：

儲存：

- Password
- JWT
- Refresh Token
- Secret

---

## 4.10 Widget

共用 UI：

必須：

抽成：

Widget。

例如：

```text
PrimaryButton

DiaryCard

MonsterAvatar

LoadingView
```

不得：

每個 Page：

複製：

相同程式。

---

## 4.11 Async

所有：

Future：

必須：

Exception Handling。

不得：

忽略：

Error。

例如：

```dart
try {

}
catch (e) {

}
```

---

## 4.12 Flutter Code Style

每個 Widget：

不得超過：

300 行。

Method：

建議：

50 行內。

Build：

保持：

簡潔。

複雜 UI：

拆 Widget。

---

## 4.13 Responsive Design

所有畫面：

支援：

- Android
- iOS
- Web

避免：

固定 Width。

固定 Height。

---

## 4.14 Theme

不得：

Hard Code：

Color。

Font。

Size。

統一：

ThemeData。

---

## 4.15 Flutter 最佳實踐

AI 應：

- 使用 const Widget
- 避免 rebuild
- 使用 immutable Model
- Provider 單一責任
- Repository 單一責任

---

# 第五章、Java / Spring Boot 開發規範（Java / Spring Boot Standard）

## 5.1 技術選型

| 項目 | 技術 |
|------|------|
| Language | Java 21 LTS（建議） |
| Framework | Spring Boot |
| ORM | Spring Data JPA |
| Database | MySQL |
| Build Tool | Maven |
| Validation | Jakarta Validation |
| Security | Spring Security + JWT |

不得自行修改。

---

## 5.2 專案架構

建議：

```text
controller/

service/

repository/

entity/

dto/

mapper/

config/

exception/

security/

util/
```

不得：

Controller：

直接：

操作：

Repository。

---

## 5.3 Controller

Controller：

只負責：

- Request
- Validation
- Response

不得：

- SQL
- Business Logic
- Transaction

---

## 5.4 Service

所有：

Business Logic：

皆放：

Service。

例如：

登入：

權限：

通知：

計算：

皆放：

Service。

---

## 5.5 Repository

Repository：

僅負責：

Database。

不得：

Business Logic。

不得：

驗證。

---

## 5.6 Entity

Entity：

僅對應：

Database。

不得：

直接：

回傳：

API。

API：

全部：

DTO。

---

## 5.7 DTO

所有 API：

Request：

Response：

皆使用：

DTO。

不得：

Entity：

直接：

Response。

---

## 5.8 Validation

所有 Request：

必須：

Validation。

例如：

```java
@NotBlank

@Email

@NotNull

@Size
```

Validation：

放：

DTO。

---

## 5.9 Transaction

Transaction：

只允許：

Service。

例如：

```java
@Transactional
```

不得：

Controller。

---

## 5.10 Dependency Injection

全部：

Constructor Injection。

建議：

```java
@RequiredArgsConstructor
```

禁止：

Field Injection。

例如：

```java
@Autowired
private UserService service;
```

---

## 5.11 Configuration

所有：

設定：

集中：

```text
config/
```

不得：

Hard Code：

JWT。

URL。

Secret。

---

## 5.12 Utility

Utility：

不得：

Business Logic。

僅：

工具。

例如：

DateUtil

FileUtil

StringUtil

---

## 5.13 Mapper

Entity：

DTO：

使用：

Mapper。

不得：

Controller：

自行：

copy。

---

## 5.14 Exception

所有 Exception：

集中：

GlobalExceptionHandler。

不得：

Controller：

大量：

try-catch。

---

## 5.15 Java Best Practice

AI 應：

- Optional
- Stream（適度）
- Constructor Injection
- Immutable Object
- Clean Code

避免：

- Null Pointer
- Long Method
- Deep Nesting
- Hard Code

---

# 第六章、REST API 開發規範（REST API Development Standard）

## 6.1 API 設計原則

本專案所有 API 必須遵循 RESTful 架構。

不得自行設計 RPC 或 Action API。

正確範例：

```text
GET     /api/users
GET     /api/users/{id}
POST    /api/users
PUT     /api/users/{id}
DELETE  /api/users/{id}
```

避免：

```text
/getUser

/createUser

/updateDiary

/deleteMonster
```

---

## 6.2 HTTP Method

| Method | 用途 |
|----------|------|
| GET | 查詢 |
| POST | 新增 |
| PUT | 完整修改 |
| PATCH | 部分修改（必要時） |
| DELETE | 刪除 |

不得混用。

---

## 6.3 API Path

命名：

全部：

小寫。

使用：

plural noun。

例如：

```text
/api/users

/api/diaries

/api/community-posts

/api/annoyances
```

不得：

CamelCase。

不得：

動詞。

---

## 6.4 Response Format

所有 API：

統一格式：

成功：

```json
{
    "success": true,
    "message": "",
    "data": {}
}
```

失敗：

```json
{
    "success": false,
    "message": "Error Message",
    "data": null
}
```

不得：

不同 API：

不同格式。

---

## 6.5 DTO

API：

Request

Response

全部：

DTO。

不得：

Entity：

直接：

Response。

---

## 6.6 Validation

所有 Request：

必須：

Validation。

例如：

```java
@NotBlank

@NotNull

@Email

@Size

@Pattern
```

Validation：

放：

DTO。

不得：

Controller：

自行：

if()

判斷。

---

## 6.7 Status Code

統一：

| Code | 用途 |
|------|------|
| 200 | Success |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 500 | Internal Server Error |

不得：

全部：

200。

---

## 6.8 Pagination

所有列表：

必須：

支援：

Pagination。

參數：

```text
page

size

sort
```

不得：

一次：

查詢：

全部資料。

---

## 6.9 Version

API：

預設：

```text
/api/
```

重大版本：

才加入：

```text
/api/v2/
```

不得：

每個 API：

自行：

加入：

Version。

---

## 6.10 API 文件

新增：

API：

必須：

同步更新：

```text
docs/API_SPEC.md
```

---

# 第七章、Database 與 SQL 規範（Database & SQL Standard）

## 7.1 Database

本專案：

使用：

MySQL。

不得：

Flutter：

直接：

存取：

Database。

所有資料：

皆經：

REST API。

---

## 7.2 Table

所有 Table：

必須：

包含：

```text
id

created_at

updated_at
```

若需要：

加入：

```text
deleted_at
```

Soft Delete。

---

## 7.3 Naming

Table：

snake_case。

Column：

snake_case。

Foreign Key：

```text
<entity>_id
```

例如：

```text
user_id

diary_id

community_post_id
```

---

## 7.4 Primary Key

Primary Key：

統一：

```text
id
```

不得：

```text
userId

diaryId
```

---

## 7.5 Index

以下欄位：

建議：

Index。

- email
- account
- created_at
- foreign key

避免：

大量：

Full Table Scan。

---

## 7.6 Constraint

所有 Foreign Key：

建立：

Constraint。

避免：

孤兒資料。

---

## 7.7 SQL

禁止：

```sql
SELECT *
```

必須：

指定：

Column。

---

## 7.8 Query

優先：

Spring Data JPA。

其次：

Specification。

QueryDSL（若導入）。

避免：

Native SQL。

---

## 7.9 Transaction

Transaction：

僅允許：

Service。

例如：

```java
@Transactional
```

不得：

Controller。

---

## 7.10 Migration

Database：

修改：

必須：

Migration。

不得：

直接：

修改：

正式資料庫。

---

## 7.11 Duplicate Data

避免：

重複資料。

必要時：

Unique Constraint。

例如：

```text
email

account
```

---

## 7.12 Performance

避免：

- N+1 Query
- Full Table Scan
- 無限制 Join
- 無限制排序

大量資料：

使用：

Pagination。

---

# 第八章、安全規範（Security Standard）

## 8.1 Authentication

登入：

統一：

JWT。

Token：

需設定：

Expiration。

必要時：

Refresh Token。

---

## 8.2 Authorization

不得：

相信：

Client：

傳入：

```text
userId

role

permission
```

權限：

必須：

Server：

驗證。

---

## 8.3 Password

Password：

不得：

明文。

必須：

Hash。

建議：

BCrypt。

---

## 8.4 Secret

不得：

Hard Code：

Password。

JWT Secret。

API Key。

Database Password。

統一：

```text
application.yml

.env

GitHub Secrets
```

---

## 8.5 Upload

所有上傳：

檢查：

- MIME Type
- Extension
- File Size

不得：

只檢查：

副檔名。

---

## 8.6 Personal Data

涉及：

- Diary
- Annoyance
- User Profile

必須：

驗證：

Owner。

不得：

跨帳號：

讀取。

---

## 8.7 Logging

不得：

Log：

- Password
- JWT
- Refresh Token
- Secret
- Personal Information

---

## 8.8 HTTPS

正式環境：

必須：

HTTPS。

不得：

HTTP。

---

## 8.9 CORS

CORS：

限制：

可信任：

Origin。

不得：

```text
*
```

---

## 8.10 Input Validation

所有：

Client Input：

皆需：

Validation。

不得：

相信：

Client。

SQL Injection。

XSS。

CSRF。

皆需：

防護。

# 第九章、Exception Handling 規範（Exception Handling Standard）

## 9.1 基本原則

所有 Exception 必須集中管理。

不得：

- 忽略 Exception
- 吞掉 Exception
- 回傳 Stack Trace 至 Client

所有 Exception 必須提供：

- 明確錯誤訊息
- 正確 HTTP Status Code
- 統一 Response Format

---

## 9.2 Exception 分層

建議建立：

```text
exception/
│
├── BusinessException.java
├── ValidationException.java
├── ResourceNotFoundException.java
├── ConflictException.java
├── UnauthorizedException.java
├── ForbiddenException.java
├── GlobalExceptionHandler.java
```

所有自訂 Exception：

繼承：

RuntimeException。

---

## 9.3 Global Exception Handler

Spring Boot：

統一使用：

```java
@RestControllerAdvice
```

集中處理所有 Exception。

不得：

每個 Controller：

大量：

```java
try {
    ...
}
catch (...) {
    ...
}
```

---

## 9.4 Response Format

Exception：

統一格式：

```json
{
    "success": false,
    "message": "Error Message",
    "data": null
}
```

不得：

不同 Exception：

不同格式。

---

## 9.5 Business Exception

商業邏輯：

不得：

直接：

```java
throw new RuntimeException();
```

應建立：

```java
BusinessException
```

例如：

- 帳號已存在
- 日記不存在
- 怪獸不存在
- 今日已完成簽到

---

## 9.6 Validation Exception

Validation：

失敗：

回傳：

400 Bad Request。

不得：

500。

---

## 9.7 Resource Not Found

找不到資料：

統一：

404。

例如：

- User
- Diary
- Community
- Annoyance

---

## 9.8 Flutter Exception

Flutter：

不得：

```dart
catch (_) {}
```

忽略錯誤。

必須：

顯示：

使用者可理解訊息。

例如：

- 網路異常
- 登入失敗
- 找不到資料
- 系統忙碌

---

## 9.9 Logging

所有 Exception：

必須：

Error Log。

不得：

空 Catch。

例如：

```java
catch (Exception e) {
    log.error("Login failed", e);
    throw e;
}
```

---

## 9.10 Retry

只有：

Network Timeout

Retry。

不得：

Business Exception：

Retry。

---

# 第十章、Logging 規範（Logging Standard）

## 10.1 Logging 原則

所有 Log：

必須：

具有：

- 可追蹤性
- 可閱讀性
- 可維護性

不得：

大量：

Debug Log。

---

## 10.2 Spring Boot

統一：

SLF4J。

例如：

```java
private static final Logger log =
LoggerFactory.getLogger(UserService.class);
```

不得：

```java
System.out.println();
```

---

## 10.3 Flutter

統一：

Logger。

不得：

大量：

```dart
print();
```

Release：

不得：

Debug Print。

---

## 10.4 Log Level

| Level | 使用時機 |
|--------|----------|
| TRACE | 詳細追蹤（一般不啟用） |
| DEBUG | 開發除錯 |
| INFO | 正常流程 |
| WARN | 非預期但可繼續 |
| ERROR | 系統錯誤 |

不得：

全部：

INFO。

---

## 10.5 必須記錄

至少：

- Login
- Logout
- Register
- API Error
- Permission Denied
- Token Expired
- Database Exception

---

## 10.6 禁止記錄

不得：

Log：

- Password
- JWT
- Refresh Token
- API Key
- Secret
- Personal Information

---

## 10.7 Log Format

建議：

```text
Time

Level

Class

Method

Message
```

例如：

```text
2026-06-30 12:30:00

INFO

UserService

login()

User login success.
```

---

## 10.8 Production

正式環境：

Debug：

關閉。

Error：

保留。

---

## 10.9 Exception Log

Exception：

必須：

完整：

Stack Trace。

但：

Client：

不得：

看到：

Stack Trace。

---

## 10.10 Audit Log

建議：

記錄：

- Login
- Logout
- Password Change
- Permission Change
- Role Change

方便：

Audit。

---

# 第十一章、Testing 規範（Testing Standard）

## 11.1 基本原則

所有功能：

必須：

測試。

不得：

跳過。

---

## 11.2 Backend Test

至少：

- Unit Test
- Service Test
- Controller Test

大型功能：

增加：

Integration Test。

---

## 11.3 Flutter Test

至少：

- Unit Test
- Widget Test
- Provider Test

重要功能：

增加：

Integration Test。

---

## 11.4 API Test

所有 API：

至少測試：

- Success
- Validation
- Unauthorized
- Forbidden
- Not Found
- Conflict
- Exception

---

## 11.5 Database Test

若涉及：

Database：

應測試：

- CRUD
- Transaction
- Constraint
- Index

---

## 11.6 Coverage

建議：

Backend：

80%+

Flutter：

70%+

非強制。

---

## 11.7 Mock

單元測試：

應使用：

Mock。

避免：

直接：

連線：

正式 Database。

---

## 11.8 Test Data

測試資料：

不得：

使用：

正式資料。

應：

建立：

Fake Data。

---

## 11.9 Regression Test

修正 Bug：

應新增：

Regression Test。

避免：

再次發生。

---

## 11.10 AI 回報

完成 Task：

AI 必須回報：

- 測試方式
- 測試項目
- 測試結果

不得回答：

```text
理論上可行

應該沒問題

未測試
```

若因環境限制無法測試：

必須：

明確說明：

原因。

# 第十二章、Dependency 管理規範（Dependency Management）

## 12.1 基本原則

本專案所有第三方套件：

必須：

- 穩定
- 持續維護
- 官方文件完整
- License 可商業使用

不得：

使用：

- 已停止維護
- 無官方文件
- 不明來源

套件。

---

## 12.2 新增第三方套件

AI：

不得：

自行新增。

新增前：

必須提出：

- 套件名稱
- 用途
- 官方網站
- License
- 是否已有替代方案
- 對專案影響

等待使用者確認。

---

## 12.3 Flutter Dependency

統一管理：

```text
pubspec.yaml
```

不得：

同一功能：

使用：

多個套件。

例如：

不得同時：

```text
dio

http
```

---

## 12.4 Backend Dependency

統一：

```text
pom.xml
```

不得：

重複：

功能相同：

Library。

---

## 12.5 Version

Dependency：

使用：

穩定版本。

避免：

Alpha

Beta

RC

除非：

使用者要求。

---

## 12.6 Upgrade

更新：

Dependency：

必須：

評估：

- Breaking Change
- Migration
- 相容性
- 安全性

不得：

直接升級：

最新版。

---

# 第十三章、Performance 規範（Performance Standard）

## 13.1 基本原則

程式：

應：

- 快速
- 穩定
- 易維護

避免：

過早最佳化（Premature Optimization）。

---

## 13.2 Flutter

避免：

- 大量 rebuild
- 不必要 setState
- 重複建立 Widget

建議：

- const Widget
- Lazy Loading
- Pagination
- Image Cache

---

## 13.3 Backend

避免：

- N+1 Query
- Full Table Scan
- 大量 Join
- 重複 Query

大型查詢：

使用：

Pagination。

---

## 13.4 API

避免：

Response：

過大。

建議：

Compression。

Pagination。

---

## 13.5 Database

Index：

建立：

常用：

搜尋欄位。

避免：

無限制：

Order By。

---

## 13.6 Memory

避免：

Memory Leak。

避免：

大量：

Static Object。

---

## 13.7 Network

避免：

重複：

API。

建議：

Cache。

Retry。

Timeout。

---

# 第十四章、Code Review Checklist

所有 Pull Request：

至少檢查：

---

## Architecture

☐ 是否符合 Architecture

☐ 是否跨 Layer

---

## Coding Style

☐ 命名一致

☐ 無 Duplicate Code

☐ 無 Hard Code

☐ 無 Magic Number

---

## API

☐ RESTful

☐ DTO

☐ Validation

---

## Database

☐ Migration

☐ Index

☐ Foreign Key

---

## Security

☐ JWT

☐ Password Hash

☐ 權限

☐ Input Validation

---

## Exception

☐ Exception Handling

☐ Log

☐ Error Response

---

## Testing

☐ Unit Test

☐ Widget Test

☐ API Test

---

## Documentation

☐ CHANGE_LOG

☐ CHANGE_HISTORY

☐ API_SPEC

☐ DATABASE_SPEC

☐ PROJECT_SPEC

---

# 第十五章、AI Coding Checklist

AI 完成程式前：

必須確認：

---

## Compile

☐ Compile Success

---

## Test

☐ Test Success

---

## Security

☐ 無 Password

☐ 無 Secret

☐ 無 API Key

---

## Git

☐ CHANGE_LOG 更新

☐ CHANGE_HISTORY 更新

Git 操作：

請依：

```text
GIT_RULE.md
```

---

## Documentation

☐ 文件同步

---

## Review

☐ 無 TODO

☐ 無 FIXME

☐ 無 Dead Code

☐ 無 Unused Import

☐ 無 Unused Variable

---

## Output

AI 必須回報：

- 修改內容
- 修改檔案
- 新增檔案
- 測試方式
- 待確認事項

格式：

依：

```text
AGENTS.md
```

---

# 文件資訊

| 項目 | 內容 |
|------|------|
| 文件名稱 | CODING_STANDARD.md |
| 版本 | v1.0 |
| 專案 | 貘nsters |
| 維護者 | WeiChun Lin |
| 適用 | 所有 AI Coding Agent 與 Repository 開發者 |
| 最後更新 | 2026-06-30 |

---

# 文件關聯

本文件：

規範：

> **程式如何撰寫**

相關文件：

| 文件 | 職責 |
|------|------|
| AGENTS.md | AI 工作流程與規範 |
| GIT_RULE.md | Git Flow、Commit、Branch、PR |
| PROJECT_SPEC.md | 專案需求 |
| DATABASE_SPEC.md | Database 設計 |
| API_SPEC.md | API 規格 |
| UI_SPEC.md | UI 規格 |
| TASKS.md | 開發任務 |

---

# Coding Standard 原則

所有 AI Coding Agent：

- 不得自行增加需求。
- 不得自行修改需求。
- 不得自行修改 API。
- 不得自行修改 Database。
- 不得自行新增第三方套件。
- 不得自行偏離本 Coding Standard。

若文件未定義：

AI 必須：

停止。

提出問題。

等待使用者確認。

不得自行推測。
