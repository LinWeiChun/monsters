# SYSTEM_DATA_REFERENCE.md

# system_data 參考資料盤點

確認日期：2026-07-03

本文件用於補齊 `docs/TASKS.md` 中先前尚未整理的 `system_data/` 相關任務，記錄舊系統資料範圍、可參考內容、不可沿用內容、初步安全檢查結果、舊功能與新版模組對照，以及共用模式轉換方向。

本次未修改、搬移、刪除或格式化 `system_data/` 內任何內容。

---

## 一、目錄確認

`system_data/` 已存在，並包含以下主要資料：

| 路徑 | 內容 | 用途 |
|---|---|---|
| `system_data/四技第111405組-貘nsters APP-系統手冊.pdf` | 舊系統手冊 | 需求、流程、資料表與畫面參考 |
| `system_data/四技第111405組-貘nsters APP-系統簡介.pdf` | 舊系統簡介 | 系統定位、功能模組與使用對象參考 |
| `system_data/back-end/` | 舊 Spring Boot 後端 | Controller、Service、DAO、Entity、舊素材檔案參考 |
| `system_data/front-end/monsters_front_end/` | 舊 Flutter 前端 | API 呼叫、Repository、Model、Page、UI 流程與素材參考 |

統計結果：

| 項目 | 數量 |
|---|---:|
| 檔案 | 661 |
| 目錄 | 137 |

主要檔案類型：

| 類型 | 數量 |
|---|---:|
| png | 306 |
| java | 107 |
| dart | 86 |
| gif | 81 |
| jpg | 12 |
| xml | 8 |
| pdf | 2 |

---

## 二、PDF 參考摘要

已讀取：

- `system_data/四技第111405組-貘nsters APP-系統手冊.pdf`
- `system_data/四技第111405組-貘nsters APP-系統簡介.pdf`

可參考內容：

- 系統概念：以食夢貘吃掉負面情緒為核心，提供情緒記錄、紓壓與陪伴感。
- 核心功能：煩惱、日記、畫心情、歷史記錄、心的軌跡、圖鑑、社群、解答之書、每日測驗、深度心理測驗、心理小遊戲、紓壓方法、密碼鎖。
- 使用對象：有煩惱需宣洩、想記錄日常心情、想透過互動區紓壓或測驗的使用者。
- 舊技術環境：Flutter、Dart、Java、Spring Boot、Gradle、MySQL。
- 舊資料表與舊 API 可協助理解欄位意義與流程，但不得直接視為新版規格。

正式文件比對：

- 舊系統功能方向與 `docs/PROJECT_SPEC.md`、`docs/UI_SPEC.md` 大致一致。
- 舊系統仍以舊資料表、舊 API path、舊 response 格式與舊 Flutter 架構呈現；新版必須以正式文件為準。

---

## 三、舊系統參考程式與素材整理

### 3.1 後端參考程式

主要位置：

- `system_data/back-end/src/main/java/com/example/demo/controller/`
- `system_data/back-end/src/main/java/com/example/demo/service/`
- `system_data/back-end/src/main/java/com/example/demo/dao/`
- `system_data/back-end/src/main/java/com/example/demo/entity/`
- `system_data/back-end/src/main/java/com/example/demo/bean/`

可參考內容：

- 舊功能模組切分：會員、煩惱、日記、歷史、怪獸、社群、互動、媒體。
- 舊欄位意義：例如會員資料、怪獸持有狀態、煩惱分類、心情分數、社群留言與按讚。
- 舊流程順序：註冊後建立預設怪獸、登入後回傳使用者資料、每日測驗累積獎勵等。
- 舊共用層次：Controller / Service / DAO / Entity / Bean 的分層方向。

不可沿用內容：

- 舊 `com.example.demo` package。
- 舊 HibernateTemplate DAO 寫法。
- 舊 `result` / `errorCode` / `message` response 格式。
- Controller 直接組 JSON tree 的寫法。
- `printStackTrace()` 與直接 `System.out.println()` 的錯誤處理。
- 舊 path，例如 `/member/login`、`/member/create`。
- 以 `account` 作為跨表關聯主鍵的做法。
- 舊設定檔中的資料庫連線資訊。

### 3.2 前端參考程式

主要位置：

- `system_data/front-end/monsters_front_end/lib/API/`
- `system_data/front-end/monsters_front_end/lib/repository/`
- `system_data/front-end/monsters_front_end/lib/model/`
- `system_data/front-end/monsters_front_end/lib/pages/`
- `system_data/front-end/monsters_front_end/assets/`

可參考內容：

- 舊登入、註冊、Google 登入、忘記密碼、個人資料、密碼鎖流程。
- 舊煩惱與日記聊天室的互動順序。
- 舊歷史紀錄、心的軌跡、社群、圖鑑與互動區入口。
- 怪獸圖片、GIF、頭像、心情點數圖與背景素材。

不可沿用內容：

- 頁面內直接使用 `http.Client` 呼叫 API。
- 前端全域變數保存登入者或流程狀態。
- 分散於頁面中的 `Navigator.push` 主要路由管理。
- 手動切割 response 字串再轉 JSON。
- 硬編碼 token、舊 domain、舊 path。
- 舊頁面內硬編碼顏色、間距與大量重複 UI。

---

## 四、初步安全與 artifact 檢查

未發現下列明顯不應保留的檔案或目錄：

- `.env`
- `.jar`
- `.war`
- `.class`
- `.apk`
- `.aab`
- `node_modules/`
- `build/`
- `.dart_tool/`
- `.gradle/`
- `target/`
- keystore / pem / key / p12 / crt 檔案

已發現需處理或確認的敏感資訊風險：

| 類型 | 位置 | 說明 |
|---|---|---|
| 舊資料庫連線設定 | `system_data/back-end/src/main/resources/application.yml` | 含舊 MySQL URL 與密碼 |
| Android 簽章密碼字串 | `system_data/front-end/monsters_front_end/android/app/build.gradle` | 含 `keyPassword`、`storePassword` |
| 硬編碼 accessToken | `system_data/front-end/monsters_front_end/lib/pages/drawer/user_Feedback.dart` | 含舊外部服務 token 字串 |
| 硬編碼 accessToken | `system_data/front-end/monsters_front_end/lib/pages/account/lock/forget_lock_auth.dart` | 含舊外部服務 token 字串 |
| 硬編碼 accessToken | `system_data/front-end/monsters_front_end/lib/pages/account/forgetPassword/forget_psw_auth.dart` | 含舊外部服務 token 字串 |
| 硬編碼 accessToken | `system_data/front-end/monsters_front_end/lib/pages/social.dart` | 含舊外部服務 token 字串 |

結論：

- `system_data/` 目前未發現明顯 build artifact。
- `system_data/` 目前仍包含疑似密碼與 token 字串，因此 `docs/TASKS.md` 中「確認 `system_data/` 不包含金鑰、憑證、build artifact 或不必要雜檔」不可標記 DONE。
- 後續需要使用者確認要如何處理舊參考程式中的敏感字串。

建議處理方案：

| 方案 | 優點 | 缺點 / 風險 |
|---|---|---|
| 方案 A：保留 `system_data/` 原始內容，將風險記錄於文件與工作報告 | 不破壞舊系統參考完整性 | Repository 仍保留疑似敏感字串，不符合清理任務完成條件 |
| 方案 B：在使用者明確同意後遮罩或移除敏感字串，保留檔案結構與流程 | 可完成安全清理任務 | 會修改舊參考程式，需要確認不影響後續參考 |
| 方案 C：將含敏感字串的舊設定與舊頁面移出版本控制，另以文件描述用途 | 最大幅度降低風險 | 會減少舊系統可追溯性，且需 Git 歷史與追蹤策略配合 |

---

## 五、舊功能與新版模組初步對照

| 舊系統位置 | 舊功能 | 新版模組 / 規格 |
|---|---|---|
| `MemberController`、`memberRepo.dart`、account pages | 註冊、登入、Google 登入、忘記密碼、個人資料、密碼鎖 | Phase 2 會員與個人資料；`Auth API`、`User API` |
| `AnnoyanceController`、`annoyanceRepo.dart`、`annoyanceChat.dart` | 新增/查詢/修改/分享/解決煩惱、煩惱聊天室 | Phase 3 煩惱功能；`Annoyance API`、Entry 架構 |
| `DiaryController`、`diaryRepo.dart`、`diaryChat.dart` | 新增/查詢/修改/分享日記、日記聊天室 | Phase 4 日記功能；Entry 架構 |
| `HistoryController`、`historyRepo.dart`、history pages | 歷史紀錄、心情分數、心的軌跡 | Phase 5 歷史記錄與心的軌跡 |
| `MonsterController`、`monsterRepo.dart`、manual/settings pages | 怪獸圖鑑、我的怪獸、換裝、素材 | Phase 6 怪獸圖鑑 |
| `SocialController`、`socialRepo.dart`、`social.dart` | 社群列表、留言、按愛心 | Phase 7 社群功能 |
| `InteractionController`、answerbook/dailyTest/mindGame repos | 解答之書、每日測驗、心理測驗、心理遊戲、紓壓方法 | Phase 8 互動區 |
| drawer pages | 使用說明、回饋、分享 App | Phase 9 使用說明、回饋與分享 |
| old config / platform folders | 舊環境設定與平台設定 | Phase 10 跨平台與部署 |

---

## 六、共用模式參考與新版轉換

### 6.1 後端共用模式

舊系統可參考：

- `BaseService` / `BaseServiceImplement`：呈現 Service 共用 CRUD 意圖。
- `BaseDAO` / `BaseDAOImplement`：呈現 DAO 共用存取意圖。
- `BaseViewService` / `BaseViewDAO`：呈現列表與查詢抽象。
- `BeanUtility`、`BeanWrapperUtility`、`VOWrapperUtility`：呈現 Bean / Entity 轉換需求。
- `DateUtils`：呈現日期處理需求。

新版轉換方式：

- 使用 Spring Data JPA Repository，避免沿用 HibernateTemplate DAO。
- Controller 只接 Request、呼叫 Service、回傳 `ApiResponse<T>`。
- Service 使用 constructor injection，集中商業邏輯與 transaction。
- DTO / Entity 轉換以明確 mapping 或局部 helper 處理，不直接搬舊 BeanUtility。
- 例外處理交由 `GlobalExceptionHandler`，不得 `printStackTrace()` 後吞錯。

### 6.2 前端共用模式

舊系統可參考：

- `lib/API/`：功能資料來源介面意圖。
- `lib/repository/`：每個模組集中 API 呼叫的意圖。
- `lib/model/`：每個模組的資料模型欄位。
- `pages/chat_items/`：聊天、錄音、繪圖等元件拆分方向。
- `assets/image/`：怪獸、心情點數、背景與動畫素材。

新版轉換方式：

- API 存取必須經由 `ApiClient`、Repository、Provider，不直接使用 `http.Client` 或 Dio。
- 錯誤處理統一轉為 `ApiException` / `ApiErrorType`。
- 路由統一使用 go_router，不在頁面中分散 `Navigator.push`。
- UI 狀態使用 Riverpod，不以全域變數保存登入狀態。
- 視覺樣式集中於 Theme 與共用元件。

---

## 七、會員與個人資料參考整理

已檢查：

- `system_data/back-end/src/main/java/com/example/demo/controller/MemberController.java`
- `system_data/back-end/src/main/java/com/example/demo/service/impl/PersonalInfoServiceImpl.java`
- `system_data/back-end/src/main/java/com/example/demo/entity/PersonalInfo.java`
- `system_data/front-end/monsters_front_end/lib/repository/memberRepo.dart`
- `system_data/front-end/monsters_front_end/lib/API/memberAPI.dart`
- `system_data/front-end/monsters_front_end/lib/pages/account/`
- `system_data/front-end/monsters_front_end/lib/pages/account/lock/`
- `system_data/front-end/monsters_front_end/lib/pages/drawer/drawer_personalInfo.dart`
- `system_data/front-end/monsters_front_end/lib/pages/drawer/edit_personalInfo.dart`

可參考流程：

- 註冊：檢查帳號 / email / 暱稱重複，建立使用者後建立預設怪獸。
- 登入：查詢使用者後以 `PasswordEncoder.matches` 比對密碼。
- Google 登入：前端使用 Google Sign-In，舊流程以 email 作為登入識別。
- 個人資料：查詢與修改暱稱、生日、email、頭像、密碼鎖狀態等欄位。
- 密碼鎖：四位數鎖定 App 入口，與登入密碼不同。

不可沿用內容：

- 舊系統以 `account` 作為主識別與跨表關聯。
- 舊登入 API 回傳舊個人資料欄位但不回傳 JWT。
- 舊 Google 登入以空密碼呼叫一般 login。
- 舊密碼鎖與使用者密碼欄位混在 `personal_info` 模型中。
- 舊前端直接寫 SharedPreferences 與全域變數管理登入狀態。

新版調整方式：

- 會員認證使用 `users`、`user_credentials`、`user_oauth_accounts`、`user_password_locks`。
- 註冊與登入已依新版 `Auth API` 實作。
- 後續 Google 登入應驗證 Google ID token，不得以空密碼登入。
- 後續個人資料 API 應以登入使用者身分查詢 `/api/users/me`。
- 密碼鎖必須以 BCrypt hash 儲存，不得明文保存。

---

## 八、TASKS 補齊狀態

本文件可支持完成：

- Phase 0：建立並確認 `system_data/` 目錄
- Phase 0：整理舊系統參考程式與素材
- Phase 0：建立舊系統功能與新版模組的初步對照
- Phase 1：檢查 `system_data/` 中舊共用元件、API Client、錯誤處理與基礎設定寫法
- Phase 1：整理可參考的共用模式並轉換為新版架構
- Phase 2：檢查 `system_data/` 中舊會員、登入、個人資料與密碼鎖相關寫法
- Phase 2：整理可參考的流程與欄位

本文件也確認以下任務尚不可完成：

- Phase 0：確認 `system_data/` 不包含金鑰、憑證、build artifact 或不必要雜檔

原因：目前已發現疑似舊資料庫密碼、Android 簽章密碼與 hardcoded accessToken。需使用者確認清理方案後才能完成。
