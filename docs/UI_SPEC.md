# UI_SPEC.md

# 貘nsters Flutter UI 規格

## 一、平台

本專案 UI 使用 Flutter 實作，需支援：

- Android
- iOS
- Web

手機版優先，Web 版需以 Responsive Layout 呈現。

## 二、主要頁面

### 2.1 初始頁面

用途：進入 App 時顯示 Logo 或品牌視覺。

操作：

- 前往登入頁面
- 判斷是否已登入

### 2.2 登入頁面

功能：

- Email / 密碼登入
- Google 登入
- 前往註冊
- 前往忘記密碼

### 2.3 註冊頁面

功能：

- 輸入 Email
- 輸入密碼
- 確認密碼
- 輸入暱稱
- 完成註冊

### 2.4 首次 Google 登入設定個人資料

功能：

- 設定暱稱
- 設定基本個人資料

### 2.5 主頁面

功能：

- 顯示目前怪獸
- 底部導覽列
- 中央加號新增煩惱或日記

導覽：

- 互動區
- 歷史記錄
- 新增
- 社群
- 圖鑑

### 2.6 抽屜選單

功能：

- 個人資料
- 更改頭貼
- 編輯個人資料
- 設定 / 更改密碼鎖
- 使用說明
- 使用回饋
- 分享 App
- 登出

### 2.7 新增煩惱聊天室

流程：

1. 怪獸引導對話
2. 選擇煩惱類別
3. 選擇文字、錄音、照片或影片
4. 輸入內容
5. 畫心情
6. 記錄煩惱分數
7. 選擇是否分享
8. 顯示獎勵頁面

### 2.8 新增日記聊天室

流程：

1. 怪獸引導對話
2. 選擇記錄方式
3. 輸入內容
4. 畫心情
5. 記錄心情分數
6. 選擇是否分享
7. 顯示獎勵頁面

### 2.9 歷史記錄頁面

功能：

- 顯示煩惱與日記列表
- 查看詳細內容
- 修改分享狀態
- 將煩惱設為已解決
- 顯示煩惱解決動畫
- 前往心的軌跡圖表

### 2.10 心的軌跡頁面

功能：

- 顯示最近七次心情分數
- 折線圖呈現情緒變化

### 2.11 社群頁面

功能：

- 查看已分享的煩惱與日記
- 按愛心
- 取消愛心
- 查看留言
- 新增留言

### 2.12 圖鑑頁面

功能：

- 顯示所有怪獸
- 區分已取得與未取得
- 查看怪獸詳細資料
- 更改怪獸造型

### 2.13 互動區頁面

入口：

- 解答之書
- 每日測驗
- 深度心理測驗
- 心理小遊戲
- 紓壓方法

### 2.14 解答之書頁面

功能：

- 使用者心中想著問題
- 點擊取得解答
- 顯示隨機解答

### 2.15 每日測驗頁面

功能：

- 顯示每日題目
- 選擇答案
- 顯示回答正確 / 錯誤頁面
- 正確時累積獎勵進度
- 累積七次可獲得怪獸造型

### 2.16 深度心理測驗頁面

功能：

- 內嵌 Youtube 影片或測驗內容
- 送出答案
- 顯示分析結果與建議

### 2.17 心理小遊戲頁面

功能：

- 顯示外部趣味測驗清單
- 點擊後開啟外部網站

### 2.18 紓壓方法頁面

功能：

- 顯示紓壓方法列表
- 查看詳細資料

## 三、Responsive Web 規範

Web 版規則：

- 最大內容寬度建議 480px 至 720px。
- 桌面寬螢幕時置中顯示主要 App 區塊。
- 不得讓聊天泡泡、卡片與按鈕過度拉伸。
- Web 不支援的手機功能需提供替代提示。

## 四、共用元件

建議建立：

- `AppScaffold`
- `PrimaryButton`
- `MonsterAvatar`
- `ChatBubble`
- `MoodScoreSelector`
- `MoodDrawingCanvas`
- `CommunityPostCard`
- `MonsterCard`
- `LoadingView`
- `ErrorView`
- `EmptyView`

## 舊系統 UI 參考與調整原則

`system_data/` 內的舊 Flutter 程式僅作為畫面流程、互動方式與視覺語彙參考，不直接沿用舊版頁面、路由、全域狀態或 Widget 實作。新版 UI 仍需依照本專案 Flutter 架構，使用 Riverpod、Dio、go_router 與共用 Widget。

### 舊 UI 參考檢查表

AI 或開發者參考 `system_data/` 舊 UI 時，應檢查以下項目：

- 舊畫面的使用者目的
- 使用者進入此畫面的路徑
- 主要操作按鈕
- 表單欄位
- 驗證邏輯
- 成功狀態
- 錯誤狀態
- 空資料狀態
- Loading 狀態
- 是否有可重用素材
- 是否需改為新版共用元件

可參考：

- 使用者流程
- 畫面資訊層級
- 怪獸視覺語彙
- 互動方式
- 圖片或動畫素材

不得直接沿用：

- 舊 Widget 結構
- 舊 Router 寫法
- 舊全域狀態
- 舊 API 呼叫方式
- 舊硬編碼尺寸
- 舊未抽共用元件的重複 UI

### `system_data/` UI 參考紀錄格式

| 項目 | 說明 |
|---|---|
| 舊系統參考位置 | `system_data/...` |
| 可參考內容 | 使用者流程 / 視覺語彙 / 素材 / 互動方式 |
| 不可沿用內容 | 舊 Widget 結構 / 舊 Router / 舊全域狀態 / 舊 API 呼叫 |
| 新版調整方式 | 依 Riverpod、go_router、共用 Widget 與 Theme 重新設計 |
| 是否需更新正式規格 | 是 / 否 |

可保留的 UI 方向：

| 舊系統觀察 | 新版調整 |
|---|---|
| 暖黃色背景、棕色主色、白色卡片或內容區塊 | 可整理成 `ThemeData` 色票，不在頁面中硬編碼色碼。 |
| 首頁顯示目前怪獸，並提供新增煩惱、歷史紀錄、互動、社群與設定入口 | 新版首頁維持怪獸與主要功能入口，但改用 `AppScaffold`、go_router 與共用導航元件。 |
| 右側 Drawer 提供個人資料、密碼鎖、使用說明、意見回饋、分享 App、登出 | 新版可保留抽屜功能項目，但登入狀態、登出與分享行為需由 Provider 與 Service 管理。 |
| 煩惱與日記採聊天式建立流程，支援文字、圖片、音訊、心情繪圖與怪獸回應 | 新版可保留聊天式體驗，拆成 `ChatBubble`、`MoodScoreSelector`、`MoodDrawingCanvas`、媒體選擇器等共用元件。 |
| 社群頁以分頁或篩選切換煩惱、日記等貼文類型，支援留言與按讚 | 新版社群需以 API 回傳的 `postId` 與分頁資料驅動，避免前端直接組合資料來源。 |
| 歷史紀錄頁提供煩惱、日記與心情軌跡入口 | 新版維持歷史清單與心情軌跡，但需支援空狀態、錯誤狀態與載入狀態。 |
| 怪獸手冊、怪獸詳情、個人怪獸與換裝 | 新版歸入怪獸模組，怪獸素材由 API 或資產設定提供，不直接依賴舊路徑。 |
| 答案書、每日測驗、心理測驗、心理遊戲、舒壓方式 | 新版歸入互動模組，依 `Interactive API` 拆分頁面與資料模型。 |

不得沿用的舊 UI 實作：

- 不使用全域變數保存登入者、目前頁面或流程狀態。
- 不以 `Navigator.push` 分散在頁面中管理主要路由；新版主要路由統一交由 `go_router`。
- 不在頁面內直接呼叫 API 或 SharedPreferences；需透過 Provider、Repository、Service。
- 不在每個頁面硬編碼顏色、字級、圓角與間距；需集中於 Theme 與共用樣式。
- 不保留過長 Page Widget；聊天、卡片、表單、抽屜項目與狀態畫面需拆成可測試共用元件。
- `system_data` 可保留舊系統圖片與動畫素材作為參考；若要正式納入新版資產，仍需另行整理授權、命名與資產規格。

## Flutter Login Page 實作規範

登入頁位置：

- `frontend/lib/pages/login_page.dart`

登入頁支援：

- Email / 密碼輸入與前端必填驗證
- 呼叫 `POST /api/auth/login`
- Loading 狀態
- API 錯誤訊息呈現
- 登入成功後導向 `home` route
- 前往註冊頁
- 忘記密碼入口提示
- Google 登入入口提示

登入頁資料流程：

```text
LoginPage
↓
AuthController
↓
AuthRepository
↓
ApiClient
↓
REST API
```

實作檔案：

| 類型 | 檔案 |
|---|---|
| Page | `frontend/lib/pages/login_page.dart` |
| Provider | `frontend/lib/providers/auth_provider.dart` |
| Repository | `frontend/lib/repositories/auth_repository.dart` |
| Model | `frontend/lib/models/auth_user.dart`、`frontend/lib/models/auth_user.g.dart`、`frontend/lib/models/login_result.dart`、`frontend/lib/models/login_result.g.dart` |

規則：

- 登入頁不得直接呼叫 Dio。
- 登入頁不得直接保存 JWT、Refresh Token 或密碼至 SharedPreferences。
- Access Token 僅由 `ApiClient.setAccessToken()` 暫存於目前執行階段。`AuthUser` 與 `LoginResult` 必須使用 `json_serializable` 產生 JSON mapping。
- Google Sign-In SDK 尚未導入前，不得假造 Google ID Token 或沿用舊系統空密碼登入流程。

## Flutter Register Page 實作規範

註冊頁位置：

- `frontend/lib/pages/register_page.dart`

註冊頁支援：

- Email 輸入與格式驗證
- 暱稱輸入與長度驗證
- 密碼輸入、確認密碼與一致性驗證
- 呼叫 `POST /api/auth/register`
- Loading 狀態
- API 錯誤訊息呈現
- 註冊成功後導向 `login` route
- 前往登入頁

註冊頁資料流程：

```text
RegisterPage
↓
AuthController
↓
AuthRepository
↓
ApiClient
↓
REST API
```

實作檔案：

| 類型 | 檔案 |
|---|---|
| Page | `frontend/lib/pages/register_page.dart` |
| Provider | `frontend/lib/providers/auth_provider.dart` |
| Repository | `frontend/lib/repositories/auth_repository.dart` |
| Model | `frontend/lib/models/register_result.dart` |

規則：

- 註冊頁不得直接呼叫 Dio。
- 註冊頁不得保存密碼或 token 至 SharedPreferences。
- 註冊成功不自動登入；使用者需回登入頁登入取得 token。
## Flutter Router 基礎規範

前端路由統一使用 go_router，入口必須使用 `MaterialApp.router`。

路由設定位置：

- `frontend/lib/routes/app_router.dart`
- `frontend/lib/routes/app_routes.dart`

目前基礎路由：

| Path | Name | Page | 用途 |
|---|---|---|---|
| `/` | `splash` | `SplashPage` | App 初始頁 |
| `/home` | `home` | `HomePage` | 首頁容器 |
| `/login` | `login` | `LoginPage` | 登入頁容器 |
| `/register` | `register` | `RegisterPage` | 註冊頁容器 |

頁面不得直接使用 `Navigator.push`。頁面切換應使用 go_router 的 `context.goNamed()` 或集中路由設定。
## Flutter Theme 基礎規範

前端視覺樣式統一使用 `ThemeData`，入口由 `MaterialApp.router` 套用 light / dark theme 與 `ThemeMode.system`。

Theme 設定位置：

- `frontend/lib/theme/app_theme.dart`
- `frontend/lib/theme/app_colors.dart`
- `frontend/lib/theme/app_spacing.dart`

目前 Theme 規範：

| 類別 | 檔案 | 用途 |
|---|---|---|
| AppTheme | `app_theme.dart` | 建立 light / dark `ThemeData` |
| AppColors | `app_colors.dart` | 集中管理色票與 seed color |
| AppSpacing / AppRadius | `app_spacing.dart` | 集中管理間距與圓角 token |

頁面不得自行 hard code 共用顏色、字體、圓角與間距；應優先使用 `Theme.of(context)` 與 theme token。
## Flutter Common State Widgets

前端共用狀態元件位置：

- `frontend/lib/widgets/state/loading_view.dart`
- `frontend/lib/widgets/state/error_view.dart`
- `frontend/lib/widgets/state/empty_view.dart`

共用狀態元件：

| Widget | 用途 | 規範 |
|---|---|---|
| LoadingView | 資料載入中 | 顯示 progress indicator 與可選文字 |
| ErrorView | 錯誤狀態 | 顯示錯誤標題、訊息與可選重試按鈕 |
| EmptyView | 空資料狀態 | 顯示空狀態標題、訊息與可選操作按鈕 |

狀態元件只負責 UI 呈現，不得直接呼叫 API、Repository 或 Service。

頁面應將資料狀態轉換為：

- loading：使用 `LoadingView`
- error：使用 `ErrorView`
- empty：使用 `EmptyView`
- data：顯示實際內容

狀態元件必須使用 `Theme.of(context)` 與 `AppSpacing` / `AppRadius`，不得 hard code 共用顏色、間距或圓角。
