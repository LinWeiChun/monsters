# AGENTS.md

# 貘nsters AI 開發規範

> Version：v3.0
>
> 本文件為貘nsters Repository 的最高層級 AI 開發規範。
>
> 所有 AI Coding Agent（Codex、Cursor Agent、GitHub Copilot Agent、Claude Code、Gemini CLI…）皆必須遵守本文件。

---

# 一、文件目的

本文件規範 AI Agent 在本專案中的工作方式。

內容包含：

- AI 工作流程
- Task 管理
- 文件同步
- 工作完成條件
- AI 回報格式
- AI 決策規範

本文件**不描述程式設計細節**。

程式撰寫方式請參閱：

- docs/CODING_STANDARD.md

Git 規範請參閱：

- docs/GIT_RULE.md

---

# 二、文件優先順序

AI 在開始任何工作前，必須依照以下順序閱讀文件。

1. AGENTS.md
2. docs/GIT_RULE.md
3. system_data/系統手冊
4. system_data/系統簡介
5. docs/PROJECT_SPEC.md
6. docs/DATABASE_SPEC.md
7. docs/API_SPEC.md
8. docs/UI_SPEC.md
9. docs/CODING_STANDARD.md
10. docs/TASKS.md
11. 使用者最新明確指示

若文件內容互相衝突：

AI 必須：

1. 停止開發
2. 說明衝突
3. 提出方案
4. 等待使用者確認

不得自行推測。

---

# 三、AI 工作原則

AI 必須：

- 優先閱讀文件
- 優先重用既有程式
- 保持一致 Coding Style
- 同步更新文件
- 提供完整工作報告
- 遵守 Git 規範
- 遵守 Coding Standard

AI 不得：

- 自行增加需求
- 自行修改需求
- 自行推測需求
- 自行修改 Architecture
- 自行修改 Database
- 自行修改 API

---

# 四、專案架構

本專案採：

Flutter

↓

REST API

↓

Spring Boot

↓

MySQL

Flutter：

不得直接存取 Database。

所有資料：

必須透過 REST API。

詳細架構：

請參閱：

docs/PROJECT_SPEC.md

---

# 五、Project Initialization

若 Repository 尚未建立：

frontend/

backend/

database/

docs/

.github/

AI 必須先完成：

- 專案初始化
- README
- log/CHANGE_LOG
- log/CHANGE_HISTORY

完成後：

才能開始第一個 Feature。

---

# 六、AI 工作流程

每次收到任務：

AI 必須：

1. 閱讀 AGENTS.md
2. 閱讀 GIT_RULE.md
3. 閱讀 docs/
4. 確認 TASKS
5. 分析需求
6. 提出疑問（若需要）
7. 開始實作
8. 更新文件
9. 更新 log/CHANGE_LOG
10. 更新 log/CHANGE_HISTORY
11. 完成工作報告

Git 操作：

依照：

GIT_RULE.md

---

# 七、Task 管理

所有 Task：

必須依：

TASKS.md

執行。

Task 狀態：

TODO

↓

IN PROGRESS

↓

REVIEW

↓

DONE

不得：

TODO

↓

DONE

---

# 八、文件同步

新增任何 Log 紀錄前：

AI 必須先檢查：

- log/CHANGE_LOG.md
- log/CHANGE_HISTORY.csv
- log/CHANGE_HISTORY.xlsx（若本次使用）

Log 僅保存一個月。

若存在超過一個月的紀錄：

AI 必須先刪除過期 Log 紀錄。

刪除後：

才能新增本次 Log 紀錄。

本次工作報告必須說明：

- 是否檢查 Log 保存期限
- 是否刪除過期 Log

若修改：

功能

↓

PROJECT_SPEC.md

API

↓

API_SPEC.md

Database

↓

DATABASE_SPEC.md

UI

↓

UI_SPEC.md

Coding Style

↓

CODING_STANDARD.md

完成 Task

↓

CHANGE_LOG.md

↓

CHANGE_HISTORY.xlsx

不得只修改程式。

---

# 九、AI 決策規範

若存在：

多種方案。

AI：

應提出：

至少兩種方案。

並說明：

- 優點
- 缺點
- 風險

等待使用者決定。

不得自行決策。

---

# 十、Definition of Ready（DoR）

開始 Task 前：

必須確認：

- 文件完成
- Task 已確認
- API 已確認
- Database 已確認
- UI 已確認
- 前置 Task 完成

否則：

不得開始。

---

# 十一、Definition of Done（DoD）

Task 完成：

必須符合：

- 功能完成
- Compile 通過
- Test 通過
- 文件完成
- CHANGE_LOG 更新
- CHANGE_HISTORY 更新
- 工作報告完成

Git 流程：

依照：

GIT_RULE.md

---

# 十二、AI 工作報告

每次完成：

必須回報：

1. 完成內容
2. 修改檔案
3. 新增檔案
4. 刪除檔案
5. API 異動
6. Database 異動
7. 文件更新
8. 測試方式
9. 待確認事項

---

# 十三、禁止事項

AI 不得：

- 自行增加需求
- 自行刪除需求
- 自行修改需求
- 自行修改 API
- 自行修改 Database
- 自行新增第三方套件
- 自行覆蓋使用者程式
- 自行推測需求
- 跳過文件同步
- 跳過測試

若文件不足：

必須詢問。

---

# 十四、外部規範引用

程式設計：

請依：

docs/CODING_STANDARD.md

Git：

請依：

GIT_RULE.md

需求：

請依：

PROJECT_SPEC.md

Database：

請依：

DATABASE_SPEC.md

API：

請依：

API_SPEC.md

UI：

請依：

UI_SPEC.md

---

# 十五、附錄

## AI 標準 Prompt

使用者可直接輸入：

開始下一個 Task

AI 應自動：

- 閱讀文件
- 確認 Task
- 開始工作
- 更新文件
- 回報成果

---

## 文件版本

| 項目 | 內容 |
|------|------|
| 文件 | AGENTS.md |
| 版本 | v3.0 |
| 專案 | 貘nsters |
| 維護者 | WeiChun Lin |
| 適用 | 所有 AI Coding Agent |
| Log 保存政策 | 新增 Log 前需檢查並刪除超過一個月的紀錄 |

---

本文件為 Repository 最高層級 AI 工作規範。

Git 規範：

請依 GIT_RULE.md。

Coding 規範：

請依 docs/CODING_STANDARD.md。
