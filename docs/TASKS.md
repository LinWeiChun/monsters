
---

## 插隊任務：Penpot MCP Web 註冊頁精準修正

- [x] 確認 Penpot MCP 目前選取 `Account / Web / 03 Register / 註冊` board（1440 x 900）。
- [x] 依 Web board 修正 Flutter 註冊頁雙欄、表單位置、欄位寬度、規則卡與完成註冊按鈕。
- [x] 顏色維持集中於 `frontend/lib/theme/app_colors.dart`。
- [x] 更新註冊頁 widget test，補上 Web 註冊頁文字驗證。
- [x] 執行 `flutter analyze --no-pub` 與 `flutter test --no-pub test/register_page_test.dart`。
- [x] 更新 UI_SPEC、CHANGE_LOG、CHANGE_HISTORY。# TASKS.md

# 貘nsters AI 開發任務清單

AI 必須依照本清單順序開發。每完成一項任務，需確認可編譯、可執行、可測試。

每個任務完成時，AI 需回報：

- 是否參考 `system_data/`
- 參考了哪些功能、流程或檔案
- 哪些舊寫法未沿用
- 是否有發現需要更新的正式文件

---

## 插隊任務：Profile／Annoyance Penpot 同步與 Web 右側留白修正（2026-07-18）

- [x] TODO：檢查 Profile、Annoyance 舊系統參考流程、正式規格、Penpot Web／Mobile 畫板與現有 Flutter 實作。
- [x] IN PROGRESS：以 Flutter 內建 `showDatePicker` 完成生日選擇、加入登出確認，並將 Home／Profile 外層改為滿寬 flow layout。
- [x] REVIEW：依 Penpot Annoyance Flow 重整 Mobile／Tablet／Desktop 介面，補齊 390 至 1920px widget tests，並同步修改 Penpot Profile Web／Mobile 畫板。
- [x] DONE：Flutter Analyze 與 Home／Profile／Annoyance 36 項測試通過；API／Database 無異動，文件與 Log 同步完成。

---

## 插隊任務：PR #59／#60 合併衝突處理（2026-07-18）

- [x] TODO：確認 `fix/auth-token-refresh` 與已合併 `develop` 的衝突檔案及兩側功能範圍。
- [x] IN PROGRESS：合併 Web-first RWD、Profile Token Refresh、測試、Task 與 Log 內容。
- [x] REVIEW：清除所有 conflict marker，完成 Flutter Analyze、115 項完整測試、Web build 與 Backend test／build。
- [x] DONE：保留兩側功能與歷史紀錄，準備提交並推送 `fix/auth-token-refresh` 供 PR #60 再次檢查。

---

## 插隊任務：Profile Token Refresh 修正（2026-07-18）

- [x] TODO：確認 Profile 401 並定位 30 天本地 session 與 1 小時 access token 的期限落差。
- [x] IN PROGRESS：新增 refresh API、refresh token rotation、30 天有效期與舊 token revocation。
- [x] REVIEW：串接 Flutter 啟動換發、並行 401 單一 refresh、原 request 單次重試與失效回登入。
- [x] DONE：Backend 完整測試、Flutter Analyze／完整測試通過，API／Database／UI／Decision／Log 同步完成。

---

## 插隊任務：Web-first RWD 共用版型（2026-07-18）

- [x] TODO：盤點 Splash、Login、Register、Home、Profile 的 Penpot 實作與固定／相對定位狀況。
- [x] IN PROGRESS：建立 Mobile／Tablet／Desktop 共用 breakpoint 與 Responsive shell，將 Web 主版面改為 flow layout。
- [x] REVIEW：修正 Home 在 900、950、1024px 的負 padding／overflow，並補齊 390 至 1920px viewport 與動態 resize 測試。
- [x] DONE：將前端開發設定明確改為 Web-first、保留 Android／iOS 相容，完成 Analyze、完整 Test、Web build、文件與 Log 同步。

---

## 插隊任務：登入帳號或 Email 驗證修正

- [x] 比對 `bec7bcf` 與 `0b3d265` 的登入欄位及後端查詢行為（DONE）
- [x] 修正 LoginRequest 將 Account 誤判為非法 Email 的驗證限制（REVIEW：保留 `email` request key，相容既有前端）
- [x] 補齊 Account / Email 登入測試（DONE：登入相關後端測試與後端完整測試通過）
- [x] 同步 API、UI 規格與 Log（DONE）

---

## 插隊任務：Penpot MCP 登入畫面排版同步

- [x] 使用 Penpot MCP 讀取指定畫面設計（DONE：已讀取 Web `Account / Web / 02 Login / 登入` 與 APP `Account / Mobile / 02 Login / 登入`）
- [x] 比對 Flutter 現有登入頁與 Penpot 排版差異（DONE：已確認桌面雙欄、手機 390x844、色票與圖片差異）
- [x] 依 Penpot 設計調整登入頁排版（REVIEW：本次僅登入頁，未直接修改其他 APP 畫面）
- [x] 執行 Flutter Analyze 與 Login Page Test（DONE：`flutter analyze`、`flutter test test/login_page_test.dart` 通過；Web 視覺驗證待使用者啟動 Chrome 流程確認）
- [x] 同步 UI 規格與 Log（DONE）

---

## 插隊任務：Penpot MCP 註冊畫面排版同步

- [x] 檢查 Penpot MCP 指定 Account & Access 畫面狀態（DONE：目前 selection 為空，註冊頁以已取得的 Account & Access 視覺系統與登入頁規格延伸）
- [x] 比對 Flutter 現有註冊頁與 Account & Access 排版差異（DONE：已確認舊版置中表單、舊 logo 路徑與未使用 Penpot 版型）
- [x] 依 Account & Access 視覺系統調整註冊頁排版（REVIEW：本次僅註冊頁）
- [x] 執行 Flutter Analyze 與 Register Page Test（DONE：`flutter analyze --no-pub`、`flutter test --no-pub test/register_page_test.dart` 通過）
- [x] 同步 UI 規格與 Log（DONE）

---
## Phase 0：專案初始化

- [x] 建立 Monorepo 結構（DONE）
- [x] 建立 Flutter 專案（DONE）
- [x] 建立 Spring Boot 專案（DONE）
- [x] 建立 MySQL 連線設定（DONE）
- [x] 建立 Docker Compose（MySQL + Backend）（DONE）
- [x] 建立 README 執行說明（DONE）
- [x] 建立並確認 `system_data/` 目錄（DONE）
- [x] 整理舊系統參考程式與素材（DONE）
- [x] 確認 `system_data/` 不包含金鑰、憑證、build artifact 或不必要雜檔（DONE）
- [x] 建立舊系統功能與新版模組的初步對照（DONE）

---

## Phase 1：共用基礎建設

- [x] 檢查 `system_data/` 中舊共用元件、API Client、錯誤處理與基礎設定寫法（DONE）
- [x] 整理可參考的共用模式並轉換為新版架構（DONE）

### 後端

- [x] 建立統一 API Response（DONE）
- [x] 建立全域 Exception Handler（DONE）
- [x] 建立 Base Entity（DONE）
- [x] 建立 CORS 設定（DONE）
- [x] 建立 Security / JWT 基礎設定（DONE）

### 前端

- [x] 建立 Dio Client（DONE）
- [x] 建立 API Error Handler（DONE）
- [x] 建立 go_router（DONE）
- [x] 建立 Theme（DONE）
- [x] 建立 Loading / Error / Empty 共用元件（DONE）

---

## Phase 2：會員與個人資料

- [x] 檢查 `system_data/` 中舊會員、登入、個人資料與密碼鎖相關寫法（DONE）
- [x] 整理可參考的流程與欄位（DONE）
- [x] 依新版 API、Database、Coding Standard 重新實作（DONE）

- [x] 註冊 API（DONE）
- [x] 登入 API（DONE）
- [x] Google 登入 API（DONE）
- [x] 忘記密碼 API（DONE）
- [x] 登出 API（DONE）
- [x] 查詢個人資料 API（DONE）
- [x] 修改個人資料 API（DONE）
- [x] 更改頭貼 API（DONE）
- [x] 密碼鎖 API（DONE）
- [x] Flutter 登入頁（DONE）
- [x] 正式啟用帳號欄位（DONE）
- [x] Flutter 30 天登入狀態保存（DONE）
- [x] Flutter Google 登入（DONE）
- [x] Flutter Web Google 登入固定本機 port（DONE）
- [x] Flutter 註冊頁（DONE）
- [x] Flutter 個人資料頁（DONE）
- [x] Flutter 密碼鎖頁（DONE）
- [x] 測試（DONE）

---

## Phase 3：煩惱功能

- [x] 檢查 `system_data/` 中舊煩惱、聊天室、心情繪圖、分數與分享流程（DONE：PR #24 已合併至 `feature/phase3`）
- [x] 整理可參考的業務邏輯與 UI 互動（DONE：PR #26 已合併至 `feature/phase3`；已核准 D1-A、D2-A、D3-A、D4-A、D5-B、D6-A、D7-A、D8-A）
- [x] 依新版 Entry 架構與 API 規格重新實作（DONE：Phase 3 整合驗證通過，PR #40、#41、#42 已合併至 `feature/phase3`）

- [x] 建立 annoyance_type（DONE：PR #27 已合併至 `feature/phase3`）
- [x] 建立 entry_media 圖片 / 錄音 / 影片 / 心情圖與 R2 上傳流程（DONE：PR #28 已合併至 `feature/phase3`）
- [x] 建立 annoyance Entity / DTO / Repository / Service / Controller（DONE：PR #29 已合併至 `feature/phase3`）
- [x] 新增煩惱 API（DONE：PR #30 已合併至 `feature/phase3`）
- [x] 重構 Backend package 為 `com.monsters.<layer>.<module>`（DONE：PR #31 已合併至 `feature/phase3`）
- [x] 查詢煩惱 API（DONE：PR #32 已合併至 `feature/phase3`）
- [x] 修改煩惱 API（DONE：PR #33 已合併至 `feature/phase3`）
- [x] 解決煩惱 API（DONE：PR #34 已合併至 `feature/phase3`）
- [x] 分享 / 取消分享煩惱 API（DONE：PR #34 已合併至 `feature/phase3`）
- [x] Flutter 新增煩惱聊天室（DONE：PR #35 已合併至 `feature/phase3`）
- [x] Flutter 文字 / 圖片 / 錄音 / 影片選取與預覽（DONE：PR #36 已合併至 `feature/phase3`）
- [x] Flutter 畫心情功能（DONE：PR #37 已合併至 `feature/phase3`）
- [x] Flutter 煩惱分數選擇（DONE：PR #38 已合併至 `feature/phase3`，review 驗證通過）
- [x] Flutter 煩惱分享選擇（DONE：PR #40 已合併至 `feature/phase3`）
- [x] Flutter 新增煩惱摘要送出與完成流程（DONE：PR #41 已合併至 `feature/phase3`）
- [x] 測試（DONE：Flutter full test 與 Backend Gradle test 通過）
- [x] Flutter 陪伴式首頁與 Web 獨立桌面版型（DONE：TASK-066 已合併至 `develop`，使用者確認可收尾）

---

## Phase 4：日記功能

- [ ] 檢查 `system_data/` 中舊日記、聊天室、心情分數與分享流程
- [ ] 整理可參考的欄位與 UI 流程
- [ ] 依新版 Entry 架構與 API 規格重新實作

- [ ] 建立 diary Entity / DTO / Repository / Service / Controller
- [ ] 新增日記 API
- [ ] 查詢日記 API
- [ ] 修改日記 API
- [ ] 分享 / 取消分享日記 API
- [ ] Flutter 新增日記聊天室
- [ ] Flutter 日記分數選擇
- [ ] 測試

---

## Phase 5：歷史記錄與心的軌跡

- [ ] 檢查 `system_data/` 中舊歷史記錄、心情分數與圖表呈現邏輯
- [ ] 整理可參考的查詢條件與圖表資料格式
- [ ] 依新版 API 與 UI 狀態處理重新實作

- [ ] 歷史記錄 API
- [ ] 心的軌跡 API
- [ ] 最近七次情緒分數查詢
- [ ] Flutter 歷史記錄頁
- [ ] Flutter 心的軌跡圖表
- [ ] 測試

---

## Phase 6：怪獸圖鑑

- [ ] 檢查 `system_data/` 中舊怪獸、怪獸群組、素材與換裝邏輯
- [ ] 整理可參考的資料欄位與素材路徑
- [ ] 依新版 Monster schema、API 與資產規格重新實作

- [ ] all_monster Entity / DTO / Repository / Service / Controller
- [ ] personal_monster Entity / DTO / Repository / Service / Controller
- [ ] 查詢全部怪獸 API
- [ ] 查詢我的怪獸 API
- [ ] 隨機取得怪獸 API
- [ ] 串接新增煩惱後的隨機怪獸獎勵與完成頁流程
- [ ] 更改怪獸造型 API
- [ ] Flutter 圖鑑頁
- [ ] Flutter 怪獸詳細頁
- [ ] 測試

---

## Phase 7：社群功能

- [ ] 檢查 `system_data/` 中舊社群、按愛心與留言流程
- [ ] 整理可參考的資料關聯與互動狀態
- [ ] 依新版共用 Entry 社群模型重新實作

- [ ] 社群文章查詢 API
- [ ] 煩惱社群按愛心 API
- [ ] 煩惱社群留言 API
- [ ] 日記社群按愛心 API
- [ ] 日記社群留言 API
- [ ] Flutter 社群頁
- [ ] Flutter 留言功能
- [ ] Flutter 愛心功能
- [ ] 測試

---

## Phase 8：互動區

- [ ] 檢查 `system_data/` 中舊解答之書、每日測驗、心理測驗、心理遊戲與紓壓方法
- [ ] 整理可參考的題目、選項、獎勵與外部連結邏輯
- [ ] 依新版 Interactive API 與 UI 規格重新實作

- [ ] 解答之書 API
- [ ] 每日測驗 API
- [ ] 每日測驗答題 API
- [ ] 每日測驗七次獎勵邏輯
- [ ] 深度心理測驗 API
- [ ] 心理小遊戲 API
- [ ] 紓壓方法 API
- [ ] Flutter 互動區首頁
- [ ] Flutter 解答之書頁
- [ ] Flutter 每日測驗頁
- [ ] Flutter 深度心理測驗頁
- [ ] Flutter 心理小遊戲頁
- [ ] Flutter 紓壓方法頁
- [ ] 測試

---

## Phase 9：使用說明、回饋與分享

- [ ] 檢查 `system_data/` 中舊使用說明、回饋與分享流程
- [ ] 整理可參考的文案、入口與資料欄位
- [ ] 依新版 UI 與 API 規格重新實作

- [ ] 使用說明頁
- [ ] 使用回饋 API
- [ ] 使用回饋頁
- [ ] 分享 App 功能
- [ ] 測試

---

## Phase 10：跨平台與部署

- [ ] 檢查 `system_data/` 中舊環境設定、平台差異與部署相關參考
- [ ] 排除舊系統金鑰、憑證、jar、metadata 與 build artifact
- [ ] 依新版環境變數、部署與 Git 規範重新整理

- [ ] App icon / Logo 三平台替換（REVIEW：本地產圖、登入 / 註冊 / 啟動畫面 logo 套用與文件同步完成；待測試與 GitHub push）
- [ ] Android 測試
- [ ] iOS 測試
- [ ] Web 測試
- [ ] RWD 調整
- [ ] 後端部署設定
- [ ] MySQL 正式環境設定
- [ ] 環境變數整理
- [ ] 最終整合測試

---

## 插隊任務：Penpot SplashPage Web / App 畫面（2026-07-16）

- [x] TODO：讀取 AGENTS.md、system_data、docs 與 Penpot SplashPage Web / App 畫板
- [x] IN PROGRESS：依 Penpot `Account / Web / 01 Splash / 啟動` 與 `Account / Mobile / 01 Splash / 啟動` 調整 Flutter SplashPage responsive layout
- [x] REVIEW：執行 `flutter analyze --no-pub` 與 `flutter test --no-pub test/splash_page_test.dart`
- [x] DONE：更新 `docs/UI_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`
---

## 插隊任務：SplashPage Session 失敗自動導向 LoginPage（2026-07-16）

- [x] TODO：確認 SplashPage 與 Penpot 差異為未登入後額外顯示登入 / 註冊按鈕
- [x] IN PROGRESS：調整 `restoreSession()` false 時直接導向 `login` route
- [x] REVIEW：更新 SplashPage widget tests 並執行 analyze / test
- [x] DONE：更新 `docs/UI_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`
---

## 插隊任務：SplashPage 精準修正至 Penpot Page（2026-07-16）

- [x] TODO：重新讀取 Penpot Splash Web / Mobile shape 與內部座標
- [x] IN PROGRESS：修正 logo fill、文字對齊、status card 圓角與 status 內部元素座標
- [x] REVIEW：補強 SplashPage widget tests，驗證 status dot / text / hint 座標
- [x] DONE：執行 analyze / test 並同步文件與 Log
---

## 插隊任務：Penpot HomePage Web / App 畫面（2026-07-16）

- [x] TODO：讀取 Penpot `Web / Companion Home` 與 `Mobile / Companion Home` 節點資料
- [x] IN PROGRESS：重寫 Flutter `HomePage` 為 Penpot Web / Mobile responsive canvas
- [x] REVIEW：執行 `flutter analyze --no-pub`、`flutter test --no-pub test/home_page_test.dart` 與 Home 路由指定測試
- [x] DONE：更新 `docs/UI_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`
---

## 插隊任務：Penpot ProfilePage Web / App 對齊與 HomePage 滿版修正（2026-07-16）

- [x] TODO：依 AGENTS.md 檢查文件、Task 狀態、`system_data/` 舊個人資料與首頁參考程式，並確認本次不異動 API / Database。
- [x] IN PROGRESS：依 Penpot `Account / Web / 06 Profile / 個人資料` 與 `Account / Mobile / 06 Profile / 個人資料` 改寫 Profile responsive canvas，並將 HomePage `WEB / Web / Companion Home` canvas 改為滿版縮放。
- [x] REVIEW：執行 `flutter analyze --no-pub`、`flutter test --no-pub test/profile_page_test.dart`、`flutter test --no-pub test/home_page_test.dart`。
- [x] DONE：更新 `docs/UI_SPEC.md`、`docs/TASKS.md`、`log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`。
