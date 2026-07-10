# SYSTEM_DATA_REFERENCE.md

# system_data 參考資料盤點

初次確認日期：2026-07-03

Phase 3 煩惱功能複核日期：2026-07-10

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

已發現並完成遮罩的敏感資訊風險：

| 類型 | 位置 | 說明 |
|---|---|---|
| 舊資料庫連線設定 | `system_data/back-end/src/main/resources/application.yml` | 已將舊 DB host、DB name、username、password 改為 placeholder |
| 舊資料庫名稱常數 | `system_data/back-end/src/main/java/com/example/demo/config/DatabaseConfig.java` | 已將舊 DB name 改為 placeholder |
| Android 簽章密碼字串 | `system_data/front-end/monsters_front_end/android/app/build.gradle` | 已將 `keyPassword`、`storePassword` 改為 placeholder |
| 硬編碼 accessToken | `system_data/front-end/monsters_front_end/lib/pages/drawer/user_Feedback.dart` | 已改為 placeholder |
| 硬編碼 accessToken | `system_data/front-end/monsters_front_end/lib/pages/account/lock/forget_lock_auth.dart` | 已改為 placeholder |
| 硬編碼 accessToken | `system_data/front-end/monsters_front_end/lib/pages/account/forgetPassword/forget_psw_auth.dart` | 已改為 placeholder |
| 硬編碼 accessToken | `system_data/front-end/monsters_front_end/lib/pages/social.dart` | 已改為 placeholder |

結論：

- `system_data/` 目前未發現明顯 build artifact。
- 已依使用者指定方案遮罩敏感字串，保留舊系統參考檔案與流程脈絡。
- 重新掃描後，未再找到原始舊 DB host、舊 DB name、舊 DB password、Android signing password 或 hardcoded accessToken。
- `docs/TASKS.md` 中「確認 `system_data/` 不包含金鑰、憑證、build artifact 或不必要雜檔」可標記 DONE。

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

本文件也支持完成：

- Phase 0：確認 `system_data/` 不包含金鑰、憑證、build artifact 或不必要雜檔

處理方式：已依使用者指定的「遮罩敏感字串」方案完成清理，並重新掃描確認原始敏感值未殘留。

---

## 九、Phase 3 煩惱功能舊系統檢查

### 9.1 檢查範圍

本次僅檢查與記錄舊系統行為，不將舊程式直接視為新版規格，且未修改 `system_data/` 內任何內容。

| 類型 | 檢查來源 | 重點 |
|---|---|---|
| 系統手冊 | `system_data/四技第111405組-貘nsters APP-系統手冊.pdf` 第 121 至 124 頁 | 煩惱聊天室、類別、記錄方式、畫心情、分數、分享與獲獎畫面 |
| 系統簡介 | `system_data/四技第111405組-貘nsters APP-系統簡介.pdf` | 煩惱記錄、畫心情、歷史記錄、心的軌跡與社群的功能定位 |
| 舊 Flutter 聊天室 | `lib/pages/annoyanceChat.dart` | 流程狀態、輸入驗證、媒體選擇、新增請求與怪獸獲獎 |
| 舊 Flutter 畫板 | `lib/pages/chat_items/drawing_colors.dart` | 回復、清空、橡皮擦、畫筆粗細、畫筆顏色、畫布顏色與 PNG 輸出 |
| 舊 Flutter 歷史畫面 | `lib/pages/history/history_annoyanceChat.dart` | 已解決狀態、分享／取消分享與煩惱詳細內容 |
| 舊 Flutter 資料層 | `lib/model/annoyanceModel.dart`、`lib/repository/annoyanceRepo.dart`、`lib/API/annoyanceAPI.dart` | 舊欄位、舊 API path、舊 Response 與錯誤處理 |
| 舊 Spring Boot | `AnnoyanceController`、`AnnoyanceServiceImpl`、`AnnoyanceDAOImpl`、`Annoyance`、`AnnoyanceType` | 新增、查詢、修改、分享條件、解決條件與舊資料欄位 |
| 舊歷史／社群後端 | `HistoryController`、`SocialController` | 清單排序、分享資料只讀取 `share = 1`、社群顯示欄位 |
| 舊素材 | `assets/image/mood/moodPoint_1.png` 至 `moodPoint_5.png`、`assets/image/present.png` | 1 至 5 分情緒圖示與怪獸獲獎視覺 |

> 上表中 `lib/` 皆相對於 `system_data/front-end/monsters_front_end/`；Java class 皆相對於 `system_data/back-end/src/main/java/com/example/demo/`。

### 9.2 舊煩惱建立流程

| 順序 | 舊系統行為 | 舊資料表現 |
|---:|---|---|
| 1 | 依當下時段顯示問候語，並詢問煩惱類別 | 僅為前端聊天狀態 |
| 2 | 從「課業、事業、愛情、友情、親情、其他」六類中擇一 | 舊 `type` 數字欄位；前端實作使用 0 至 5 |
| 3 | 選擇文字或媒體來記錄煩惱 | 文字放入 `content`；圖片與錄音以 Base64 放入舊欄位 |
| 4 | 詢問是否畫心情；選擇「是」則開啟畫板 | 完成圖以 PNG 輸出，再轉 Base64 存入舊 `mood` |
| 5 | 以五張表情圖選擇 1 至 5 分，1 為最低煩惱程度、5 為最高 | 存入舊 `index` 欄位 |
| 6 | 詢問是否分享至社群 | 存入舊 `share` 整數 0／1 |
| 7 | 後端建立煩惱並抽取怪獸；若是新怪獸則顯示獲獎視窗 | 舊 Response 額外回傳 `newMonster` 與 `newMonsterGroup` |
| 8 | 完成後可前往歷史記錄 | 歷史畫面可將 `solve` 改為 1，並隨時切換 `share` |

舊版媒體來源在程式中包含相機拍照、相簿圖片、錄影、相簿影片與錄音；但錄影、影片匯入與錄音選單在舊 `annoyanceChat.dart` 中被註解，不能視為當時可穩定使用的完成功能。

### 9.3 可參考的業務意圖與 UI 語彙

- 聊天式引導是煩惱建立流程的核心體驗，每次只要求一項輸入。
- 煩惱類別與是／否問題有明確的可用選項，輸入不符時重複提示當前問題。
- 畫心情是可選步驟；舊畫板提供復原、清空、橡皮擦、畫筆粗細、畫筆顏色、畫布顏色與完成輸出。
- 分數使用 1 至 5 的連續視覺，由綠色開心逐步轉為紅色難過，可作為新版 `MoodScoreSelector` 的視覺參考。
- 分享預設應由使用者明確選擇，並可於歷史記錄中隨時取消或重新分享。
- 將煩惱設為已解決時，舊版會顯示怪獸「吃掉煩惱」的短動畫，可參考其療癒性質，但不直接搬移實作。
- 新增煩惱後的怪獸獲獎提供「查看圖鑑」與「關閉」兩種後續操作。

### 9.4 舊資料欄位與新版概念對照

| 舊欄位／概念 | 舊用途 | 新版概念 | 轉換注意事項 |
|---|---|---|---|
| `account` | 使用者關聯 | `entries.user_id` | 必須來自已驗證 JWT，不得由 Client 傳入 |
| `type` | 煩惱類別數字 | `entries.annoyance_type_id` → `annoyance_types` | 舊前端使用 0 至 5，舊 enum 卻使用 1 至 6，不得直接沿用 ID |
| `content` | 文字或媒體代替文案 | `entries.content` | 僅保存文字，不以「圖片煩惱」等假內容取代媒體 |
| `image_content` / `audio_content` | Base64 媒體 | `entry_media.media_url` | 媒體應存雲端，MySQL 只存 URL |
| `mood` | 「否」或心情圖 Base64 | `entry_media` 的 drawing 資產 | 繪圖與情緒分數必須分開，不再共用字串欄位 |
| `index` | 1 至 5 分 | `entries.mood_id` → `moods.score` | 新版使用 lookup table，API 不應信任任意數字 |
| `monster_id` | 新增時抽取的怪獸 | `entries.monster_id` | 舊版有權重抽取與分組邏輯，需由後續正式規格定案 |
| `solve` | 0／1 解決狀態 | `entries.is_solved` | 僅 ANNOYANCE 可用，新增時預設 false |
| `share` | 0／1 分享狀態 | `entries.is_shared` | 新增、分享與取消分享由後端驗證 owner |
| `time` | 建立時間 | `entries.occurred_at` 與共用 audit 欄位 | 使用者記錄時間與系統建立時間不應混用 |

### 9.5 不可沿用的舊實作

- `annoyanceChat.dart` 使用單一大型 StatefulWidget、整數 `chatRound`、非型別化 `userAnswers` 與 `setState`，不符新版 Riverpod 與可測試狀態機規範。
- 舊程式在 `build()` 內觸發聊天狀態與 `setState()`，容易重複執行或造成 build 期間狀態異動。
- 分享驗證使用 `text != "是" || text != "否"`，條件永遠為 true，不能沿用。
- 錄音方法的局部 `audioFile` 遮蔽同名欄位，導致建立請求未實際夾帶錄音資料。
- 媒體以同步 `readAsBytesSync()` 後轉 Base64 放進 JSON，不符新版雲端檔案儲存與 URL 欄位設計。
- 舊 Repository 硬編碼網域、使用 `http.Client`、吞掉例外後回傳 null，不符 `ApiClient` 與 `ApiException` 規範。
- 舊 API 由 Client 傳入 `account`，並以 path 參數作 owner 條件，無法取代後端的 JWT owner 驗證。
- 舊 Controller 直接組 ObjectNode、使用 `System.out.println`、吞掉 Exception 並無論成敗回傳 201，不符新版 DTO、`ApiResponse<T>` 與 `GlobalExceptionHandler`。
- 舊建立請求的 null 驗證在 null 時仍呼叫 `.isEmpty()`，存在 NullPointerException 風險。
- 舊類別前端索引為 0 至 5，Java enum 卻定義 1 至 6，說明舊資料 ID 不具可靠的跨層一致性。
- 舊程式寫死本機 Windows 檔案路徑與怪獸 ID，不可搬入新版。

### 9.6 與正式規格的差異與後續 DoR

以下項目不影響本次「檢查舊系統」Task 完成，但在進入實作 Task 前必須定案：

1. `PROJECT_SPEC.md` 與 `UI_SPEC.md` 說明煩惱可以使用影片，但 `DATABASE_SPEC.md` 與 `01_schema.sql` 的 `entry_media.media_type` 只允許 `image`、`audio`、`drawing`。
2. `API_SPEC.md` 目前僅列出 Annoyance endpoint，尚未定義 Request／Response DTO、媒體上傳方式、分頁、owner 驗證、驗證錯誤與怪獸獲獎回應。
3. 新版 `annoyance_types` 與 `moods` 已有 schema，但目前沒有 seed data，六種類別與 1 至 5 分的 code／label／display order 尚未定案。
4. 舊版建立煩惱會同步抽取怪獸，但新版「怪獸抽取是否隸屬新增煩惱 transaction」、權重、重複怪獸處理與 Response 尚未定義。
5. 心情圖、內容圖片、錄音與影片的數量、大小、MIME type、display order 與 R2 key prefix 尚未定義。

下一個 Phase 3 Task「整理可參考的業務邏輯與 UI 互動」應以本節為輸入，產出可供使用者確認的選項與新版行為建議；在正式文件完成後才能開始 Annoyance 實作。

### 9.7 本 Task 結論

- 已完成舊煩惱、聊天室、心情繪圖、分數、分享、解決狀態與怪獸獲獎流程的源碼與手冊交叉檢查。
- 舊系統可提供流程意圖、視覺語彙、六種煩惱類別與 1 至 5 分的參考。
- 舊系統存在架構、資安、資料模型與實作錯誤，只能重新設計，不得複製。
- 本 Task 沒有新增或修改 API、Database、UI 行為與第三方套件；上述正式規格缺口留待後續 Task 定案。
