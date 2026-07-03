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

## 三、待確認事項

| 項目 | 目前狀態 |
|------|----------|
| 檔案上傳儲存方式 | 待確認：本機儲存、雲端儲存或資料庫儲存 |
| Google 登入 Client ID | 待確認：Web 與 App 是否使用同一組 Client ID |
| Web 管理後台 | 待確認：是否需要管理後台 |
| 舊資料庫相容性 | 待確認：是否需要相容 `diary_socila_like` 與 `dialy_test` 舊表名 |
| 舊系統素材是否可正式沿用 | 待確認：需確認授權、命名與資產規格 |
| 舊資料庫是否需要 migration | 待確認：需建立舊表到新表的 mapping |
| 舊 API 是否需要建立完整對照表 | 待確認：需比對 path、method、request、response 與錯誤情境 |
| 舊 Flutter UI 是否需要畫面對照清單 | 待確認：需比對畫面流程、元件、狀態與素材 |

