# GIT_RULE.md

# 貘nsters Git 操作與分支維護規範

Version：v1.0

本文件為 Repository 所有 Git 操作之唯一規範。

適用於：

- Codex
- Cursor Agent
- GitHub Copilot Agent
- Claude Code
- Gemini CLI
- 其他 AI Coding Agent

以及所有參與本 Repository 開發之開發者。

Git 相關事項均以本文件為準。

若與 AGENTS.md 發生衝突：

AI 工作流程以 AGENTS.md 為最高優先。

Git 操作則以 GIT_RULE.md 為準。
---

## 一、Git Flow 總則

本專案採用簡化版 Git Flow。

```text
main
└── develop
    ├── feature/phase<n>
    │   ├── feature/phase<n>-<module>
    │   ├── fix/phase<n>-<module>
    │   ├── refactor/phase<n>-<module>
    │   └── docs/phase<n>-<module>
    ├── feature/*
    ├── fix/*
    ├── refactor/*
    ├── docs/*
    ├── release/*
    └── hotfix/*
```

不得直接於 `main` 開發。

### Git Flow 原則

本專案遵循以下原則：

- `main` 永遠保持可發布狀態。
- `develop` 為主要整合分支。
- 每個 Phase 開始時，必須由 `develop` 建立對應的 `feature/phase<n>` Phase 整合分支。
- Phase 內的每個 Task 必須由對應的 `feature/phase<n>` 建立獨立工作分支。
- Task 分支完成後先透過 Pull Request 合併回對應的 Phase 整合分支。
- Phase 內所有 Task 通過整合測試後，Phase 整合分支再透過 Pull Request 合併至 `develop`。
- 非 Phase 工作或未納入 Phase 的緊急工作，仍由 `develop` 建立對應分支。
- Feature Branch 不得直接 Merge 至 `main`。
- Release 完成後必須同步 Merge 回 `develop`。
- Hotfix 完成後必須同步 Merge 回 `develop`。

---

## 二、分支角色

| 分支 | 用途 | 規則 |
|---|---|---|
| `main` | 正式版本 | 永遠保持可發布狀態，不得直接開發 |
| `develop` | 開發整合分支 | 所有功能完成後先合併到此分支 |
| `feature/phase<n>` | Phase 整合分支 | 從 `develop` 建立，收納該 Phase 的 Task PR，Phase 完成後合併回 `develop` |
| `feature/phase<n>-<module>` | Phase 功能 Task | 從對應 `feature/phase<n>` 建立，完成後合併回該 Phase 分支 |
| `fix/phase<n>-<module>` | Phase Bug 修正 | 從對應 `feature/phase<n>` 建立，完成後合併回該 Phase 分支 |
| `refactor/phase<n>-<module>` | Phase 重構 Task | 從對應 `feature/phase<n>` 建立，不得改變既有功能行為 |
| `docs/phase<n>-<module>` | Phase 文件 Task | 從對應 `feature/phase<n>` 建立，僅用於文件與規格調整 |
| `release/<version>` | 發布前整理 | 從 `develop` 建立，測試完成後合併到 `main` |
| `hotfix/<issue>` | 正式版緊急修正 | 從 `main` 建立，完成後合併回 `main` 與 `develop` |

---

## 三、Branch 命名規則

必須使用下列格式：

```text
feature/phase3
feature/phase3-annoyance-api
fix/phase3-annoyance-validation
refactor/phase3-entry-service
docs/phase3-api-spec
feature/auth
feature/user
feature/diary
feature/annoyance
feature/community
fix/login-error
refactor/auth-service
docs/api-spec
release/1.0.0
hotfix/security-token
```

不得使用不明確名稱，例如：

```text
test
new
update
abc
final
my-branch
```

---

## 四、Commit Message 規範

使用 Conventional Commits。

格式：

```text
<type>(<scope>): <summary>
```

常用 Type：

| Type | 用途 |
|---|---|
| feat | 新增功能 |
| fix | 修正錯誤 |
| refactor | 重構 |
| docs | 文件更新 |
| test | 測試 |
| chore | 建置或設定調整 |
| style | 格式調整 |

範例：

```text
feat(auth): 完成會員登入功能
fix(api): 修正登入錯誤回應格式
docs(readme): 更新 Git 使用說明
refactor(service): 重構使用者服務邏輯
test(auth): 新增登入 API 測試
chore(git): 新增 .gitignore
```

原則：一個 Commit 只處理一件事情，不得將 `feat`、`fix`、`refactor` 混在同一次 Commit。

---

## 五、AI 可執行的 Git 操作

AI 可以執行下列低風險 Git 指令：

```bash
git status
git diff
git log
git branch
git fetch
git pull
git checkout <branch>
git switch <branch>
git checkout -b <branch>
git switch -c <branch>
git add .
git commit -m "<message>"
git push origin <branch>
git merge <feature-branch>
```

限制：

- Phase Task 的 `feature/*`、`fix/*`、`refactor/*`、`docs/*` 僅能合併至對應的 `feature/phase<n>`。
- `feature/phase<n>` 僅能在 Phase 整合測試完成後合併至 `develop`。
- 非 Phase 工作的 `feature/*`、`fix/*`、`refactor/*`、`docs/*` 仍只能合併至 `develop`。
- AI 執行 `git commit` 前必須先檢查 `git status`。
- AI 執行 `git push` 前必須確認目前分支不是 `main`。
- AI 每次 Commit 後必須更新 `CHANGE_LOG.md` 與 `CHANGE_HISTORY.xlsx` 或 `CHANGE_HISTORY.csv`。

### Git 操作前檢查

AI 執行任何 Git 操作前，必須確認：

- Working Tree 是否乾淨
- 是否位於正確 Branch
- 是否存在未提交變更
- Commit Message 是否符合 Conventional Commits

若不符合，應停止並提醒使用者。

### Commit 前檢查

Commit 前 AI 必須確認：

- Compile 成功
- 測試完成
- CHANGE_LOG.md 已更新
- CHANGE_HISTORY.xlsx / csv 已更新
- 文件同步完成
- git status 無異常
- Branch 正確

---

## 六、AI 不得執行的 Git 操作

AI 未經使用者明確確認，不得執行下列指令：

```bash
git push --force
git push -f
git reset --hard
git clean -fd
git clean -fdx
git rebase
git branch -D <branch>
git tag
git revert <commit>
git cherry-pick <commit>
git merge develop
git merge main
git stash drop
git stash clear
git filter-branch
git filter-repo
git gc --prune
git reflog expire
```

AI 永遠不得自行執行：

- 將任何分支直接合併到 `main`
- 對 `main` 直接 Push
- 強制推送
- 清除未追蹤檔案
- 重設使用者尚未確認的修改
- 嘗試繞過 GitHub Branch Protection

### system_data Git 規範

`system_data/` 可納入版本控制的內容：

- 舊系統參考程式
- 舊系統設定範例
- 舊 UI 素材
- 可公開的圖片、動畫或靜態資源
- 可協助理解舊系統的結構性資料

`system_data/` 不得納入版本控制的內容：

- 金鑰
- 密碼
- Token
- 憑證
- `.env`
- build artifact
- jar / war
- node_modules
- metadata
- IDE 暫存檔
- 私人資料
- 不必要的大型檔案

AI 不得在未被明確要求的情況下修改、刪除、搬移或格式化 `system_data/` 內容。

---

## 七、標準開發流程

每一個 Task 建議對應一個 Branch。

### 7.1 建立 Phase 整合分支

```bash
git checkout develop
git pull origin develop
git checkout -b feature/phase<n>
git push -u origin feature/phase<n>
```

### 7.2 建立 Phase Task 分支

```bash
git checkout feature/phase<n>
git pull origin feature/phase<n>
git checkout -b feature/phase<n>-<module>
```

### 7.3 完成 Task 後提交

```bash
git status
git add .
git commit -m "feat(<module>): <summary>"
git push origin feature/phase<n>-<module>
```

### 7.4 建立 Pull Request

Pull Request 方向：

```text
feature/phase<n>-<module> → feature/phase<n>
```

Phase 整合完成後：

```text
feature/phase<n> → develop
```

正式發布方向：

```text
develop → main
```

`develop → main` 必須由使用者確認後才能執行。

---

## 八、AI 任務啟動 Git 流程

收到任務後，AI 必須依序執行：

```text
確認目前 Branch
↓
git fetch
↓
git pull
↓
確認 TASKS.md
↓
確認目前 Task
↓
建立 Feature Branch（若需要）
↓
開始實作
↓
更新文件
↓
Commit
↓
Push
↓
產生 Pull Request Summary
```

若目前 Branch 為 `main`、`develop` 或 `feature/phase<n>`，不得直接開始修改程式，必須依任務建立適當的 Task 分支。

Phase Task 啟動前必須確認：

- Task 分支的 base 是對應的 `feature/phase<n>`。
- Pull Request 目標是對應的 `feature/phase<n>`，不是 `develop`。
- Phase 整合分支只收納同一 Phase 的變更。

---

## 九、Pull Request 規範

AI 完成任務後，必須提供 Pull Request Summary。

格式：

```markdown
## 修改內容

- 說明本次新增、修改或修正的內容

## 修改檔案

- path/to/file

## 測試項目

- 測試方式與結果

## 文件更新

- CHANGE_LOG.md
- CHANGE_HISTORY.xlsx
- docs/API_SPEC.md（若有）

## 注意事項

- 尚未完成事項或需要使用者確認事項
```

### Pull Request 應至少包含

- 修改內容
- Related Issue（若有）
- 修改檔案
- API 異動
- Database 異動
- Migration（若有）
- 測試項目
- 文件更新
- Reviewer（建議）
- 注意事項

---

## 十、GitHub Issue Flow

所有新功能建議先建立 Issue。

流程：

```text
Issue
↓
Task
↓
Phase Task Branch
↓
Commit
↓
Push
↓
Pull Request → Phase Branch
↓
Code Review
↓
Phase Integration Test
↓
Pull Request → develop
↓
Release
↓
Merge main
```

### 10.1 Issue 命名

建議使用：

```text
TASK-001
TASK-002
BUG-001
DOC-001
```

### 10.2 Branch 對應

建議一個 Task 對應一個 Branch 與一個 Pull Request，Task Branch 的目標為對應 Phase Branch。

避免一個 Branch 完成多個功能。

每個 Phase 只有一條整合分支，例如 `feature/phase3`。Phase 內的 Task Branch 不得跨 Phase 合併。

---

## 十一、GitHub Repository 保護規範

建議在 GitHub 設定：

- 保護 `main` 分支
- 禁止直接 Push 到 `main`
- 所有合併到 `main` 的變更必須透過 Pull Request
- 合併前必須確認測試通過
- 若加入 GitHub Actions，必須通過 CI 後才能合併

### 11.1 Branch Protection

`main` 設為 Protected Branch。

### 11.2 Default Branch

建議 Default Branch 設為：

```text
develop
```

### 11.3 Review

建議至少一位 Reviewer。AI 不得自行略過 Review。

### 11.4 Branch Cleanup Automation

Repository 使用 GitHub Actions 每週一檢查分支。

規則：

- 永遠保留 `main` 與 `develop`。
- 進行中且尚未合併至 `develop` 的 `feature/phase<n>` 不得刪除。
- 尚未合併至對應 Phase Branch 的 Task Branch 不得刪除。
- 已合併到 `main` 的工作分支可自動刪除。
- 只合併到 `develop`、尚未合併到 `main` 的分支不得刪除。
- 尚未合併到 `develop` 的分支不得刪除。
- 自動化不得使用 force push、reset、clean 或 rebase。

---

## 十二、Release Flow

正式版本建議流程：

```text
develop
↓
release/x.x.x
↓
QA
↓
main
↓
merge develop
```

完成 Release 後必須更新：

```text
RELEASE_NOTE.md
```

Release Note 至少包含：

- Version
- Release Date
- New Features
- Bug Fixes
- Breaking Changes
- Migration Notes
- Known Issues

---

## 十三、GitHub Actions 與 CI

若 Repository 建立 CI，建議 Pull Request 必須通過：

- Flutter Analyze
- Flutter Test
- Backend Build
- Backend Test
- Docs Check
- Security Scan
- Dependency Check

CI 未通過不得 Merge。

---

## 十四、Git 操作回報規則

AI 每次執行 Git 操作後，必須回報：

1. 目前 Branch
2. 執行過的 Git 指令
3. Commit Hash（若有）
4. Push 目標分支（若有）
5. 是否需要建立 Pull Request
6. 是否有衝突或未提交變更

若 Git 操作失敗，必須完整回報錯誤訊息，不得自行猜測或強制修復。

---

## 十五、標準啟動指令

使用者可以輸入：

```text
開始下一個 Task
```

AI 必須依照本文件自動完成：

- 確認 Branch
- 同步 Repository
- 建立任務 Branch
- 完成 Git 相關流程
- Commit
- Push
- 產生 Pull Request Summary

不得要求使用者再次描述 Git 流程。

---

## 十六、Merge Policy

Repository 建議採用：

- Merge Commit（預設）
- Squash Merge（需使用者確認）
- Rebase Merge（需使用者確認）

AI 不得自行決定 Merge 方式。

---

## 十七、Repository Checklist

Repository 至少應包含：

- README.md
- AGENTS.md
- GIT_RULE.md
- CHANGE_LOG.md
- CHANGE_HISTORY.xlsx（或 csv）
- docs/
- system_data/
- .gitignore

建議包含：

- LICENSE
- .github/

---

## 十八、Git Decision Rules

若存在多種 Git 操作方案：

AI 不得自行決定。

應提出：

- 方案一
- 方案二

並說明：

- 優點
- 缺點
- 風險

等待使用者確認後再執行。

---

## 文件資訊

| 項目 | 內容 |
|------|------|
| 文件名稱 | GIT_RULE.md |
| 版本 | v1.1 |
| 專案 | 貘nsters |
| 維護者 | WeiChun Lin |
| 適用 | Repository 所有開發者與 AI Coding Agent |
| 最後更新 | 2026-07-10 |
