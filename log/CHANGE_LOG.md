# 專案異動紀錄

本文件用於記錄貘nsters 專案每次由 AI Coding Agent 或開發者完成的檔案異動。

AI 每次完成任務後，必須新增一筆紀錄，並同步更新 `CHANGE_HISTORY.csv` 或 `CHANGE_HISTORY.xlsx`。

新增 Log 紀錄前，必須先檢查既有 Log 日期；若存在超過一個月的紀錄，需先刪除過期紀錄，再新增本次紀錄。

---

## 2026-07-16 10:56

Task
TASK-068 登入帳號或 Email 驗證修正（REVIEW）

Agent
Codex

### Completed

- 比對 `bec7bcf` 的登入欄位調整與 `0b3d265` 的 Account / Email 後端查詢邏輯。
- 確認登入 400 的原因為 `LoginRequest.email` 仍套用 `@Email`，使 Account 在進入 `AuthService` 前即被拒絕。
- 保留既有 `email` request key，移除 Email-only 格式限制，改為必填且最大長度 255，讓後端可接收 Account 或 Email。
- 更新登入 Controller 與 Service 測試，涵蓋 Account request validation、Account 正規化查詢、Email 查詢、未知使用者與錯誤密碼。
- 檢查 Log 保存期限；最早紀錄為 2026-06-29，未早於 2026-06-16，因此未刪除 Log。

### Modified

- `backend/src/main/java/com/monsters/dto/auth/LoginRequest.java`
- `backend/src/test/java/com/monsters/controller/auth/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/service/auth/AuthServiceTest.java`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- `gradlew.bat test --tests "com.monsters.controller.auth.AuthControllerTest" --tests "com.monsters.service.auth.AuthServiceTest"`：通過。
- `gradlew.bat test`：BUILD SUCCESSFUL。
- `flutter test --no-pub test/login_page_test.dart`：180 秒內無輸出並逾時；本次未修改前端程式，保留為 REVIEW 待後續環境確認。

### system_data Reference

- 參考舊系統以 Account 登入的流程意圖；未沿用舊系統空密碼 Google 登入、全域狀態或不安全憑證處理方式。

### API

- `POST /api/auth/login` 的 `email` 欄位名稱不變，語意擴充為可輸入已註冊的 Account 或 Email。

### Database

- No Database change.

### UI

- No frontend code changed；UI 規格同步標示登入欄位為「帳號或 Email」。

### Pending

- 待 Code Review 與 Railway 部署後，以 Account 及 Email 各執行一次公開環境登入驗證。
- Flutter 登入頁測試需在 Flutter test runner 可正常輸出的環境重跑。

---

## 2026-07-15 16:41

Task
插隊任務 Penpot MCP 註冊畫面排版同步（REVIEW）

Agent
Codex

### Completed

- 將 Flutter 註冊頁從舊版置中表單調整為 Account & Access 系列版型。
- Web 版使用左側品牌區與右側表單區；Mobile 版以 390px 寬、36px 邊距、54px 欄位高度調整。
- 註冊頁圖片改用 `frontend/assets/images/title.png` 與 `frontend/assets/images/icon.png`。
- 將註冊頁色票集中於 `AppColors`，頁面不直接宣告設計色票。
- 更新註冊頁 widget tests，固定手機尺寸並同步新版文案。
- 盤點目前已完成頁面與 Penpot MCP 差異：Splash、Home、Profile、Password Lock、Annoyance Chat 仍未完成 Penpot 精準對齊；Login 已完成；Register 本次完成。
- 檢查 Log 保存期限；最早紀錄為 2026-06-29，未超過一個月，因此未刪除 Log。

### Modified

- `frontend/lib/pages/register_page.dart`
- `frontend/lib/theme/app_colors.dart`
- `frontend/test/register_page_test.dart`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- `dart format lib/pages/register_page.dart lib/theme/app_colors.dart test/register_page_test.dart`
- `flutter analyze --no-pub`：通過
- `flutter test --no-pub test/register_page_test.dart`：6 tests passed

### system_data Reference

- 本次依 Penpot MCP 與已完成登入頁 Account & Access 視覺系統調整，未新增引用 `system_data/` 舊程式。

### API

- No API endpoint changed.

### Database

- No Database change.

### UI

- 註冊頁 Web 與 Mobile 視覺排版、圖片與色票已調整為 Account & Access 系列規格。

### Pending

- Penpot MCP 目前 selection 為空，註冊頁未能直接讀取註冊畫板子節點；若使用者選取註冊畫板，可再做精準尺寸比對。
- 已完成但仍需 Penpot 精準對齊的畫面：Splash、Home、Profile、Password Lock、Annoyance Chat。

---

## 2026-07-15 15:19

Task
插隊任務 Penpot MCP 登入畫面排版同步（REVIEW）

Agent
Codex

### Completed

- 依 Penpot `Account / Web / 02 Login / 登入` 調整 Flutter Web 登入頁雙欄排版、品牌區、表單區、欄位與按鈕尺寸。
- 依 Penpot `Account / Mobile / 02 Login / 登入` 調整 App / Mobile 登入頁 390x844 版型、logo 位置、欄位高度與登入操作區。
- 將登入頁設計色票集中到 `AppColors`，登入頁不再直接宣告設計用 `Color(0x...)`。
- 套用使用者放入 `frontend/assets/images/` 的 `title.png` 與 `icon.png`，並以 `assets/images/` 目錄註冊 Flutter assets。
- 更新登入頁 widget tests，固定手機尺寸並以 key 操作 Google 登入按鈕。
- 檢查 Log 保存期限；最早紀錄為 2026-06-29，未超過一個月，因此未刪除 Log。

### Modified

- `frontend/lib/pages/login_page.dart`
- `frontend/lib/theme/app_colors.dart`
- `frontend/pubspec.yaml`
- `frontend/test/login_page_test.dart`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Added

- `frontend/assets/images/bonus.png`
- `frontend/assets/images/icon.png`
- `frontend/assets/images/icon_main.png`
- `frontend/assets/images/title.png`

### Tests

- `dart format lib/pages/login_page.dart lib/theme/app_colors.dart test/login_page_test.dart`
- `flutter analyze`：通過
- `flutter test test/login_page_test.dart`：10 tests passed

### system_data Reference

- 本次依 Penpot MCP 指定畫面與現有 Flutter 登入頁調整，未新增引用 `system_data/` 舊程式。

### API

- No API endpoint changed.

### Database

- No Database change.

### UI

- 登入頁 Web 與 Mobile 視覺排版、圖片與色票已同步至 Penpot 登入畫面規格。

### Pending

- Web Chrome 實機視覺驗證尚未在本次流程啟動；目前以 Flutter analyze 與登入頁 widget tests 作為驗證。

---

## 2026-07-13 17:57

Task
TASK-067 Phase 3 TASK-066 視覺 review 收尾（DONE）

Agent
Codex

### Completed

- Confirmed `TASK-066` is already merged into `develop` through `feature/phase3`.
- Confirmed the Phase 3 checklist has no remaining unfinished item after `TASK-066`.
- Updated `Flutter 陪伴式首頁與 Web 獨立桌面版型` from REVIEW to DONE based on user closeout confirmation.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Modified

- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- No code changed in this closeout.
- Used existing `TASK-066` verification evidence: `flutter test` passed with 74 tests for the layout task and 76 tests after the monster animation supplement.

### system_data Reference

- No new `system_data/` implementation reference was required for this status-only closeout.

### API

- No API endpoint changed.

### Database

- No Database change.

### UI

- No UI behavior changed in this closeout; TASK-066 visual review was accepted by user instruction to close out.

### Pending

- None for Phase 3.

---

## 2026-07-13 15:18

Task
TASK-066 陪伴式首頁怪獸互動動畫補充（REVIEW）

Agent
Codex

### Completed

- 維持新版陪伴式首頁與 Web 獨立桌面版型。
- 使用 Flutter `AnimationController` 為既有怪獸 PNG 加入有限次數的呼吸與上下漂浮動畫。
- 點擊怪獸時播放彈跳、縮放與小幅擺動，不修改原始圖片且未新增第三方套件。
- 支援系統「減少動態效果」，啟用時停止待機與點擊動畫。
- 新增語意標籤、Tooltip 與可點擊區域。
- 在既有 Figma 檔案新增怪獸待機、點擊與 Reduce Motion 動效規格區塊。
- 檢查 Log 保存期限；最早紀錄為 2026-06-29，沒有超過一個月的紀錄，因此未刪除 Log。

### Modified

- `frontend/lib/widgets/home/companion_hero.dart`
- `frontend/test/home_page_test.dart`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- `flutter analyze lib/widgets/home/companion_hero.dart test/home_page_test.dart`：通過，無問題。
- `flutter test test/home_page_test.dart`：5 項測試全部通過。
- `flutter test`：76 項測試全部通過。

### system_data Reference

- 延續舊版首頁怪獸具有生命感的設計意圖。
- 未沿用舊版全畫面隨機位移、Timer 與固定座標動畫。

### API

- 無 API 異動。

### Database

- 無 Database 異動。

### Pending

- 待使用者進行動畫視覺 review。

---

## 2026-07-13 14:50

Task
TASK-066 Flutter 陪伴式首頁與 Web 獨立桌面版型（REVIEW）

Agent
Codex

### Completed

- 依使用者核准的 A 方案完成陪伴式首頁。
- 使用 Figma plugin 建立可編輯的 390px 手機版與 1440px Web 桌面版設計，並上傳既有怪獸圖示作為正式視覺素材。
- 手機版保留怪獸陪伴區、單一主要行動、快捷操作、底部導覽與個人選單。
- Web 版改為固定左側導覽、怪獸陪伴區與功能操作區並列，不直接放大手機畫面。
- 以 900px breakpoint 切換手機與桌面版型，未完成模組顯示開發排程提示。
- 保留既有 Riverpod、go_router、Theme 與登入登出流程，未新增第三方套件。
- 檢查 Log 保存期限；最早紀錄為 2026-06-29，沒有超過一個月的紀錄，因此未刪除 Log。

### Added

- `frontend/lib/widgets/home/companion_hero.dart`
- `frontend/lib/widgets/home/home_navigation.dart`
- `frontend/lib/widgets/home/home_quick_action.dart`
- `frontend/test/home_page_test.dart`

### Modified

- `frontend/lib/pages/home_page.dart`
- `frontend/lib/theme/app_colors.dart`
- `frontend/lib/theme/app_spacing.dart`
- `frontend/lib/theme/app_theme.dart`
- `frontend/test/login_page_test.dart`
- `frontend/test/password_lock_page_test.dart`
- `frontend/test/profile_page_test.dart`
- `docs/PROJECT_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- Targeted `dart analyze`：通過，無 issue。
- `flutter test test/home_page_test.dart test/routes/app_router_test.dart test/theme/app_theme_test.dart`：8 targeted tests passed。
- 既有首頁個人資料、密碼鎖與登出導頁測試已改為操作新版個人選單。
- `flutter test`：74 tests passed。
- `flutter build web --no-wasm-dry-run`：通過並產生 `build/web`；建置顯示既有 CupertinoIcons 字型未納入警告，本次未使用 CupertinoIcons。
- 完整 `flutter analyze` 在本機環境啟動逾時，已改以本次異動檔案 targeted analyze 驗證。

### system_data Reference

- 參考舊版 `system_data/front-end/monsters_front_end/lib/pages/home.dart` 的暖色背景、首頁怪獸、主要功能入口與底部導覽。
- 參考 `system_data/front-end/monsters_front_end/lib/state/drawer.dart` 的個人資料、密碼鎖及登出資訊架構。
- 未沿用 Adobe XD 固定座標、舊 Navigator、全域狀態、頁面內資料存取與浮動展開按鈕。

### API

- 無 API 異動。

### Database

- 無 Database 異動。

### UI

- Figma：[貘nsters 陪伴式首頁 UI - Mobile & Web](https://www.figma.com/design/bo3ooJWyoIThN9D7YqkY1x)
- 手機與 Web 使用不同資訊架構，共用 Theme token 與首頁元件。

### Pending

- 待使用者進行 Figma 與實際 Web／手機畫面 review。
- 待在實際瀏覽器與手機裝置進行視覺 review。

---

## 2026-07-13 11:32

Task
TASK-065 Phase 3 收尾與整合驗證（REVIEW）

Agent
Codex

### Completed

- Confirmed `feature/phase3` includes PR #40, PR #41, and PR #42.
- Rechecked the Phase 3 task list after the sharing, submit, and migration fix branches were merged.
- Marked `Flutter 煩惱分享選擇` as DONE.
- Marked `Flutter 新增煩惱摘要送出與完成流程` as DONE.
- Marked the Phase 3 umbrella item `依新版 Entry 架構與 API 規格重新實作` as DONE after integration verification passed.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Modified

- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- `flutter analyze` passed with zero issues.
- Full `flutter test` passed with 71 tests.
- Backend `./gradlew.bat test` passed.
- `docker compose config` passed, with Docker config permission warnings from `C:\Users\linwe\.docker\config.json`.

### system_data Reference

- No new `system_data/` implementation reference was required for this closeout; Phase 3 reference work was completed in earlier Phase 3 Tasks.

### API

- No API endpoint changed.

### Database

- No new Database migration was added in this closeout.
- Existing Phase 3 migration rerun fixes from TASK-064 remain part of the integrated Phase 3 state.

### UI

- No UI behavior changed in this closeout.

### Pending

- Phase 3 is ready for final review / PR flow from `feature/phase3` to `develop`.
- `frontend/tool/run_web_local.ps1` has an unrelated local change and was intentionally excluded from this Task.

---

## 2026-07-13 10:52

Task
TASK-064 Phase 3 annoyance type migration 重跑修復（REVIEW）

Agent
Codex

### Completed

- Investigated the Workbench error `Error Code: 1060. Duplicate column name 'code'` from `20260711_01_add_annoyance_type_codes_and_seed.sql`.
- Updated the migration to check `information_schema.columns` before adding `annoyance_types.code`.
- Updated the migration to check `information_schema.statistics` before adding `uk_annoyance_types_code`.
- Reviewed the other SQL migration files and updated `20260711_02` to avoid rerun failures after `entry_media` has already been migrated to `object_key`.
- Confirmed `20260711_03` already checks for the unique score index and added an explicit `USE monsters;` for Workbench execution consistency.
- Kept the approved Phase 3 seed values unchanged.
- Updated database documentation to state that `20260711_01` can be rerun in Workbench.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Modified

- `database/migrations/20260711_01_add_annoyance_type_codes_and_seed.sql`
- `database/migrations/20260711_02_make_entry_media_private.sql`
- `database/migrations/20260711_03_make_mood_score_unique.sql`
- `database/init/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- `docker compose config` passed in the previous migration fix; direct MySQL execution was not run because Docker daemon was unavailable in this environment.
- SQL was made idempotent for the reported duplicate column case, the matching duplicate index case, and the already-migrated entry media schema case.

### system_data Reference

- No new legacy behavior was copied; the migration keeps the approved Phase 3 lookup code contract.

### API

- No API endpoint changed.

### Database

- `20260711_01` now safely skips existing `code` column and existing `uk_annoyance_types_code` index, then upserts the six approved category rows.
- `20260711_02` now skips legacy column conversion when `media_url` is already gone, and conditionally adds missing private-media columns, index, and constraints.
- `20260711_03` already had rerun guards for `moods.score` uniqueness and now explicitly selects the `monsters` schema.

### UI

- No UI change.

### Pending

- Re-run `database/migrations/20260711_01_add_annoyance_type_codes_and_seed.sql` in Workbench, then retry the annoyance submit flow.
- `backend/src/main/resources/application.yml` and `frontend/tool/run_web_local.ps1` have unrelated local changes and were intentionally excluded from this Task.

---

## 2026-07-13 10:48

Task
TASK-063 Phase 3 annoyance type lookup seed 修復（REVIEW）

Agent
Codex

### Completed

- Investigated the submit-time `ResourceNotFoundException: Annoyance category not found` error.
- Confirmed Flutter sends the approved `categoryCode` values and backend tests/specs also use the same codes.
- Identified the likely runtime cause as an existing MySQL database missing the Phase 3 `annoyance_types` lookup seed.
- Added an idempotent repair migration to seed the six approved annoyance type codes for existing databases.
- Updated the database init README with the error symptom and required repair migration.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `database/migrations/20260713_01_seed_missing_annoyance_lookups.sql`

### Modified

- `database/init/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- `docker compose config` passed.
- Direct database verification was not run because Docker daemon was not available in this environment.

### system_data Reference

- Rechecked the legacy annoyance category enum names and confirmed they must not replace the approved Phase 3 category code contract.

### API

- No API endpoint changed.
- Existing create-annoyance requests continue to use `categoryCode`.

### Database

- Added a repair migration that inserts or updates the approved `annoyance_types` seed rows: `ACADEMIC`, `CAREER`, `LOVE`, `FRIENDSHIP`, `FAMILY`, `OTHER`.

### UI

- No UI change.

### Pending

- Apply `database/migrations/20260713_01_seed_missing_annoyance_lookups.sql` to the affected local database, then retry submit.
- `backend/src/main/resources/application.yml` and `frontend/tool/run_web_local.ps1` have unrelated local changes and were intentionally excluded from this Task.

---

## 2026-07-13 10:35

Task
TASK-062 Flutter 新增煩惱摘要送出與完成流程（REVIEW）

Agent
Codex

### Completed

- Re-read the governing Phase 3 specs, task state, API contract, and legacy `system_data/` annoyance flow before continuing implementation.
- Created `feature/phase3-annoyance-submit` from the Phase 3 integration branch.
- Added a Flutter `AnnoyanceRepository` that submits the completed draft to the existing multipart `POST /api/annoyances` endpoint.
- Added typed `AnnoyanceResponse` parsing for the create-annoyance API response.
- Replaced the review placeholder with a summary card, submit action, submitting state, completed card, retryable API error handling, and create-another restart flow.
- Preserved the Phase 3 boundary by not adding fake monster rewards; the completed page only confirms creation and sharing state.
- Updated Provider, repository, page, and route tests for the full local annoyance flow.
- Added `Flutter 新增煩惱摘要送出與完成流程` to `docs/TASKS.md` as REVIEW.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `frontend/lib/models/annoyance_response.dart`
- `frontend/lib/repositories/annoyance_repository.dart`
- `frontend/lib/widgets/annoyance/annoyance_review_card.dart`
- `frontend/lib/widgets/annoyance/annoyance_completed_card.dart`
- `frontend/test/repositories/annoyance_repository_test.dart`

### Modified

- `frontend/lib/models/annoyance_draft.dart`
- `frontend/lib/pages/annoyance_chat_page.dart`
- `frontend/lib/providers/annoyance_chat_provider.dart`
- `frontend/test/annoyance_chat_page_test.dart`
- `frontend/test/providers/annoyance_chat_provider_test.dart`
- `frontend/test/routes/app_router_test.dart`
- `docs/TASKS.md`
- `docs/UI_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- Flutter formatter passed for all Task files.
- `flutter analyze` passed with zero issues.
- Targeted submit-related tests passed: `flutter test test/repositories/annoyance_repository_test.dart test/providers/annoyance_chat_provider_test.dart test/annoyance_chat_page_test.dart`.
- Full `flutter test` passed with 71 tests.
- Flutter commands required elevated execution because the Flutter SDK cache is outside the repository sandbox.

### system_data Reference

- Reviewed the legacy annoyance content, drawing, score, sharing, review, and completion intent from `system_data/`.
- Reused only the flow intent: pre-submit review, submission feedback, and completion confirmation.
- Did not copy legacy random reward assignment, local file path handling, integer sharing flags, hardcoded values, or old backend structure.

### API

- No backend API endpoint changed.
- Flutter now consumes the existing create-annoyance `POST /api/annoyances` multipart contract with `request`, optional `contentFile`, and optional `drawingFile`.

### Database

- No Database or migration change.

### UI

- Added the Phase 3 review, submitting, and completed UI for the existing `/annoyances/new` flow.

### Pending

- The Phase 3 umbrella `Entry` architecture/API consistency item remains pending until the integration branch is reviewed as a whole.
- `frontend/tool/run_web_local.ps1` has an unrelated local change and was intentionally excluded from this Task.

---

## 2026-07-13 10:11

Task
TASK-061 Flutter 煩惱分享選擇（REVIEW）

Agent
Codex

### Completed

- Re-read the Phase 3 task state, UI spec, API share contract, and legacy `system_data/` sharing flow before implementing.
- Created `feature/phase3-annoyance-sharing` from the synchronized Phase 3 integration branch.
- Added `ShareChoiceCard` with explicit `保持私人` and `分享到社群` choices instead of a toggle.
- Stored the selected sharing state as nullable boolean `isShared` in `AnnoyanceChatState`.
- Advanced valid sharing selection from `sharing` to `review`, preserved the choice when returning from review, and cleared it when returning to score/upstream steps or restarting.
- Updated the chat page to show the sharing prompt, selected sharing bubble, and review placeholder for the next Task.
- Added Provider, widget, and chat flow tests for sharing selection and revision.
- Moved `Flutter 煩惱分享選擇` from TODO to REVIEW in `docs/TASKS.md`.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `frontend/lib/widgets/annoyance/share_choice_card.dart`
- `frontend/test/widgets/share_choice_card_test.dart`

### Modified

- `frontend/lib/pages/annoyance_chat_page.dart`
- `frontend/lib/providers/annoyance_chat_provider.dart`
- `frontend/test/annoyance_chat_page_test.dart`
- `frontend/test/providers/annoyance_chat_provider_test.dart`
- `docs/TASKS.md`
- `docs/UI_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- Flutter formatter passed for all Task files.
- `flutter analyze` passed with zero issues.
- Targeted sharing-related tests passed: `flutter test test/widgets/share_choice_card_test.dart test/providers/annoyance_chat_provider_test.dart test/annoyance_chat_page_test.dart` with 14 tests.
- Full `flutter test` passed with 68 tests.
- Flutter commands required elevated execution because the Flutter SDK cache is outside the repository sandbox.

### system_data Reference

- Reviewed the old annoyance chat and history chat sharing flow, including the legacy 0/1 share value and social query usage.
- No legacy code, global state, hardcoded credentials, or old toggle behavior was copied.

### API

- No API endpoint changed.
- The selected sharing value maps to the existing create-annoyance `isShared` boolean contract: `false` for private and `true` for social sharing.

### Database

- No Database or migration change.

### UI

- Added the Phase 3 sharing choice UI and kept review, submit, and completion UI for later Task work.

### Pending

- Review summary, create-annoyance submission, completion UI, and the Phase 3 umbrella `Entry` architecture/API consistency item remain pending.
- `frontend/tool/run_web_local.ps1` has an unrelated local change and was intentionally excluded from this Task.

---

## 2026-07-13 09:32

Task
TASK-059 Phase 3 煩惱分數選擇 review 與測試收尾

Agent
Codex

### Completed

- Re-read AGENTS, Git, project, API, Database, UI, Coding Standard, Decisions, Tasks, and `system_data/` location status before continuing.
- Synchronized `feature/phase3` and created `feature/phase3-annoyance-score-review` from the Phase 3 integration branch.
- Reviewed the merged `MoodScoreSelector`, `AnnoyanceChatController.selectScore`, chat page score flow, and related Provider / Widget tests.
- Confirmed the score selector uses neutral `1分` through `5分` options, preserves a selected score when returning from sharing, rejects out-of-range score values, and advances valid selections to the sharing step.
- Marked Flutter annoyance score selection as DONE and marked Phase 3 testing as DONE in `docs/TASKS.md`.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- None

### Modified

- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- Targeted Flutter score-related tests passed: `flutter test test/widgets/mood_score_selector_test.dart test/providers/annoyance_chat_provider_test.dart test/annoyance_chat_page_test.dart`.
- Full Flutter test suite passed: `flutter test` with 66 tests.
- Backend Gradle test suite passed with JDK 18: `gradlew.bat test`.
- Flutter commands required elevated execution because the Flutter SDK cache lockfile is outside the repository sandbox.
- Backend Gradle test required elevated execution because Gradle wrapper dependency download was blocked by sandbox network restrictions.

### system_data Reference

- `system_data/` contains the old backend, old frontend, system manual PDF, and system introduction PDF.
- No new legacy code was copied or modified in this review-only Task.

### API

- No API endpoint or request contract changed.

### Database

- No Database or migration change.

### UI

- No UI code changed. Existing score UI was reviewed against the approved neutral 1-to-5 score selector contract.

### Pending

- `docs/TASKS.md` still leaves the umbrella item `依新版 Entry 架構與 API 規格重新實作` unchecked. Sharing, review, submission, and completion UI remain represented as later work in the UI spec, while no dedicated rows exist for them in the current Phase 3 task list.

## 2026-07-13 06:33

Task
TASK-058 Flutter 煩惱分數選擇（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-057 was merged into `feature/phase3` through PR #37 and marked it DONE.
- Created `feature/phase3-annoyance-score` from the synchronized Phase 3 integration branch while preserving the unrelated local `application.yml` change.
- Added neutral `1分` through `5分` score definitions and labels without binding lookup values to positive or negative emotion semantics.
- Added a responsive and accessible `MoodScoreSelector` with equal visual weight, structured keys, selected state, and tap handling.
- Added an immutable nullable score to the Riverpod chat state, guarded selection to the approved 1-to-5 range, and advanced valid selections from `score` to `sharing`.
- Preserved a selected score when returning from sharing so it can be revised, and cleared it when returning to upstream drawing/content choices or restarting.
- Added chat bubbles for the selected score and next-step sharing prompt while leaving sharing implementation outside this Task.
- Added Provider, selector Widget, and end-to-end chat flow tests.
- Updated the formal UI implementation and Task status from TODO through IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `frontend/lib/widgets/annoyance/mood_score_selector.dart`
- `frontend/test/widgets/mood_score_selector_test.dart`

### Modified

- `frontend/lib/models/annoyance_draft.dart`
- `frontend/lib/pages/annoyance_chat_page.dart`
- `frontend/lib/providers/annoyance_chat_provider.dart`
- `frontend/test/annoyance_chat_page_test.dart`
- `frontend/test/providers/annoyance_chat_provider_test.dart`
- `docs/TASKS.md`
- `docs/UI_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- Flutter formatter passed for all Task files.
- `flutter analyze` passed with zero issues.
- Targeted Provider, score selector, and chat flow tests passed: 13 tests.
- Full `flutter test` passed: 66 tests.
- Flutter Web build passed; the existing optional Cupertino icon font warning remains non-blocking.
- Android debug APK build passed.
- iOS device no-codesign build passed.
- iOS simulator build passed.
- `AnnoyanceChatPage` is 277 lines, `MoodScoreSelector` is 90 lines, and `AnnoyanceChatController` is 245 lines; all remain below the 300-line Flutter limit.
- `CHANGE_HISTORY.csv` was imported, inspected, and rendered as a 13-column table with the spreadsheet runtime.

### system_data Reference

- Reviewed legacy manual pages 123–124, the system introduction, the old `annoyanceChat.dart` score flow, and the five `moodPoint` assets.
- Retained the interaction intent for a structured 1-to-5 choice that immediately advances to the sharing question.
- Did not reuse legacy free-text parsing, `chatRound`, mutable answer arrays, green-to-red emotion semantics, or score image assets because the approved D14-A lookup labels are neutral.
- `system_data/` was not modified.

### API

- No API endpoint or request contract changed.
- The saved integer remains compatible with the existing create/update `score` field, which accepts 1 through 5.

### Database

- No Database or migration change.
- The selector matches the existing `SCORE_1` through `SCORE_5` mood seeds.

### UI

- Added neutral score selection, selected-state restoration, score chat summary, and transition to the sharing step.
- Sharing, review, submission, and completion remain assigned to subsequent work.

### Pending

- The `sharing` panel remains an explicit placeholder until its dedicated implementation is scheduled.

## 2026-07-12 20:27

Task
TASK-057 Flutter 畫心情功能（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-056 was merged into `feature/phase3` through PR #36 and marked it DONE.
- Created `feature/phase3-annoyance-drawing` from the synchronized Phase 3 integration branch.
- Added a structured drawing decision step that either opens the drawing canvas or proceeds directly to the score step.
- Added an immutable drawing draft model with PNG/WebP and 5 MB validation compatible with the existing Annoyance API contract.
- Added a responsive square `CustomPainter` canvas with normalized stroke coordinates, six pen colors, adjustable width, eraser, undo, clear, cancel, and completion controls.
- Exported completed drawings to a white-background 1024×1024 PNG without adding a dependency or saving a duplicate file to the device gallery.
- Added drawing preview, chat summary, back/restart cleanup, and `drawingDecision → drawing → score` state transitions to the existing Riverpod flow.
- Split drawing controls from the canvas so each Widget remains below the 300-line Flutter Coding Standard limit.
- Added Provider, drawing canvas, and end-to-end chat Widget tests.
- Updated the formal UI implementation and Task status from TODO through IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `frontend/lib/models/annoyance_drawing.dart`
- `frontend/lib/widgets/annoyance/drawing_choice_card.dart`
- `frontend/lib/widgets/annoyance/drawing_preview_card.dart`
- `frontend/lib/widgets/annoyance/mood_drawing_canvas.dart`
- `frontend/lib/widgets/annoyance/mood_drawing_controls.dart`
- `frontend/lib/widgets/annoyance/mood_drawing_exporter.dart`
- `frontend/lib/widgets/annoyance/mood_drawing_painter.dart`
- `frontend/test/widgets/mood_drawing_canvas_test.dart`

### Modified

- `frontend/lib/pages/annoyance_chat_page.dart`
- `frontend/lib/providers/annoyance_chat_provider.dart`
- `frontend/lib/widgets/annoyance/annoyance_content_input.dart`
- `frontend/test/annoyance_chat_page_test.dart`
- `frontend/test/providers/annoyance_chat_provider_test.dart`
- `docs/TASKS.md`
- `docs/UI_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- Flutter formatter passed for all Task files.
- `flutter analyze` passed with zero issues.
- Targeted Provider, drawing canvas, and chat flow tests passed: 12 tests.
- Full `flutter test` passed: 64 tests.
- Flutter Web build passed; the existing optional Cupertino icon font warning remains non-blocking.
- Android debug APK build passed.
- iOS device no-codesign build passed.
- iOS simulator build passed.
- `MoodDrawingCanvas` is 253 lines and `MoodDrawingControls` is 89 lines, both below the 300-line Widget limit.
- `CHANGE_HISTORY.csv` was imported, inspected, and rendered as a 13-column table with the spreadsheet runtime.

### system_data Reference

- Reviewed legacy manual page 123 and the old `drawing_colors.dart` plus `annoyanceChat.dart` drawing flow.
- Retained the interaction intent for cancel, undo, clear, completion, adjustable pen width, eraser, color selection, and a drawing preview in chat.
- Replaced direct navigation, mutable page/global state, gallery file creation, plugin-based image saving, and legacy hard-coded screen coordinates with the existing Riverpod state machine, normalized strokes, `CustomPainter`, and in-memory API-ready PNG data.
- `system_data/` was not modified.

### API

- No API endpoint or request contract changed.
- The drawing draft remains compatible with the existing optional multipart `drawingFile` part.

### Database

- No Database or migration change.

### UI

- Added structured drawing choice, full drawing canvas controls, error/loading states, completed PNG preview, and transition to the score step.
- Score selection, sharing, review, submission, and completion remain assigned to subsequent Tasks.

### Pending

- Physical-device touch and stylus smoke testing remains recommended before release.

## 2026-07-12 18:31

Task
TASK-056 Flutter 文字 / 圖片 / 錄音 / 影片選取與預覽（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-055 was merged into `feature/phase3` through PR #35 and marked it DONE.
- Created `feature/phase3-annoyance-media` from the synchronized Phase 3 integration branch.
- Added the user-approved `image_picker`, `record`, `video_player`, and `just_audio` dependencies for Web, Android, and iOS.
- Pinned the official `image_picker` Android implementation to an AGP 8.7-compatible version after the current release pulled AndroidX libraries requiring AGP 8.9.1; avoided an unrelated Android toolchain upgrade.
- Added a typed single-media draft model, Riverpod media service provider, platform adapters, and API-compatible MIME type, extension, size, and duration validation.
- Added text input, image and video gallery/camera selection, WAV recording with automatic five-minute stop, preview, playback, loading, permission/error feedback, removal, and reselection.
- Kept audio/video as `XFile` references and retained preview bytes only for validated images to avoid holding duplicate 50 MB video data in memory.
- Added Android camera/microphone permissions and iOS photo library/camera/microphone usage descriptions.
- Made the content panel independently scrollable so previews remain usable in the standard mobile and 800×600 test viewport.
- Added Validator, Provider, image preview/removal, and audio recording Widget tests.
- Stabilized one pre-existing Register validation test by scrolling its submit button into the test viewport; production behavior was not changed.
- Updated the formal UI implementation, approved dependencies, and Task status from TODO through IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `frontend/lib/models/annoyance_media.dart`
- `frontend/lib/providers/annoyance_media_provider.dart`
- `frontend/lib/services/annoyance_media_platform.dart`
- `frontend/lib/services/annoyance_media_platform_factory.dart`
- `frontend/lib/services/annoyance_media_platform_io.dart`
- `frontend/lib/services/annoyance_media_platform_stub.dart`
- `frontend/lib/services/annoyance_media_platform_web.dart`
- `frontend/lib/services/annoyance_media_service.dart`
- `frontend/lib/services/annoyance_media_validator.dart`
- `frontend/lib/widgets/annoyance/annoyance_content_input.dart`
- `frontend/lib/widgets/annoyance/media_preview_card.dart`
- `frontend/test/services/annoyance_media_validator_test.dart`

### Modified

- `frontend/pubspec.yaml`
- `frontend/pubspec.lock`
- `frontend/android/app/src/main/AndroidManifest.xml`
- `frontend/ios/Runner/Info.plist`
- `frontend/lib/pages/annoyance_chat_page.dart`
- `frontend/lib/providers/annoyance_chat_provider.dart`
- `frontend/test/annoyance_chat_page_test.dart`
- `frontend/test/providers/annoyance_chat_provider_test.dart`
- `frontend/test/register_page_test.dart`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `docs/UI_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- Flutter formatter passed for all Task files.
- `flutter analyze --no-pub` passed with zero issues.
- Targeted media Validator, Provider, and Widget tests passed: 12 tests.
- Full `flutter test --no-pub` passed: 60 tests.
- Flutter Web build passed; the existing optional Cupertino icon font warning remains non-blocking.
- Android debug APK build passed after selecting the compatible official image picker implementation.
- iOS device no-codesign build passed.
- iOS simulator build passed.
- `git diff --check` passed.
- `CHANGE_HISTORY.csv` was imported, inspected, and rendered as a 13-column table with the spreadsheet runtime.

### system_data Reference

- Reviewed the legacy manual pages 121–124 and the old `annoyanceChat.dart`, audio recorder, and audio player flow.
- Retained the chat-guided choice of text, photo, video, and recording plus visible media confirmation.
- Replaced mutable `File` fields, direct `Navigator.push`, page-owned plugin calls, commented-out menu options, hard-coded 15-second recording, and legacy global state with typed `XFile` drafts, Riverpod, service/platform adapters, shared validation, and structured Widgets.
- `system_data/` was not modified.

### API

- No API endpoint or request contract changed.
- Frontend validation matches the existing multipart Annoyance API MIME, extension, size, and duration limits.

### Database

- No Database or migration change.

### UI

- Added cross-platform text input, single image/video selection, WAV recording, media metadata, playback/preview, removal, reselection, loading, and error states to the existing chat `content` step.
- Drawing, score, sharing, review, submission, and completion remain assigned to subsequent Tasks.

### Pending

- Review and merge the Task PR into `feature/phase3`.
- Camera, microphone, and gallery permission prompts should receive a physical-device smoke test during review.
- The next Task is Flutter mood drawing.

---

## 2026-07-13 09:55

Task
TASK-060 Flutter Web Google 登入 Windows 啟動腳本
Agent
Codex

### Completed

- Added a Windows PowerShell script for launching Flutter Web on Chrome with fixed `localhost:5050`.
- Centralized the repeated `flutter run -d chrome --web-port=5050 --dart-define=GOOGLE_CLIENT_ID=...` command into `frontend/tool/run_web_local.ps1`.
- Kept Web Google Sign-In initialization limited to `GOOGLE_CLIENT_ID`; the script does not pass `GOOGLE_SERVER_CLIENT_ID`.
- Updated frontend README and formal API / UI docs to mention the Windows script.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `frontend/tool/run_web_local.ps1`

### Modified

- `frontend/README.md`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- Not run. This change only adds a local launch wrapper and documentation.

### system_data Reference

- Checked that `system_data/` is present. No related legacy launcher script was needed, and no `system_data/` file was modified.

### API

- No API endpoint or request contract changed.

### Database

- No Database or migration change.

### UI

- No UI behavior changed.

### Pending

- Fill `frontend/tool/run_web_local.ps1` `$DefaultGoogleClientId` once, or pass `-GoogleClientId` when running the script.

---
## 2026-07-12 11:58

Task
TASK-055 Flutter 新增煩惱聊天室（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-053 and TASK-054 were merged into `feature/phase3` through PR #34 and marked both DONE.
- Created `feature/phase3-annoyance-chat` from the synchronized Phase 3 integration branch.
- Added the `/annoyances/new` go_router route and a Home Page entry for the Annoyance chat.
- Added an auto-disposed Riverpod draft controller with the formal Phase 3 step enum and guarded structured transitions.
- Implemented the chat foundation through `intro → category → recordMethod → content` while reserving later steps for their dedicated Tasks.
- Added six stable category-code choices and TEXT／IMAGE／AUDIO／VIDEO record-method choices without free-text parsing.
- Added responsive assistant/user chat bubbles, scroll-to-latest behavior, back, restart, and explicit return-to-home actions.
- Added Controller, Widget, route, and Home entry tests.
- Stabilized existing Splash, Register, and router tests so they target the current logo widget and scroll off-screen actions into the standard 800×600 test viewport; no existing production behavior was changed.
- Updated the formal UI implementation boundary and moved this Task from TODO through IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `frontend/lib/models/annoyance_draft.dart`
- `frontend/lib/pages/annoyance_chat_page.dart`
- `frontend/lib/providers/annoyance_chat_provider.dart`
- `frontend/lib/widgets/annoyance/annoyance_category_selector.dart`
- `frontend/lib/widgets/annoyance/annoyance_chat_bubble.dart`
- `frontend/lib/widgets/annoyance/record_method_selector.dart`
- `frontend/test/annoyance_chat_page_test.dart`
- `frontend/test/providers/annoyance_chat_provider_test.dart`

### Modified

- `frontend/lib/pages/home_page.dart`
- `frontend/lib/routes/app_router.dart`
- `frontend/lib/routes/app_routes.dart`
- `frontend/test/register_page_test.dart`
- `frontend/test/routes/app_router_test.dart`
- `frontend/test/widget_test.dart`
- `docs/TASKS.md`
- `docs/UI_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- Flutter formatter passed for all Task files.
- `flutter analyze --no-pub` passed with zero issues.
- Targeted chat Controller, Widget, and router tests passed: 7 tests.
- Full `flutter test --no-pub` passed: 52 tests.
- Full `flutter test --no-pub --concurrency=1` also passed: 52 tests.
- Flutter Web build passed.
- Android debug APK build passed.
- iOS device no-codesign build passed.
- iOS simulator build passed.
- `git diff --check` passed.
- `CHANGE_HISTORY.csv` was imported, inspected, and rendered as a 13-column table with the spreadsheet runtime.

### system_data Reference

- Rechecked the legacy Annoyance chat greeting, six categories, record-method prompt, back-and-forth flow, and history entry intent.
- Reused the companionship tone and six-category business meaning.
- Replaced free-text option parsing, round integers, mutable answer arrays, console logging, and direct legacy repository coupling with typed enums, stable codes, structured Widgets, Riverpod state, and go_router.
- `system_data/` was not modified.

### API

- No API request is sent in this Task; multipart submission is connected after the remaining draft inputs are implemented.
- Category codes and record-method API values match the existing Backend contract.

### Database

- No Database or migration change.

### UI

- Added the cross-platform Annoyance chat foundation, Home entry, route, structured category selector, and record-method selector.
- Media content, drawing, score, sharing, review, submit, and completed UI remain assigned to subsequent Tasks.

### Pending

- Review and merge the Task PR into `feature/phase3`.
- The next Task is Flutter text/image/audio/video selection and preview.

---

## 2026-07-12 07:27

Task
TASK-054 分享 / 取消分享煩惱 API（REVIEW）

Agent
Codex

### Completed

- Continued on the user-approved combined `feature/phase3-annoyance-state` branch after TASK-053 was committed independently.
- Added authenticated owner-scoped `PATCH /api/annoyances/{id}/share`.
- Required an explicit non-null `isShared` target state and supported both false-to-true sharing and true-to-false cancellation.
- Returned idempotent success without an unnecessary Database write when the target state already matched.
- Returned the updated Annoyance response and kept missing, deleted, or non-owned entries hidden as 404.
- Moved TASK-054 from TODO through IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `backend/src/main/java/com/monsters/dto/annoyance/ShareAnnoyanceRequest.java`
- `backend/src/test/java/com/monsters/dto/annoyance/ShareAnnoyanceRequestTest.java`

### Modified

- `backend/src/main/java/com/monsters/controller/annoyance/AnnoyanceController.java`
- `backend/src/main/java/com/monsters/service/annoyance/AnnoyanceService.java`
- `backend/src/test/java/com/monsters/controller/annoyance/AnnoyanceControllerTest.java`
- `backend/src/test/java/com/monsters/service/annoyance/AnnoyanceServiceTest.java`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- `./gradlew clean test build` passed: 194 tests, 0 failures, 0 errors.
- Request validation, sharing, unsharing, same-state idempotency, Controller response, solve endpoint regression, and all existing Backend tests passed.
- `git diff --check` passed.
- `CHANGE_HISTORY.csv` was imported, inspected, and rendered as a 13-column table with the spreadsheet runtime.

### system_data Reference

- Rechecked the legacy history screen share toggle and modify endpoint.
- Retained only the user-controlled share/unshare intent; did not reuse client-side toggle inference, account-in-path authorization, integer flags, or mixed legacy updates.
- `system_data/` was not modified.

### API

- Added `PATCH /api/annoyances/{id}/share` with explicit boolean target state.
- Share, unshare, and repeated same-state requests return 200 with Annoyance data; null returns 400.

### Database

- No schema, migration, or seed change; only the existing `entries.is_shared` field is updated.

### UI

- No Flutter file was changed.

### Pending

- Review and merge the combined Draft PR into `feature/phase3`; TASK-053 and TASK-054 are preserved as separate commits.

---

## 2026-07-12 07:22

Task
TASK-053 解決煩惱 API（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-052 was merged into `feature/phase3` through PR #33 and marked it DONE.
- Created the user-approved combined `feature/phase3-annoyance-state` branch from the synchronized Phase 3 integration branch; TASK-053 and TASK-054 remain separate commits and Log entries.
- Added authenticated owner-scoped `PATCH /api/annoyances/{id}/solve`.
- Required an explicit `isSolved = true` target state; false or null is rejected with 400.
- Preserved one-way Phase 3 solve semantics and returned idempotent success without an unnecessary write when the annoyance is already solved.
- Returned the updated Annoyance response and kept missing, deleted, or non-owned entries hidden as 404.
- Moved TASK-053 from TODO through IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `backend/src/main/java/com/monsters/dto/annoyance/SolveAnnoyanceRequest.java`
- `backend/src/test/java/com/monsters/dto/annoyance/SolveAnnoyanceRequestTest.java`

### Modified

- `backend/src/main/java/com/monsters/controller/annoyance/AnnoyanceController.java`
- `backend/src/main/java/com/monsters/service/annoyance/AnnoyanceService.java`
- `backend/src/test/java/com/monsters/controller/annoyance/AnnoyanceControllerTest.java`
- `backend/src/test/java/com/monsters/service/annoyance/AnnoyanceServiceTest.java`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Tests

- `./gradlew test` passed: 188 tests, 0 failures, 0 errors.
- Request validation, owner transition, repeated true idempotency, false/null rejection, Controller response, and existing Annoyance regression tests passed.
- `git diff --check` passed.
- `CHANGE_HISTORY.csv` was imported, inspected, and rendered as a 13-column table with the spreadsheet runtime.

### system_data Reference

- Rechecked the legacy history screen solve action and modify endpoint.
- Retained only the one-way solve intent; did not reuse account-in-path authorization, integer flags, partial legacy object overwrite, or mixed solve/share mutation.
- `system_data/` was not modified.

### API

- Added `PATCH /api/annoyances/{id}/solve` with explicit boolean target state.
- Successful and repeated-true requests return 200 with Annoyance data; false/null returns 400.

### Database

- No schema, migration, or seed change; only the existing `entries.is_solved` field is updated.

### UI

- No Flutter file was changed.

### Pending

- TASK-054 share/unshare API will be completed as the second independent commit on the approved combined branch.

---

## 2026-07-12 07:02

Task
TASK-052 修改煩惱 API（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-051 was merged into `feature/phase3` through PR #32 and marked it DONE.
- Created `feature/phase3-annoyance-update` from the synchronized Phase 3 integration branch.
- Added authenticated owner-scoped `PUT /api/annoyances/{id}` with the approved multipart full-replacement contract.
- Added complete update validation for category, record method, content, score, sharing, occurred time, existing primary media, and existing drawing media.
- Supported retaining, replacing, or removing the primary media and optional drawing while preserving the existing solved state.
- Required retained media IDs to belong to the target entry and match the requested media purpose and type.
- Persisted Entry updates, old-media soft deletion, and new-media metadata in one Database transaction.
- Cleaned newly uploaded R2 objects when upload orchestration or Database persistence failed.
- Deferred old R2 object deletion until after transaction success and treated cleanup as best effort so cleanup failure cannot roll back committed data.
- Updated the API contract and moved this Task from TODO through IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `backend/src/main/java/com/monsters/dto/annoyance/UpdateAnnoyanceRequest.java`
- `backend/src/main/java/com/monsters/service/annoyance/UpdatedAnnoyance.java`
- `backend/src/test/java/com/monsters/dto/annoyance/UpdateAnnoyanceRequestTest.java`

### Modified

- `backend/src/main/java/com/monsters/controller/annoyance/AnnoyanceController.java`
- `backend/src/main/java/com/monsters/service/annoyance/AnnoyancePersistenceService.java`
- `backend/src/main/java/com/monsters/service/annoyance/AnnoyanceService.java`
- `backend/src/test/java/com/monsters/controller/annoyance/AnnoyanceControllerTest.java`
- `backend/src/test/java/com/monsters/service/annoyance/AnnoyancePersistenceServiceTest.java`
- `backend/src/test/java/com/monsters/service/annoyance/AnnoyanceServiceTest.java`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None.

### Tests

- `./gradlew clean test build` passed: 183 tests, 0 failures, 0 errors.
- Update DTO validation, Controller response, owner scope, text/media conversion, retained-media type validation, media replacement, drawing retention, Database failure cleanup, post-commit old-object cleanup, and transaction boundaries are covered.
- `git diff --check` passed.
- `CHANGE_HISTORY.csv` was imported, inspected, and rendered as a 13-column table with the spreadsheet runtime.

### system_data Reference

- Rechecked the legacy account-scoped modify Controller, Service, Flutter Repository, and history screen calls.
- Retained only the useful owner-update intent.
- Did not reuse account-in-path authorization, partial object overwrites, Base64 media fields, PATCH semantics for full replacement, mixed solve/share updates, or legacy response handling.
- `system_data/` was not modified.

### API

- Added `PUT /api/annoyances/{id}` using multipart `request`, optional `contentFile`, and optional `drawingFile` parts.
- Added `existingContentMediaId` and `existingDrawingMediaId` retention fields to the complete update request.
- Returns 200 with the updated Annoyance response; missing, deleted, or non-owned entries remain 404 and invalid media combinations return 400.
- Solved state, monster assignment, and Phase 3 reward are not editable through this endpoint.

### Database

- No schema, seed, index, or migration change.
- Existing Entry and EntryMedia columns are updated transactionally; replaced or removed media rows are soft deleted.

### UI

- No Flutter file was changed.
- The API contract is ready for the later Flutter history-edit integration.

### Pending

- Review and merge the Task PR into `feature/phase3`.
- The next Phase 3 Task is the solve Annoyance API.

---

## 2026-07-12 00:05

Task
TASK-051 查詢煩惱 API（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-050 was merged into `feature/phase3` through PR #31 and marked it DONE.
- Created `feature/phase3-annoyance-query` from the synchronized Phase 3 integration branch.
- Added authenticated owner-scoped `GET /api/annoyances` and `GET /api/annoyances/{id}` endpoints.
- Implemented zero-based pagination with default size 20, maximum size 100, total metadata, optional solved/shared filters, and occurredAt/createdAt/score sorting.
- Kept page and size as query controls only; no page-number or score column was added to the Database.
- Added deterministic entry-id descending tie-breaking and excluded deleted entries and deleted users.
- Batch-loaded annoyance types, moods, and media for list responses to avoid per-entry lookup queries.
- Returned 404 for missing, deleted, or non-owned single entries and 400 for invalid pagination, sort, or query-parameter types.
- Added page response, Repository contract, Service, Controller, and exception-handler tests.
- Updated the formal API contract and moved this Task from IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `backend/src/main/java/com/monsters/dto/common/PageResponse.java`
- `backend/src/test/java/com/monsters/dto/common/PageResponseTest.java`

### Modified

- `backend/src/main/java/com/monsters/controller/annoyance/AnnoyanceController.java`
- `backend/src/main/java/com/monsters/exception/common/GlobalExceptionHandler.java`
- `backend/src/main/java/com/monsters/repository/entry/EntryMediaRepository.java`
- `backend/src/main/java/com/monsters/repository/entry/EntryRepository.java`
- `backend/src/main/java/com/monsters/service/annoyance/AnnoyanceService.java`
- `backend/src/test/java/com/monsters/controller/annoyance/AnnoyanceControllerTest.java`
- `backend/src/test/java/com/monsters/exception/common/GlobalExceptionHandlerTest.java`
- `backend/src/test/java/com/monsters/repository/entry/EntryMediaRepositoryTest.java`
- `backend/src/test/java/com/monsters/repository/entry/EntryRepositoryTest.java`
- `backend/src/test/java/com/monsters/service/annoyance/AnnoyanceServiceTest.java`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None.

### Tests

- `./gradlew test` passed: 171 tests, 0 failures, 0 errors.
- Spring application context and Spring Data Repository query validation passed.
- Pagination boundary, default sort, score sort, boolean filters, empty pages, owner scope, soft delete, batch lookup, single query, and invalid parameter handling are covered.
- `git diff --check` passed.
- `CHANGE_HISTORY.csv` was imported, inspected, and rendered as a 13-column table with the spreadsheet runtime.

### system_data Reference

- Rechecked the old annoyance account search, solved search, history list, and shared-query flows.
- Retained the useful intent of owner history and solved filtering.
- Did not reuse account-in-path authorization, unpaginated list loading, the separate legacy annoyance table, unrestricted shared queries, or legacy response models.
- `system_data/` was not modified.

### API

- Added `GET /api/annoyances` with `page`, `size`, `sort`, `isSolved`, and `isShared` query parameters.
- Added owner-only `GET /api/annoyances/{id}`.
- Added the common page response metadata contract and 400 handling for invalid query-parameter types.

### Database

- No schema, seed, index, or migration change.
- Pagination uses Spring Data Pageable and generated LIMIT/OFFSET behavior; no page field was added.
- Score sorting joins the existing `moods.score`; no score field was duplicated in entries.

### UI

- No Flutter file was changed.
- The paginated response contract is ready for the later Flutter history integration Task.

### Pending

- Review and merge the Task PR into `feature/phase3`.
- Database execution-plan tuning can be revisited with production-volume metrics; no speculative index was added in this Task.

---

## 2026-07-11 23:50

Task
TASK-050 Backend layer-first package layout refactor（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-049 was merged into `feature/phase3` through PR #30 and marked it DONE.
- Created `refactor/phase3-backend-package-layout` from the synchronized Phase 3 integration branch.
- Reorganized Backend production and test packages from `com.monsters.<module>.<layer>` to `com.monsters.<layer>.<module>` as explicitly requested.
- Moved Controller, DTO, Entity, Exception, Mapper, Repository, Security, Service, Storage, and Config packages while preserving module boundaries.
- Mapped shared code to the `common` module under each layer, such as `com.monsters.entity.common` and `com.monsters.security.common`.
- Kept `MonstersApplication` in root package `com.monsters` so Spring component, configuration, Entity, and Repository scanning still covers every layer.
- Updated package declarations and imports in all affected production and test Java files.
- Verified every one of the 120 named-package Java files has a package declaration matching its physical directory.
- Removed empty feature-first directories and confirmed no old package reference remains outside historical Log and `system_data`.
- Updated the formal package architecture rules and moved this extra task from IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- None; all Java changes are tracked as package moves and import updates.

### Moved

- `com.monsters.<module>.controller` → `com.monsters.controller.<module>`
- `com.monsters.<module>.dto` → `com.monsters.dto.<module>`
- `com.monsters.<module>.entity` → `com.monsters.entity.<module>`
- `com.monsters.<module>.mapper` → `com.monsters.mapper.<module>`
- `com.monsters.<module>.repository` → `com.monsters.repository.<module>`
- `com.monsters.<module>.service` → `com.monsters.service.<module>`
- `com.monsters.<module>.storage` → `com.monsters.storage.<module>`
- `com.monsters.common.config` → `com.monsters.config.common`
- `com.monsters.common.exception` → `com.monsters.exception.common`
- `com.monsters.common.security` → `com.monsters.security.common`
- Matching test packages under `backend/src/test/java/com/monsters/`

### Modified

- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `backend/README.md`
- `docs/API_SPEC.md`
- `docs/CODING_STANDARD.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
- `docs/PROJECT_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- No source file was deleted; only empty old package directories were removed.

### Tests

- `./gradlew clean test build` passed: 160 tests, 0 failures, 0 errors.
- All Spring application context, Security, JWT, JPA Repository, Entity converter, R2 storage, and Annoyance tests passed after package relocation.
- Physical path versus declared package check passed for all 120 named-package Java files.
- Old feature-first package search passed with zero matches outside historical Log and `system_data`.
- `git diff --check` passed.
- `CHANGE_HISTORY.csv` was imported, inspected, and rendered as a 13-column table with the spreadsheet runtime.

### system_data Reference

- Checked the old Backend directory organization only as historical context.
- Did not reuse old `com.example.demo` code, package names, framework patterns, business logic, or dependencies.
- The refactor is based on the user's explicit layer-first requirement and current formal architecture, not the old implementation.
- `system_data/` was not modified.

### API

- No endpoint, request, response, status code, authentication, or runtime behavior change.
- API specification updates only replace Java implementation package references.

### Database

- No Entity mapping behavior, schema, seed, SQL, or migration change.
- No migration required.

### Notes

- Future Backend code must use `com.monsters.<layer>.<module>`; feature-first packages are prohibited by the updated Coding Standard.
- The next Phase 3 feature Task remains the query Annoyance API.

---

## 2026-07-11 23:38

Task
TASK-049 Phase 3 新增煩惱 API（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-048 was merged into `feature/phase3` through PR #29 and marked it DONE.
- Created `feature/phase3-annoyance-create` from the synchronized Phase 3 integration branch.
- Added authenticated `POST /api/annoyances` with the approved multipart JSON, primary media, and optional drawing contract.
- Added request validation for category, record method, score, default private sharing, and the TEXT versus media combination.
- Normalized category codes and converted request occurrence timestamps to `Asia/Taipei` before storing MySQL `DATETIME` values.
- Kept R2 uploads outside the Database transaction and delegated Entry plus EntryMedia writes to a separate transactional Spring bean, allowing commit failures to propagate back to the upload orchestrator.
- Added best-effort cleanup for every R2 object uploaded by a failed request; cleanup failures neither expose object keys nor replace the original failure.
- Added MIME type plus filename extension validation and explicit 413 behavior for per-file and global multipart limits.
- Added readable 400 responses for malformed JSON, invalid multipart data, and missing multipart parts.
- Added 17 tests and moved TASK-049 from TODO through IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `backend/src/main/java/com/monsters/annoyance/dto/CreateAnnoyanceRequest.java`
- `backend/src/main/java/com/monsters/annoyance/service/AnnoyancePersistenceService.java`
- `backend/src/main/java/com/monsters/annoyance/service/CreatedAnnoyance.java`
- `backend/src/main/java/com/monsters/annoyance/service/NewEntryMedia.java`
- `backend/src/main/java/com/monsters/common/exception/PayloadTooLargeException.java`
- `backend/src/test/java/com/monsters/annoyance/dto/CreateAnnoyanceRequestTest.java`
- `backend/src/test/java/com/monsters/annoyance/service/AnnoyancePersistenceServiceTest.java`

### Modified

- `README.md`
- `backend/README.md`
- `backend/src/main/java/com/monsters/annoyance/controller/AnnoyanceController.java`
- `backend/src/main/java/com/monsters/annoyance/service/AnnoyanceService.java`
- `backend/src/main/java/com/monsters/common/exception/GlobalExceptionHandler.java`
- `backend/src/main/java/com/monsters/entry/storage/R2EntryMediaStorageService.java`
- `backend/src/main/resources/application.yml`
- `backend/src/test/java/com/monsters/annoyance/controller/AnnoyanceControllerTest.java`
- `backend/src/test/java/com/monsters/annoyance/service/AnnoyanceServiceTest.java`
- `backend/src/test/java/com/monsters/common/exception/GlobalExceptionHandlerTest.java`
- `backend/src/test/java/com/monsters/entry/storage/R2EntryMediaStorageServiceTest.java`
- `docker-compose.yml`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Tests

- `./gradlew clean test build` passed: 160 tests, 0 failures, 0 errors.
- `docker compose config --quiet` passed.
- `git diff --check` passed.
- Static checks found no TODO, FIXME, console output, stack-trace printing, credential, or object-key logging in the new production flow.
- `CHANGE_HISTORY.csv` was imported, inspected, and rendered as a 13-column table with the spreadsheet runtime.
- Docker Desktop is not running, so a live R2 and MySQL end-to-end multipart request was not executed; upload, cleanup, transaction, Controller, validation, and exception behavior are covered by isolated tests.

### system_data Reference

- Rechecked the old Annoyance Controller, Service, Entity, Flutter model, and create chat flow.
- Reused the intent for category, one primary record, optional drawing, score, sharing, and occurrence time.
- Did not reuse Base64 payloads, account input from Client, local file paths, Controller business logic, integer booleans, console output, or random monster rewards.
- `system_data/` was not modified.

### API

- Implemented `POST /api/annoyances` as authenticated `multipart/form-data` with `request`, optional `contentFile`, and optional `drawingFile` parts.
- Added 201 success response through the shared `ApiResponse` envelope; Phase 3 reward remains null.
- Added 400 handling for malformed or missing multipart input and 413 handling for oversized uploads.
- Media responses contain Backend download paths and never contain R2 object keys or bucket details.

### Database

- No schema change and no migration required.
- Entry and EntryMedia writes execute in one Database transaction after external uploads complete.

### Notes

- `MULTIPART_MAX_FILE_SIZE` defaults to 50MB and `MULTIPART_MAX_REQUEST_SIZE` defaults to 60MB; per-media limits remain stricter where applicable.
- Every existing annoyance type row is treated as enabled because the approved Database schema has no `is_active` field.
- The next Task is the query Annoyance API.

---

## 2026-07-11 17:33

Task
TASK-048 Phase 3 Annoyance Core（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-047 was merged into `feature/phase3` through PR #28 and marked it DONE.
- Created `feature/phase3-annoyance-core` from the synchronized Phase 3 integration branch.
- Applied D11-A and introduced the shared `Entry` aggregate and Repository for Annoyance and future Diary features.
- Applied D12-A and added Annoyance DTOs, Mapper, Service lookup and primary-record validation, plus the `/api/annoyances` Controller skeleton; endpoint methods remain in later API Tasks.
- Applied D13-A and corrected the API specification so private media persistence consistently says object key instead of URL.
- Applied D14-A and added neutral `SCORE_1` through `SCORE_5` mood seeds for shared Annoyance and Diary use.
- Added a guarded and rerunnable migration that rejects duplicate or conflicting mood rows before adding the unique score constraint and seeds.
- Added owner-scoped soft-delete lookup foundations and ensured object keys are never included in Annoyance response DTOs.
- Added explicit `Asia/Taipei` conversion from Database `DATETIME` to API `OffsetDateTime`.
- Added 18 tests and moved TASK-048 from TODO through IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. The oldest record is 2026-06-29, so no record older than one month exists and none was deleted.

### Added

- `backend/src/main/java/com/monsters/entry/entity/Entry.java`
- `backend/src/main/java/com/monsters/entry/entity/EntryType.java`
- `backend/src/main/java/com/monsters/entry/entity/Mood.java`
- `backend/src/main/java/com/monsters/entry/repository/EntryRepository.java`
- `backend/src/main/java/com/monsters/entry/repository/MoodRepository.java`
- `backend/src/main/java/com/monsters/annoyance/controller/AnnoyanceController.java`
- `backend/src/main/java/com/monsters/annoyance/dto/AnnoyanceCategoryResponse.java`
- `backend/src/main/java/com/monsters/annoyance/dto/AnnoyanceMediaResponse.java`
- `backend/src/main/java/com/monsters/annoyance/dto/AnnoyanceRecordMethod.java`
- `backend/src/main/java/com/monsters/annoyance/dto/AnnoyanceResponse.java`
- `backend/src/main/java/com/monsters/annoyance/mapper/AnnoyanceMapper.java`
- `backend/src/main/java/com/monsters/annoyance/service/AnnoyanceService.java`
- `backend/src/test/java/com/monsters/annoyance/controller/AnnoyanceControllerTest.java`
- `backend/src/test/java/com/monsters/annoyance/mapper/AnnoyanceMapperTest.java`
- `backend/src/test/java/com/monsters/annoyance/service/AnnoyanceServiceTest.java`
- `backend/src/test/java/com/monsters/entry/entity/EntryTest.java`
- `backend/src/test/java/com/monsters/entry/entity/MoodSchemaTest.java`
- `backend/src/test/java/com/monsters/entry/entity/MoodTest.java`
- `backend/src/test/java/com/monsters/entry/repository/EntryRepositoryTest.java`
- `backend/src/test/java/com/monsters/entry/repository/MoodRepositoryTest.java`
- `database/migrations/20260711_03_make_mood_score_unique.sql`

### Modified

- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `database/init/01_schema.sql`
- `database/init/README.md`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Tests

- `./gradlew test` passed: 143 tests, 0 failures, 0 errors.
- `./gradlew build` passed and produced the Backend artifacts.
- `docker compose config --quiet` passed.
- `git diff --check` passed.
- Static checks found no TODO, FIXME, console output, or stack-trace printing in the new production code.
- Docker Desktop is not running, so MySQL 8.4 could not execute the migration; fresh schema and migration behavior are covered by static contract tests.
- `CHANGE_HISTORY.csv` was imported, inspected, and rendered with the spreadsheet runtime after this entry was added.

### system_data Reference

- Rechecked the old Annoyance Entity, Bean, Controller, Service, DAO, Flutter model, and chat score flow.
- Reused the business intent for category, one primary record, drawing, score, solved state, shared state, and occurrence time.
- Did not reuse account-string ownership, separate annoyance table, Base64 media columns, integer booleans, controller business logic, random monster rewards, local file paths, console output, or unrestricted shared queries.
- Kept Phase 3 rewards null as specified; real reward integration remains in Phase 6.
- `system_data/` was not modified.

### API

- Added response DTO and mapping foundations only; no new endpoint method is exposed in this Task.
- Response media contains authenticated Backend download paths and never contains R2 bucket or object key values.
- Corrected the media persistence wording to private object key and preserved `+08:00` response timestamps.

### Database

- Added shared `Entry` and `Mood` JPA mappings and owner-scoped Entry Repository lookup.
- Changed the fresh schema mood score index to a unique constraint and seeded `SCORE_1` through `SCORE_5`.
- Added `20260711_03_make_mood_score_unique.sql`; migration is required for existing databases and intentionally stops on duplicate or conflicting mood data.

### Notes

- Run the mood migration against a reviewed MySQL backup before enabling the later create API in an existing environment.
- The next Task is the create Annoyance API and will reuse this core validation and mapping foundation.

---

## 2026-07-11 17:02

Task
TASK-047 Phase 3 entry_media 與 private R2 上傳流程（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-046 was merged into `feature/phase3` through PR #27 and marked it DONE.
- Created `feature/phase3-entry-media-r2` from the synchronized Phase 3 integration branch.
- Applied approved decisions D9-A and D10-A: private Backend-streamed media and ffprobe duration validation.
- Added EntryMedia Entity, lowercase media type converter, Repository, private R2 upload/download/delete abstraction, and single-range support.
- Added MIME type, size, audio duration, video duration, object key prefix, and R2 configuration validation.
- Separated public avatar storage from a dedicated private entry media bucket so public bucket access cannot expose private annoyance media.
- Updated the shared Java S3 client to Cloudflare's current `region=auto`, path-style, and chunked-encoding-disabled configuration.
- Added FFmpeg to the Backend runtime image and documented local ffprobe and environment requirements.
- Updated schema and a guarded one-time migration; the migration stops when legacy entry media rows exist and requires a separately reviewed data migration.
- Added 28 tests and moved TASK-047 from TODO through IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/entry/entity/EntryMedia.java`
- `backend/src/main/java/com/monsters/entry/entity/EntryMediaType.java`
- `backend/src/main/java/com/monsters/entry/entity/EntryMediaTypeConverter.java`
- `backend/src/main/java/com/monsters/entry/repository/EntryMediaRepository.java`
- `backend/src/main/java/com/monsters/entry/storage/DownloadedEntryMedia.java`
- `backend/src/main/java/com/monsters/entry/storage/EntryMediaStorageService.java`
- `backend/src/main/java/com/monsters/entry/storage/FfprobeMediaDurationProbe.java`
- `backend/src/main/java/com/monsters/entry/storage/MediaDurationProbe.java`
- `backend/src/main/java/com/monsters/entry/storage/R2EntryMediaStorageService.java`
- `backend/src/main/java/com/monsters/entry/storage/StoredEntryMedia.java`
- `backend/src/test/java/com/monsters/common/storage/R2StorageConfigTest.java`
- `backend/src/test/java/com/monsters/entry/entity/EntryMediaTest.java`
- `backend/src/test/java/com/monsters/entry/entity/EntryMediaTypeConverterTest.java`
- `backend/src/test/java/com/monsters/entry/repository/EntryMediaRepositoryTest.java`
- `backend/src/test/java/com/monsters/entry/storage/FfprobeMediaDurationProbeTest.java`
- `backend/src/test/java/com/monsters/entry/storage/R2EntryMediaStorageServiceTest.java`
- `database/migrations/20260711_02_make_entry_media_private.sql`

### Modified

- `README.md`
- `backend/Dockerfile`
- `backend/README.md`
- `backend/src/main/java/com/monsters/common/storage/R2Properties.java`
- `backend/src/main/java/com/monsters/common/storage/R2StorageConfig.java`
- `backend/src/main/resources/application.yml`
- `backend/src/test/java/com/monsters/common/storage/R2AvatarStorageServiceTest.java`
- `database/init/01_schema.sql`
- `database/init/README.md`
- `docker-compose.yml`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `docs/UI_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Tests

- First `./gradlew test` run found and fixed an AWS SDK test import path error.
- Final `./gradlew test` passed: 125 tests, 0 failures, 0 errors.
- `./gradlew build` passed and produced the Backend artifacts.
- `docker compose config --quiet` passed.
- `git diff --check` passed.
- Docker image build could not run because Docker Desktop was not running; the Dockerfile FFmpeg installation remains to be verified by CI or a running Docker daemon.
- MySQL migration execution could not run without the Docker MySQL service; schema and migration received static consistency checks.
- `CHANGE_HISTORY.csv` was imported and inspected as a 13-column table.

### system_data Reference

- Rechecked the old local FileUploadService, Annoyance Entity, Flutter media pickers, and Base64 media flow.
- Reused only the intent to support image, audio, video, and drawing media.
- Did not reuse original-filename local storage, Base64-in-Database fields, direct public media access, console output, destructive delete-all behavior, or exception messages that expose internal details.
- `system_data/` was not modified.

### API

- Added private media metadata and authenticated Backend download URL semantics.
- Added `GET /api/annoyances/{id}/media/{mediaId}` with owner/shared authorization and single HTTP Range behavior; Controller implementation remains in the Annoyance API Task.
- Object key, bucket, credentials, temporary paths, and ffprobe output must never be returned.

### Database

- Replaced `media_url` with unique `object_key` and added content type, file size, duration, video, size, and duration constraints.
- Added `20260711_02_make_entry_media_private.sql`; migration is required and intentionally stops on non-empty legacy media data.

### Notes

- `R2_ENTRY_MEDIA_BUCKET` must reference a dedicated private bucket; do not enable public access.
- The Backend R2 token should use Object Read & Write scoped only to the required buckets; bucket administration permission is unnecessary.
- The next Task is the Annoyance Entity / DTO / Repository / Service / Controller foundation.

---

## 2026-07-11 13:06

Task
TASK-046 Phase 3 建立 annoyance_type（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-045 was merged into `feature/phase3` through PR #26 and marked it DONE.
- Created `feature/phase3-annoyance-type` from the synchronized Phase 3 integration branch.
- Added the `AnnoyanceType` JPA Entity and `AnnoyanceTypeRepository` using stable code lookup and display-order sorting.
- Added the six approved categories: ACADEMIC, CAREER, LOVE, FRIENDSHIP, FAMILY, and OTHER.
- Updated the fresh-install schema and added a one-time manual migration for existing databases.
- Added Entity and Repository contract tests and moved TASK-046 from TODO through IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/annoyance/entity/AnnoyanceType.java`
- `backend/src/main/java/com/monsters/annoyance/repository/AnnoyanceTypeRepository.java`
- `backend/src/test/java/com/monsters/annoyance/entity/AnnoyanceTypeTest.java`
- `backend/src/test/java/com/monsters/annoyance/repository/AnnoyanceTypeRepositoryTest.java`
- `database/migrations/20260711_01_add_annoyance_type_codes_and_seed.sql`

### Modified

- `database/init/01_schema.sql`
- `database/init/README.md`
- `docs/DATABASE_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Tests

- `./gradlew test` in `backend/` passed: 97 tests, 0 failures, 0 errors.
- The four new Entity tests and three new Repository contract tests passed.
- `git diff --check` passed.
- Docker Desktop was not running, so the MySQL 8.4 container validation could not be executed.
- A temporary local MySQL 9.7 server was attempted for SQL validation but crashed during startup in the sandbox; schema and migration received static consistency checks instead.
- `CHANGE_HISTORY.csv` was imported and inspected as a 13-column table.

### system_data Reference

- Rechecked the system manual annoyance pages and the merged Phase 3 audit.
- Referenced the old six category names and display sequence only.
- Did not reuse the old numeric ID enum, singular table name, mutable Lombok Entity, or generic DAO hierarchy.
- `system_data/` was not modified.

### API

- No endpoint or response change.
- Repository lookup by stable category code prepares the approved Annoyance API contract.

### Database

- Added `annoyance_types.code VARCHAR(50) NOT NULL` with a unique constraint.
- Added six ordered seed records to the fresh-install schema.
- Added a one-time migration for existing databases; migration is required for environments whose schema predates TASK-046.

### Notes

- The migration must be run exactly once on an existing database and reviewed against any local custom annoyance type rows before execution.
- The next Task is the entry_media image, audio, video, drawing, and R2 upload flow.

---

## 2026-07-11 09:34

Task
TASK-045 Phase 3 業務邏輯與 UI 互動整理（REVIEW）

Agent
Codex

### Completed

- Confirmed TASK-044 was merged into `feature/phase3` through PR #24 and marked it DONE.
- Converted the legacy annoyance audit into a typed new-version business flow and Flutter UI state proposal.
- Defined common owner validation, pagination, draft preservation, structured chat selection, and error-state principles.
- Received approval for D1-A, D2-A, D3-A, D4-A, D5-B, D6-A, D7-A, and D8-A.
- Finalized video support, one primary record method plus optional drawing, multipart upload, code/score lookup, page/size/sort pagination, structured chat selection, and consistent media limits.
- Kept monster reward delivery out of Phase 3 and assigned the annoyance reward integration to Phase 6.
- Documented at least two options with advantages, disadvantages, and risks for every decision.
- Synchronized the approved decisions to Decision, Project, Database, API, UI, and Task specifications.
- Moved TASK-045 from IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `docs/PHASE3_ANNOYANCE_DESIGN_PROPOSAL.md`

### Modified

- `docs/DECISIONS.md`
- `docs/PROJECT_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Tests

- Documentation-only change; backend and Flutter compilation were not required.
- `git diff --check` passed.
- Confirmed all eight approved decisions are represented consistently across formal specifications.
- `CHANGE_HISTORY.csv` was imported and inspected as a 13-column table.

### system_data Reference

- Used the merged TASK-044 audit in `docs/SYSTEM_DATA_REFERENCE.md` as the source.
- Reused only the chat flow, six categories, drawing interaction, 1-to-5 scale, sharing behavior, solved-state intent, and reward experience.
- `system_data/` was not modified.

### API

- Defined multipart create/update, stable code/score inputs, owner validation, page/size/sort pagination, explicit solve/share target states, response shape, media limits, and R2 failure handling.

### Database

- Added stable annoyance category codes, unique mood scores, video media type, and one-primary-record-method rules to the specification.
- Confirmed D6-A requires no page-number Database field; implementation uses query limit/offset.

### Notes

- Approved combination: D1-A, D2-A, D3-A, D4-A, D5-B, D6-A, D7-A, D8-A.
- Per the user's explicit instruction, unrelated working-tree changes were excluded from this Task's staging and commit; sensitive R2 configuration was not staged.

---

## 2026-07-10 19:08

Task
TASK-044 Phase 3 舊煩惱流程檢查（REVIEW）

Agent
Codex

### Completed

- Reviewed the old system manual and introduction for annoyance, chat, mood drawing, score, sharing, solved state, and reward flows.
- Reviewed the related old Flutter pages, models, repositories, API interface, assets, Spring Boot controller, service, DAO, entity, history, and social query behavior.
- Recorded the eight-step legacy annoyance flow, six categories, 1-to-5 score visuals, optional drawing tools, sharing toggle, solved-state flow, and monster reward response.
- Mapped old fields and behavior to the normalized Entry architecture without treating old IDs or implementations as the new specification.
- Recorded legacy defects and unsafe patterns that must not be reused.
- Identified formal specification gaps that must be resolved before Annoyance implementation begins.
- Updated the Phase 3 first Task from TODO through IN PROGRESS to REVIEW.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `docs/SYSTEM_DATA_REFERENCE.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Tests

- Documentation-only task; backend and Flutter compilation were not required.
- `git diff --check` passed.
- Confirmed every documented legacy source path exists.
- Cross-checked the six categories, score range, sharing behavior, drawing controls, and reward response against both manual text/screenshots and source code.
- Imported and inspected the updated `CHANGE_HISTORY.csv` as a 13-column table.

### system_data Reference

- Referenced both old-system PDFs, the annoyance chat and drawing pages, history detail page, annoyance model/repository/API interface, backend annoyance layers, history/social controllers, mood score assets, and reward asset.
- Reused only business intent, flow order, UI vocabulary, categories, score visuals, and asset references.
- Did not reuse the old widget structure, integer state machine, API paths, Base64 media storage, account-based ownership, hardcoded domain/path, JSON assembly, exception handling, or flawed validation.
- `system_data/` was not modified.

### API

- No API change.
- Recorded that Annoyance Request/Response, media upload, pagination, owner validation, validation errors, and reward response remain undefined.

### Database

- No Database change or migration.
- Recorded the video media-type mismatch and missing `annoyance_types` / `moods` seed data as later DoR items.

### Notes

- The next Phase 3 Task should convert the audit into explicit business/UI proposals and resolve the documented options before implementation.
- This Task remains REVIEW until its PR is merged into `feature/phase3`.

---

## 2026-07-10 18:57

Task
DOC-012 建立 Phase 整合分支流程（REVIEW）

Agent
Codex

### Completed

- Adopted the Phase integration branch workflow for Phase 3 and all subsequent phases.
- Defined `feature/phase<n>` as the integration branch created from `develop`.
- Defined Phase Task branches as independent branches created from the corresponding Phase branch.
- Defined Task PR targets as the corresponding Phase branch and the completed Phase PR target as `develop`.
- Updated branch roles, naming, startup flow, merge restrictions, PR direction, issue flow, and cleanup rules.
- Updated README Git instructions and recorded the decision in `docs/DECISIONS.md`.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `README.md`
- `docs/GIT_RULE.md`
- `docs/DECISIONS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Tests

- Documentation-only change; compile and automated tests were not required.
- `git diff --check` passed.
- Git flow references were searched to confirm the previous direct `develop` Task flow was replaced in the updated sections.
- `CHANGE_HISTORY.csv` was imported and inspected as a 13-column table; the header and all five new DOC-012 rows matched the expected structure.

### system_data Reference

- `system_data/` was not required and was not modified because this task only changes the repository branching policy.

### API

- None

### Database

- None

### Notes

- This documentation branch was created from `feature/phase3` and should be merged back into `feature/phase3`.
- After this change is merged, all Phase 3 and later Task branches must use the corresponding Phase integration branch as their base.

---

## 2026-07-10 18:48

Task
TASK-043 App icon / Logo 圖片套用（REVIEW）

Agent
Codex

### Completed

- Regenerated Android, iOS, and Web app icon images from root `icon/icon.png`.
- Added Flutter image assets from root icon/logo sources.
- Added `app_logo.png` to splash, login, and register pages.
- Added Flutter asset declarations for `app_icon.png` and `app_logo.png`.
- Updated UI spec, frontend README, task status, and logs for the logo asset usage.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/assets/images/app_icon.png`
- `frontend/assets/images/app_logo.png`

### Modified

- `frontend/android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `frontend/android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `frontend/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `frontend/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `frontend/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`
- `frontend/web/favicon.png`
- `frontend/web/icons/*.png`
- `frontend/lib/pages/splash_page.dart`
- `frontend/lib/pages/login_page.dart`
- `frontend/lib/pages/register_page.dart`
- `frontend/pubspec.yaml`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Tests

- Not run by request. Image dimensions were checked locally with `sips`.
- Dart format was run for the touched Flutter page files.

### system_data Reference

- No `system_data/` code was needed for this image-only task.
- Root `icon/icon.png` and `icon/標題.png` were used as the source images.

### Notes

- `backend/src/main/resources/application.yml` remains an unrelated local configuration change and was not modified.
- Task remains in REVIEW until tests and GitHub push are completed.

---

## 2026-07-10 18:40

Task
TASK-042 Phase 2 狀態收尾（DONE）

Agent
Codex

### Completed

- Confirmed Phase 0 and Phase 1 are fully marked DONE.
- Confirmed Phase 2 review items have been merged into `develop`.
- Updated Phase 2 account, 30-day login persistence, Flutter Google login, fixed Web Google local port, and test tasks from REVIEW to DONE.
- Corrected previous Phase 2 log headings from REVIEW to DONE where the corresponding work is now merged.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Tests

- Documentation/status-only change; compile and automated tests were not rerun.
- Git history was checked locally to verify the Phase 2 commits are present in `develop`.

### system_data Reference

- Confirmed `system_data/` exists and was not modified.
- No old system behavior was needed because this task only corrected task status metadata.

### Notes

- `backend/src/main/resources/application.yml` remains an unrelated local configuration change and was not modified.

---

## 2026-07-10 13:19

Task
TASK-041 正式啟用帳號欄位（DONE）

Agent
Codex

### Completed

- Enabled `account` as a formal required unique user field for registration.
- Added backend account validation, normalization, duplicate checking, and response fields.
- Updated Google first-login user creation to generate a unique account from the email prefix.
- Updated Flutter registration page to collect and validate account.
- Updated Flutter auth models and session test data so login users include account.
- Updated API, database, project, UI, task, and README documentation.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `backend/src/main/java/com/monsters/auth/dto/AuthUserResponse.java`
- `backend/src/main/java/com/monsters/auth/dto/RegisterRequest.java`
- `backend/src/main/java/com/monsters/auth/dto/RegisterResponse.java`
- `backend/src/main/java/com/monsters/auth/service/AuthService.java`
- `backend/src/main/java/com/monsters/user/entity/User.java`
- `backend/src/main/java/com/monsters/user/repository/UserRepository.java`
- `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/auth/service/AuthServiceTest.java`
- `backend/src/test/java/com/monsters/common/security/JwtTokenServiceTest.java`
- `backend/src/test/java/com/monsters/common/security/SecurityConfigTest.java`
- `backend/src/test/java/com/monsters/user/service/UserServiceTest.java`
- `database/init/01_schema.sql`
- `frontend/lib/models/auth_user.dart`
- `frontend/lib/models/auth_user.g.dart`
- `frontend/lib/models/register_result.dart`
- `frontend/lib/pages/register_page.dart`
- `frontend/lib/providers/auth_provider.dart`
- `frontend/lib/repositories/auth_repository.dart`
- `frontend/test/auth_session_store_test.dart`
- `frontend/test/login_page_test.dart`
- `frontend/test/register_page_test.dart`
- `docs/PROJECT_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- `database/init/01_schema.sql` now creates `users.account` as `NOT NULL`.
- Existing local databases created before this change may need manual migration if they contain users with null account.

### API

- `POST /api/auth/register` request now requires `account`.
- Register response includes `account`.
- Login and Google login user response includes `account`.

### Database

- `users.account` changed from compatibility-only nullable field to formal required unique field.

### Tests

- `./gradlew test`
- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub --dart-define=GOOGLE_CLIENT_ID=test-web-client.apps.googleusercontent.com`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub --dart-define=GOOGLE_CLIENT_ID=test-android-client.apps.googleusercontent.com --dart-define=GOOGLE_SERVER_CLIENT_ID=test-server-client.apps.googleusercontent.com`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --debug --no-codesign --no-pub --dart-define=GOOGLE_CLIENT_ID=test-ios-client.apps.googleusercontent.com --dart-define=GOOGLE_SERVER_CLIENT_ID=test-server-client.apps.googleusercontent.com`

### Notes

- `system_data/` reference: checked old account-based login and account-linked data flow.
- Reused only the intent of a stable user account identifier.
- Not reused: old account-as-cross-table-foreign-key pattern, old API paths, and page-level persistence.
- Existing unrelated `backend/src/main/resources/application.yml` changes were left untouched and are not part of this task.

## 2026-07-10 13:03

Task
TASK-040 Flutter Web Google 登入固定本機 port（DONE）

Agent
Codex

### Completed

- Added a macOS-friendly Flutter Web local launch script that fixes the local origin at `http://localhost:5050`.
- Updated Google login local testing documentation so Google Cloud OAuth only needs `http://localhost:5050` in Authorized JavaScript origins.
- Kept Google Web local testing on `GOOGLE_CLIENT_ID` only; no real Client ID is committed.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/tool/run_web_local.sh`

### Modified

- `frontend/README.md`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- No API contract change.

### Database

- None

### Tests

- `bash -n frontend/tool/run_web_local.sh`
- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`

### Notes

- `system_data/` reference: not needed for this local development startup fix.
- Google Cloud OAuth Client should add `http://localhost:5050` to Authorized JavaScript origins.
- Existing unrelated `backend/src/main/resources/application.yml` changes were left untouched and are not part of this task.

## 2026-07-10 12:51

Task
TASK-039 修正 Web Google 登入按鈕 Getting ready（DONE）

Agent
Codex

### Completed

- Fixed Web Google Sign-In initialization so `serverClientId` is only passed on Android / iOS.
- Updated README and specs to clarify Web local testing should pass only `GOOGLE_CLIENT_ID`.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `frontend/lib/services/google_sign_in_service.dart`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- No API contract change.

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub --dart-define=GOOGLE_CLIENT_ID=test-web-client.apps.googleusercontent.com`

### Notes

- `system_data/` reference: not needed for this SDK compatibility fix.
- Cause: `google_sign_in_web` does not support `serverClientId`; passing it in debug mode can leave the Web official button at `Getting ready`.
- Existing unrelated `backend/src/main/resources/application.yml` changes were left untouched and are not part of this task.

## 2026-07-10 12:20

Task
TASK-038 Flutter Google 登入（DONE）

Agent
Codex

### Completed

- Implemented approved option 1 for Flutter Google login using `google_sign_in` and `google_sign_in_web`.
- Added a Google Sign-In service that initializes SDK client IDs from dart-define values and returns Google ID Tokens.
- Updated login UI so Web uses the Google Identity Services official button, while Android and iOS use the shared Flutter Google login action.
- Updated Auth repository and controller to call existing `POST /api/auth/google-login`, save the returned session, and navigate to home.
- Updated logout to clear local session and attempt Google SDK sign-out.
- Added widget tests for Google ID Token login, Google backend error handling, Web authentication-event login, and Google sign-out during logout.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/lib/services/google_sign_in_service.dart`
- `frontend/lib/widgets/auth/google_sign_in_web_button.dart`
- `frontend/lib/widgets/auth/google_sign_in_web_button_stub.dart`
- `frontend/lib/widgets/auth/google_sign_in_web_button_web.dart`

### Modified

- `frontend/lib/config/app_config.dart`
- `frontend/lib/pages/login_page.dart`
- `frontend/lib/providers/auth_provider.dart`
- `frontend/lib/repositories/auth_repository.dart`
- `frontend/test/login_page_test.dart`
- `frontend/pubspec.yaml`
- `frontend/pubspec.lock`
- `frontend/ios/Runner.xcodeproj/project.pbxproj`
- `docs/DECISIONS.md`
- `docs/PROJECT_SPEC.md`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Uses existing `POST /api/auth/google-login`.
- No backend endpoint contract change.

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub --dart-define=GOOGLE_CLIENT_ID=test-web-client.apps.googleusercontent.com --dart-define=GOOGLE_SERVER_CLIENT_ID=test-server-client.apps.googleusercontent.com`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub --dart-define=GOOGLE_CLIENT_ID=test-android-client.apps.googleusercontent.com --dart-define=GOOGLE_SERVER_CLIENT_ID=test-server-client.apps.googleusercontent.com`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --debug --no-codesign --no-pub --dart-define=GOOGLE_CLIENT_ID=test-ios-client.apps.googleusercontent.com --dart-define=GOOGLE_SERVER_CLIENT_ID=test-server-client.apps.googleusercontent.com`

### Commit Message

```text
feat(frontend): 完成 Google 登入
```

### Notes

- `system_data/` reference: checked old Flutter login code and `google_sign_in_API.dart`.
- Reused only the intent of using Google Sign-In as the entry point.
- Not reused: old empty-password API login flow, direct Google user-data trust, direct page-level API code, and old global navigation/state patterns.
- Real Google OAuth Client IDs are intentionally not committed. Runtime must provide `GOOGLE_CLIENT_ID` and `GOOGLE_SERVER_CLIENT_ID`; backend `GOOGLE_CLIENT_IDS` must include the accepted audiences.
- iOS CocoaPods added the Google Sign-In resources copy build phase to the Runner Xcode project.
- Existing unrelated `backend/src/main/resources/application.yml` changes were left untouched and are not part of this task.

## 2026-07-10 08:17

Task
TASK-037 Flutter 30 天登入狀態保存（DONE）

Agent
Codex

### Completed

- Added shared Flutter session persistence for Web, Android, and iOS using the approved SharedPreferences package.
- Added `AuthSessionStore` to save `LoginResult` and last-opened time.
- Updated login flow to save session after successful login.
- Updated splash flow to restore valid sessions and navigate directly to home when the user has not logged out and opened the app within 30 days.
- Added logout flow from home to call logout, clear Authorization header, clear local session, and return to login.
- Added tests for session restore, session expiry, splash auto-navigation, and logout navigation.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/ios/Podfile`
- `frontend/lib/repositories/auth_session_store.dart`
- `frontend/test/auth_session_store_test.dart`

### Modified

- `frontend/lib/repositories/auth_repository.dart`
- `frontend/lib/providers/auth_provider.dart`
- `frontend/lib/pages/splash_page.dart`
- `frontend/lib/pages/home_page.dart`
- `frontend/test/login_page_test.dart`
- `frontend/test/widget_test.dart`
- `frontend/pubspec.yaml`
- `frontend/pubspec.lock`
- `frontend/ios/Flutter/Debug.xcconfig`
- `frontend/ios/Flutter/Release.xcconfig`
- `frontend/android/settings.gradle.kts`
- `frontend/ios/Runner.xcodeproj/project.pbxproj`
- `frontend/ios/Runner.xcworkspace/contents.xcworkspacedata`
- `docs/PROJECT_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Uses existing `POST /api/auth/login`.
- Uses existing `POST /api/auth/logout`.

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub`

### Commit Message

```text
feat(frontend): 保存三平台登入狀態
```

### Notes

- `system_data/` reference: checked old Flutter login pages that used SharedPreferences to remember self login.
- Reused only the intent of remembering login state.
- Not reused: old account-only persistence, direct page-level SharedPreferences access, `Navigator` routing, and missing expiry policy.
- Android Kotlin Gradle plugin was updated from 1.8.22 to 2.1.0 so the approved `shared_preferences` Android plugin can compile.
- Existing unrelated `backend/src/main/resources/application.yml` changes were left untouched and are not part of this task.

## 2026-07-10 08:00

Task
TASK-036 Flutter App Icon 三平台替換（REVIEW）

Agent
Codex

### Completed

- Replaced default Flutter launcher icons for Android, iOS, and Web with icons generated from root `icon/icon.png`.
- Generated Android mipmap launcher icons for all existing densities.
- Generated iOS AppIcon image set including the 1024px marketing icon without transparency.
- Generated Web favicon, PWA icons, and maskable icons.
- Updated Web manifest theme and background colors from Flutter default blue to the legacy warm yellow / brown palette.
- Updated UI spec, frontend README, and task status for the shared app icon source and generation rules.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `frontend/android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `frontend/android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `frontend/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `frontend/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `frontend/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`
- `frontend/web/favicon.png`
- `frontend/web/icons/*.png`
- `frontend/web/manifest.json`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub`

### Commit Message

```text
style(frontend): 替換三平台 app icon
```

### Notes

- `system_data/` reference: checked available files. No direct old app icon implementation was needed for this asset-only task.
- Used `icon/icon.png` as the icon source. `icon/標題.png` was not used because it is a title image with a non-square ratio.
- Existing unrelated `backend/src/main/resources/application.yml` changes were left untouched and are not part of this task.

## 2026-07-10 07:28

Task
TASK-035 Phase 2 測試與 Task 標示整理（DONE）

Agent
Codex

### Completed

- Updated previous Flutter Phase 2 task labels from `REVIEW` to `DONE` because they are now merged into `develop`.
- Added Phase 2 test report and test matrix.
- Fixed `backend/gradlew` executable permission so backend tests can run through the project wrapper.
- Ran backend tests, frontend analyze, frontend tests, and Web / Android / iOS builds.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `docs/PHASE2_TEST_REPORT.md`

### Modified

- `backend/gradlew`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- `cd backend && ./gradlew test`
- `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter build web --no-pub`
- `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub`
- `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub`
- `cd frontend && /Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub`

### Commit Message

```text
test(phase2): 補齊會員功能測試報告
```

### Notes

- `system_data/` reference: no additional old-system code was needed for this test-summary task; previous Phase 2 feature tasks already recorded their references.
- Existing untracked `backend/bin/` was left untouched.
- Android build still reports a Kotlin version future-deprecation warning; it does not block the build.

## 2026-07-10 07:16

Task
TASK-034 Flutter 密碼鎖頁（REVIEW）

Agent
Codex

### Completed

- Added shared Flutter password lock page for Web, Android, and iOS.
- Added password lock status and verification models.
- Added `UserRepository` calls for `PUT /api/users/me/password-lock` and `POST /api/users/me/password-lock/verify`.
- Added Riverpod password lock controller for setting and verifying lock password.
- Added `/password-lock` route and home-page entry action.
- Added widget tests for required validation, mismatch validation, successful set, successful verify, failed verify, and home navigation.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/lib/models/password_lock_status.dart`
- `frontend/lib/models/password_lock_status.g.dart`
- `frontend/lib/models/password_lock_verification.dart`
- `frontend/lib/models/password_lock_verification.g.dart`
- `frontend/lib/pages/password_lock_page.dart`
- `frontend/lib/providers/password_lock_provider.dart`
- `frontend/test/password_lock_page_test.dart`

### Modified

- `frontend/lib/repositories/user_repository.dart`
- `frontend/lib/pages/home_page.dart`
- `frontend/lib/routes/app_router.dart`
- `frontend/lib/routes/app_routes.dart`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Uses existing `PUT /api/users/me/password-lock`.
- Uses existing `POST /api/users/me/password-lock/verify`.

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub test/password_lock_page_test.dart`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub`

### Commit Message

```text
feat(frontend): 新增密碼鎖頁
```

### Notes

- `system_data/` reference: checked old `setting_lock_page.dart`, `check_lock_page.dart`, `lock_page.dart`, `lock_widget.dart`, and member repository lock-related methods.
- Reused the set / confirm / verify interaction flow only.
- Not reused: old SharedPreferences PIN storage, local lock state, `Navigator` routing, direct old repository calls, and hard-coded page colors.
- Forgot password lock flow is not implemented in this task because no formal API is defined yet.

## 2026-07-10 07:07

Task
TASK-033 前端色調調整為舊版暖黃色 / 棕色

Agent
Codex

### Completed

- Cleaned local branch state by deleting local branches already merged into `origin/main`.
- Kept `main`, `develop`, `feature/flutter-register-page`, and `feature/profile-page`; then created `feature/frontend-legacy-colors` for this UI color task.
- Updated centralized Flutter theme colors to match old system warm yellow and brown palette.
- Updated UI spec and frontend README with legacy color token mapping.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `frontend/lib/theme/app_colors.dart`
- `docs/UI_SPEC.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub`

### Commit Message

```text
style(frontend): 調整前端為舊版暖色調
```

### Notes

- `system_data/` reference: checked `system_data/front-end/monsters_front_end/lib/pages/settings/style.dart`.
- Reused old color intent and values only; did not copy old widget structure or page-level hard-coded styling.
- Branch cleanup used safe local branch deletion for branches already merged to `origin/main`.

## 2026-07-09 20:58

Task
TASK-032 Flutter 個人資料頁（REVIEW）

Agent
Codex

### Completed

- Added shared Flutter profile page for Web, Android, and iOS.
- Added `UserProfile` model, `UserRepository`, and Riverpod `UserProfileController`.
- Connected `/profile` go_router route and added a home-page entry action.
- Implemented profile loading, API error retry, user name validation, birthday validation, and profile update success feedback.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/lib/models/user_profile.dart`
- `frontend/lib/models/user_profile.g.dart`
- `frontend/lib/pages/profile_page.dart`
- `frontend/lib/providers/user_profile_provider.dart`
- `frontend/lib/repositories/user_repository.dart`
- `frontend/test/profile_page_test.dart`

### Modified

- `frontend/lib/pages/home_page.dart`
- `frontend/lib/routes/app_router.dart`
- `frontend/lib/routes/app_routes.dart`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Uses existing `GET /api/users/me`.
- Uses existing `PUT /api/users/me`.

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub test/profile_page_test.dart`

### Commit Message

```text
feat(frontend): 新增個人資料頁
```

### Notes

- `system_data/` reference: checked old `drawer_personalInfo.dart`, `edit_personalInfo.dart`, `memberRepo.dart`, and `memberModel.dart`; reused the profile display/edit flow only.
- Not reused: old global account state, direct HTTP calls, old API paths, `Navigator` routing, hard-coded colors, and avatar monster-index logic.
- Avatar file upload UI is deferred because cross-platform file picking requires a separate approved package or platform strategy.

## 2026-07-09 20:29

Task
TASK-031 Flutter 註冊頁三平台補齊

Agent
Codex

### Completed

- Confirmed the Flutter app already has Web, Android, and iOS platform project folders.
- Confirmed current Flutter pages are implemented in shared `frontend/lib/` code and therefore target Web, Android, and iOS together.
- Updated Android, iOS, and Web app metadata from Flutter defaults to `貘nsters`.
- Updated UI spec and frontend README to make Web / Android / iOS support the default expectation for future frontend tasks.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `frontend/android/app/src/main/AndroidManifest.xml`
- `frontend/ios/Runner/Info.plist`
- `frontend/web/index.html`
- `frontend/web/manifest.json`
- `docs/UI_SPEC.md`
- `frontend/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build web --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build apk --debug --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --no-codesign --no-pub`（blocked：local Xcode is missing iOS 26.2 platform）
- `/Users/linweijun/fultter/flutter/bin/flutter build ios --simulator --no-pub`（blocked：local Xcode is missing iOS 26.2 platform）

### Commit Message

```text
chore(frontend): 補齊三平台 metadata
```

### Notes

- Future frontend tasks must be implemented as cross-platform Flutter code by default, with platform-specific handling documented when needed.
- Web and Android builds passed. iOS build is blocked by local Xcode platform installation, not by a Dart or Flutter compile error.

## 2026-07-09 20:20

Task
TASK-031 Flutter 註冊頁（REVIEW）

Agent
Codex

### Completed

- Replaced the placeholder Flutter register route with a complete registration form.
- Added register flow to `AuthRepository` and Riverpod `AuthController` using the existing `ApiClient`.
- Added register result model for the current Auth API response shape.
- Added Email, nickname, password length, and confirm-password validation.
- Added loading, API error, success navigation, and login navigation states.
- Added register page widget tests and updated router test for the new register UI.
- Updated API spec, UI spec, frontend README, task, and log documents.
- Completed local commit. Remote push remains blocked by external GitHub egress safety review.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/lib/models/register_result.dart`
- `frontend/test/register_page_test.dart`

### Modified

- `frontend/README.md`
- `frontend/lib/pages/register_page.dart`
- `frontend/lib/providers/auth_provider.dart`
- `frontend/lib/repositories/auth_repository.dart`
- `frontend/test/routes/app_router_test.dart`
- `docs/API_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- No backend endpoint change. Frontend now calls existing `POST /api/auth/register`.

### Database

- None

### Tests

- `/Users/linweijun/fultter/flutter/bin/dart format lib/pages/register_page.dart lib/providers/auth_provider.dart lib/repositories/auth_repository.dart lib/models/register_result.dart test/register_page_test.dart test/routes/app_router_test.dart`
- `/Users/linweijun/fultter/flutter/bin/flutter test --no-pub`
- `/Users/linweijun/fultter/flutter/bin/flutter analyze --no-pub`

### Commit Message

```text
feat(frontend): 建立註冊頁
```

### Notes

- Task remains in REVIEW until remote push completes.
- Register success returns to the login route; it does not persist password or token and does not auto-login.

## 2026-07-09 14:59

Task
TASK-030 Flutter 登入頁

Agent
Codex

### Completed

- Replaced the placeholder Flutter login route with a complete Email / password login form.
- Added Auth Repository and Riverpod Auth Controller flow using the existing `ApiClient`.
- Added login response models for the current Auth API response shape using `json_serializable`.
- Added loading, validation, API error, register navigation, forgot-password hint, and Google-login pending states.
- Kept JWT out of SharedPreferences; access token is applied only to the current `ApiClient` runtime header.
- Added login page widget tests and updated router / app tests for the new login UI.
- Updated UI spec, frontend README, task, and log documents.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `frontend/lib/models/auth_user.dart`
- `frontend/lib/models/auth_user.g.dart`
- `frontend/lib/models/login_result.dart`
- `frontend/lib/models/login_result.g.dart`
- `frontend/lib/providers/auth_provider.dart`
- `frontend/lib/repositories/auth_repository.dart`
- `frontend/test/login_page_test.dart`

### Modified

- `frontend/README.md`
- `frontend/pubspec.yaml`
- `frontend/pubspec.lock`
- `frontend/lib/pages/login_page.dart`
- `frontend/test/routes/app_router_test.dart`
- `frontend/test/widget_test.dart`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- No backend endpoint change. Frontend now calls existing `POST /api/auth/login`.

### Database

- None

### Tests

- `flutter pub add json_annotation dev:build_runner dev:json_serializable`
- `dart run build_runner build --delete-conflicting-outputs`
- `dart format lib test`
- `flutter test`
- `flutter analyze`

### Commit Message

```text
feat(frontend): 建立登入頁
```

### Notes

- Google login UI entry is present, but Google Sign-In SDK is not introduced in this task to avoid adding an unapproved dependency. It shows a pending message until the dedicated Google Sign-In frontend task is defined.

---

## 2026-07-09 14:40

Task
TASK-029 密碼鎖 API

Agent
Codex

### Completed

- Added password lock APIs for the authenticated current user.
- Added `UserPasswordLock` entity and repository for existing `user_password_locks` schema.
- Added request and response DTOs for password lock update and verification.
- Stored password locks with BCrypt hash only; no raw lock password is persisted.
- Added service and controller tests for create/update/verify/missing user/missing lock flows.
- Updated API spec, database mapping, backend README, task, and log documents.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/user/dto/PasswordLockRequest.java`
- `backend/src/main/java/com/monsters/user/dto/PasswordLockStatusResponse.java`
- `backend/src/main/java/com/monsters/user/dto/PasswordLockVerificationResponse.java`
- `backend/src/main/java/com/monsters/user/entity/UserPasswordLock.java`
- `backend/src/main/java/com/monsters/user/repository/UserPasswordLockRepository.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/user/controller/UserController.java`
- `backend/src/main/java/com/monsters/user/service/UserService.java`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `backend/src/test/java/com/monsters/user/controller/UserControllerTest.java`
- `backend/src/test/java/com/monsters/user/service/UserServiceTest.java`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None. The existing `database/init/01_schema.sql` already contains `user_password_locks`.

### API

- Added `PUT /api/users/me/password-lock`.
- Added `POST /api/users/me/password-lock/verify`.

### Database

- No schema change. Password lock API uses existing `user_password_locks`.

### Tests

- `$env:JAVA_HOME='C:\Program Files\Java\jdk-18.0.2'; $env:Path="$env:JAVA_HOME\bin;$env:Path"; .\gradlew.bat test`
- `$env:JAVA_HOME='C:\Program Files\Java\jdk-18.0.2'; $env:Path="$env:JAVA_HOME\bin;$env:Path"; .\gradlew.bat build`
- `git diff --check`

### Commit Message

```text
feat(user): 建立密碼鎖 API
```

### Notes

- The old system stored a 4-digit lock value in user profile data and frontend local state. The new implementation stores only a backend BCrypt hash and verifies by authenticated user id.

---

## 2026-07-06 11:16

Task
TASK-028 Phase 2 會員規格一致性檢查

Agent
Codex

### Completed

- Confirmed Phase 0 and Phase 1 tasks are complete.
- Confirmed current Phase 2 member API implementation has reached avatar update and is present on remote `develop`.
- Cross-checked implemented User APIs against `docs/API_SPEC.md`, `docs/DATABASE_SPEC.md`, `docs/CODING_STANDARD.md`, backend controller, service, R2 storage settings, and tests.
- Added missing User API database mapping for profile query, profile update, and avatar update.
- Updated `docs/TASKS.md` to mark the Phase 2 implementation alignment item as DONE.
- Updated the stale avatar API REVIEW status to DONE because `origin/develop` already contains the avatar API commit.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `docs/DATABASE_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- No endpoint change. This task only verified and documented existing User APIs.

### Database

- No schema change. Added documentation mapping for existing `users` columns used by User APIs.

### Tests

- `$env:JAVA_HOME='C:\Program Files\Java\jdk-18.0.2'; $env:Path="$env:JAVA_HOME\bin;$env:Path"; .\gradlew.bat test`
- `$env:JAVA_HOME='C:\Program Files\Java\jdk-18.0.2'; $env:Path="$env:JAVA_HOME\bin;$env:Path"; .\gradlew.bat build`
- `git diff --check`

### Commit Message

```text
docs(phase2): 同步會員規格狀態
```

### Notes

- Next executable task after this alignment is `密碼鎖 API`.

---

## 2026-07-04 12:13

Task
TASK-027 更改頭貼 API（REVIEW）

Agent
Codex

### Completed

- Added `PUT /api/users/me/avatar`.
- Added Cloudflare R2 S3-compatible storage settings and avatar storage service.
- Added AWS SDK S3 dependency with user-approved package addition.
- Added avatar file validation for required file, supported image MIME types, and file size.
- Added user avatar update flow that uploads the file to R2 and stores only the public avatar URL.
- Added controller, service, and storage tests.
- Updated API spec, backend README, decision, task, and log documents.
- Confirmed the previous `PUT /api/users/me` task is on remote `develop` and corrected its stale REVIEW status to DONE.
- Completed local commit. Remote push remains blocked by external GitHub egress safety review.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/common/storage/AvatarStorageService.java`
- `backend/src/main/java/com/monsters/common/storage/R2AvatarStorageService.java`
- `backend/src/main/java/com/monsters/common/storage/R2Properties.java`
- `backend/src/main/java/com/monsters/common/storage/R2StorageConfig.java`
- `backend/src/test/java/com/monsters/common/storage/R2AvatarStorageServiceTest.java`

### Modified

- `backend/README.md`
- `backend/build.gradle`
- `backend/src/main/java/com/monsters/user/controller/UserController.java`
- `backend/src/main/java/com/monsters/user/entity/User.java`
- `backend/src/main/java/com/monsters/user/service/UserService.java`
- `backend/src/main/resources/application.yml`
- `backend/src/test/java/com/monsters/user/controller/UserControllerTest.java`
- `backend/src/test/java/com/monsters/user/service/UserServiceTest.java`
- `docs/API_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Added `PUT /api/users/me/avatar`.

### Database

- No schema change. Avatar update writes existing `users.avatar_url`.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`
- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew build`

### Commit Message

```text
feat(user): 建立更改頭貼 API
```

### Notes

- Task remains in REVIEW until remote push completes.
- R2 credentials and bucket values must be provided through environment variables before using avatar upload in runtime.

## 2026-07-04 12:01

Task
TASK-026 修改個人資料 API

Agent
Codex

### Completed

- Added `PUT /api/users/me`.
- Added profile update request DTO with `userName` validation.
- Added user profile update service logic using authenticated JWT principal user id.
- Added controller and service tests for profile update success and missing user cases.
- Updated API spec, backend README, task, and log documents.
- Confirmed the previous `GET /api/users/me` task is on remote `develop` and corrected its stale REVIEW status to DONE.
- Confirmed remote `develop` contains the profile update API commit and updated task state to DONE.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/user/dto/UpdateUserProfileRequest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/user/controller/UserController.java`
- `backend/src/main/java/com/monsters/user/entity/User.java`
- `backend/src/main/java/com/monsters/user/service/UserService.java`
- `backend/src/test/java/com/monsters/user/controller/UserControllerTest.java`
- `backend/src/test/java/com/monsters/user/service/UserServiceTest.java`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Added `PUT /api/users/me`.

### Database

- No schema change. Profile update writes existing `users.user_name` and `users.birthday`.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`
- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew build`

### Commit Message

```text
feat(user): 建立修改個人資料 API
```

### Notes

- This API updates only `userName` and `birthday`; avatar, account, email, and password lock remain separate flows.

## 2026-07-04 11:45

Task
TASK-024 登出 API

Agent
Codex

### Completed

- Added `POST /api/auth/logout`.
- Added JWT access token verification for protected APIs.
- Added revoked token persistence with token hash and original token expiration.
- Added JWT authentication filter that rejects revoked tokens and invalid tokens.
- Extended JWT service with access token verification and SHA-256 token hashing.
- Added controller, service, JWT, and security tests.
- Updated API, database, backend README, decision, task, schema, and log documents.
- Confirmed remote `develop` contains the logout API commit and updated task state to DONE.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/auth/service/TokenRevocationService.java`
- `backend/src/main/java/com/monsters/common/security/AuthenticatedUser.java`
- `backend/src/main/java/com/monsters/common/security/JwtAuthenticationFilter.java`
- `backend/src/main/java/com/monsters/common/security/JwtTokenPayload.java`
- `backend/src/main/java/com/monsters/user/entity/RevokedToken.java`
- `backend/src/main/java/com/monsters/user/repository/RevokedTokenRepository.java`
- `backend/src/test/java/com/monsters/auth/service/TokenRevocationServiceTest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/auth/controller/AuthController.java`
- `backend/src/main/java/com/monsters/common/security/JwtTokenService.java`
- `backend/src/main/java/com/monsters/common/security/SecurityConfig.java`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/common/config/CorsConfigTest.java`
- `backend/src/test/java/com/monsters/common/security/JwtTokenServiceTest.java`
- `backend/src/test/java/com/monsters/common/security/SecurityConfigTest.java`
- `database/init/01_schema.sql`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- Added `revoked_tokens` to `database/init/01_schema.sql`.

### API

- Added `POST /api/auth/logout`.

### Database

- Added `revoked_tokens`.
- JWT plaintext is not stored; only token hash is persisted.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`

### Commit Message

```text
feat(auth): 建立登出 API
```

### Notes

- Logout uses JWT revocation, not only frontend token cleanup.

## 2026-07-04 11:53

Task
TASK-025 查詢個人資料 API

Agent
Codex

### Completed

- Added `GET /api/users/me`.
- Added user profile response DTO.
- Added user service query by authenticated JWT principal user id.
- Added user controller and service tests.
- Updated API spec, backend README, task, and log documents.
- Confirmed remote `develop` contains the profile query API commit and updated task state to DONE.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/user/controller/UserController.java`
- `backend/src/main/java/com/monsters/user/dto/UserProfileResponse.java`
- `backend/src/main/java/com/monsters/user/service/UserService.java`
- `backend/src/test/java/com/monsters/user/controller/UserControllerTest.java`
- `backend/src/test/java/com/monsters/user/service/UserServiceTest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/user/repository/UserRepository.java`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Added `GET /api/users/me`.

### Database

- No schema change. Profile API reads existing `users` table.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`

### Commit Message

```text
feat(user): 建立查詢個人資料 API
```

### Notes

- The API uses authenticated JWT principal data and does not accept user id or account from the client.

## 2026-07-04 11:36

Task
TASK-023 整理 DECISIONS 決策狀態

Agent
Codex

### Completed

- Reviewed `docs/DECISIONS.md`.
- Moved already-decided items from pending confirmation into the confirmed decision table.
- Confirmed Cloudflare R2 as the file upload storage direction.
- Confirmed SMTP as the formal email delivery direction for forgot password.
- Confirmed Web admin backend is needed.
- Clarified old database, old API, old Flutter UI, and old material reuse decisions.
- Replaced the pending confirmation table with a pending-detail table for implementation details.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `docs/DECISIONS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- `git diff --check`

### Commit Message

```text
docs(decisions): 整理已定案事項
```

### Notes

- R2 credentials, SMTP credentials, Web admin permission model, old API mapping, old UI mapping, and material inventory remain implementation details for later tasks.

## 2026-07-04 11:21

Task
TASK-022 忘記密碼 API

Agent
Codex

### Completed

- Added `POST /api/auth/forgot-password`.
- Added `POST /api/auth/reset-password`.
- Added one-time password reset token generation with 15-minute expiration.
- Stored only reset token hashes in `password_reset_tokens`.
- Invalidated previous unused reset tokens when a new token is issued for the same user.
- Added password reset flow to update existing credentials or create credentials for OAuth-only users after token verification.
- Added controller, service, and token hashing tests.
- Updated API, database, backend README, decision, task, schema, and log documents.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/auth/dto/ForgotPasswordRequest.java`
- `backend/src/main/java/com/monsters/auth/dto/ForgotPasswordResponse.java`
- `backend/src/main/java/com/monsters/auth/dto/ResetPasswordRequest.java`
- `backend/src/main/java/com/monsters/common/security/PasswordResetTokenService.java`
- `backend/src/main/java/com/monsters/user/entity/PasswordResetToken.java`
- `backend/src/main/java/com/monsters/user/repository/PasswordResetTokenRepository.java`
- `backend/src/test/java/com/monsters/common/security/PasswordResetTokenServiceTest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/auth/controller/AuthController.java`
- `backend/src/main/java/com/monsters/auth/service/AuthService.java`
- `backend/src/main/java/com/monsters/user/entity/UserCredential.java`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/auth/service/AuthServiceTest.java`
- `database/init/01_schema.sql`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- Added `password_reset_tokens` to `database/init/01_schema.sql`.

### API

- Added `POST /api/auth/forgot-password`.
- Added `POST /api/auth/reset-password`.

### Database

- Added `password_reset_tokens`.
- Reset token plaintext is not stored; only token hash is persisted.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`

### Commit Message

```text
feat(auth): 建立忘記密碼 API
```

### Notes

- Current forgot-password response returns `resetToken` for development and frontend integration. Formal email delivery remains pending in `docs/DECISIONS.md`.

## 2026-07-04 06:42

Task
TASK-021 Google 登入 API

Agent
Codex

### Completed

- Added backend Google login endpoint implementation for `POST /api/auth/google-login`.
- Added backend Google ID Token verification with Google's JWKS, RS256 signature validation, issuer validation, audience validation, expiration validation, and verified-email validation.
- Added `GOOGLE_CLIENT_IDS` configuration to allow one or more Web / App Google Client IDs.
- Added `user_oauth_accounts` JPA entity and repository for Google account linking.
- Added Google login service flow to reuse an existing OAuth account, link an existing email user, or create a new user.
- Added controller, service, and token verifier tests.
- Updated API, database, backend README, decision, task, and log documents.
- Completed full backend test and build verification after fixing Spring constructor injection selection.
- Confirmed remote branch status now includes the Google login commit and updated task state to DONE.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/auth/dto/GoogleLoginRequest.java`
- `backend/src/main/java/com/monsters/common/security/GoogleIdTokenVerifier.java`
- `backend/src/main/java/com/monsters/common/security/GoogleJwkProvider.java`
- `backend/src/main/java/com/monsters/common/security/GoogleJwkProviderImpl.java`
- `backend/src/main/java/com/monsters/common/security/GoogleProperties.java`
- `backend/src/main/java/com/monsters/common/security/GoogleUserInfo.java`
- `backend/src/main/java/com/monsters/user/entity/UserOAuthAccount.java`
- `backend/src/main/java/com/monsters/user/repository/UserOAuthAccountRepository.java`
- `backend/src/test/java/com/monsters/common/security/GoogleIdTokenVerifierTest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/auth/controller/AuthController.java`
- `backend/src/main/java/com/monsters/auth/service/AuthService.java`
- `backend/src/main/java/com/monsters/common/security/SecurityConfig.java`
- `backend/src/main/resources/application.yml`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/auth/service/AuthServiceTest.java`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Added `POST /api/auth/google-login`.

### Database

- Added JPA mapping for existing spec table `user_oauth_accounts`.
- Google login reads and writes `users` and `user_oauth_accounts`.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`
- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew build`
- `git diff --check`
- First rerun found Spring constructor injection selection issues in `GoogleIdTokenVerifier` and `GoogleJwkProviderImpl`; both were fixed with explicit `@Autowired` constructors.

### Commit Message

```text
feat(auth): 建立 Google 登入 API
```

### Notes

- `GOOGLE_CLIENT_IDS` and `JWT_SECRET` must be configured before Google login can issue JWT tokens.

## 2026-07-03 20:58

Task
TASK-020 遮罩 system_data 敏感字串

Agent
Codex

### Completed

- Masked old database host, database name, username, and password in `system_data/back-end/src/main/resources/application.yml`.
- Masked old database name constant in `system_data/back-end/src/main/java/com/example/demo/config/DatabaseConfig.java`.
- Masked Android debug signing passwords in `system_data/front-end/monsters_front_end/android/app/build.gradle`.
- Masked hardcoded accessToken strings in four old Flutter reference pages.
- Re-scanned `system_data/` and confirmed the original sensitive values were no longer present.
- Confirmed no checked build artifact or credential file extension was found.
- Updated `docs/SYSTEM_DATA_REFERENCE.md`, `docs/TASKS.md`, and logs.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- None

### Modified

- `docs/SYSTEM_DATA_REFERENCE.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`
- `system_data/back-end/src/main/java/com/example/demo/config/DatabaseConfig.java`
- `system_data/back-end/src/main/resources/application.yml`
- `system_data/front-end/monsters_front_end/android/app/build.gradle`
- `system_data/front-end/monsters_front_end/lib/pages/account/forgetPassword/forget_psw_auth.dart`
- `system_data/front-end/monsters_front_end/lib/pages/account/lock/forget_lock_auth.dart`
- `system_data/front-end/monsters_front_end/lib/pages/drawer/user_Feedback.dart`
- `system_data/front-end/monsters_front_end/lib/pages/social.dart`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- Searched for original sensitive values in `system_data/`.
- Checked common build artifact and credential file extensions.
- Checked common generated dependency/build directories.
- `git diff --check`

### Commit Message

```text
docs(system-data): 遮罩舊系統敏感字串
```

### Notes

- `system_data/` reference files were preserved; only sensitive literal values were replaced with placeholders.

## 2026-07-03 20:51

Task
TASK-019 補齊 system_data 參考任務

Agent
Codex

### Completed

- Added `docs/SYSTEM_DATA_REFERENCE.md` to record the `system_data/` inventory, PDF summary, old code/material organization, feature mapping, shared pattern conversion, and member/auth reference notes.
- Confirmed `system_data/` contains old manuals, old backend code, old Flutter code, and assets.
- Confirmed no obvious build artifact file or directory was found in the checked patterns.
- Updated `docs/TASKS.md` for completed Phase 0, Phase 1, and Phase 2 reference-check tasks.
- Kept the Phase 0 sensitive-data cleanup task in REVIEW because old database credentials, Android signing password strings, and hardcoded accessToken strings were found.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `docs/SYSTEM_DATA_REFERENCE.md`

### Modified

- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- None

### Database

- None

### Tests

- Checked `system_data/` file and directory counts.
- Checked common build artifact and credential file extensions.
- Scanned text files for sensitive keyword patterns.
- Reviewed old backend common layers, member controller, member service, and old Flutter member repository/API.
- `git diff --check`

### Commit Message

```text
docs(system-data): 補齊舊系統參考任務
```

### Notes

- `system_data/` was not modified.
- The remaining Phase 0 sensitive-data task requires user confirmation before masking, removing, or relocating old reference files.

## 2026-07-03 20:36

Task
TASK-018 Login API

Agent
Codex

### Completed

- Added `POST /api/auth/login`.
- Added login request and response DTOs.
- Added JWT access and refresh token generation with JDK HMAC-SHA256 APIs, without adding a third-party dependency.
- Added login service logic for normalized email lookup, BCrypt password matching, deleted-user rejection, and 401 invalid credential handling.
- Added service, controller, and JWT token tests.
- Updated API, database, backend README, task, and log documents.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/auth/dto/AuthUserResponse.java`
- `backend/src/main/java/com/monsters/auth/dto/LoginRequest.java`
- `backend/src/main/java/com/monsters/auth/dto/LoginResponse.java`
- `backend/src/main/java/com/monsters/common/security/JwtTokenService.java`
- `backend/src/test/java/com/monsters/common/security/JwtTokenServiceTest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/auth/controller/AuthController.java`
- `backend/src/main/java/com/monsters/auth/service/AuthService.java`
- `backend/src/main/java/com/monsters/user/repository/UserCredentialRepository.java`
- `backend/src/main/java/com/monsters/user/repository/UserRepository.java`
- `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/auth/service/AuthServiceTest.java`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Added `POST /api/auth/login`.

### Database

- No schema change. Login API reads existing `users` and `user_credentials` tables.

### Tests

- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew test`
- `GRADLE_USER_HOME=/Users/linweijun/Desktop/monsters/.gradle-cache JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home sh gradlew build`
- `git diff --check`

### Commit Message

```text
feat(auth): 建立登入 API
```

### Notes

- `JWT_SECRET` must be configured before login can issue JWT tokens.

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

## 2026-07-03 14:55

Task
TASK-017 Register API

Agent
Codex

### Completed

- Added `POST /api/auth/register`.
- Added User and UserCredential JPA entities mapped to `users` and `user_credentials`.
- Added repositories, DTOs, AuthService, and AuthController.
- Added service and controller tests for successful registration, validation, and duplicate email behavior.
- Fixed existing common exception handler/test mojibake string syntax so backend tests can compile.
- Checked log retention before adding this entry. No log older than one month was found, so no expired log was deleted.

### Added

- `backend/src/main/java/com/monsters/auth/controller/AuthController.java`
- `backend/src/main/java/com/monsters/auth/dto/RegisterRequest.java`
- `backend/src/main/java/com/monsters/auth/dto/RegisterResponse.java`
- `backend/src/main/java/com/monsters/auth/service/AuthService.java`
- `backend/src/main/java/com/monsters/user/entity/User.java`
- `backend/src/main/java/com/monsters/user/entity/UserCredential.java`
- `backend/src/main/java/com/monsters/user/repository/UserRepository.java`
- `backend/src/main/java/com/monsters/user/repository/UserCredentialRepository.java`
- `backend/src/test/java/com/monsters/auth/controller/AuthControllerTest.java`
- `backend/src/test/java/com/monsters/auth/service/AuthServiceTest.java`

### Modified

- `backend/README.md`
- `backend/src/main/java/com/monsters/common/exception/GlobalExceptionHandler.java`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `backend/src/test/java/com/monsters/common/exception/GlobalExceptionHandlerTest.java`
- `docs/API_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### Deleted

- None

### Migration

- None

### API

- Added `POST /api/auth/register`.

### Database

- No schema change. Register API writes to existing `users` and `user_credentials` tables.

### Tests

- `.\gradlew.bat test`
- `.\gradlew.bat build`
- `git diff --check`

### Commit Message

```text
feat(auth): 建立註冊 API
```

### Notes

- Passwords are stored only as BCrypt hashes.

---

## 2026-07-03 14:23

Task
TASK-016 建立 Loading / Error / Empty 共用元件

變更者
Codex

### 本次完成

- 新增 Flutter 共用狀態元件 `LoadingView`、`ErrorView`、`EmptyView`。
- 狀態元件集中放置於 `frontend/lib/widgets/state/`。
- 元件使用 `Theme.of(context)` 與 `AppSpacing`，避免 hard code 共用樣式。
- 新增 widget tests，覆蓋 loading indicator、error retry action、empty action。
- 更新 frontend README 與 UI_SPEC，補充共用狀態元件規範。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限，未發現超過一個月的紀錄，未刪除過期 Log。

### 新增

- `frontend/lib/widgets/state/loading_view.dart`
- `frontend/lib/widgets/state/error_view.dart`
- `frontend/lib/widgets/state/empty_view.dart`
- `frontend/test/widgets/state_views_test.dart`

### 修改

- `frontend/README.md`
- `docs/UI_SPEC.md`
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

- `dart format lib/widgets/state test/widgets/state_views_test.dart`
- `flutter analyze`
- `flutter test`
- `flutter build web`

### Commit 撱箄降

```text
feat(frontend): 建立共用狀態元件
```

### 註記 / 待確認事項

- 後續頁面應使用共用狀態元件呈現 loading / error / empty 狀態。

---

## 2026-07-03 14:17

Task
DOC-011 merge feature/theme into develop

變更者
Codex

### 本次完成

- 將 `feature/theme` 合併至 `develop`。
- 解決 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 的 merge conflict，保留 DOC-010 與 TASK-015 紀錄。
- 修正 `frontend/lib/theme/app_theme.dart` 使用 deprecated `ColorScheme.background` 導致 `flutter analyze` 失敗的問題。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限，未發現超過一個月的紀錄，未刪除過期 Log。

### 新增

- 無

### 修改

- `frontend/lib/theme/app_theme.dart`
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

- `flutter analyze`
- `flutter test`
- `flutter build web`
- `git diff --check`

### Commit 撱箄降

```text
merge: feature theme into develop
docs(log): 補充 theme merge 紀錄
```

### 註記 / 待確認事項

- `feature/theme` commit 已包含於 `develop`。

---

## 2026-07-03 09:31

Task
DOC-010 資料庫架構正規化重構

變更者
Codex

### 本次完成

- 依照 `system_data` 舊後端 Entity 與現有 API 規格重構資料庫架構。
- 將使用者關聯統一改用 `users.id`，不再以 `account` 作為跨表關聯鍵。
- 拆分使用者認證、OAuth、隱私鎖、怪物資產、紀錄媒體、每日測驗選項。
- 將 diary / annoyance 正規化為共用 `entries`，並以 `entry_type` 區分。
- 將 diary / annoyance 社群按讚與留言整合為 `entry_likes`、`entry_comments`。
- 新增 MySQL 初始化 schema `database/init/01_schema.sql`。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限，未發現超過一個月的紀錄，未刪除過期 Log。

### 新增

- `database/init/01_schema.sql`

### 修改

- `docs/DATABASE_SPEC.md`
- `database/init/README.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 新增 Docker MySQL 首次初始化用 schema。
- 既有資料庫 volume 不會自動套用，若已有資料需另行撰寫資料搬遷 script。

### API

- 無 endpoint 異動。
- Community API 的資料底層將由共用 `entries` / `entry_likes` / `entry_comments` 支援。

### Database

- 重構為正規化 schema，新增 users、credentials、OAuth、monster asset、entries、entry media、daily test options 等資料表。

### 測試

- `git diff --check`
- `docker compose config`

### Commit 撱箄降

```text
refactor(database): 正規化資料庫架構
```

### 註記 / 待確認事項

- 後續實作 Auth / Diary / Annoyance / Community Entity 時需依此 schema 建立 JPA Entity 與 DTO。

---

## 2026-07-03 09:19

Task
TASK-015 建立 Theme

修改來源
Codex

### 本次完成

- 新增 Flutter Theme 基礎層，集中建立 light / dark ThemeData。
- 新增 AppColors、AppSpacing、AppRadius 作為共用設計 token。
- App 入口套用 AppTheme.light()、AppTheme.dark() 與 ThemeMode.system。
- 新增 Theme 單元測試，驗證 light / dark theme、Material 3、背景色與共用元件 theme 設定。
- 更新 frontend README 與 UI_SPEC，記錄 Theme 檔案位置與禁止頁面 hard code 共用樣式。
- 新增 Log 前已檢查 log/CHANGE_LOG.md 與 log/CHANGE_HISTORY.csv 保存期限，未發現超過一個月紀錄，未刪除紀錄。

### 新增

- `frontend/lib/theme/app_theme.dart`
- `frontend/lib/theme/app_colors.dart`
- `frontend/lib/theme/app_spacing.dart`
- `frontend/test/theme/app_theme_test.dart`

### 修改

- `frontend/lib/app.dart`
- `frontend/README.md`
- `docs/UI_SPEC.md`
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

- `flutter analyze`
- `flutter test`
- `flutter build web`

### Commit 建議

```text
feat(frontend): 建立 theme
```

### 備註 / 待確認事項

- Theme 為基礎視覺設定，後續共用元件 Task 應優先使用 ThemeData 與 theme token。
---

## 2026-07-03 09:08

Task
TASK-014 建立 go_router

修改來源
Codex

### 本次完成

- 新增 Flutter go_router 依賴並更新 pubspec.lock。
- 將 App 入口改為 Riverpod ProviderScope + MaterialApp.router。
- 新增集中式路由設定 appRouterProvider、AppRoute、AppPath。
- 新增基礎路由頁面 SplashPage、HomePage、LoginPage、RegisterPage。
- 移除 Flutter template counter app 與 counter widget test。
- 新增 route widget tests，驗證初始路由、登入路由與註冊轉登入流程。
- 更新 frontend README 與 UI_SPEC，記錄 go_router 基礎路由與 Navigator 使用限制。
- 新增 Log 前已檢查 log/CHANGE_LOG.md 與 log/CHANGE_HISTORY.csv 保存期限，未發現超過一個月紀錄，未刪除紀錄。

### 新增

- `frontend/lib/app.dart`
- `frontend/lib/routes/app_router.dart`
- `frontend/lib/routes/app_routes.dart`
- `frontend/lib/pages/splash_page.dart`
- `frontend/lib/pages/home_page.dart`
- `frontend/lib/pages/login_page.dart`
- `frontend/lib/pages/register_page.dart`
- `frontend/test/routes/app_router_test.dart`

### 修改

- `frontend/lib/main.dart`
- `frontend/test/widget_test.dart`
- `frontend/README.md`
- `docs/UI_SPEC.md`
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

- `flutter analyze`
- `flutter test`
- `flutter build web`

### Commit 建議

```text
feat(frontend): 建立 go_router
```

### 備註 / 待確認事項

- 目前頁面為路由容器骨架，實際登入、註冊與首頁功能將依後續 Task 補齊。
---

## 2026-07-02 14:33

Task
TASK-013 建立 API Error Handler

修改來源
Codex

### 本次完成

- 新增 Flutter API Error Handler，將 DioException、timeout、network、cancel、HTTP error 與非標準 response 統一轉換為 ApiException。
- 新增 ApiErrorType，供 Repository / UI 依錯誤類型判斷 unauthorized、forbidden、notFound、conflict、validation、server 等狀態。
- 更新 ApiClient，所有 request 統一透過 ApiErrorHandler 處理例外，不再直接向上拋出 DioException 或 FormatException。
- 新增 API Error Handler 與 ApiClient 錯誤處理測試。
- 修正 docs/TASKS.md 前端 Dio Client 與 API Error Handler 清單斷行問題，並依序推進 IN PROGRESS、REVIEW、DONE。
- 更新 API 文件與 frontend README，記錄前端錯誤處理合約。
- 新增 Log 前已檢查 log/CHANGE_LOG.md 與 log/CHANGE_HISTORY.csv 保存期限，未發現超過一個月紀錄，未刪除紀錄。

### 新增

- `frontend/lib/core/network/api_error_handler.dart`
- `frontend/lib/core/network/api_error_type.dart`
- `frontend/lib/core/network/api_exception.dart`
- `frontend/test/core/network/api_error_handler_test.dart`

### 修改

- `frontend/lib/core/network/api_client.dart`
- `frontend/lib/providers/api_client_provider.dart`
- `frontend/test/core/network/api_client_test.dart`
- `frontend/README.md`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 未新增或修改後端 API endpoint。
- 前端新增 API 錯誤處理合約：ApiClient 統一拋出 ApiException。

### Database

- 無

### 測試

- `flutter analyze`
- `flutter test`
- `flutter build web`

### Commit 建議

```text
feat(frontend): 建立 api error handler
```

### 備註 / 待確認事項

- 本分支 `feature/dio-client` 目前包含 TASK-012 Dio Client 與 TASK-013 API Error Handler，尚待合併至 develop。
---

## 2026-07-02 09:49

Task
TASK-012 建立 Dio Client

修改來源
Codex

### 本次完成

- 新增 Flutter Dio Client 基礎層，統一設定 API Base URL、timeout、JSON header 與標準 API response parsing。
- 新增 `AppConfig`，支援 `API_BASE_URL` dart-define 覆寫，預設為 `http://localhost:8080/api`。
- 新增 Riverpod Provider，後續 Repository 可透過 `apiClientProvider` 注入 `ApiClient`。
- 新增 Dio Client 單元測試，涵蓋 base options、Bearer token 設定與標準 API response parsing。
- 更新 `docs/TASKS.md`，依流程將 Dio Client Task 完成為 DONE。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限，未發現超過一個月紀錄。

### 新增

- `frontend/lib/config/app_config.dart`
- `frontend/lib/core/network/api_client.dart`
- `frontend/lib/core/network/api_response.dart`
- `frontend/lib/providers/api_client_provider.dart`
- `frontend/test/core/network/api_client_test.dart`

### 修改

- `frontend/README.md`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 無新增後端 API endpoint。
- 前端新增 API Client 設定與呼叫入口。

### Database

- 無

### 測試

- `flutter pub get`
- `flutter analyze`
- `flutter test`

### Commit 建議

```text
feat(frontend): 建立 dio client
```

### 備註 / 待確認事項

- 下一個 Task 為 `建立 API Error Handler`，可接續擴充 Dio interceptor 與錯誤轉換。

---

## 2026-07-02 09:37

Task
DOC-009 merge system_data reference to develop

靽格鈭?
Codex

### ?祆活摰?

- 撠? `docs/system-data-reference` merge ??`develop`嚗? merge commit 靽?????
- 靘蝙?刻????蔥??`develop` ?? local branch嚗??芾 merge `main`嚗?蝚血? GIT_RULE.md??
- 靽格?頂蝯梁?撘?獢??空白問題，清理 trailing whitespace 與 EOF 空白。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限，未發現超過一個月紀錄。

### ?啣?

- ??

### 靽格

- `system_data/` 部分舊參考程式檔
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### ?芷

- ??

### Migration

- ??

### API

- ??

### Database

- ??

### 皜祈岫

- `git branch --no-merged develop`
- `git diff --check HEAD^ HEAD`
- `git status --short --branch`

### Commit 撱箄降

```text
chore(git): 合併 system_data 參考資料
```

### ?酉 / 敺Ⅱ隤???

- `main` 仍顯示為未合併至 `develop`，但依 GIT_RULE.md 禁止執行 `git merge main`，本次未處理。

---
## 2026-07-02 09:10

Task
DOC-008 system_data 選擇性追蹤程式與圖片

變更者
Codex

### 本次完成

- 依使用者要求重新將 `system_data/` 納入 Git，但只追蹤程式檔案、專案設定檔與圖片素材。
- 調整 `.gitignore` 為白名單規則，預設忽略 `system_data/**`，再放行 source、Flutter/Android/iOS/Windows 專案設定與圖片格式。
- 刪除 `system_data/` 內不需推上 Git 的 PDF、docx、mp4、txt 雜檔、jks、jar、metadata、README 等非程式或非圖片資料，共 15 個檔案。
- 更新 README 與 UI 規格，使文件與「保留程式檔案及圖片資料」規則一致。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限；目前無超過一個月紀錄，未刪除過期 Log。

### 新增

- `system_data/` 內程式檔案、專案設定檔與圖片素材

### 修改

- `.gitignore`
- `README.md`
- `docs/UI_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- `system_data/` 內非程式與非圖片資料 15 個檔案

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- `git diff --check`
- 檢查 `system_data/` 剩餘檔案副檔名
- 檢查 `git status --ignored -- system_data`

### Commit 建議

```text
docs(system-data): 追蹤舊系統程式與圖片資料
```

### 備註 / 待確認事項

- `system_data/` 僅供舊系統參考；正式新版程式仍以 `frontend/`、`backend/`、`database/` 為準。

---

## 2026-07-02 09:02

Task
DOC-007 system_data 舊系統參考文件化

靽格鈭?
Codex

### ?祆活摰?

- 參考 `system_data` 舊後端 Entity，整理新版資料庫可採用與需調整的欄位、關聯與命名原則。
- 參考 `system_data` 舊 Flutter 程式，整理新版 UI 可採用的畫面流程、互動方式與不得沿用的實作方式。
- 將 `system_data/` 設定為 Git 不追蹤，並保留其本機參考用途說明。
- 新增 Log 前已檢查 `log/CHANGE_LOG.md` 與 `log/CHANGE_HISTORY.csv` 保存期限；目前無超過一個月紀錄，未刪除過期 Log。

### ?啣?

- 無

### 靽格

- `.gitignore`
- `README.md`
- `docs/DATABASE_SPEC.md`
- `docs/UI_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### ?芷

- `system_data/四技第111405組-貘nsters APP-系統手冊.pdf`（僅自 Git 索引移除，保留本機檔案）
- `system_data/四技第111405組-貘nsters APP-系統簡介.pdf`（僅自 Git 索引移除，保留本機檔案）

### Migration

- 無

### API

- 無

### Database

- 文件補充舊系統資料庫參考與新版調整原則，未修改實體資料庫。

### 皜祈岫

- `git diff --check`
- `git status --short --ignored -- system_data`

### Commit 撱箄降

```text
docs(system-data): 補充舊系統參考規範
```

### ?酉 / 敺Ⅱ隤???

- `system_data/` 只作為本機參考資料，不再納入 Git 追蹤。

---

## 2026-07-01 15:14

Task
TASK-011 建立 Security / JWT 基礎設定

修改人
Codex

### 本次完成

- 新增 Spring Security starter。
- 新增 `SecurityConfig`，設定 Stateless session、停用 CSRF、啟用 CORS、開放 Auth API 並保護 `/api/**`。
- 新增 `SecurityExceptionHandler`，統一輸出 401 / 403 `ApiResponse<Void>`。
- 新增 `JwtProperties`，集中管理 JWT issuer、secret 與 token 有效時間設定。
- 新增 `BCryptPasswordEncoder` Bean。
- 新增 `SecurityConfigTest`，驗證 JWT 設定綁定、BCrypt、Auth API 匿名存取與受保護 API 401 回應。
- 更新 README、Backend README、`docs/API_SPEC.md` 與 `docs/TASKS.md`。
- 新增 Log 前已檢查保存期限，現有 Log 未超過一個月，無需刪除。

### 新增

- `backend/src/main/java/com/monsters/common/security/JwtProperties.java`
- `backend/src/main/java/com/monsters/common/security/SecurityConfig.java`
- `backend/src/main/java/com/monsters/common/security/SecurityExceptionHandler.java`
- `backend/src/test/java/com/monsters/common/security/SecurityConfigTest.java`

### 修改

- `README.md`
- `backend/README.md`
- `backend/build.gradle`
- `backend/src/main/resources/application.yml`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 新增 Security 基礎規則：Auth API 允許匿名，其餘 `/api/**` 需驗證。
- 未新增業務 API endpoint。

### Database

- 無

### 測試

- `.\gradlew.bat test`
- `.\gradlew.bat build`
- `git diff --check`

### Commit 建議

```text
feat(security): 建立 security jwt 基礎設定
```

### 備註 / 待確認事項

- 正式環境必須設定 `JWT_SECRET`。
- 本 Task 未導入額外 JWT 第三方套件，token 產生與驗證會在 Auth API Task 實作。

---

## 2026-07-01 15:03

Task
DOC-006 停止追蹤本機 dev 設定檔

修改人
Codex

### 本次完成

- 將 `backend/src/main/resources/application-dev.yml` 加入 `.gitignore`。
- 使用 `git rm --cached` 將 `application-dev.yml` 從 Git index 移除，保留本機檔案。
- 新增 Log 前已檢查保存期限，現有 Log 未超過一個月，無需刪除。

### 新增

- 無

### 修改

- `.gitignore`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- `backend/src/main/resources/application-dev.yml`（僅停止 Git 追蹤，本機檔案保留）

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- `git status --short --ignored -- backend/src/main/resources/application-dev.yml`
- `git diff --check`

### Commit 建議

```text
chore(config): 停止追蹤 dev application 設定
```

### 備註 / 待確認事項

- 本機 `application-dev.yml` 已被 `.gitignore` 忽略，可保留本機資料庫帳密。

---

## 2026-07-01 14:48

Task
TASK-010 建立 CORS 設定

修改人
Codex

### 本次完成

- 新增後端 `CorsConfig`，將 CORS 設定套用於 `/api/**`。
- 新增 `CorsProperties`，由 `app.cors.*` 與環境變數集中管理允許來源、methods、headers、credentials 與 max age。
- 新增 `CorsConfigTest`，驗證設定綁定、允許本機來源與拒絕未授權來源。
- 更新 `application.yml` 加入 CORS 預設設定。
- 更新 README、Backend README 與 `docs/API_SPEC.md` 補充 CORS 設定方式。
- 更新 `docs/TASKS.md` 標示本 Task 完成。
- 新增 Log 前已檢查保存期限，現有 Log 未超過一個月，無需刪除。

### 新增

- `backend/src/main/java/com/monsters/common/config/CorsConfig.java`
- `backend/src/main/java/com/monsters/common/config/CorsProperties.java`
- `backend/src/test/java/com/monsters/common/config/CorsConfigTest.java`

### 修改

- `README.md`
- `backend/README.md`
- `backend/src/main/resources/application.yml`
- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 新增 `/api/**` CORS 設定，未新增業務 API endpoint。

### Database

- 無

### 測試

- `.\gradlew.bat test`
- `.\gradlew.bat build`
- `git diff --check`

### Commit 建議

```text
feat(api): 建立 cors 設定
```

### 備註 / 待確認事項

- 正式環境需設定 `CORS_ALLOWED_ORIGIN_PATTERNS` 為可信任前端網域。

---

## 2026-07-01 14:40

Task
TASK-009 建立 Base Entity

修改人
Codex

### 本次完成

- 新增後端共用 `BaseEntity`，統一 `id`、`createdAt`、`updatedAt` 欄位與 JPA lifecycle callback。
- 新增 `BaseEntityTest`，驗證 JPA annotation、欄位命名與時間戳更新行為。
- 更新 `docs/DATABASE_SPEC.md` 補充 Base Entity 對應規範。
- 更新 `docs/TASKS.md` 標示本 Task 完成。
- 新增 Log 前已檢查保存期限，現有 Log 未超過一個月，無需刪除。

### 新增

- `backend/src/main/java/com/monsters/common/entity/BaseEntity.java`
- `backend/src/test/java/com/monsters/common/entity/BaseEntityTest.java`

### 修改

- `docs/DATABASE_SPEC.md`
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

- 新增後端 Entity 共用欄位規範，未新增資料表或 Migration。

### 測試

- `.\gradlew.bat test`
- `.\gradlew.bat build`
- `git diff --check`

### Commit 建議

```text
feat(database): 建立 base entity
```

### 備註 / 待確認事項

- 無

---

## 2026-07-01 14:29

Task
TASK-008 建立全域 Exception Handler

修改人
Codex

### 本次完成

- 新增後端共用 Exception 類別，集中定義 400、401、403、404、409 錯誤。
- 新增 `GlobalExceptionHandler`，以 `RestControllerAdvice` 統一處理 Business、Validation 與未預期 Exception。
- 新增 `GlobalExceptionHandlerTest`，驗證 HTTP Status 與 `ApiResponse<Void>` 錯誤格式。
- 更新 `docs/API_SPEC.md` 補充全域 Exception Handler 與 Exception 對應 Status。
- 更新 `docs/TASKS.md` 標示本 Task 完成。
- 新增 Log 前已檢查保存期限，現有 Log 未超過一個月，無需刪除。

### 新增

- `backend/src/main/java/com/monsters/common/exception/BusinessException.java`
- `backend/src/main/java/com/monsters/common/exception/ValidationException.java`
- `backend/src/main/java/com/monsters/common/exception/ResourceNotFoundException.java`
- `backend/src/main/java/com/monsters/common/exception/ConflictException.java`
- `backend/src/main/java/com/monsters/common/exception/UnauthorizedException.java`
- `backend/src/main/java/com/monsters/common/exception/ForbiddenException.java`
- `backend/src/main/java/com/monsters/common/exception/GlobalExceptionHandler.java`
- `backend/src/test/java/com/monsters/common/exception/GlobalExceptionHandlerTest.java`

### 修改

- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 補充後端全域 Exception Handler 與錯誤 Response 規範，未新增業務 API endpoint。

### Database

- 無

### 測試

- `.\gradlew.bat test`
- `.\gradlew.bat build`
- `git diff --check`

### Commit 建議

```text
feat(api): 建立全域 exception handler
```

### 備註 / 待確認事項

- 無

---

## 2026-07-01 11:02

Task
DOC-005 建立 Log 保存期限規範

修改人
Codex

### 本次完成

- 新增 Log 保存政策：Log 僅保存一個月。
- 規範新增 Log 前必須先檢查 `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv` 是否有超過一個月的紀錄。
- 將 Log 保存政策記錄於 `AGENTS.md` 文件資訊。
- 本次檢查現有 Log 最早日期為 `2026-06-29`，未超過一個月，無需刪除。

### 新增

- 無

### 修改

- `AGENTS.md`
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

- `git diff --check`
- 確認現有 Log 日期皆未超過一個月。

### Commit 建議

```text
docs(log): 新增 log 保存期限規範
```

### 備註 / 待確認事項

- 無

---

## 2026-07-01 10:54

Task
TASK-007 建立統一 API Response

修改人
Codex

### 本次完成

- 新增後端共用 `ApiResponse<T>` DTO，統一 API 回傳格式。
- 新增 `ApiResponseTest`，驗證成功、失敗與 JSON 序列化欄位。
- 更新 `docs/API_SPEC.md` 補充後端共用 Response DTO 規範。
- 更新 `docs/TASKS.md` 標示本 Task 完成。
- 更新 `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv`。

### 新增

- `backend/src/main/java/com/monsters/common/dto/ApiResponse.java`
- `backend/src/test/java/com/monsters/common/dto/ApiResponseTest.java`

### 修改

- `docs/API_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 補充後端 API Response 共用 DTO 規範，未新增業務 API endpoint。

### Database

- 無

### 測試

- `.\gradlew.bat test`
- `git diff --check`

### Commit 建議

```text
feat(api): 建立統一 response dto
```

### 備註 / 待確認事項

- 無

---

## 2026-07-01 10:02

Task
TASK-006 建立 README 執行說明

修改人
Codex

### 本次完成

- 補充根目錄 README 的必要環境、前端執行、後端執行、Docker Compose、環境變數、測試與提交流程。
- 更新 `docs/TASKS.md` 標示 README 執行說明 Task 完成。
- 更新 `CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv`。

### 新增

- 無

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

- `git diff --check`

### Commit 建議

```text
docs(readme): 補充專案執行說明
```

### 備註 / 待確認事項

- `docs/DECISIONS.md` 既有未提交修改非本次 Task 內容，未納入提交。

---

## 2026-06-30 11:16

Task
TASK-005 建立 Docker Compose（MySQL + Backend）

修改人
Codex

### 本次完成

- 新增 Docker Compose，包含 MySQL 與 Backend service。
- 新增後端 Dockerfile，使用 JDK 18 建置與執行 Spring Boot jar。
- 新增 `database/init/` 初始化 SQL 目錄說明。
- 更新 README 的 Docker Compose 啟動方式。
- 更新 `DATABASE_SPEC.md` 與 `DECISIONS.md` 的容器環境說明。
- 更新 `docs/TASKS.md` 標示本 Task 完成。

### 新增

- `docker-compose.yml`
- `backend/Dockerfile`
- `database/init/README.md`

### 修改

- `README.md`
- `backend/README.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
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

- 新增 MySQL Docker Compose service，未建立資料表或 Migration。

### 測試

- `docker compose config`
- 使用 JDK 18 執行 `.\gradlew.bat test`

### Commit 建議

```text
chore(docker): 建立 mysql 與 backend compose
```

### 備註 / 待確認事項

- 尚未建立實際資料表 migration。
- Docker image 需在有 Docker 與網路環境時下載。

---

## 2026-06-30 11:07

Task
DOC-004 建立 GitHub Actions 分支清理自動化

修改人
Codex

### 本次完成

- 新增 GitHub Actions workflow，每週一自動檢查遠端分支。
- 僅刪除已合併到 `origin/main` 的工作分支。
- 保留 `main`、`develop`、只合併到 `develop` 的分支，以及尚未合併到 `develop` 的分支。
- 支援手動觸發 `workflow_dispatch`。
- 更新 `docs/GIT_RULE.md` 補充分支清理自動化規則。

### 新增

- `.github/workflows/cleanup-merged-branches.yml`

### 修改

- `docs/GIT_RULE.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- `.github/.gitkeep`

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- 檢查 workflow YAML 內容與 Git 分支判斷規則。
- 執行 `git diff --check` 檢查格式。

### Commit 建議

```text
ci(github): 建立分支清理 workflow
```

### 備註 / 待確認事項

- GitHub Actions 需 workflow 被合併到 GitHub 預設分支後才會按排程執行。

---

## 2026-06-30 10:47

Task
TASK-004 調整 MySQL Profile 設定

修改人
Codex

### 本次完成

- 將後端 Spring Boot 設定拆分為共用、dev、prod 三份。
- `application.yml` 保留共用設定與預設 `dev` profile。
- 新增 `application-dev.yml` 作為本機開發 MySQL 連線設定。
- 新增 `application-prod.yml` 作為正式環境 MySQL 連線設定，必須使用環境變數。
- 移除重複用途的 `application-example.yml`。
- 調整 `.gitignore`，允許追蹤 `application-dev.yml`。
- 更新 `backend/README.md` 與 `docs/DATABASE_SPEC.md`。

### 新增

- `backend/src/main/resources/application-dev.yml`
- `backend/src/main/resources/application-prod.yml`

### 修改

- `.gitignore`
- `backend/README.md`
- `backend/src/main/resources/application.yml`
- `docs/DATABASE_SPEC.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- `backend/src/main/resources/application-example.yml`

### Migration

- 無

### API

- 無

### Database

- 文件補充 Spring Boot Profile 與 MySQL 連線設定，未建立資料表或 Migration。

### 測試

- 使用 JDK 18 執行 `.\gradlew.bat test`

### Commit 建議

```text
chore(database): 拆分 spring profile 設定
```

### 備註 / 待確認事項

- `prod` profile 不提供預設帳密，正式環境需設定 `DB_URL`、`DB_USERNAME`、`DB_PASSWORD`。

---

## 2026-06-30 10:41

Task
TASK-004 建立 MySQL 連線設定

修改人
Codex

### 本次完成

- 新增 Spring Data JPA 與 MySQL Connector 依賴。
- 於 `application.yml` 加入 MySQL datasource 與 JPA 基本設定。
- 新增 `application-example.yml` 作為 MySQL 連線範例。
- 調整後端 context load 測試，避免測試環境依賴本機 MySQL。
- 更新 `DATABASE_SPEC.md` 與 `backend/README.md` 的連線設定說明。
- 更新 `docs/TASKS.md` 標示本 Task 完成。

### 新增

- `backend/src/main/resources/application-example.yml`

### 修改

- `backend/build.gradle`
- `backend/README.md`
- `backend/src/main/resources/application.yml`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`
- `docs/DATABASE_SPEC.md`
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

- 新增 MySQL 連線設定文件，未建立資料表或 Migration。

### 測試

- 使用 JDK 18 執行 `.\gradlew.bat test`

### Commit 建議

```text
feat(database): 建立 mysql 連線設定
```

### 備註 / 待確認事項

- 尚未建立 Docker Compose，下一個 Task 將補上 MySQL + Backend 執行環境。
- 預設帳密僅供本機開發使用，正式環境需改用環境變數。

---

## 2026-06-30 10:27

Task
DOC-003 文件一致性與精簡

修改人
Codex

### 本次完成

- 新增 `docs/DECISIONS.md`，集中管理已定案技術選型與待確認事項。
- 統一 `CODING_STANDARD.md` 版本資訊與 Gradle 說明。
- 更新 `GIT_RULE.md` 最後更新日期。
- 補齊 `DATABASE_SPEC.md` 中日記社群愛心與留言資料表欄位。
- 明確定義 `API_SPEC.md` 社群 `postId` 格式。
- 將 `API_SPEC.md` 待確認事項集中引用至 `DECISIONS.md`。
- 將 `TASKS.md` 中 Docker Compose 任務由可選調整為必做，避免與不得跳過 Phase 衝突。

### 新增

- `docs/DECISIONS.md`

### 修改

- `docs/API_SPEC.md`
- `docs/CODING_STANDARD.md`
- `docs/DATABASE_SPEC.md`
- `docs/GIT_RULE.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### Migration

- 無

### API

- 文件補充：定義社群 `postId` 格式為 `{type}:{id}`。

### Database

- 文件補充：補齊 `diary_social_like` 與 `diary_social_comment` 欄位規格。

### 測試

- 使用 `rg` 掃描 Maven、Java 21、YYYY-MM-DD、待確認事項與欄位缺漏。
- 使用 `git diff --check` 檢查文件格式。

### Commit 建議

```text
docs(spec): 整理文件一致性與決策紀錄
```

### 備註 / 待確認事項

- `docs/DECISIONS.md` 中仍保留需使用者後續決策的項目。

---

## 2026-06-30 10:17

Task
TASK-003 建立 Spring Boot 專案

修改人
Codex

### 本次完成

- 依使用者確認改用 Gradle 建立後端 Spring Boot 專案。
- 將 `docs/CODING_STANDARD.md` 後端 Build Tool 由 `Maven` 調整為 `Gradle`。
- 建立 `backend/` Gradle 專案、Spring Boot 入口類別、基本 `application.yml` 與 context load 測試。
- 產生 Gradle wrapper，後續後端可用 `backend/gradlew.bat` 執行建置與測試。
- 移除 `backend/.gitkeep`。
- 更新 `docs/TASKS.md` 標示本 Task 完成。

### 新增

- `backend/README.md`
- `backend/build.gradle`
- `backend/settings.gradle`
- `backend/gradlew`
- `backend/gradlew.bat`
- `backend/gradle/wrapper/gradle-wrapper.jar`
- `backend/gradle/wrapper/gradle-wrapper.properties`
- `backend/src/main/java/com/monsters/MonstersApplication.java`
- `backend/src/main/resources/application.yml`
- `backend/src/test/java/com/monsters/MonstersApplicationTests.java`

### 修改

- `docs/CODING_STANDARD.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- `backend/.gitkeep`

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- 使用 JDK 18 執行 `gradle wrapper --gradle-version 8.7`
- 使用 JDK 18 執行 `.\gradlew.bat test`

### Commit 建議

```text
feat(backend): 建立 spring boot 專案
```

### 備註 / 待確認事項

- 本 Task 未加入 MySQL / JPA 設定，避免提前實作下一個 Task。
- 建立後端時以暫時環境變數指定 `JAVA_HOME=C:\Program Files\Java\jdk-18.0.2`。

---

## 2026-06-30 09:54

Task
TASK-002 建立 Flutter 專案

修改人
Codex

### 本次完成

- 使用 Flutter CLI 在 `frontend/` 建立 `monsters` 前端專案。
- 建立 Android、iOS、Web 平台骨架。
- 移除 Flutter template 預設 hosted 直接依賴，保留 SDK 依賴。
- 調整根目錄 `.gitignore`，允許追蹤 Flutter app 必要檔案 `frontend/pubspec.lock` 與 `frontend/.metadata`。
- 更新 `frontend/README.md` 為貘nsters 前端說明。
- 更新 `docs/TASKS.md` 標示本 Task 完成。

### 新增

- `frontend/.gitignore`
- `frontend/.metadata`
- `frontend/README.md`
- `frontend/analysis_options.yaml`
- `frontend/android/`
- `frontend/ios/`
- `frontend/lib/`
- `frontend/pubspec.lock`
- `frontend/pubspec.yaml`
- `frontend/test/`
- `frontend/web/`

### 修改

- `.gitignore`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- `frontend/.gitkeep`

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- `flutter pub get`
- `flutter analyze`
- `flutter test`

### Commit 建議

```text
feat(frontend): 建立 flutter 專案
```

### 備註 / 待確認事項

- `flutter_test` 仍會帶入 SDK 測試所需傳遞套件，未新增非必要直接 hosted 依賴。
- 目前功能仍為 Flutter template smoke test，後續 Phase 1 再建立 Router、Theme 與共用元件。

---

## 2026-06-30 09:44

Task
DOC-002 調整後端 Java 版本規範

修改人
Codex

### 本次完成

- 將後端 Java 版本規範由 `Java 21 LTS（建議）` 調整為 `JDK 18`。
- 後續 Spring Boot 專案建立與 Java 指令應以本機可用的 `C:\Program Files\Java\jdk-18.0.2` 為準。

### 新增

- 無

### 修改

- `docs/CODING_STANDARD.md`
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

- 確認 `docs/CODING_STANDARD.md` 已改為 `JDK 18`。
- 已於前次環境檢查確認 `C:\Program Files\Java\jdk-18.0.2\bin\java.exe` 與 `javac.exe` 可執行。

### Commit 建議

```text
docs(java): 調整後端 java 版本規範
```

### 備註 / 待確認事項

- 目前系統 PATH 仍優先使用 Java 8，建立 Spring Boot 專案時需暫時設定 `JAVA_HOME` 與 PATH 指向 JDK 18，或由使用者永久調整系統環境變數。

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

---

## 2026-07-16 15:49

Task
PENPOT-WEB-REGISTER Web 註冊頁依 Penpot 設計精準修正

執行者
Codex

### 完成內容

- 依 Penpot MCP 選取 board `Account / Web / 03 Register / 註冊` 修正 Web 註冊頁。
- Web 版調整為 620px brand panel、520px 表單寬度，對齊 x=756 的表單起點。
- 調整 Web 版返回登入、標題、副標、欄位提示、規則卡與 `完成註冊` 按鈕順序。
- 新增註冊頁 Web widget test，驗證 Web copy 與主要元素。
- 註冊頁新增顏色皆集中於 `AppColors`。

### 新增

- 無

### 修改

- `frontend/lib/pages/register_page.dart`
- `frontend/lib/theme/app_colors.dart`
- `frontend/test/register_page_test.dart`
- `docs/UI_SPEC.md`
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

- `flutter analyze --no-pub`：通過，No issues found。
- `flutter test --no-pub test/register_page_test.dart`：通過，7 tests passed。

### Log 保存期限檢查

- 已於新增本次 Log 前檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx` 是否存在。
- 目前最早紀錄為 2026-06-29，距 2026-07-16 未超過一個月，未刪除紀錄。

### 待確認事項

- 目前未執行瀏覽器截圖比對；本次以 Penpot MCP 座標與 Flutter widget/analyze 驗證為準。
---

## 2026-07-16 16:12

Task
PENPOT-SPLASH Web / App SplashPage Penpot 畫面對齊

執行者
Codex

### 完成內容

- 使用 Penpot MCP 讀取 Account / Web / 01 Splash / 啟動 與 Account / Mobile / 01 Splash / 啟動。
- 將 SplashPage 改為 Web 1440x900 與 Mobile 390x844 的 responsive layout。
- 保留 AuthController.restoreSession()：有效 session 導向 home；無效 session 顯示登入 / 註冊行動。
- 新增 Splash theme token，避免 page 直接宣告色碼。
- 新增 SplashPage widget tests，驗證 Web / Mobile 位置尺寸與登入 / 註冊導向。

### 新增

- rontend/test/splash_page_test.dart

### 修改

- rontend/lib/pages/splash_page.dart
- rontend/lib/theme/app_colors.dart
- docs/UI_SPEC.md
- docs/TASKS.md
- log/CHANGE_LOG.md
- log/CHANGE_HISTORY.csv

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- lutter analyze --no-pub：通過，No issues found
- lutter test --no-pub test/splash_page_test.dart：通過，4 tests passed

### Log 保存期限檢查

- 已檢查 CHANGE_LOG.md、CHANGE_HISTORY.csv 與 CHANGE_HISTORY.xlsx。
- 截止日為 2026-06-16；CHANGE_LOG.md 最早日期為 2026-06-16，CHANGE_HISTORY.csv 最早日期為 2026-06-29。
- 本次沒有超過一個月的 Log，未刪除既有紀錄。

### 待確認事項

- 無
---

## 2026-07-16 16:22

Task
PENPOT-SPLASH-REDIRECT SplashPage session 失敗自動導向 LoginPage

執行者
Codex

### 完成內容

- 將 SplashPage session restore 失敗流程改為直接導向 login route。
- 移除 Splash 畫面中的登入 / 註冊行動按鈕，避免與 Penpot Splash 畫板不一致。
- 更新 SplashPage widget tests：檢查中狀態仍對齊 Penpot Web / Mobile，restore false 後自動進入 LoginPage。

### 新增

- 無

### 修改

- rontend/lib/pages/splash_page.dart
- rontend/test/splash_page_test.dart
- docs/UI_SPEC.md
- docs/TASKS.md
- log/CHANGE_LOG.md
- log/CHANGE_HISTORY.csv

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- lutter analyze --no-pub：通過，No issues found
- lutter test --no-pub test/splash_page_test.dart：通過，3 tests passed

### Log 保存期限檢查

- 已檢查 CHANGE_LOG.md、CHANGE_HISTORY.csv 與 CHANGE_HISTORY.xlsx。
- 截止日為 2026-06-16；CHANGE_LOG.md 最早日期為 2026-06-16，CHANGE_HISTORY.csv 最早日期為 2026-06-29。
- 本次沒有超過一個月的 Log，未刪除既有紀錄。

### 待確認事項

- 無
---

## 2026-07-16 16:29

Task
PENPOT-SPLASH-EXACT SplashPage 精準修正至 Penpot Page

執行者
Codex

### 完成內容

- 重新讀取 Penpot Splash Web / Mobile shape 資訊。
- 修正 SplashPage 與 Penpot 不一致處：文字改為 left align、Logo 改為 BoxFit.fill、Status card 移除圓角、Status dot/text/hint 改為絕對座標定位。
- 補強 widget tests，新增 status dot、status text、status hint 的 Web / Mobile 座標驗證。

### 新增

- 無

### 修改

- rontend/lib/pages/splash_page.dart
- rontend/test/splash_page_test.dart
- docs/UI_SPEC.md
- docs/TASKS.md
- log/CHANGE_LOG.md
- log/CHANGE_HISTORY.csv

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- lutter analyze --no-pub：通過，No issues found
- lutter test --no-pub test/splash_page_test.dart：通過，3 tests passed

### Log 保存期限檢查

- 已檢查 CHANGE_LOG.md、CHANGE_HISTORY.csv 與 CHANGE_HISTORY.xlsx。
- 截止日為 2026-06-16；CHANGE_LOG.md 最早日期為 2026-06-16，CHANGE_HISTORY.csv 最早日期為 2026-06-29。
- 本次沒有超過一個月的 Log，未刪除既有紀錄。

### 待確認事項

- 無
---

## 2026-07-16 16:46

Task
PENPOT-HOME HomePage Web / App Penpot 畫面對齊

執行者
Codex

### 完成內容

- 使用 Penpot MCP 讀取 Web / Companion Home 與 Mobile / Companion Home。
- 重寫 HomePage 為 Web 1440x900 與 Mobile 390x844 的 Penpot canvas。
- 移除 HomePage 對 Material AppBar / NavigationBar / 舊 quick action layout 的依賴，改為 Penpot 自訂版面。
- 保留主按鈕導向 nnoyanceChat、帳號按鈕導向 profile、怪獸點擊動畫 key 與 reduced motion 行為。
- 新增 Home theme token，避免 page 直接宣告色碼。

### 新增

- 無

### 修改

- rontend/lib/pages/home_page.dart
- rontend/lib/theme/app_colors.dart
- rontend/test/home_page_test.dart
- docs/UI_SPEC.md
- docs/TASKS.md
- log/CHANGE_LOG.md
- log/CHANGE_HISTORY.csv

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- lutter analyze --no-pub：通過，No issues found
- lutter test --no-pub test/home_page_test.dart：通過，5 tests passed
- lutter test --no-pub test/routes/app_router_test.dart --plain-name "supports annoyance chat route and home entry"：通過，1 test passed

### Log 保存期限檢查

- 已檢查 CHANGE_LOG.md、CHANGE_HISTORY.csv 與 CHANGE_HISTORY.xlsx。
- 截止日為 2026-06-16；CHANGE_LOG.md 最早日期為 2026-06-16，CHANGE_HISTORY.csv 最早日期為 2026-06-29。
- 本次沒有超過一個月的 Log，未刪除既有紀錄。

### 待確認事項

- 	est/routes/app_router_test.dart 全檔仍有既有 Register 測試文字定位失敗；本次只驗證 Home route 指定測試。
---

## 2026-07-16 17:26 PENPOT-PROFILE-HOME-FULL

Task
Penpot ProfilePage Web / App 對齊與 HomePage 滿版修正

執行者
Codex

### 完成內容

- 依 Penpot Profile Web / Mobile 設計調整 Flutter ProfilePage。
- 保留既有 UserProfileController / UserRepository / ApiClient 流程與表單驗證。
- 新增 profile theme tokens，ProfilePage 不直接宣告色碼。
- 將 Profile Penpot canvas widgets 拆至 rontend/lib/widgets/profile/profile_penpot_canvas.dart，避免 Page 檔案過長。
- 將 HomePage WEB / Web / Companion Home canvas 外層縮放改為 BoxFit.cover，修正部署寬螢幕非滿版問題。

### 新增

- rontend/lib/widgets/profile/profile_penpot_canvas.dart

### 修改

- rontend/lib/pages/profile_page.dart
- rontend/lib/pages/home_page.dart
- rontend/lib/theme/app_colors.dart
- docs/UI_SPEC.md
- docs/TASKS.md
- log/CHANGE_LOG.md
- log/CHANGE_HISTORY.csv

### 刪除

- 無

### Migration

- 無

### API

- 無

### Database

- 無

### 測試

- lutter analyze --no-pub：通過，No issues found
- lutter test --no-pub test/profile_page_test.dart：通過，5 tests passed
- lutter test --no-pub test/home_page_test.dart：通過，5 tests passed

### system_data 參考

- 已檢查 system_data/front-end/monsters_front_end/lib/pages/drawer/edit_personalInfo.dart 與 system_data/front-end/monsters_front_end/lib/pages/home.dart。
- 僅參考舊系統個人資料編輯與首頁怪獸互動意圖，未複製舊程式、未沿用舊硬編碼色碼或舊架構。

### Log 保存期限檢查

- 已檢查 CHANGE_LOG.md、CHANGE_HISTORY.csv 與 CHANGE_HISTORY.xlsx 是否存在。
- 保存期限截止日：2026-06-16。
- CHANGE_LOG.md 最早日期為 2026-06-16，CHANGE_HISTORY.csv 最早日期為 2026-06-29，未發現超過一個月紀錄。
- 本次未刪除過期 Log。

### 待確認事項

- 若要進一步精準比對 HomePage，需由使用者在 Penpot 選取正確 WEB / Web / Companion Home board 後再執行尺寸比對。

---

## 2026-07-18 WEB-FIRST-RWD 與 AUTH-REFRESH

Task
整合 Web-first RWD 共用版型、Penpot 頁面相對定位，以及 Profile 401 與 30 天登入狀態 Token Refresh 修正

執行者
Codex

### AUTH-REFRESH 完成內容

- 確認 ProfilePage 本身與 `GET /api/users/me` 路徑正確，根因為本地 session 30 天但 access token 僅 1 小時。
- 新增 `POST /api/auth/refresh`，驗證 refresh token 簽章、issuer、type、期限與使用者狀態。
- Refresh token 預設期限改為 2592000 秒，符合 rolling 30 天登入需求。
- 實作 refresh token rotation；舊 token hash 寫入既有 `revoked_tokens`，重複使用會回傳 401。
- Flutter 啟動恢復 session 時先換發新 Token，不再直接重用保存的 access token。
- `ApiClient` 遇到受保護 API 401 時共用單一 refresh request，成功後只重試原 request 一次。
- Refresh token 驗證失敗時清除 Authorization header 與本地 session，並由 App 導回登入頁；暫時性網路錯誤保留 session。
- 登出 request 可攜帶 refresh token，後端一併撤銷 access 與 refresh token。

### 新增

- `backend/src/main/java/com/monsters/dto/auth/RefreshTokenRequest.java`
- `frontend/test/repositories/auth_repository_test.dart`

### 修改

- Backend Auth Controller／Service、JWT、Security、Token revocation 與相關測試。
- Flutter App、ApiClient、Auth Provider／Repository 與登入、路由相關測試。
- `README.md`、Backend／Frontend README、PROJECT／API／DATABASE／UI／DECISIONS／TASKS 規格。
- `log/CHANGE_LOG.md`、`log/CHANGE_HISTORY.csv`。

### system_data 參考

- 已搜尋舊前端 access token 使用方式，未找到 refresh token 或 rotation 流程可重用。
- 舊程式只出現硬編碼 `<ACCESS_TOKEN>` placeholder，本次未沿用，也未修改 `system_data/`。

### API

- 新增 `POST /api/auth/refresh`。
- `POST /api/auth/logout` 新增 optional `refreshToken` request body，未帶 body 的舊 Client 仍相容。
- Refresh 成功沿用既有 `LoginResponse` contract；無效、過期、type 錯誤、已 rotation 或使用者無效回傳 401。

### Database

- 沿用既有 `revoked_tokens` schema 保存 refresh token hash，無欄位與資料表異動。
- 無 Migration。

### 文件更新

- Refresh token 預設有效期由 14 天統一調整為 rolling 30 天。
- 補齊 rotation、並行 401 single-flight、單次 retry、失效導頁與登出撤銷規格。

### 測試

- Backend `./gradlew test`：通過。
- Backend `./gradlew build`：通過。
- Frontend `flutter analyze --no-pub`：通過，No issues found。
- Frontend `flutter test --no-pub`：通過，86 tests passed。
- Frontend `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Web build 顯示既有 Cupertino icon font 提示，不影響建置或 Token Refresh。

### WEB-FIRST-RWD 完成內容

- 盤點 Splash、Login、Register、Home、Profile 的 Penpot 實作與定位方式。
- 新增 Mobile／Tablet／Desktop 共用 breakpoint 與 `ResponsiveLayout`／`ResponsiveContent`。
- 將 Splash、Login、Register、Home、Profile 的 Tablet／Desktop 主版面改為相對 flow layout；Mobile 保留 Penpot 精準畫布。
- 修正 Home 在 900、950、1024px 的負 padding、導覽 overflow 與固定 canvas 問題。
- 補上 Web-first 開發設定、固定本機網址、RWD 驗收寬度與瀏覽器即時 resize 規範。
- 更新既有啟動、路由與密碼鎖測試，使測試契約符合目前路由及頁面入口。

### 新增

- `frontend/lib/layout/responsive_layout.dart`
- `frontend/test/layout/responsive_layout_test.dart`

### 修改

- `frontend/lib/pages/splash_page.dart`
- `frontend/lib/pages/login_page.dart`
- `frontend/lib/pages/register_page.dart`
- `frontend/lib/pages/home_page.dart`
- `frontend/lib/pages/profile_page.dart`
- `frontend/lib/widgets/profile/profile_penpot_canvas.dart`
- `frontend/test/splash_page_test.dart`
- `frontend/test/login_page_test.dart`
- `frontend/test/register_page_test.dart`
- `frontend/test/home_page_test.dart`
- `frontend/test/profile_page_test.dart`
- `frontend/test/widget_test.dart`
- `frontend/test/routes/app_router_test.dart`
- `frontend/test/password_lock_page_test.dart`
- `README.md`
- `frontend/README.md`
- `docs/PROJECT_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/CODING_STANDARD.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 刪除

- 無

### system_data 參考

- 已依本次盤點結果確認舊系統首頁與個人資料流程僅作互動意圖參考。
- 未修改 `system_data/`，未沿用舊系統固定座標 Web 畫面、舊架構、金鑰或環境設定。

### API

- 無異動。

### Database

- 無異動，無 Migration。

### 文件更新

- 明確定義目前前端採 Web-first 開發與驗收，Android／iOS 維持相容。
- 共用 breakpoint 定為 Mobile `< 600px`、Tablet `600px - 1199px`、Desktop `>= 1200px`。
- 補上 Penpot 頁面定位方式盤點、相對 layout 規範與 390 至 1920px RWD 測試矩陣。

### 測試

- `flutter analyze --no-pub`：通過，No issues found。
- `flutter test --no-pub`：通過，107 tests passed。
- `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Web build 顯示既有 Cupertino icon font 提示，不影響建置成功或本次 RWD 功能。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx` 是否存在。
- 保存期限截止日為 2026-06-18；`CHANGE_LOG.md` 最早正式 Task 日期為 2026-06-29，`CHANGE_HISTORY.csv` 最早日期為 2026-06-29。
- 未發現超過一個月的正式紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源，未修改。

### 待確認事項

- 部署時需確認未以環境變數將 `JWT_REFRESH_TOKEN_EXPIRATION_SECONDS` 覆寫回舊值 1209600。

---

## 2026-07-18 14:28 MERGE-PR59-PR60

Task
處理 PR #59 Web-first RWD 合併至 `develop` 後，PR #60 Profile Token Refresh 的合併衝突

執行者
Codex

### 完成內容

- 將 `origin/develop` 合併至 `fix/auth-token-refresh`，逐項解決 5 個衝突檔案。
- `docs/TASKS.md`、`CHANGE_LOG.md` 與 `CHANGE_HISTORY.csv` 均保留 RWD 與 Token Refresh 兩側紀錄。
- `login_page_test.dart` 同時保留 Splash 未登入導頁、登出清除 session 與 Home 帳號入口驗證。
- `widget_test.dart` 同時保留啟動登入頁、Auth 失效導頁與登入前往註冊頁驗證。
- 已確認 Repository 不再存在 conflict marker，且 `git diff --check` 通過。

### 修改

- `docs/TASKS.md`
- `frontend/test/login_page_test.dart`
- `frontend/test/widget_test.dart`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### 新增／刪除

- 無；其餘 RWD 新增檔案來自已合併的 PR #59。

### system_data 參考

- RWD 與 Token Refresh 原任務皆已完成 `system_data/` 檢查；本次只處理兩組已驗證變更的 Git 衝突，未發現需再次引用的舊流程。
- 未修改 `system_data/`。

### API

- 本次衝突處理未新增或修改 API；保留 PR #60 已完成的 `POST /api/auth/refresh` 與相容 logout contract。

### Database

- 無異動，無 Migration；保留既有 `revoked_tokens` 使用方式。

### 文件更新

- 更新 Task 狀態並整合 RWD、Token Refresh 與本次 merge 工作報告及歷史紀錄。

### 測試

- Backend `./gradlew test`：通過。
- Backend `./gradlew build`：通過。
- Frontend `flutter analyze --no-pub`：通過，No issues found。
- Frontend `flutter test --no-pub`：通過，115 tests passed。
- Frontend `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Web build 僅顯示既有 Cupertino icon font 提示，不影響建置結果。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-18。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log。

### 待確認事項

- 部署環境仍需確認未將 `JWT_REFRESH_TOKEN_EXPIRATION_SECONDS` 覆寫回舊值 1209600。

---

## 2026-07-18 15:03 PROFILE-ANNOYANCE-PENPOT-RWD

Task
同步 Profile 生日／登出與 Annoyance Penpot 畫面，並修正 Home／Profile Web 右側留白

執行者
Codex

### 完成內容

- Profile 生日欄位改用 Flutter 內建 `showDatePicker`，限制 1900-01-01 至當日並維持 `yyyy-MM-dd` API 格式；未新增第三方套件。
- Profile Web、Tablet、Mobile 加入可見登出按鈕與確認對話框，確認後沿用 `AuthController.logout()` 清除登入狀態並返回登入頁。
- Home／Profile Tablet 與 Desktop 最外層改為 stretch 的滿寬 flow layout，修正 674px 固定內容寬度造成的右側留白。
- Annoyance Page 依 Penpot Web／Mobile Flow 同步導覽、進度、陪伴訊息與操作面板，保留原本結構化狀態機、媒體、繪圖、分數、分享與送出流程。
- Penpot Profile Web／Mobile 個人首頁新增登出入口、編輯頁新增日曆生日欄位；匯出四張畫板完成視覺檢查。
- 依正式規格未實作 Penpot 獎勵延伸畫面，Phase 3 建立成功後仍只顯示完成結果。

### 新增

- `frontend/lib/widgets/annoyance/annoyance_penpot_shell.dart`

### 修改

- `frontend/lib/pages/annoyance_chat_page.dart`
- `frontend/lib/pages/home_page.dart`
- `frontend/lib/pages/profile_page.dart`
- `frontend/lib/theme/app_colors.dart`
- `frontend/lib/widgets/profile/profile_penpot_canvas.dart`
- `frontend/test/annoyance_chat_page_test.dart`
- `frontend/test/home_page_test.dart`
- `frontend/test/profile_page_test.dart`
- `docs/PROJECT_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### system_data 參考

- 參考 `四技第111405組-貘nsters APP-系統手冊.pdf`、系統簡介與舊 Flutter Profile／Home／Annoyance 流程，保留舊系統的個人資料顯示、抽屜登出及聊天式煩惱建立意圖。
- 新版改用 Riverpod、go_router、REST API 與相對 RWD layout；未沿用舊全域狀態、固定 Web 座標、硬編碼登入資料或舊獎勵流程。
- 未修改 `system_data/`。

### API／Database

- API 無異動；Profile 更新、登出與 Annoyance 建立沿用現有 contract。
- Database 無異動，無 Migration。

### 文件更新

- PROJECT_SPEC 補上內建日曆生日輸入及個人資料頁登出需求。
- UI_SPEC 補上滿寬 shell、Profile 日曆／登出、Annoyance Penpot 與 390 至 1920px RWD 規範。
- DECISIONS 記錄使用者選定方案 A，不新增第三方日曆套件。
- TASKS 完整記錄 TODO → IN PROGRESS → REVIEW → DONE。

### 測試

- `flutter analyze --no-pub`：通過，No issues found。
- Home／Profile／Annoyance targeted widget tests：36 tests passed。
- `flutter test --no-pub`：124 tests passed。
- `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Web build 僅顯示既有 Cupertino icon font 提示，不影響建置結果。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-18。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源，未修改。

### 待確認事項

- 無。

---

## 2026-07-18 22:21 PHASE4-DIARY-CONTRACT

Task
Phase 4 日記 contract-first、Penpot design-first 與 Web-first 準備

執行者
Codex

### 完成內容

- 完成 Phase 4 DoR 與舊系統 Diary 流程盤點，採用使用者核准的三項方案 A：獎勵延至 Phase 6、抽出 Entry 共用前端元件、心情繪圖可略過。
- 將 Diary API 從 endpoint 清單補齊為可實作 contract，包含 multipart、新增、分頁查詢、單筆、完整修改、分享、private media download、HTTP Range 與錯誤處理。
- 將 Phase 4 與後續含 UI 的 Phase 定義為 Penpot design-first，並明確採 Web-first 實作與驗收。
- 以 Penpot `Diary Flow / Web` 作第一驗收來源，保留 `Diary Flow / Mobile`；將第 08 確認頁按鈕改為「儲存這篇日記」、Phase 4 完成頁移除假獎勵，未來獎勵畫板標示為 Phase 6。
- 比對已完成的 Penpot `Web / Companion Home` 與 `Annoyance Flow / Web`，確認日記畫板沿用共用 Navbar、1440×900 Desktop 基準、1200px 內容區、雙欄、暖色卡片、字級、間距、圓角、陰影與按鈕層級。

### 修改／新增／刪除檔案

- 修改 `docs/PROJECT_SPEC.md`。
- 修改 `docs/API_SPEC.md`。
- 修改 `docs/UI_SPEC.md`。
- 修改 `docs/DECISIONS.md`。
- 修改 `docs/TASKS.md`。
- 修改 `log/CHANGE_LOG.md`。
- 修改 `log/CHANGE_HISTORY.csv`。
- 無新增或刪除 Repository 檔案；另已更新連線中的 Penpot Web／Mobile Diary 畫板。

### system_data 參考結果

- 參考舊系統手冊與簡介中的日記流程，以及舊 Flutter `diaryChat.dart`、`diaryAPI.dart`、`diaryRepo.dart`、`diaryModel.dart` 和舊 Backend Diary Controller／Service／DAO／Model。
- 保留日記記錄方式、optional 心情圖、分數與分享的業務意圖；未沿用 account path param、Base64 媒體、頁面直呼 HTTP、global state、自由文字 yes／no、硬編碼磁碟路徑、Controller 發獎與舊 DAO 錯誤作法。
- 未修改 `system_data/`。

### API 異動

- 僅更新 Phase 4 Diary API 正式 contract，尚未修改 Backend 程式。
- Diary 使用共用 Entry／EntryMedia，支援 TEXT／IMAGE／AUDIO／VIDEO 一種主要內容與一張 optional drawing；Phase 4 `reward = null`。

### Database 異動

- 無 Database schema 或 Migration 異動。
- 正式規格沿用既有 `entries` 與 `entry_media`；Diary 為 `entry_type = DIARY`、`annoyance_type_id = NULL`、`is_solved = false`。

### 文件更新

- PROJECT_SPEC：補齊 Diary 流程、Phase 4 reward 邊界、Penpot design-first、Web-first 與既有頁面樣式基準。
- API_SPEC：補齊 Diary multipart、response、分頁、更新、分享、媒體與錯誤 contract。
- UI_SPEC：補齊 Penpot 全 Phase 規則、Diary Web／Mobile 畫板來源、狀態機、共用元件、RWD 與完成頁規格。
- DECISIONS：記錄全部方案 A、Penpot design-first、Web-first 與既有樣式重用決策。
- TASKS：記錄 contract-first 狀態與 Phase 4 至 Phase 10 的 Penpot／Web-first 檢查項目。

### 測試方式與結果

- Contract 修改前 Backend `./gradlew test`：BUILD SUCCESSFUL。
- Contract 修改前 Flutter `flutter analyze --no-pub`：No issues found。
- Contract 修改前 Flutter `flutter test --no-pub`：132 tests passed。
- `flutter build web --no-pub`：通過，產出 `frontend/build/web`；僅顯示既有 Cupertino icon font 提示。
- Penpot 已匯出並檢視 Diary Web／Mobile 確認頁與完成頁，以及已完成的 Companion Home／Annoyance Web 畫板；未發現溢位、遮擋或 Phase 4 假獎勵文案。
- 本次僅修改文件與 Penpot，未修改 Backend、Frontend 或 Database 程式。

### Log 保存期限檢查結果

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-18。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源且未修改。

### 待確認事項

- 無；下一個實作 Task 依序為共用 Entry Diary domain／DTO／Service／Controller，再完成 Diary API，最後以 Penpot Web 畫板實作 Flutter Web 日記流程。

---

## 2026-07-18 15:29 MOBILE-FULL-WIDTH-MOOD-SCORE

Task
修正 391 至 599px Mobile 右側留白、加入煩惱分數圖片選擇，並提交 annoyance type／mood migration 時間欄位

執行者
Codex

### 完成內容

- 透過實際 Flutter Web 500px viewport 重現問題，確認 Mobile 分支的 390px Penpot canvas 維持固定寬度靠左，造成右側留白。
- 新增 `ResponsiveFixedCanvas`，讓 390 x 844 canvas 依 viewport 寬度等比例填滿；縮放高度超過 viewport 時改為垂直捲動。
- Home 與 Profile Mobile 套用滿寬 canvas，補上 500px、599px 回歸測試。
- `MoodScoreSelector` 改用 `moodPoint_1.png`～`moodPoint_5.png` 圖片卡片，保留 `1分`～`5分`、既有 key、API 整數值與無障礙語意。
- 分數卡片在窄螢幕自動換行，選取狀態使用品牌色邊框、底色與陰影。
- 納入使用者修改的兩支 Database migration，並將六位短日期字串正規化為 MySQL `CURRENT_TIMESTAMP`。

### 新增

- `frontend/assets/images/moodPoint_1.png`
- `frontend/assets/images/moodPoint_2.png`
- `frontend/assets/images/moodPoint_3.png`
- `frontend/assets/images/moodPoint_4.png`
- `frontend/assets/images/moodPoint_5.png`

### 修改

- `frontend/lib/layout/responsive_layout.dart`
- `frontend/lib/pages/home_page.dart`
- `frontend/lib/pages/profile_page.dart`
- `frontend/lib/widgets/annoyance/mood_score_selector.dart`
- `frontend/test/home_page_test.dart`
- `frontend/test/profile_page_test.dart`
- `frontend/test/widgets/mood_score_selector_test.dart`
- `database/migrations/20260711_01_add_annoyance_type_codes_and_seed.sql`
- `database/migrations/20260711_03_make_mood_score_unique.sql`
- `docs/PROJECT_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/DATABASE_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### system_data 參考

- 本次為已完成 Home／Profile／Annoyance 流程的精準 follow-up，沿用前一任務對舊 Mobile 固定畫布與煩惱分數流程的參考結果，未新增複製舊程式。
- 未修改 `system_data/`，未沿用舊全域狀態或直接 Database 存取方式。

### API／Database

- API 無異動；煩惱分數仍送出整數 1 至 5。
- Database schema 無異動，無新 Migration；修改既有 `20260711_01`、`20260711_03` seed DML，使 `created_at`／`updated_at` 明確使用 `CURRENT_TIMESTAMP`。

### 文件更新

- PROJECT_SPEC、UI_SPEC 同步分數圖片卡片與 Mobile 等比例滿寬行為。
- DATABASE_SPEC 同步兩支 migration 的 timestamp seed 規則。
- DECISIONS 記錄使用者指定的分數圖片 UI，Database lookup 仍維持中性整數語意。
- TASKS 記錄 TODO → IN PROGRESS → REVIEW → DONE。

### 測試

- `flutter analyze --no-pub`：通過，No issues found。
- Home／Profile／MoodScore／Annoyance targeted tests：42 tests passed。
- `flutter test --no-pub`：129 tests passed。
- `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Flutter Web 瀏覽器 500 x 844 viewport：`body`、`flutter-view` 均為 500px，Home 右側空白已消失。
- 5 張 moodPoint 圖片皆驗證為 156 x 156 RGBA PNG，Flutter asset bundle 載入通過。
- Docker daemon 未啟動，未執行隔離 MySQL migration；已完成 migration diff、短日期殘留與 `CURRENT_TIMESTAMP` 靜態檢查。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-18。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源，未修改。

### 待確認事項

- Docker／MySQL 啟動後可再於隔離測試資料庫實際執行兩支既有 migration；本次未連線或修改任何本機 Database 資料。

---

## 2026-07-18 18:31 SHARED-NAVIGATION-TRANSITION

Task
Web 方案 A 共用完整 Navbar、Mobile 方案 1 改通知，並統一頁面切換效果

執行者
Codex

### 完成內容

- 新增 `AppTopNavigation`，統一 Home／Profile／Annoyance Desktop Navbar 的 Logo、五個主要模組、記下心情 CTA、通知與個人資料入口。
- 新增 `MobileAppBottomNavigation`，統一 Home／Profile 的首頁、社群、怪獸、互動與「我的」；首頁與「我的」使用正式 route，其餘顯示具名即將開放提示。
- 首頁 Mobile 右上角由個人資料改為通知，移除重複 Profile 入口；底部「我的」成為正式個人資料入口。
- Profile Desktop 將儲存與登出移至共用 Navbar 下方的頁面 action bar，保留原驗證、API 與登出確認流程。
- 所有 route 前進進場動畫改為 0 秒；Home→Profile／Annoyance、Login→Register 使用 push 保留導覽堆疊，明確返回按鈕以 220ms 向右退出。
- 補齊 Mobile 通知、底部 Profile 導頁、三頁共用 Navbar、390 至 1920px overflow 與返回方向測試。

### 新增

- `frontend/lib/widgets/navigation/app_navigation.dart`

### 修改

- `frontend/lib/pages/home_page.dart`
- `frontend/lib/pages/profile_page.dart`
- `frontend/lib/pages/annoyance_chat_page.dart`
- `frontend/lib/pages/login_page.dart`
- `frontend/lib/pages/register_page.dart`
- `frontend/lib/routes/app_router.dart`
- `frontend/lib/widgets/profile/profile_penpot_canvas.dart`
- `frontend/lib/widgets/annoyance/annoyance_penpot_shell.dart`
- `frontend/test/home_page_test.dart`
- `frontend/test/profile_page_test.dart`
- `frontend/test/annoyance_chat_page_test.dart`
- `docs/PROJECT_SPEC.md`
- `docs/UI_SPEC.md`
- `docs/DECISIONS.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### system_data 參考

- 參考舊 Flutter `state/drawer.dart` 與 `pages/home.dart` 的個人資料、密碼鎖、使用說明、回饋及登出入口意圖。
- 新版依使用者選定方案改為 Web 共用 Navbar 與 Mobile 底部「我的」，未沿用舊 `endDrawer`、各頁重複選單、`MaterialPageRoute` 或直接操作本地登入資料的作法。
- 未修改 `system_data/`。

### API／Database

- API 無異動；通知與未完成模組目前只顯示 UI 提示，不呼叫假 API。
- Database 無異動，無 Migration。

### 文件更新

- PROJECT_SPEC 同步 Web／Mobile 導覽角色與頁面切換原則。
- UI_SPEC 補上共用 Navbar、Mobile 底部選單、通知入口、route stack 與 220ms 返回動畫規格。
- DECISIONS 記錄使用者選定 Web 方案 A、Mobile 方案 1改通知及頁面切換決策。
- TASKS 完整記錄 TODO → IN PROGRESS → REVIEW → DONE。

### 測試

- `flutter analyze --no-pub`：通過，No issues found。
- Home／Profile／Annoyance／Login／Register targeted tests：70 tests passed。
- `flutter test --no-pub`：131 tests passed。
- `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Web build 僅顯示既有 Cupertino icon font 提示，不影響建置結果。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-18。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未作為本次紀錄來源，未修改。

### 待確認事項

- 通知後端與通知中心頁面尚未開發；目前依正式規格顯示「通知即將開放」。

---

## 2026-07-18 18:38 PROFILE-ACTION-BACKGROUND

Task
將個人資料頁操作列底色同步為新增煩惱進度列底色

執行者
Codex

### 完成內容

- 新增 `profileActionBackground` 色票，使用與 `annoyanceBrandBackground` 相同的 `#FFFDD2`。
- 將 Desktop Profile 的個人資料／登出／儲存變更操作列改為淡黃色底色。
- 保留共用 Navbar、Profile 內容背景、表單卡片、按鈕與 Mobile 版型不變。
- 新增 Widget test，驗證 Profile action bar 與 Annoyance brand background 色值一致。

### 修改

- `frontend/lib/theme/app_colors.dart`
- `frontend/lib/widgets/profile/profile_penpot_canvas.dart`
- `frontend/test/profile_page_test.dart`
- `docs/UI_SPEC.md`
- `docs/TASKS.md`
- `log/CHANGE_LOG.md`
- `log/CHANGE_HISTORY.csv`

### system_data 參考

- 本次為現有 Profile／Annoyance 視覺 token 同步，未新增引用或修改 `system_data/`。

### API／Database

- API 無異動。
- Database 無異動，無 Migration。

### 測試

- `flutter analyze --no-pub`：通過，No issues found。
- `flutter test --no-pub`：132 tests passed。
- `flutter build web --no-pub`：通過，已產出 `frontend/build/web`。
- Web build 僅顯示既有 Cupertino icon font 提示，不影響建置結果。

### Log 保存期限檢查

- 已檢查 `CHANGE_LOG.md`、`CHANGE_HISTORY.csv` 與 `CHANGE_HISTORY.xlsx`；保存期限截止日為 2026-06-18。
- 最早正式紀錄為 2026-06-29，未發現超過一個月紀錄，本次未刪除 Log；`CHANGE_HISTORY.xlsx` 未修改。

### 待確認事項

- 無。
