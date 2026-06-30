# 專案異動紀錄

本文件用於記錄貘nsters 專案每次由 AI Coding Agent 或開發者完成的檔案異動。

AI 每次完成任務後，必須新增一筆紀錄，並同步更新 `CHANGE_HISTORY.csv` 或 `CHANGE_HISTORY.xlsx`。

---

## 紀錄格式

```markdown
## YYYY-MM-DD HH:mm

Task
TASK-XXX 任務名稱

修改人
Codex / Cursor Agent / GitHub Copilot Agent / Developer

### 本次完成

- 說明本次完成內容

### 新增

- path/to/new_file

### 修改

- path/to/modified_file

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- 說明如何測試

### Commit 建議

```text
feat(scope): 說明本次異動
```

### 備註 / 待確認事項

- 無
```

---

## 2026-06-30 09:36

Task
TASK-001 建立 Monorepo 結構

修改人
Codex

### 本次完成

- 建立 `frontend/`、`backend/`、`database/`、`.github/` Monorepo 基礎目錄。
- 新增 `.gitkeep` 保留檔，確保空目錄可被 Git 追蹤。
- 更新 `README.md` Repository 結構，使文件與實際目錄一致。
- 更新 `docs/TASKS.md` 標示本 Task 執行狀態。

### 新增

- `.github/.gitkeep`
- `frontend/.gitkeep`
- `backend/.gitkeep`
- `database/.gitkeep`

### 修改

- `README.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- 確認 `frontend/`、`backend/`、`database/`、`.github/` 目錄已建立。
- 確認新增目錄內含 `.gitkeep`，可被 Git 追蹤。

### Commit 建議

```text
chore(project): 建立 monorepo 基礎結構
```

### 備註 / 待確認事項

- Flutter SDK 指令逾時，下一項「建立 Flutter 專案」前需再次確認 Flutter 環境。
- 目前 Java 版本為 1.8，低於 `docs/CODING_STANDARD.md` 建議的 Java 21；建立 Spring Boot 專案前需確認是否升級或調整規範。

---

## 2026-06-29 17:10

Task
DOC-001 建立異動紀錄檔並更新 README 使用指令

修改人
ChatGPT

### 本次完成

- 新增 `CHANGE_LOG.md`，作為專案文字版異動紀錄。
- 新增 `CHANGE_HISTORY.csv`，作為專案表格版異動歷程。
- 新增 `CHANGE_HISTORY.xlsx`，作為 Excel 版異動歷程。
- 更新 `README.md` 的 AI 使用指令，使文件閱讀順序與 `docs/` 路徑一致。

### 新增

- CHANGE_LOG.md
- CHANGE_HISTORY.csv
- CHANGE_HISTORY.xlsx

### 修改

- README.md
- AGENTS.md

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- 確認根目錄已包含 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv`、`CHANGE_HISTORY.xlsx`。
- 確認 `README.md` 已明確要求 AI 依序閱讀 `AGENTS.md` 與 `docs/` 內規格文件。

### Commit 建議

```text
docs(project): 新增異動紀錄檔並更新 README 使用指令
```

### 備註 / 待確認事項

- 無
