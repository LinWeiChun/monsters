# UI_SPEC.md

# 貘nsters Flutter UI 規格

## 一、平台

本專案 UI 使用 Flutter 實作，需支援：

- Android
- iOS
- Web

手機版優先，Web 版需以 Responsive Layout 呈現。

前端功能 Task 預設需以 Flutter 共用程式實作，並確認 Web、Android、iOS 三平台皆可使用。若功能涉及平台差異，例如檔案選取、通知、相機、外部連結或權限，必須在同一 Task 內補齊三平台處理或明確記錄平台限制與替代方案。

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

- 顯示目前怪獸與陪伴問候語
- 以「記下現在的心情」作為單一主要操作，進入新增煩惱聊天室
- 日記與歷史記錄在對應 Phase 完成前顯示「即將開放」且不可操作
- 手機版使用底部導覽列，個人資料、密碼鎖與登出收納於個人選單
- Web 桌面版使用固定左側導覽與雙欄內容，不直接放大手機版面

導覽：

- 互動區
- 歷史記錄
- 新增
- 社群
- 圖鑑

首頁以 900px 作為手機／桌面版型切換基準。手機內容最大寬度 560px；桌面主要內容最大寬度 1180px，怪獸陪伴區與操作區並列。設計來源為 Figma 檔案 [貘nsters 陪伴式首頁 UI - Mobile & Web](https://www.figma.com/design/bo3ooJWyoIThN9D7YqkY1x)。

首頁怪獸使用 Flutter 程式動畫，不修改或拆分原始圖片。進入首頁時播放有限次數的輕微呼吸與上下漂浮，點擊怪獸時播放彈跳、縮放及小幅擺動；動畫只作用於怪獸區，不得遮擋或移動主要操作。系統啟用「減少動態效果」時必須停止待機與點擊動畫，並維持靜態圖片與完整操作功能。

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
2. 以結構化選擇元件選擇煩惱類別
3. 選擇文字、錄音、照片或影片其中一種主要記錄方式
4. 輸入文字或選取一個主要媒體，顯示預覽、移除與重選操作
5. 選擇是否畫心情；選擇繪圖時最多附加一張心情圖
6. 以結構化元件選擇 1 至 5 分
7. 選擇是否分享，預設私人
8. 檢視摘要並送出；送出中禁止重複操作，失敗時保留草稿
9. 顯示建立完成頁面，可前往歷史記錄

互動採聊天外觀搭配 `AnnoyanceCategorySelector`、`RecordMethodSelector`、`MediaPreviewCard`、`MoodDrawingCanvas`、`MoodScoreSelector`、`ShareChoiceCard` 與 `AnnoyanceReviewCard`，不得以自由文字比對選項。狀態依 `intro → category → recordMethod → content → drawingDecision → drawing（optional）→ score → sharing → review → submitting → completed` 推進。

前後端媒體限制一致：圖片 jpeg/png/webp，最多 5 MB；錄音 mp4/aac/mpeg/wav，最多 10 MB 或 5 分鐘；影片 mp4/quicktime/webm，最多 50 MB 或 60 秒；心情圖 png/webp，最多 5 MB。Web、Android、iOS 的平台差異集中於媒體 Service／Adapter。

煩惱媒體存放於獨立的 private R2 bucket。Flutter 只能使用 API 回傳的 Backend download URL 並附帶 JWT 讀取，不得組合 R2 bucket URL 或保存 object key；錄音與影片播放器需支援 Backend 的 HTTP Range response。

Phase 3 完成頁不顯示假怪獸獎勵；真實獎勵與圖鑑導向於 Phase 6 串接。

聊天室入口使用 `/annoyances/new`，由首頁「新增煩惱」進入。聊天室基礎 Task 建立聊天泡泡、不可變草稿狀態、上一步／重新開始操作，以及 `intro → category → recordMethod → content` 的結構化推進；content 之後的媒體選取、繪圖、分數、分享、摘要與送出依後續 Phase 3 Task 接續同一狀態機，不得另建平行流程。

媒體內容 Task 在 `content` 步驟提供文字輸入、單一圖片或影片的相簿／相機來源、App 內 WAV 錄音，以及圖片、錄音、影片預覽。選取後需顯示檔名、MIME type、大小與可取得的長度，並提供移除及重新選擇；媒體處理集中於 `AnnoyanceMediaService` 與平台 Adapter。圖片只在通過 5 MB 限制後讀入預覽 bytes，錄音與影片保留 `XFile`，避免在草稿中長期複製大型檔案。Android 最低 SDK 依目前 Flutter 預設 24，iOS 必須宣告相簿、相機與麥克風用途；Web 不支援的相機來源需顯示可理解的失敗訊息並保留檔案選取替代操作。

畫心情 Task 在主要內容確認後顯示「想畫／先不用」結構化選項；選擇略過時直接進入分數步驟，選擇繪圖時顯示單一正方形畫布。`MoodDrawingCanvas` 使用正規化座標保存筆畫，提供六色畫筆、2 至 16 的線寬、橡皮擦、復原、清除、取消與完成操作；完成時以白色背景輸出固定 1024×1024 PNG，限制 5 MB，並在聊天紀錄顯示一張心情圖預覽後進入分數步驟。取消繪圖須返回是否繪圖選項，返回上一步或重新選擇主要內容時須清除未提交的繪圖草稿；心情圖不另存至相簿，後續由既有新增煩惱 multipart API 的 `drawingFile` 上傳。

煩惱分數 Task 使用 `MoodScoreSelector` 顯示視覺權重一致的 `1分`～`5分` 結構化按鈕，不以顏色、表情或文案綁定正負情緒語意。使用者點選後，草稿保存整數 `score` 並進入 `sharing` 步驟；僅接受 1 至 5，與既有 API `score` contract 及 Database `SCORE_1`～`SCORE_5` lookup 一致。從分享步驟返回時保留原分數並標示選取狀態以便修改；返回繪圖選擇或重新開始時清除分數。分享、摘要、送出與完成 UI 由後續 Task 接續同一狀態機。

煩惱分享 Task 使用 `ShareChoiceCard` 顯示「保持私人」與「分享到社群」兩個結構化選項，預設語意為私人，不使用無參數 toggle。使用者選擇後，草稿保存 boolean `isShared`，並進入 `review` 步驟；選擇「保持私人」對應既有 API `isShared = false`，選擇「分享到社群」對應 `isShared = true`。從摘要步驟返回分享步驟時保留原選擇並標示選取狀態；返回分數步驟、上游內容步驟或重新開始時清除分享選擇。

煩惱摘要送出 Task 使用 `AnnoyanceReviewCard` 顯示類別、記錄方式、主要內容、心情圖、分數與分享狀態。送出時由 `AnnoyanceRepository` 呼叫既有 `POST /api/annoyances` multipart contract，`request` 為 JSON part，依草稿內容附加 optional `contentFile` 與 `drawingFile`；送出中進入 `submitting` 狀態並禁止上一步與重複送出。成功後保存 `AnnoyanceResponse` 並顯示 `AnnoyanceCompletedCard`，Phase 3 僅呈現建立成功與分享狀態，不顯示假怪獸獎勵；失敗時返回 `review`、保留草稿並顯示 API 錯誤訊息。

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

- 表單、聊天室與單一內容流程最大內容寬度建議 480px 至 720px。
- 首頁等資訊架構頁在 900px 以上需使用 Web 專用桌面版型，可採固定側邊導覽與多欄內容。
- Web 專用版型不得直接放大或置中顯示完整手機畫面。
- 桌面主要內容需設定最大寬度並置中，避免卡片與文字隨視窗無限延伸。
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

- Account 或 Email / 密碼輸入與前端必填驗證
- 呼叫 `POST /api/auth/login`
- Loading 狀態
- API 錯誤訊息呈現
- 登入成功後導向 `home` route
- 前往註冊頁
- 忘記密碼入口提示
- Google 登入：Android / iOS 由 `google_sign_in` 觸發登入，Web 使用 `google_sign_in_web` 官方按鈕

登入頁 Penpot 對齊規格：

- 本次插隊任務僅調整登入頁，不同步修改註冊、首頁或其他已完成頁面。
- Web 參考 Penpot `PAGES WEB / Account & Access / Web` 的 `Account / Web / 02 Login / 登入`：左側品牌區為 `#FFFDD2`，右側表單區為 `#F7F1E8`，左側保留 logo、怪獸圖與歡迎文字，右側表單寬度 500px。
- App / Mobile 參考 Penpot `PAGES APP / Account & Access / Mobile` 的 `Account / Mobile / 02 Login / 登入`：390x844 畫板、左右 36px 邊距、logo 150x46、欄位與按鈕寬 318px、高 54px。
- 登入頁色票集中於 `frontend/lib/theme/app_colors.dart`，頁面不得直接宣告 `Color(0x...)` 作為設計色票。
- 登入頁圖片使用 `frontend/assets/images/title.png` 作為 logo、`frontend/assets/images/icon.png` 作為 Web 品牌區怪獸圖；Flutter asset 以 `assets/images/` 目錄註冊。
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
| Google Sign-In Service | `frontend/lib/services/google_sign_in_service.dart` |
| Web Google Sign-In Button | `frontend/lib/widgets/auth/google_sign_in_web_button.dart` |
| Session Store | `frontend/lib/repositories/auth_session_store.dart` |
| Model | `frontend/lib/models/auth_user.dart`、`frontend/lib/models/auth_user.g.dart`、`frontend/lib/models/login_result.dart`、`frontend/lib/models/login_result.g.dart` |

規則：

- 登入識別欄位顯示「帳號或 Email」；前端沿用 `email` request key，後端接受已註冊的 Account 或 Email，並在查詢前去除前後空白及轉為小寫。
- 登入頁不得直接呼叫 Dio。
- 登入頁不得直接保存 JWT、Refresh Token 或密碼至 SharedPreferences；登入狀態保存必須集中由 `AuthRepository` 與 `AuthSessionStore` 管理。
- 登入成功後，`AuthSessionStore` 保存 `LoginResult` 與最後開啟時間，讓 Web、Android、iOS 在未登出且 30 天內再次開啟時自動恢復登入。
- App 啟動時由 `SplashPage` 透過 `AuthController.restoreSession()` 判斷登入狀態；若本地 session 有效，必須先以 refresh token 換發新 Token、覆蓋舊 session，再套用新 access token 並導向 `home` route。
- 受保護 API 回傳 401 時，並行 request 必須共用單一 refresh request；換發成功後每個原 request 最多重試一次，refresh request 本身不得遞迴重試。
- 若 refresh token 無效／過期／已 rotation、最後開啟時間超過 30 天、session 格式無效或使用者登出，必須清除本地登入狀態並導向登入頁；暫時性網路錯誤只顯示連線錯誤並保留 session。
- 登出需呼叫 `AuthController.logout()`，由 Repository 呼叫登出 API、清除 `ApiClient` Authorization header 與本地 session。
- 密碼不得保存至 SharedPreferences。`AuthUser` 與 `LoginResult` 必須使用 `json_serializable` 產生 JSON mapping。
- Google 登入不得假造 Google ID Token、不得沿用舊系統空密碼登入流程、不得在前端自行驗證後傳入 Google 使用者資料。
- Google 登入成功後需呼叫 `POST /api/auth/google-login`，由後端驗證 Google ID Token 並回傳本系統 `LoginResult`。
- Web 版需使用 Google Identity Services 官方按鈕；Android / iOS 可使用共用 Flutter 按鈕觸發 Google SDK。
- Web 版 Google SDK 初始化只傳 `GOOGLE_CLIENT_ID`，不得傳 `serverClientId`，避免官方按鈕停留在 `Getting ready` 狀態。
- Web 本機測試需使用固定 origin `http://localhost:5050`，並透過 `frontend/tool/run_web_local.sh` 或 Windows `frontend/tool/run_web_local.ps1` 啟動，避免每次重啟隨機 port 造成 Google OAuth origin mismatch。
- Google 登入成功後必須沿用 `AuthSessionStore` 保存 30 天登入狀態；登出時需同時清除本地 session 並嘗試執行 Google SDK sign-out。

## Flutter Register Page 實作規範

註冊頁位置：

- `frontend/lib/pages/register_page.dart`

註冊頁支援：

- Email 輸入與格式驗證
- 帳號輸入與格式驗證
- 暱稱輸入與長度驗證
- 密碼輸入、確認密碼與一致性驗證
- 呼叫 `POST /api/auth/register`
- Loading 狀態
- API 錯誤訊息呈現
- 註冊成功後導向 `login` route
- 前往登入頁

註冊頁 Penpot 對齊規格：

- 本次插隊任務僅調整註冊頁，延續 `Account & Access` 登入頁已建立的 Web / Mobile 排版語彙。
- Web 版使用左側品牌區與右側表單區；品牌區使用 `title.png` 與 `icon.png`，表單最大寬度 500px。
- App / Mobile 版以 390px 寬畫面為基準，左右 36px 邊距，logo 150px，欄位與主要按鈕高 54px。
- 註冊頁色票集中於 `frontend/lib/theme/app_colors.dart`，頁面不得直接宣告 `Color(0x...)` 作為設計色票。
- 註冊成功不自動登入；成功後仍依規格導向登入頁。
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
- 帳號為必填，需英文開頭，只能包含英文、數字、底線，長度 4 到 50；送出前需轉為小寫。
## Flutter Profile Page 實作規範

個人資料頁位置：

- `frontend/lib/pages/profile_page.dart`

個人資料頁支援：

- 呼叫 `GET /api/users/me` 查詢目前登入使用者個人資料
- 顯示頭貼、暱稱、Email、舊帳號與生日
- 修改暱稱與生日
- 呼叫 `PUT /api/users/me` 儲存個人資料
- Loading 狀態
- API 錯誤訊息與重試
- 儲存成功提示
- 從首頁進入個人資料頁

個人資料頁資料流程：

```text
ProfilePage
↓
UserProfileController
↓
UserRepository
↓
ApiClient
↓
REST API
```

實作檔案：

| 類型 | 檔案 |
|---|---|
| Page | `frontend/lib/pages/profile_page.dart` |
| Provider | `frontend/lib/providers/user_profile_provider.dart` |
| Repository | `frontend/lib/repositories/user_repository.dart` |
| Model | `frontend/lib/models/user_profile.dart`、`frontend/lib/models/user_profile.g.dart` |

規則：

- 個人資料頁不得直接呼叫 Dio。
- 個人資料頁不得由前端傳入 user id 或 account 進行查詢或修改。
- `userName` 必填，最大長度 80。
- `birthday` 可為空；若填寫，格式需為 `yyyy-MM-dd`。
- 頭貼上傳涉及三平台檔案選取流程，需於後續更改頭貼 UI Task 定案檔案選取方案後實作。
## Flutter Password Lock Page 實作規範

密碼鎖頁位置：

- `frontend/lib/pages/password_lock_page.dart`

密碼鎖頁支援：

- 設定或更改四位數密碼鎖
- 呼叫 `PUT /api/users/me/password-lock`
- 驗證四位數密碼鎖
- 呼叫 `POST /api/users/me/password-lock/verify`
- 前端 4 位數字格式驗證
- 設定時需再次輸入確認
- Loading 狀態
- API 錯誤訊息呈現
- 設定成功與驗證成功提示
- 從首頁進入密碼鎖頁

密碼鎖頁資料流程：

```text
PasswordLockPage
↓
PasswordLockController
↓
UserRepository
↓
ApiClient
↓
REST API
```

實作檔案：

| 類型 | 檔案 |
|---|---|
| Page | `frontend/lib/pages/password_lock_page.dart` |
| Provider | `frontend/lib/providers/password_lock_provider.dart` |
| Repository | `frontend/lib/repositories/user_repository.dart` |
| Model | `frontend/lib/models/password_lock_status.dart`、`frontend/lib/models/password_lock_verification.dart` |

規則：

- 密碼鎖頁不得直接呼叫 Dio。
- 密碼鎖頁不得由前端傳入 user id 或 account。
- 密碼鎖固定為 4 位數字。
- 密碼鎖不得保存於 SharedPreferences 或其他前端本地儲存。
- 忘記密碼鎖流程尚未有正式 API，需於後續 API 定案後實作。
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
| `/profile` | `profile` | `ProfilePage` | 個人資料頁容器 |
| `/password-lock` | `passwordLock` | `PasswordLockPage` | 密碼鎖頁容器 |

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

Theme 色票需承接舊版暖黃色與棕色視覺語彙：

| Token | 色值 | 舊版來源 |
|---|---|---|
| `legacyBackgroundLight` / `lightBackground` | `#FFFED4` | `BackgroundColorLight` |
| `legacyBackgroundSoft` | `#FFED97` | `BackgroundColorSoft` |
| `legacyWarm` / `seed` | `#A0522D` | `BackgroundColorWarm` |
| `legacyWarmOpacity` | `#E6A0522D` | `BackgroundColorWarmOpacity` |

頁面不得自行 hard code 共用顏色、字體、圓角與間距；應優先使用 `Theme.of(context)` 與 theme token。
## Flutter App Icon / Logo 資產規範

三平台 App Icon 以根目錄 `icon/icon.png` 作為正式來源素材，產生 Android、iOS 與 Web 所需尺寸。品牌 Logo 以根目錄 `icon/標題.png` 作為正式來源素材，匯入 Flutter asset 後用於啟動畫面、登入頁與註冊頁。

App Icon 規範：

| 平台 | 產出位置 | 規範 |
|---|---|---|
| Android | `frontend/android/app/src/main/res/mipmap-*/ic_launcher.png` | 需替換所有 mipmap density 預設 Flutter 圖示 |
| iOS | `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png` | 需替換全部 `Contents.json` 宣告尺寸，1024 icon 不得含透明背景 |
| Web | `frontend/web/favicon.png`、`frontend/web/icons/*.png`、`frontend/web/manifest.json` | 需替換 favicon、PWA icon、maskable icon，manifest theme/background color 需對齊舊版暖黃色與棕色 |

Logo 規範：

| 用途 | 路徑 | 規則 |
|---|---|---|
| Flutter asset logo | `frontend/assets/images/app_logo.png` | 來源為 `icon/標題.png`，用於品牌露出頁面 |
| Flutter asset icon | `frontend/assets/images/app_icon.png` | 來源為 `icon/icon.png`，保留 1024px square 版本供 Flutter UI 或後續工具重用 |
| 啟動畫面 | `frontend/lib/pages/splash_page.dart` | 需顯示品牌 logo |
| 登入頁 | `frontend/lib/pages/login_page.dart` | 需顯示品牌 logo |
| 註冊頁 | `frontend/lib/pages/register_page.dart` | 需顯示品牌 logo |

產圖原則：

- 背景使用舊版主要背景色 `#FFFED4`。
- 主圖置中並保留安全邊界，避免 Android / iOS / Web 安裝圖示裁切主視覺。
- 不得保留 Flutter 預設藍色 icon 或 manifest theme color。
- 若來源圖尺寸不足或比例不適合，需重新產生可用平台圖示並於 Log 紀錄。
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

---

## 2026-07-16 Penpot Web Register Alignment

本次依 Penpot MCP 目前選取 board `Account / Web / 03 Register / 註冊` 修正 Web 註冊頁。

### Penpot Board

| 項目 | 規格 |
|---|---|
| Board | 1440 x 900 |
| Brand panel | x=0, y=0, w=620, h=900, `#FFFDD2` |
| Form area | x=620, y=0, w=820, h=900, `#F7F1E8` |
| Logo | x=54, y=42, w=160, h=50, `assets/images/title.png` |
| Monster | x=130, y=208, w=360, h=360, `assets/images/icon.png` |
| Form left | x=756 |
| Form width | 520 |
| Back link | x=756, y=46, text `‹  返回登入` |
| Heading | x=756, y=96, text `建立新帳號` |
| Subheading | x=756, y=138, text `註冊完成後，請使用新帳號登入。` |
| Fields | x=756, w=520, h=56; y=220 / 312 / 404 / 496 / 588 |
| Rule card | x=756, y=662, w=520, h=64, `#FFFDFC` |
| Submit button | x=756, y=758, w=520, h=56, text `完成註冊` |

### Implementation Notes

- Web 註冊頁維持 Flutter `RegisterPage -> AuthController -> AuthRepository -> ApiClient -> REST API` 流程。
- Web 版使用 620px brand panel 與 520px 表單寬度，在 1440px viewport 對齊 Penpot 座標。
- 顏色 token 必須集中於 `frontend/lib/theme/app_colors.dart`，Page 不得直接新增硬編碼 `Color(0x...)`。
- Mobile 註冊頁不屬於本次 Web 精準修正範圍，僅沿用共用文字與驗證邏輯。
---

## 2026-07-16 Penpot SplashPage Web / App Alignment

本次依 Penpot MCP 讀取 `Account & Access / Web` 與 `Account & Access / Mobile` 的 Splash 畫板，更新 Flutter `SplashPage` 的 Web / App responsive layout。

### Penpot Boards

| Target | Board | Size | Background |
|---|---|---:|---|
| Web | `Account / Web / 01 Splash / 啟動` | 1440 x 900 | `#FFFDD2` |
| App / Mobile | `Account / Mobile / 01 Splash / 啟動` | 390 x 844 | `#FFFDD2` |

### Web Layout

| Element | Position / Size | Note |
|---|---|---|
| Logo | x=570, y=120, w=300, h=92 | `assets/images/app_logo.png` |
| Halo | x=555, y=270, w=330, h=330 | `AppColors.splashHalo` |
| Monster | x=610, y=318, w=220, h=220 | `assets/images/icon.png` |
| Quote | x=500, y=642, w=390, h=36 | `把心裡的重量，先放在這裡。` |
| Status card | x=550, y=724, w=340, h=74 | 顯示登入狀態檢查與 30 天保存提示 |

### App / Mobile Layout

| Element | Position / Size | Note |
|---|---|---|
| Logo | x=92, y=94, w=206, h=64 | `assets/images/app_logo.png` |
| Monster | x=78, y=224, w=234, h=234 | `assets/images/icon.png` |
| Quote | x=68, y=496, w=270, h=24 | `把心裡的重量，先放在這裡。` |
| Status card | x=54, y=586, w=282, h=82 | 顯示登入狀態檢查與 30 天保存提示 |
| Brand note | x=79, y=774, w=162, h=15 | `貘nsters · 陪你整理每一種心情` |

### Implementation Notes

- `SplashPage` 保留 `AuthController.restoreSession()` 流程；有效 session 導向 `home`，無效 session 顯示登入 / 註冊行動。
- Splash 顏色集中於 `frontend/lib/theme/app_colors.dart` 的 `splash*` token，page 不直接宣告色碼。
- Web / App 尺寸以 `_SplashSpec` 分別記錄 Penpot 座標，並透過 `FittedBox` 支援不同螢幕比例縮放。
- Splash 導向仍使用 `go_router` 的 `context.goNamed()`；Flutter 不直接存取 Database 或 Auth storage。
### 2026-07-16 SplashPage Redirect Update

- `SplashPage` 僅在 `AuthController.restoreSession()` 檢查期間顯示 Penpot Splash 畫面。
- 若 session 有效，導向 `home` route。
- 若 session 無效、過期或格式錯誤，直接導向 `login` route，不在 Splash 畫面顯示登入 / 註冊按鈕。
- 此行為讓 Splash Web / App 畫面與 Penpot 靜態畫板一致；登入與註冊行動由 LoginPage / RegisterPage 負責。
### 2026-07-16 SplashPage Exact Penpot Correction

- SplashPage Web / Mobile 文字對齊依 Penpot 設為 left，不再使用 center。
- Logo image fill 依 Penpot rectangle fill 呈現，Flutter 改用 `BoxFit.fill`；Monster 保持 `BoxFit.contain`。
- Status card 依 Penpot 移除圓角，維持 `#FFFDFC` fill 與 `#E7C7B5` stroke。
- Status dot、status text、status hint 改為絕對座標定位：
  - Web：dot `(576,753) 16x16`、text `(610,746) 123x17`、hint `(610,770) 118x14`。
  - Mobile：dot `(76,614) 16x16`、text `(108,608) 123x17`、hint `(108,634) 118x14`。
- Widget test 已新增上述內部元素座標驗證，避免再次只檢查外層 card 而漏掉 Penpot 差異。
---

## 2026-07-16 Penpot HomePage Web / App Alignment

本次依 Penpot MCP 讀取 `Web / Companion Home` 與 `Mobile / Companion Home`，重寫 Flutter `HomePage` 的 Web / App responsive layout。

### Penpot Boards

| Target | Board | Size | Background |
|---|---|---:|---|
| Web | `Web / Companion Home` | 1440 x 900 | `#FFFED4` |
| App / Mobile | `Mobile / Companion Home` | 390 x 844 | `#FFFED4` |

### Web Layout

| Element | Relative Layout | Note |
|---|---|---|
| Page shell | `Column` with fixed-height top nav and flexible content area | Web does not use fixed 1440 x 900 canvas scaling |
| Content width | centered `ConstrainedBox`, max width 1200 | horizontal padding derived from viewport width |
| Header | vertical `Column` | title and subtitle use natural text flow |
| Main content | `Row` with flex 19:10 | left companion / collection column, right action column |
| Companion hero | responsive `Row` inside hero panel | monster and greeting card share available width proportionally |
| Action cards | `Column` with responsive gaps | primary / diary / history / interaction use reusable tile widget |
| Collection panel | `Column` + `Row` chips | chip spacing is based on layout flow, not absolute x/y offsets |
| Navbar | `Row` with `Spacer` | menu, CTA, notification and profile buttons align by flex flow |
### App / Mobile Layout

| Element | Position / Size | Note |
|---|---|---|
| App bar | x=0, y=0, w=390, h=72 | white |
| Logo | x=20, y=12, w=96, h=48 | `assets/images/app_logo.png` |
| Account button | x=338, y=18, w=38, h=38 | routes to profile |
| Companion hero | x=16, y=92, w=358, h=294 | `#D9F1F2` |
| Monster | x=119, y=102, w=152, h=152 | animated monster key preserved |
| Greeting card | x=40, y=250, w=310, h=118 | white card |
| Collection panel | x=16, y=402, w=358, h=118 | monster collection summary |
| Primary action | x=16, y=536, w=358, h=54 | routes to `annoyanceChat` |
| Quick actions | x=16 / 138 / 260, y=606, w=114, h=104 | diary / history / interaction |
| Bottom navigation | x=0, y=774, w=390, h=70 | custom Penpot nav, not Material NavigationBar |

### Implementation Notes

- `HomePage` Web 版改為 `LayoutBuilder + Column / Row / Expanded / ConstrainedBox` 的相對 layout；Mobile 版仍保留 390 x 844 Penpot canvas。
- Home 色彩集中於 `frontend/lib/theme/app_colors.dart` 的 `home*` token，page 不直接宣告色碼。
- 主要行動 `homeAnnoyanceChatButton` 保留既有路由：`context.goNamed(AppRoute.annoyanceChat)`。
- 帳號按鈕導向 `profile`；尚未開放的 diary / history / collection / interaction / bottom nav 入口顯示即將開放訊息。
- `homeAnimatedMonster`、`homeAnimatedMonsterIdle`、`homeAnimatedMonsterReacting` 測試 key 保留，降低既有測試與互動行為破壞。
---

## 2026-07-16 Penpot ProfilePage Web / App Alignment

本次依 Penpot `Account / Web / 06 Profile / 個人資料` 與 `Account / Mobile / 06 Profile / 個人資料` 調整 Flutter `ProfilePage`，並保留既有 `UserProfileController -> UserRepository -> ApiClient -> REST API` 流程。

### Penpot Boards

| Target | Board | Size | Background |
|---|---|---:|---|
| Web | `Account / Web / 06 Profile / 個人資料` | 1440 x 900 | `#F7F1E8` |
| App / Mobile | `Account / Mobile / 06 Profile / 個人資料` | 390 x 844 | `#FFFDD2` |

### Implementation Notes

- Profile Web / Mobile 採 `Stack + FittedBox(BoxFit.cover)` Penpot canvas，保持畫面滿版並以 top center 對齊。
- Web 保留 1440x900 Profile canvas、上方導覽列、資料卡、avatar、基本資料欄位、唯讀 Email / 帳號欄位與儲存狀態卡。
- Mobile 保留 390x844 Profile canvas、App bar、avatar、暱稱 / Email / 帳號 / 生日欄位、儲存狀態卡與底部導覽列。
- 可編輯欄位維持 `profileUserNameField`、`profileBirthdayField`、`profileSaveButton` 測試 key 與原本驗證規則。
- Profile 顏色 token 集中於 `frontend/lib/theme/app_colors.dart` 的 `profile*` token，Page 不直接宣告色碼。
- Penpot canvas widgets 拆至 `frontend/lib/widgets/profile/profile_penpot_canvas.dart`，`ProfilePage` 僅保留狀態、驗證與提交流程。

## 2026-07-16 HomePage Full-Bleed Correction

- `HomePage` 仍使用 `WEB / Web / Companion Home` 與 `Mobile / Companion Home` 規格。
- Web / Mobile canvas 外層縮放由 `BoxFit.contain` 改為 `BoxFit.cover`，避免寬螢幕部署畫面出現非滿版留白。
- 修正僅影響縮放與裁切策略，不改變 HomePage 的 Penpot 元件座標、導覽、互動 key 或 API 行為。
## 2026-07-16 HomePage Web Companion Home Refinement

- 本次以 Penpot MCP 選取的 `WEB / Web / Companion Home` 為準，修正 Web HomePage 不應套用舊版 `Web / Companion Home` 近似版型的問題。
- Web HomePage 改為相對 layout：內容最大寬度、水平 padding、區塊 gap 由 viewport 推導，避免使用固定 x/y 座標排列。
- Web 版新增 Penpot navbar、右上 CTA、通知圓鈕與 profile 圓鈕；profile 入口導向 `profile` route，尚未開放入口維持 snackbar placeholder。
- Web collection panel 改為 flow layout，保留 7 個怪獸 chip 與 `+1` more chip。
- 本次僅調整 Web HomePage；Mobile HomePage 規格與座標未變更。
