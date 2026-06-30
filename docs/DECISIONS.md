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

