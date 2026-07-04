# DECISIONS.md

# 貘nsters 技術決策紀錄

本文件記錄已定案與待確認的跨文件決策。

## 一、已定案

| 項目 | 決策 |
|------|------|
| 前端框架 | Flutter |
| 後端框架 | Spring Boot |
| 後端 Java 版本 | JDK 18 |
| 後端 Build Tool | Gradle |
| Database | MySQL |
| API 架構 | REST API |
| 本機容器環境 | Docker Compose |
| `system_data/` 定位 | `system_data/` 僅作為舊系統參考來源，不作為新版規格來源 |
| 舊程式使用方式 | 可參考流程、資料結構、UI 行為與業務邏輯，但不得直接複製舊程式 |
| 規格衝突處理 | 當 `system_data/` 與正式文件衝突時，以正式文件為準 |
| AI 回報要求 | AI 若參考 `system_data/`，需於工作報告中說明參考內容與轉換方式 |
| Google 登入 Client ID | 後端透過 `GOOGLE_CLIENT_IDS` 設定允許的 Google Client ID，可用逗號支援 Web / App 多組 Client ID |
| 忘記密碼流程 | 後端產生 15 分鐘短效 reset token，資料庫只保存 token hash；目前回傳 resetToken 供開發串接，正式寄信服務待後續定案 |
| 檔案上傳儲存方式 | 使用 Cloudflare R2 雲端儲存；連線設定與環境變數於檔案上傳 Task 實作時補齊 |
| Web 管理後台 | 需要建立 Web 管理後台；實作範圍與權限模型於後續管理後台 Task 細化 |
| 正式寄信服務 | 忘記密碼正式環境使用 SMTP 寄送 reset link |
| 舊資料庫相容性 | 不直接沿用舊錯字表名；以新版 schema 為準，必要時以 mapping 文件將舊資料概念結合至新版資料庫 |
| 舊系統素材沿用 | 可沿用舊系統圖片或影片素材；不得沿用舊程式邏輯，素材授權與命名需於資產整理 Task 檢查 |
| 舊資料庫 migration | 不建立舊資料庫自動 migration；舊資料僅作欄位 mapping 與新版資料模型參考 |
| 舊 API 對照表 | 需要建立完整舊 API 對照表，比對 path、method、request、response 與錯誤情境 |
| 舊 Flutter UI 對照清單 | 需要建立舊 Flutter UI 畫面對照清單，比對流程、元件、狀態與素材 |

## 二、已核准套件與工具

### Frontend

| 類型 | 套件 / 工具 |
|------|-------------|
| State Management | Riverpod |
| HTTP Client | Dio |
| JSON | json_serializable |
| Routing | go_router |
| Local Storage | SharedPreferences |

### Backend

| 類型 | 套件 / 工具 |
|------|-------------|
| Framework | Spring Boot |
| ORM | Spring Data JPA |
| Validation | Jakarta Validation |
| Security | Spring Security + JWT |
| Build Tool | Gradle |

## 三、待細化事項

| 項目 | 目前狀態 |
|------|----------|
| R2 連線設定 | 待細化：Account ID、Bucket、Access Key、Secret Key、公開 URL / CDN 網域與環境變數命名 |
| SMTP 設定 | 待細化：SMTP host、port、TLS、帳號、寄件者、reset link base URL 與正式環境 secret 管理方式 |
| Web 管理後台 | 待細化：管理者角色、登入方式、可管理資料範圍、稽核 log 與前端路由 |
| 舊 API 對照表 | 待建立：需依 `system_data/` 舊後端與舊前端呼叫整理完整對照 |
| 舊 Flutter UI 對照清單 | 待建立：需依 `system_data/` 舊 Flutter 頁面整理流程、元件、狀態與素材 |
| 舊系統素材清單 | 待建立：需確認可沿用圖片 / 影片清單、檔名規則、資產目錄與授權備註 |
