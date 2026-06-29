# 貘nsters AI 開發規格包

本資料夾提供 Codex、Cursor Agent、GitHub Copilot Agent 或其他 AI Coding Agent 使用的專案規格文件。

---

## 一、建議使用方式

1. 開啟 Codex、Cursor Agent、GitHub Copilot Agent 或其他 AI Coding Agent。
2. 將整個專案資料夾加入 AI 的工作區。
3. 先要求 AI 閱讀根目錄的 `AGENTS.md`。
4. 再要求 AI 依序閱讀 `docs/` 資料夾中的規格文件。
5. 最後要求 AI 從 `docs/TASKS.md` 的 Phase 0 開始執行，不得跳過步驟。

建議指令：

```text
請先閱讀 AGENTS.md，並依序閱讀 docs/PROJECT_SPEC.md、docs/DATABASE_SPEC.md、docs/API_SPEC.md、docs/UI_SPEC.md、docs/CODING_STANDARD.md、docs/TASKS.md，然後執行 docs/TASKS.md 的 Phase 0。不要跳過任何步驟。每次完成任務後，必須更新 CHANGE_LOG.md 與 CHANGE_HISTORY.csv（或 CHANGE_HISTORY.xlsx），並依照 AGENTS.md 的 AI 回覆格式回報。
```

---

## 二、文件結構

```text
monsters/
├── AGENTS.md                 # AI 工作規範，最高優先權
├── README.md                 # 專案說明與使用方式
├── CHANGE_LOG.md             # 文字版專案異動紀錄
├── CHANGE_HISTORY.csv        # CSV 版專案異動歷程
├── CHANGE_HISTORY.xlsx       # Excel 版專案異動歷程
├── docs/
│   ├── PROJECT_SPEC.md       # 專案需求規格
│   ├── DATABASE_SPEC.md      # 資料庫設計規格
│   ├── API_SPEC.md           # REST API 規格
│   ├── UI_SPEC.md            # Flutter UI 規格
│   ├── CODING_STANDARD.md    # 程式撰寫規範
│   └── TASKS.md              # AI 開發任務清單
├── icon/                     # 專案圖示與視覺素材
└── system data/              # 原始系統手冊與系統簡介
```

---

## 三、AI 工作規則摘要

AI 開發時必須遵守：

- 不得自行增加未定義需求。
- 不得跳過 `docs/TASKS.md` 中的開發順序。
- 不得直接修改資料表或 API 命名，除非文件明確要求或使用者確認。
- 每次完成任務後，必須更新 `CHANGE_LOG.md`。
- 每次完成任務後，必須同步更新 `CHANGE_HISTORY.csv` 或 `CHANGE_HISTORY.xlsx`。
- 若修改 API、資料庫、UI 或開發流程，必須同步更新對應規格文件。

---

## 四、重要提醒

若 AI 發現規格不足、文件互相衝突，或現有程式碼與文件不一致，必須先提出問題並等待確認，不得自行推測或直接實作。
