# TASKS.md

# 貘nsters AI 開發任務清單

AI 必須依照本清單順序開發。每完成一項任務，需確認可編譯、可執行、可測試。

---

## Phase 0：專案初始化

- [x] 建立 Monorepo 結構（DONE）
- [x] 建立 Flutter 專案（DONE）
- [x] 建立 Spring Boot 專案（DONE）
- [x] 建立 MySQL 連線設定（DONE）
- [x] 建立 Docker Compose（MySQL + Backend）（DONE）
- [x] 建立 README 執行說明（DONE）

---

## Phase 1：共用基礎建設

### 後端

- [x] 建立統一 API Response（DONE）
- [x] 建立全域 Exception Handler（DONE）
- [x] 建立 Base Entity（DONE）
- [x] 建立 CORS 設定（DONE）
- [ ] 建立 Security / JWT 基礎設定

### 前端

- [ ] 建立 Dio Client
- [ ] 建立 API Error Handler
- [ ] 建立 go_router
- [ ] 建立 Theme
- [ ] 建立 Loading / Error / Empty 共用元件

---

## Phase 2：會員與個人資料

- [ ] 註冊 API
- [ ] 登入 API
- [ ] Google 登入 API
- [ ] 忘記密碼 API
- [ ] 登出 API
- [ ] 查詢個人資料 API
- [ ] 修改個人資料 API
- [ ] 更改頭貼 API
- [ ] 密碼鎖 API
- [ ] Flutter 登入頁
- [ ] Flutter 註冊頁
- [ ] Flutter 個人資料頁
- [ ] Flutter 密碼鎖頁
- [ ] 測試

---

## Phase 3：煩惱功能

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

- [ ] 歷史記錄 API
- [ ] 心的軌跡 API
- [ ] 最近七次情緒分數查詢
- [ ] Flutter 歷史記錄頁
- [ ] Flutter 心的軌跡圖表
- [ ] 測試

---

## Phase 6：怪獸圖鑑

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

- [ ] 使用說明頁
- [ ] 使用回饋 API
- [ ] 使用回饋頁
- [ ] 分享 App 功能
- [ ] 測試

---

## Phase 10：跨平台與部署

- [ ] Android 測試
- [ ] iOS 測試
- [ ] Web 測試
- [ ] RWD 調整
- [ ] 後端部署設定
- [ ] MySQL 正式環境設定
- [ ] 環境變數整理
- [ ] 最終整合測試
