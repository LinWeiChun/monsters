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
| 登出流程 | 使用 JWT revocation；登出時保存 access token hash，前端提供 refresh token 時一併保存其 hash 與原 token 過期時間，JWT 驗證與 refresh rotation 需拒絕已撤銷 token |
| Token Refresh | Refresh token 預設有效 30 天並採 rotation；啟動恢復 session 先換發新 Token，受保護 API 的並行 401 共用單一 refresh request，舊 refresh token hash 寫入 `revoked_tokens` 後不可重用 |
| Profile 生日選擇器 | 採方案 A：使用 Flutter 內建 `showDatePicker`，不新增第三方套件；選擇範圍為 1900-01-01 至當日，送出格式維持 `yyyy-MM-dd` |
| 檔案上傳儲存方式 | 使用 Cloudflare R2 S3-compatible API；public avatar 與 private entry media 使用不同 bucket，環境變數包含 `R2_ACCOUNT_ID`、`R2_ACCESS_KEY_ID`、`R2_SECRET_ACCESS_KEY`、`R2_BUCKET`、`R2_PUBLIC_BASE_URL`、`R2_ENTRY_MEDIA_BUCKET` 與各類媒體限制 |
| Web 管理後台 | 需要建立 Web 管理後台；實作範圍與權限模型於後續管理後台 Task 細化 |
| 正式寄信服務 | 忘記密碼正式環境使用 SMTP 寄送 reset link |
| 舊資料庫相容性 | 不直接沿用舊錯字表名；以新版 schema 為準，必要時以 mapping 文件將舊資料概念結合至新版資料庫 |
| 舊系統素材沿用 | 可沿用舊系統圖片或影片素材；不得沿用舊程式邏輯，素材授權與命名需於資產整理 Task 檢查 |
| 舊資料庫 migration | 不建立舊資料庫自動 migration；舊資料僅作欄位 mapping 與新版資料模型參考 |
| 舊 API 對照表 | 需要建立完整舊 API 對照表，比對 path、method、request、response 與錯誤情境 |
| 舊 Flutter UI 對照清單 | 需要建立舊 Flutter UI 畫面對照清單，比對流程、元件、狀態與素材 |
| Phase 分支流程 | 所有後續 Phase 均由 `develop` 建立 `feature/phase<n>` 整合分支；Phase 內 Task 由該 Phase 分支切出獨立分支，Task PR 先合併回 Phase 分支，Phase 完成後再由 Phase 分支 PR 至 `develop` |
| Phase 3 煩惱記錄方式 | 支援文字、圖片、錄音與影片；每筆使用一種主要記錄方式，另可附一張心情圖（D1-A、D2-A） |
| Phase 3 煩惱上傳契約 | 新增與修改採 `multipart/form-data`；Client 傳分類 code 與 1 至 5 分 score，由後端解析 lookup ID（D3-A、D4-A） |
| Phase 3 怪獸獎勵 | Phase 3 只建立煩惱並顯示完成結果；新增煩惱後的真實怪獸獎勵延至 Phase 6 串接（D5-B） |
| Phase 3 煩惱列表 | 使用 `page`、`size`、`sort` offset pagination；Database 不新增頁碼欄位（D6-A） |
| Phase 3 聊天互動 | 採聊天外觀搭配結構化 selector Widget，不以自由文字解析類別、記錄方式、分數或分享選項（D7-A） |
| Phase 3 媒體限制 | 圖片與心情圖 5 MB；錄音 10 MB／5 分鐘；影片 50 MB／60 秒；前後端使用相同 MIME type 白名單（D8-A） |
| Phase 3 煩惱媒體存取 | 使用獨立且不可公開存取的 R2 entry media bucket，Database 只保存 object key；Backend 驗證 owner 或分享權限後串流，API 不回傳 object key（D9-A） |
| Phase 3 媒體長度驗證 | Backend 使用 `ffprobe` 驗證錄音最多 5 分鐘、影片最多 60 秒；Backend runtime 必須安裝 FFmpeg（D10-A） |
| Phase 3 Entry 領域模型 | Annoyance 與後續 Diary 共用 `Entry` Entity 與 Repository，Annoyance 模組使用獨立 DTO、Mapper、Service 與 Controller（D11-A） |
| Phase 3 Annoyance Core 範圍 | Core Task 建立領域基礎、lookup、DTO、Mapper、Service 驗證與 Controller 骨架；實際 API endpoint 依後續 Task 逐一完成（D12-A） |
| Phase 3 R2 規格用語 | Entry media 在 Database 只保存 private R2 object key，不保存 public URL（D13-A） |
| Phase 3 Mood seed | Annoyance 與 Diary 共用中性分數 code `SCORE_1`～`SCORE_5`，label 為 `1分`～`5分`，不在 lookup 綁定好壞或程度語意（D14-A） |
| Phase 3 煩惱分數 UI | 依 2026-07-18 使用者指示，前端 `MoodScoreSelector` 使用 `moodPoint_1.png`～`moodPoint_5.png` 的綠色笑臉至紅色難過圖片呈現 1 至 5 分；API 與 Database lookup 仍只保存中性整數分數 |
| Backend package layout | 全面採 layer-first `com.monsters.<layer>.<module>`；`common` 作為共用模組名，`MonstersApplication` 維持在 `com.monsters` |

## 二、已核准套件與工具

### Frontend

| 類型 | 套件 / 工具 |
|------|-------------|
| State Management | Riverpod |
| HTTP Client | Dio |
| JSON | json_serializable |
| Routing | go_router |
| Local Storage | SharedPreferences |
| Google Sign-In | google_sign_in、google_sign_in_web |
| 媒體選取 | image_picker；Android 實作固定 image_picker_android 0.8.12+24 以相容 AGP 8.7 |
| 錄音 | record |
| 影音預覽 | video_player、just_audio |

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
| SMTP 設定 | 待細化：SMTP host、port、TLS、帳號、寄件者、reset link base URL 與正式環境 secret 管理方式 |
| Web 管理後台 | 待細化：管理者角色、登入方式、可管理資料範圍、稽核 log 與前端路由 |
| 舊 API 對照表 | 待建立：需依 `system_data/` 舊後端與舊前端呼叫整理完整對照 |
| 舊 Flutter UI 對照清單 | 待建立：需依 `system_data/` 舊 Flutter 頁面整理流程、元件、狀態與素材 |
| 舊系統素材清單 | 待建立：需確認可沿用圖片 / 影片清單、檔名規則、資產目錄與授權備註 |
