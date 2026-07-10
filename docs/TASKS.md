# TASKS.md

# 貘nsters AI 開發任務清單

AI 必須依照本清單順序開發。每完成一項任務，需確認可編譯、可執行、可測試。

每個任務完成時，AI 需回報：

- 是否參考 `system_data/`
- 參考了哪些功能、流程或檔案
- 哪些舊寫法未沿用
- 是否有發現需要更新的正式文件

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

- [ ] 檢查 `system_data/` 中舊煩惱、聊天室、心情繪圖、分數與分享流程
- [ ] 整理可參考的業務邏輯與 UI 互動
- [ ] 依新版 Entry 架構與 API 規格重新實作

- [ ] 建立 annoyance_type
- [ ] 建立 annoyance Entity / DTO / Repository / Service / Controller
- [ ] 新增煩惱 API
- [ ] 查詢煩惱 API
- [ ] 修改煩惱 API
- [ ] 解決煩惱 API
- [ ] 分享 / 取消分享煩惱 API
- [ ] Flutter 新增煩惱聊天室
- [ ] Flutter 畫心情功能
- [ ] Flutter 煩惱分數選擇
- [ ] 測試

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
