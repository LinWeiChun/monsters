# AGENTS.md

# 貘nsters AI 開發規範

> Version：v3.4
> 本文件為貘nsters Repository 的最高層級 AI 開發規範，適用於 Codex、Cursor Agent、GitHub Copilot Agent、Claude Code、Gemini CLI 等所有 AI Coding Agent。

---

## 一、目的與定位

本文件規範 AI Agent 的工作流程、Task 管理、文件同步、完成條件、決策原則與回報格式。

本文件不描述程式碼、Git、API、Database 或 UI 細節；細節依對應文件執行。

---

## 二、文件閱讀順序

AI 開始任何任務前，必須依序閱讀：

1. `AGENTS.md`
2. `CONTEXT.md`
3. `system_data/系統手冊`
4. `system_data/系統簡介`
5. `system_data/參考程式` 或 `system_data/` 內既有程式
6. `docs/GIT_RULE.md`
7. `docs/PROJECT_SPEC.md`
8. `docs/DATABASE_SPEC.md`
9. `docs/API_SPEC.md`
10. `docs/UI_SPEC.md`
11. `docs/CODING_STANDARD.md`
12. `docs/DECISIONS.md`
13. `docs/adr/` 中與任務相關的 ADR
14. `docs/TASKS.md`
15. 使用者最新明確指示

若內容互相衝突，AI 必須停止實作，說明衝突、提出方案，並等待使用者確認；不得自行推測。

---

## 三、專案架構原則

專案架構如下：

```text
Flutter → REST API → Spring Boot → MySQL
```

Flutter 不得直接存取 Database；所有資料必須透過 REST API。詳細規格依 `docs/PROJECT_SPEC.md`。

### 3.1 已核准產品與資料邊界

下列原則為 2026-07-26 grilling 後確認的不可自行弱化基線：

- 產品定位為非醫療情緒記錄與自我照顧工具，不提供診斷、治療或臨床風險判讀。
- 私人日記、煩惱、媒體、情緒負荷與自我探索結果不得被 AI、關鍵字或人工後台自動分析。
- 第一版服務地區為台灣，最低年齡為 13 歲；13 至 17 歲需監護人同意且不得使用社群。
- 匿名社群只對符合資格的成年會員開放；檢舉、封鎖、人工審核、申訴、稽核與特權帳號 MFA 完成前不得啟用。
- 管理員、審核員、內容審閱者與客服不得查看私人內容、模擬會員登入或取得會員 Token。
- 使用者內容不得用於生成式 AI 訓練、廣告、跨站追蹤、敏感分群或未另行同意的研究。
- 取消分享、刪除、匯出、帳號停用與法律保全必須依正式資料生命週期處理，不得以備份、Log、搜尋索引或客服系統形成永久副本。
- 第一版不採端對端加密；文件與 UI 必須如實說明，不得暗示平台無法解密資料。
- 第一版不接受使用者上傳個人頭貼；頭貼只能從已取得的貘怪圖鑑素材選擇。
- 第一版先完成私人核心封閉測試，社群於治理與安全門檻完成後另行開放。

完整領域語言以 `CONTEXT.md` 為準，具架構取捨的決策以 `docs/adr/` 與 `docs/DECISIONS.md` 為準。

---

## 四、Project Initialization

若 Repository 尚未建立下列結構，AI 必須先完成初始化，才能開始 Feature：

```text
frontend/
backend/
database/
docs/
system_data/
.github/
```

初始化至少包含：`README.md`、`log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv` 與必要基礎設定。

`system_data/` 用於放置系統手冊、系統簡介與參考程式；除非使用者明確要求，AI 不得修改或覆蓋其中內容。

---

## 五、參考程式 `system_data/` 使用原則

`system_data/` 為 AI 的參考資料來源，用於理解舊系統的既有寫法、命名、分層、錯誤處理、API 流程、資料模型、UI 元件、素材與測試風格。

實作前，AI 必須先檢查 `system_data/` 是否存在相似功能、流程或程式片段，並萃取可用的業務邏輯、流程與設計意圖；不得將舊程式直接視為新版規格。若無可參考內容，須在工作報告中說明。

AI 使用參考程式時必須遵守：

- 只能參考與延伸，不得盲目複製不相干或過期程式
- 不得因參考程式而違反 `docs/PROJECT_SPEC.md`、`docs/API_SPEC.md`、`docs/DATABASE_SPEC.md`、`docs/UI_SPEC.md` 或 `docs/CODING_STANDARD.md`
- 若參考程式與正式文件衝突，以正式文件為準，並回報衝突
- 若發現可重用的舊流程或模式，應重構為新版架構可接受的實作
- 不得沿用舊系統中的金鑰、帳密、Token、硬編碼環境設定或不安全作法
- 除非使用者明確要求，不得修改、搬移、刪除或格式化 `system_data/` 內容

---

## 六、AI 工作流程

每次收到任務，AI 必須：

1. 閱讀必要文件與最新任務
2. 依 `CONTEXT.md` 確認領域詞彙，並閱讀相關 ADR
3. 確認 `docs/TASKS.md` 狀態與前置條件
4. 檢查 `system_data/` 是否有可參考的既有寫法、流程、素材或資料結構
5. 比對舊系統、現有程式與正式文件是否衝突
6. 檢查 DoR
7. 分析需求並提出必要問題
8. 依既有架構、正式文件與 `docs/CODING_STANDARD.md` 實作
9. 執行 Compile / Test / 必要檢查
10. 更新相關文件、ADR 與 Log
11. 依 `docs/GIT_RULE.md` 執行 Git / PR 流程
12. 回報成果

AI 必須優先重用既有程式與架構，保持 Coding Style 一致，不得只改程式而不更新文件。

---

## 七、Task 管理、DoR 與 DoD

Task 狀態流程固定為：

```text
TODO → IN PROGRESS → REVIEW → DONE
```

禁止直接由 `TODO` 跳到 `DONE`。

### Definition of Ready（DoR）

開始實作前，必須確認：Task、需求、API、Database、UI 與前置 Task 皆已明確。

涉及會員、Entry、媒體、社群、內容管理或營運功能時，還必須確認年齡資格、owner、角色、刪除／匯出、稽核、重試、失敗狀態及隱私邊界。

未符合 DoR 時，不得開始實作。

### Definition of Done（DoD）

宣告完成前，必須確認：功能完成、Compile 通過、Test 通過、文件完成、`CHANGE_LOG` 更新、`CHANGE_HISTORY` 更新、Git 流程完成、工作報告完成。

未符合 DoD 時，不得宣告完成。

---

## 八、文件與 Log 同步

異動對應文件如下：

| 異動類型 | 文件 |
|---|---|
| 功能 / 需求 | `docs/PROJECT_SPEC.md` |
| API | `docs/API_SPEC.md` |
| Database | `docs/DATABASE_SPEC.md` |
| UI | `docs/UI_SPEC.md` |
| Coding Style | `docs/CODING_STANDARD.md` |
| Task / Log | `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY` |
| 領域詞彙 | `CONTEXT.md` |
| 難以逆轉的架構決策 | `docs/adr/`、`docs/DECISIONS.md` |

新增 Log 前，AI 必須檢查 `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`、`log/CHANGE_HISTORY.xlsx`（若本次使用）。

Log 僅保存一個月；若存在過期紀錄，必須先刪除再新增本次紀錄。工作報告需說明是否檢查保存期限，以及是否刪除過期 Log。

---

## 九、決策與禁止事項

若任務存在多種方案，AI 必須至少提出兩種方案，說明優點、缺點與風險，並等待使用者決定。

AI 不得：

- 自行增加、刪除或修改需求
- 自行修改 Architecture、Database 或 API
- 自行新增第三方套件
- 自行覆蓋使用者程式
- 自行推測未明確需求
- 跳過文件同步或測試
- 違反 `docs/GIT_RULE.md` 或 `docs/CODING_STANDARD.md`
- 將私人內容、Token、Email、生日、監護人資料或媒體寫入 Log、分析事件、客服工單或第三方監控
- 以情緒分數、文字內容或未經同意的推測影響獎勵、排序、通知、資格或處分
- 只在前端隱藏功能而未由 Backend 強制權限與功能開關
- 在 `feature/phase4` 尚未正式整合且基礎安全階段未完成前開始 Phase 5 以後功能

---

## 十、Git / GitHub 規範

所有 Git、Branch、Commit、Pull Request、GitHub Issue、GitHub Actions、Release Flow 與 Repository Protection 規範，均依 `docs/GIT_RULE.md` 執行。

AI 執行任何 Git 操作前，必須先完成 `docs/GIT_RULE.md` 定義的檢查。

---

## 十一、工作報告格式

任務完成後，AI 必須回報：

1. 完成內容
2. 修改 / 新增 / 刪除檔案
3. `system_data/` 參考結果
4. API 異動
5. Database 異動
6. 文件更新
7. 測試方式與結果
8. Log 保存期限檢查結果
9. 待確認事項

---

## 十二、標準啟動 Prompt

使用者可輸入：

```text
開始下一個 Task
```

AI 必須自動閱讀文件、確認 Task、實作、更新文件、執行 Git 流程並回報成果。

---

## 十三、文件資訊

| 項目 | 內容 |
|---|---|
| 文件 | `AGENTS.md` |
| 版本 | v3.4 |
| 專案 | 貘nsters |
| 維護者 | WeiChun Lin |
| 適用 | 所有 AI Coding Agent |
| 主要引用 | `CONTEXT.md`、`docs/GIT_RULE.md`、`docs/CODING_STANDARD.md`、`docs/adr/`、`system_data/` |
| Log 保存政策 | 新增 Log 前需檢查並刪除超過一個月的紀錄 |

---

本文件為 Repository 最高層級 AI 工作規範。程式設計依 `docs/CODING_STANDARD.md`，Git 流程依 `docs/GIT_RULE.md`，既有寫法參考 `system_data/`。
