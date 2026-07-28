# Phase 4.5 基礎安全與領域模型規格

> 狀態：REVIEW
> 日期：2026-07-28
> 來源：2026-07-26 Grilling 核准基線與 `to-spec` 文件化
> 前置條件：Phase 4 候選成果完成 Review、整合測試並正式合併至 `develop`

> 註冊、登入與會員管理第 1–38 題細節及 2026-07-28 公開暱稱社群決策以 [`REGISTRATION_LOGIN_MEMBER_MANAGEMENT_SPEC.md`](REGISTRATION_LOGIN_MEMBER_MANAGEMENT_SPEC.md) 為準。

## Problem Statement

目前 `develop` 與 `feature/phase4` 保留多項歷史契約，包括使用者可見 `account`、JWT Refresh Token、SharedPreferences 憑證、伺服器四位數 PIN、公開頭貼上傳、`Entry.isShared`、必填分類／分數及隨機獎勵。這些契約與已核准的非醫療私人核心、年齡資格、資料生命週期、封閉社群及平台安全邊界不一致。

若直接開始 Phase 5 以後功能，後續將同時承擔資料遷移、API 相容、跨平台 Session、權限與刪除語意重作，並可能讓私人內容、兒少資格或已刪除資料暴露於錯誤邊界。因此需要先建立可驗證的 Phase 4.5 基礎，使後續功能只依賴正式 v1 契約。

## Solution

建立一個以私人核心跨平台 E2E 流程為最高驗收接縫的基礎安全階段，完整涵蓋：

1. 台灣限定註冊、Email 驗證、年齡資格與 Guardian Consent。
2. 短效 Access Token、opaque Refresh Session、裝置撤銷與用途受限 reauth。
3. Entry 共用核心、optional Emotional Load／Private Category、獨立 Community Post 快照。
4. 私人媒體隔離處理、容量限制、匯出、刪除及備份後刪除標記重播。
5. UUID public ID、optimistic version、idempotency、Flyway 與 Transactional Outbox。
6. Web、Android、iOS 平台分流的 Credential Store 與本機 Privacy Lock。
7. 欄位白名單監控、環境隔離、Emergency Feature Flags 與正式 CI Gate。

Phase 4.5 完成後，舊契約只保留為 Migration 或歷史測試依據，不得再被新功能使用。

## User Stories

1. 作為台灣使用者，我希望能以 Email 註冊，使我能建立可驗證的會員身分。
2. 作為使用者，我希望驗證 Email 後才能建立私人內容，使誤填或未驗證信箱不會綁定敏感資料。
3. 作為未滿 13 歲的使用者，我希望系統清楚阻止註冊，使產品遵守最低年齡限制。
4. 作為非台灣地區使用者，我希望看到服務地區限制，使我不會誤以為已取得正式服務資格。
5. 作為 13 至 17 歲會員，我希望監護人能同意特定版本條款，使我能使用私人核心。
6. 作為未成年會員，我希望監護人同意不授予內容查看權，使私人記錄仍只屬於我。
7. 作為未成年會員，我希望不能使用社群，使我不會接觸陌生人互動。
8. 作為成年轉換會員，我希望重新同意成人條款後才取得社群資格，使資格變更可追溯。
9. 作為會員，我希望生日確認後不能任意修改，使年齡限制不會被輕易繞過。
10. 作為會員，我希望更正生日時需要 reauth、理由與稽核，使錯誤可被修正而不破壞資格控制。
11. 作為會員，我希望不需要建立額外的 `account`，使 verified Email 成為清楚的登入識別。
12. 作為既有會員，我希望 Google 帳號不會因相同 Email 自動合併，使他人無法接管我的會員身分。
13. 作為會員，我希望忘記密碼連結只有 15 分鐘且只能使用一次，使重設流程不易被重播。
14. 作為會員，我希望密碼重設後撤銷所有工作階段，使失竊裝置無法繼續存取。
15. 作為會員，我希望 Access Token 短效且只存在記憶體，使憑證外洩影響受限。
16. 作為會員，我希望 Refresh Session 可以輪替並偵測重播，使被竊 Token 可觸發整個 family 撤銷。
17. 作為 Web 會員，我希望 Refresh Credential 存於安全 Cookie，使前端程式無法直接讀取。
18. 作為 App 會員，我希望 Refresh Credential 存於 Keychain／Keystore，使敏感憑證不進入一般偏好設定。
19. 作為會員，我希望看到並撤銷個別裝置工作階段，使我能處理遺失裝置。
20. 作為會員，我希望敏感操作前重新驗證，使已開啟的 Session 不足以直接匯出或刪除資料。
21. 作為 App 會員，我希望每台裝置有獨立本機 Privacy Lock，使旁人無法直接查看已登入畫面。
22. 作為 Web 會員，我希望頁籤失焦時遮蔽、閒置後 reauth，使 Web 不假裝具有本機 PIN。
23. 作為會員，我希望 Diary 與 Annoyance 使用一致的 Entry 核心，使私人資料權利一致。
24. 作為會員，我希望 Diary 與 Annoyance 保留不同操作流程，使兩種記錄情境不被混為一談。
25. 作為會員，我希望 Emotional Load 可以略過，使系統不強迫我量化感受。
26. 作為會員，我希望 Private Category 可以略過，使系統不替我推測或強制分類。
27. 作為會員，我希望修改衝突時收到明確提示，使較舊版本不會覆蓋較新內容。
28. 作為會員，我希望重試建立命令不會產生重複 Entry，使不穩定網路不破壞資料。
29. 作為會員，我希望公開分享建立獨立 Community Post，使後續私人編輯不會意外公開。
30. 作為會員，我希望取消分享後公開內容與討論立即不可見，使公開資料生命週期可被控制。
31. 作為會員，我希望圖片、錄音與影片先經隔離、格式解析、重新處理及掃描，使惡意或含識別資訊的檔案不會直接提供。
32. 作為會員，我希望媒體達容量上限時只拒絕新增，使既有內容不被自動刪除或壓縮。
33. 作為會員，我希望刪除單筆內容後立即不可見並於七天內清除，使刪除語意可預期。
34. 作為會員，我希望帳號刪除具有七天取消期，使誤操作可以復原。
35. 作為會員，我希望取消期後帳號與內容永久清除，使停用不會成為永久保存。
36. 作為會員，我希望取得 JSON 與原始媒體 ZIP，使我能攜出自己的資料。
37. 作為會員，我希望匯出下載連結短效且需 reauth，使匯出檔不會長期公開。
38. 作為會員，我希望災難復原不會復活已刪除或已取消分享資料，使備份不破壞我的資料權利。
39. 作為特權角色，我希望只能使用職責所需資料，使我不能查看私人 Entry 或取得會員 Token。
40. 作為 Moderator，我希望只能處理已檢舉公開內容，使私人核心不進入審核工作流。
41. 作為 Admin，我希望高風險操作需要 MFA 且留下不可修改稽核，使權限使用可問責。
42. 作為 Content Reviewer，我希望只能審閱版本化內容，使我不會接觸會員或社群案件資料。
43. 作為開發者，我希望所有公開資源使用 UUID，使外部識別值不可依序推測。
44. 作為開發者，我希望所有可重試非同步工作使用 Outbox 與 idempotent Worker，使 Email、刪除、匯出與通知不依賴一次性 best-effort。
45. 作為維運人員，我希望 Worker 具有 retry、backoff、failed queue 與 alert，使失敗工作不會無聲遺失。
46. 作為維運人員，我希望 Development、Staging、Production 完全隔離，使正式資料與憑證不會流入非正式環境。
47. 作為維運人員，我希望監控只接受欄位白名單，使私人內容、Email、Token、媒體路徑及搜尋詞不會進入 Log。
48. 作為維運人員，我希望可由 Server 強制關閉高風險功能，使事故期間不依賴前端版本更新。
49. 作為測試人員，我希望從註冊一路驗證 Entry、匯出及刪除，使最重要的私人核心契約能以單一 E2E 故事證明。
50. 作為測試人員，我希望真實 MySQL 驗證空資料庫建立與既有版本升級，使 Flyway Migration 可重跑、可部署。
51. 作為 API 使用者，我希望 OpenAPI 定義穩定 error code、requestId、version 與 idempotency，使三平台行為一致。
52. 作為產品負責人，我希望 Phase 4.5 未通過前 Phase 5 以後維持 blocked，使新功能不建立在待淘汰契約上。

## Implementation Decisions

- Phase 4.5 是正式 Migration 與安全基礎，不是新增產品功能的 Phase。
- `CONTEXT.md` 與 ADR 定義領域語言及難以逆轉的決策；本規格負責把基線轉為可驗收範圍。
- 主要模組為 Identity／Eligibility、Session、Entry、Media、Data Rights、Authorization、Outbox、Observability 與 Platform Credential Adapter。
- API 統一使用 `/api/v1`、OpenAPI、UUID public ID、穩定 error code 與 opaque requestId。
- Aggregate 修改使用 optimistic version；可重試 Command 使用 idempotency key。
- Access Token 為 10 分鐘 JWT；Refresh Token 為只保存 hash 的 opaque session family。
- Web Refresh Session 使用 `__Host-` HttpOnly／Secure／SameSite Cookie；App 使用 Keychain／Keystore。
- App Privacy Lock 為裝置本機功能；Backend 不接收、保存或驗證 PIN。
- Diary 與 Annoyance 共用 Entry Aggregate，但保留分離 Use Case／Command。
- Community Post 是 Entry 的版本化公開快照，不以 `isShared` 直接公開 Entry。
- Public Nickname 為2–30 Unicode、非唯一且不可登入的跨貼文顯示身分；首次社群公開前必須明確確認。
- Media 先進 quarantine，完成真實格式解析、重新處理、metadata 移除與 malware scan 後才可使用。
- 資料刪除、取消分享、Session 撤銷與停權建立可於 Restore 後重播的 marker。
- Database 使用 Flyway immutable version Migration 與 expand／migrate／contract。
- Email、Media、Export、Deletion、Notification 與 Reward 使用 Transactional Outbox。
- 權限由 Backend 以 owner、Role、Community Eligibility、Restriction 與生命週期狀態共同強制。
- Emergency Feature Flags 由 Backend 強制，不以只隱藏 Flutter UI 代替。
- 舊 `account`、JWT Refresh、SharedPreferences Credential、public avatar、server PIN、`isShared`、random reward 契約只供 Migration 使用。

## Testing Decisions

- 主要驗收接縫是私人核心跨平台 E2E：註冊／資格 → Session → Entry／Media → Export／Deletion。
- E2E 只驗證外部可觀察行為、權限、狀態轉換及資料生命週期，不斷言內部類別或 Repository 呼叫次數。
- Backend 以真實 MySQL 驗證 Flyway 空庫建立、上一版本升級、Constraint、Outbox、idempotency、optimistic conflict 與 Restore marker。
- API 以 OpenAPI contract test 與受 Security Filter 保護的 HTTP integration test 驗證，不以關閉 Filter 的 Controller test 取代授權驗收。
- Flutter 沿用既有 Widget 測試接縫，驗證 Web／Android／iOS 可見狀態、錯誤恢復、Breakpoint、Privacy Lock 與 Session 失效導向。
- Credential Store 使用單一介面 contract test 驗證三平台 Adapter；測試不得讀寫真實使用者 Credential。
- Media 測試涵蓋偽造 MIME、損壞內容、超限、metadata、掃描失敗、重試及隔離物件不可下載。
- Data Rights 測試涵蓋 reauth、短效下載、七天生命週期、失敗告警、備份 Restore 後 marker 重播。
- Authorization 測試至少涵蓋跨會員 UUID、兒少社群阻擋、特權角色私人內容阻擋及一致 404。
- CI Gate 必須涵蓋 Backend、Flutter、Web／Android／iOS Build、Flyway、OpenAPI、security scan 與 E2E。
- 既有 `MockMvc`、`SpringBootTest`、Flutter `testWidgets` 與 Router／Session 測試可作先例；歷史契約測試需改為 Migration 或刪除驗證。

## Out of Scope

- 不在本規格整合或修改 `feature/phase4` 候選程式。
- 不實作 Phase 5 Emotional Trace、Phase 6 Monster Unlock、Phase 8 內容活動或 Phase 9 回饋功能。
- 不開放 Phase 7 公開暱稱社群；Phase 4.5 只建立資格、公開暱稱、角色、快照與 Feature Flag 基礎。
- 不導入 E2EE、Kubernetes、跨區多主、專用 Message Broker 或持久裝置指紋。
- 不選定 SMTP、R2、CAPTCHA 或監控供應商。
- 不修改 `system_data/`。
- 本文件工作不執行 Schema Migration、API endpoint、Flutter 畫面或部署。

## Further Notes

- Phase 4.5 必須拆成可獨立 Review、Migration 與回復驗證的 Task，不得一次性大爆炸替換。
- 第一個真實使用者版本仍是台灣限定的私人核心封閉測試。
- Phase 4.5 完成只解除 Phase 5、6、8、9 的基礎阻擋；Phase 7 仍需私人核心穩定四週且治理、安全與特權 MFA Gate 全數通過。
- Issue Tracker 發布不在本次使用者核准的「修改文件」範圍內；若後續要求發布，應套用 `ready-for-agent` label。
