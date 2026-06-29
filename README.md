# 貘nsters（Monsters）

> 一套提供使用者抒發情緒、記錄日記、管理煩惱、社群互動、怪獸蒐集與心理紓壓功能的跨平台系統。

本專案採用 **Flutter + Spring Boot + MySQL** 架構，並以 **AI Assisted Development（AI 輔助開發）** 為核心開發流程。

支援平台：

* Android
* iOS
* Web

---

# 專案特色

* Flutter 跨平台開發
* Spring Boot REST API
* MySQL 資料庫
* Riverpod 狀態管理
* Clean Architecture
* AI Agent 協助開發（Codex / Cursor / GitHub Copilot Agent）
* 完整需求、API、資料庫與 UI 規格文件

---

# 技術架構

```text
Flutter
(Android / iOS / Web)

        │

 REST API

        │

Spring Boot

        │

 MySQL
```

---

# Repository 結構

```text
monsters/
│
├── AGENTS.md
├── README.md
├── .gitignore
├── CHANGE_LOG.md
├── CHANGE_HISTORY.csv
├── CHANGE_HISTORY.xlsx
│
├── docs/
│   ├── PROJECT_SPEC.md
│   ├── DATABASE_SPEC.md
│   ├── API_SPEC.md
│   ├── UI_SPEC.md
│   ├── CODING_STANDARD.md
│   └── TASKS.md
│
├── frontend/
│
├── backend/
│
├── database/
│
├── icon/
│
└── system data/
```

---

# AI 開發流程

所有 AI Agent（Codex、Cursor、GitHub Copilot Agent…）開始工作前，**必須先閱讀文件**。

閱讀順序：

```text
AGENTS.md

↓

docs/PROJECT_SPEC.md

↓

docs/DATABASE_SPEC.md

↓

docs/API_SPEC.md

↓

docs/UI_SPEC.md

↓

docs/CODING_STANDARD.md

↓

docs/TASKS.md
```

不得跳過任何步驟。

---

# 建議 Prompt

第一次開始開發時，請對 AI 使用以下指令：

```text
請先閱讀 AGENTS.md。

接著依序閱讀：

docs/PROJECT_SPEC.md
docs/DATABASE_SPEC.md
docs/API_SPEC.md
docs/UI_SPEC.md
docs/CODING_STANDARD.md
docs/TASKS.md

閱讀完成後，確認目前應執行的 Task。

依照 AGENTS.md 規範開始實作。

不得跳過任何 Phase。

每完成一項 Task 必須：

1. 更新 CHANGE_LOG.md
2. 更新 CHANGE_HISTORY.csv（或 CHANGE_HISTORY.xlsx）
3. 更新相關文件
4. 依照 AGENTS.md 回覆格式產生工作報告
```

---

# Git Flow

Branch：

```text
main

develop

feature/<module>

fix/<module>

refactor/<module>

docs/<module>
```

Commit：

```text
feat:

fix:

refactor:

docs:

test:

style:

chore:
```

---

# 文件說明

| 文件                        | 用途             |
| ------------------------- | -------------- |
| AGENTS.md                 | AI 開發規範（最高優先權） |
| PROJECT_SPEC.md           | 專案需求規格         |
| DATABASE_SPEC.md          | 資料庫設計          |
| API_SPEC.md               | REST API 規格    |
| UI_SPEC.md                | Flutter UI 規格  |
| CODING_STANDARD.md        | Coding Style   |
| TASKS.md                  | AI 開發任務        |
| CHANGE_LOG.md             | 專案異動紀錄         |
| CHANGE_HISTORY.csv / xlsx | 專案異動歷程         |

---

# 開發規則

所有 AI Agent 必須遵守：

* 不得自行新增需求。
* 不得修改資料表。
* 不得修改 API。
* 不得修改需求文件。
* 不得跳過 TASKS。
* 每次完成任務必須同步更新文件。
* 每次完成任務必須更新 Change Log。
* 若需求衝突，必須停止並詢問使用者。

---

# 如何開始開發

第一次：

```bash
git clone <repository-url>

cd monsters
```

開始開發：

```bash
git checkout develop
```

建立功能分支：

```bash
git checkout -b feature/auth
```

完成後：

```bash
git add .

git commit -m "feat(auth): 完成登入功能"

git push origin feature/auth
```

---

# License

本專案僅供學術研究、專題開發及授權用途。

未經授權，不得商業使用。

---

# 維護者

Developer

WeiChun Lin

AI Development

OpenAI Codex
