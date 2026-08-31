# Registration Login Tasks

> 狀態：APPROVED
> 日期：2026-07-29
> 來源：`REGISTRATION_LOGIN_MEMBER_MANAGEMENT_SPEC.md`
> 範圍：Registration／Login／Eligibility／Session／Member Management／Data Rights／Privileged Administration

## 執行規則

- 本文件獨立管理 `registration_login` Task，不併入 `docs/TASKS.md`。
- 每張 Task 都是可獨立展示與驗證的垂直切片，應在單一工作階段內完成。
- `Blocked by` 所列 Task 全部完成前，不得開始該 Task。
- 可立即工作的 Task frontier 為阻擋項目皆已完成的 `ready-for-agent` Task。
- 每張 Task 仍須依 Repository 規範經過 `TODO → IN PROGRESS → REVIEW → DONE`。
- `ready-for-agent` 只代表前置依賴已清楚，不代表 Task 已進入 `IN PROGRESS`。
- 完成條件包含實作、真實 Security Filter／MySQL 驗證、Flutter測試、正式文件、Log及Git／PR證據。
- 管理者相關功能安排於會員本人流程之後，避免阻擋註冊、登入與資料權利主線。

## 依賴總覽

```text
01
├─ 02
│  ├─ 03
│  │  └─ 06
│  └─ 05 ← 03 + 04
│     ├─ 07
│     │  ├─ 08
│     │  │  └─ 09
│     │  ├─ 10
│     │  ├─ 11
│     │  ├─ 12 ← 06
│     │  │  ├─ 13
│     │  │  └─ 14
│     │  └─ 15
│     └─ 10
└─ 04

15 ← 02 + 07
16 ← 12 + 15
17 ← 14 + 15 + 16
18 ← 05–17
```

---

# 01 — 建立 Auth／Member 真實驗收骨架

**What to build:** 建立可重複執行的 Auth／Member 驗收接縫，使後續每張 Task 都能以真實 MySQL、啟用 Security Filter 的 HTTP 請求及可控制外部依賴驗證完整行為。

**Blocked by:** None — can start immediately.

**Status:** DONE

**Evidence:** PR #87 已合併至 `feature/phase4.5`；PR #88 修正 Flutter 3.29.2 相依後，Backend unit、MySQL integration、Flutter 與 OpenAPI CI 全部通過。

- [x] 測試環境使用與正式環境相同 major version 的 MySQL，不以 H2 作主要驗收。
- [x] Auth與Member HTTP整合測試啟用真實Security Filter。
- [x] 測試可控制時間、Email寄送、Google身分驗證及非同步工作。
- [x] 共用API envelope可驗證穩定`code`、安全`fieldErrors`與opaque `requestId`。
- [x] 測試資料使用synthetic data，不記錄密碼、Token、完整Email、生日或Guardian資料。
- [x] Backend測試、Flutter既有測試及OpenAPI檢查可在CI中分層執行。

---

# 02 — 建立會員狀態機與 Continuation Credential

**What to build:** 讓會員依驗證、資格、停用、停權及刪除狀態取得正確的完整Session或用途受限流程，不再以單一刪除旗標代表會員生命週期。

**Blocked by:** 01 — 建立 Auth／Member 真實驗收骨架。

**Status:** DONE

**Evidence:** PR #89 已合併至 `feature/phase4.5`；commit `a754a38` 的 `Registration and login checks` GitHub Actions 已通過，Backend、MySQL、Flyway、Flutter 與 OpenAPI 驗證完成。

- [x] 支援`PENDING_EMAIL_VERIFICATION`、`PENDING_ELIGIBILITY`、`ACTIVE`、`USER_DEACTIVATED`、`ADMIN_SUSPENDED`、`DELETION_PENDING`及`DELETED`。
- [x] 不合法狀態轉換回`409 MEMBER_STATE_CONFLICT`。
- [x] 憑證正確但流程未完成時回`200`、`nextAction`及用途受限continuation credential。
- [x] Continuation credential不得存取一般會員API。
- [x] Community Eligibility與Community Restriction不以會員狀態或Role取代。
- [x] 狀態、Outbox、Audit及optimistic version在同一交易更新。

---

# 03 — 完成註冊與 Email 驗證流程

**What to build:** 讓台灣使用者只以Email、密碼及必要條款開始註冊，完成Email驗證後才進入資格資料流程，且公開回應不洩漏Email是否存在。

**Blocked by:** 02 — 建立會員狀態機與 Continuation Credential。

**Status:** DONE

**Evidence:** PR #91 已合併至 `feature/phase4.5`；註冊、Email 驗證、MySQL 整合、Flutter 與 OpenAPI 驗收已完成。

- [x] 初始註冊不收`account`、生日、地區、暱稱、Guardian Email或使用者頭貼。
- [x] 新註冊與相同Email恢復流程對外統一回`202 REGISTRATION_ACCEPTED`。
- [x] Email驗證Token有效24小時、單次使用且Server只保存hash。
- [x] 重寄驗證信淘汰舊Token並有60秒冷卻與多維度限流。
- [x] Email驗證前不得建立私人內容或取得一般Session。
- [x] 七天未驗證且沒有私人資料的空會員可由可靠工作安全清除。
- [x] Flutter呈現已受理、待驗證、重寄冷卻、Token過期及重新開始流程。

---

# 04 — 導入新密碼政策與 BCrypt 漸進遷移

**What to build:** 讓新密碼使用現行安全政策與Argon2id，同時讓既有BCrypt會員在成功登入時無感遷移。

**Blocked by:** 01 — 建立 Auth／Member 真實驗收骨架。

**Status:** DONE

**Evidence:** PR #92 已合併至 `feature/phase4.5`；Backend、Flutter、MySQL 整合與 OpenAPI 驗收皆通過。

- [x] 密碼接受15–128個Unicode code points，且不trim。
- [x] 密碼驗證使用NFC正規化與弱密碼blocklist，不強制固定字元組合。
- [x] 新密碼使用Argon2id並保存可辨識的參數版本。
- [x] 既有BCrypt密碼只在成功登入後原子rehash；失敗登入不得修改hash。
- [x] 14／15／128／129 code points、Emoji、空白與弱密碼案例皆有測試。
- [x] 密碼、hash及blocklist命中內容不得進入Log、Audit或分析事件。
- [x] Flutter與Backend使用一致的長度與錯誤碼契約。

---

# 05 — 改為 Verified Email 登入並展開 Account Migration

**What to build:** 讓新會員只以已驗證Email登入，同時以expand方式保留既有`account`會員的受控遷移能力，維持部署期間可登入。

**Blocked by:** 02 — 建立會員狀態機與 Continuation Credential；03 — 完成註冊與 Email 驗證流程；04 — 導入新密碼政策與 BCrypt 漸進遷移。

**Status:** DONE

**Evidence:** PR #93 已合併至 `feature/phase4.5`；v1 Email-only、legacy account expand 共存、Penpot／Flutter 無主畫面捲動，且 Backend unit、MySQL integration、Flutter 與 OpenAPI CI 全部通過。

- [x] v1登入欄位與正式契約只接受verified Email。
- [x] 不存在、密碼錯誤或不可揭露狀態統一回`401 AUTH_INVALID_CREDENTIALS`。
- [x] 相同Email依會員狀態進入驗證、資格、恢復或刪除等待流程。
- [x] Email正規化不得擅自套用Gmail點號或`+tag`合併。
- [x] 舊`account`只存在於一次性Migration路徑，新註冊不再建立`account`。
- [x] Migration期間新舊資料可安全共存，且每一批遷移都維持CI綠燈。
- [x] Flutter登入頁不再顯示或送出`account`。

---

# 06 — 完成 Eligibility、Guardian Consent與公開暱稱 Onboarding

**What to build:** 讓Email已驗證會員完成台灣地區、生日、必要同意、公開暱稱與未成年監護人同意後，取得符合年齡的功能資格。

**Blocked by:** 03 — 完成註冊與 Email 驗證流程。

**Status:** DONE

**Evidence:** PR #94 與Flutter 3.29.2相容修復PR #95均已合併至`feature/phase4.5`；Backend、MySQL integration、Flutter與OpenAPI CI全部通過。

- [x] Email驗證後才收地區、生日、公開暱稱與必要Guardian Email。
- [x] 未滿13歲不能取得一般功能，只保留必要申訴、匯出與刪除入口。
- [x] 13至17歲需完成特定條款版本的Guardian Consent，且不得使用社群。
- [x] Guardian Consent不授予查看會員私人內容的權限，並可撤回及重新取得。
- [x] 公開暱稱為2–30 Unicode code points、NFC、非唯一且不可用於登入或owner判斷。
- [x] 禁止控制字元、雙向控制、純空白、不可見字元及官方冒充名稱。
- [x] 首次社群公開前需預覽並明確確認暱稱；未確認不得發布或留言。
- [x] 12／13／17／18歲及時區日期邊界皆有Backend與Flutter測試。

---

# 07 — 建立 Opaque Refresh Session Family

**What to build:** 讓每台裝置具有獨立、可輪替及可撤銷的Refresh Session Family，並在Token遭重播時限制受影響範圍。

**Blocked by:** 05 — 改為 Verified Email 登入並展開 Account Migration。

**Status:** DONE

**Evidence:** 方案1以獨立HMAC Secret重建10秒內相同輪替結果，Backend只保存SHA-256 hash；Flyway V5、v1 Refresh API、期限、reuse containment與Audit／Outbox已完成。PR #96已於2026-08-01合併至`feature/phase4.5`；Backend unit、MySQL integration、Flutter與OpenAPI四個CI job均通過，對應GitHub Actions `Registration and login checks` conclusion為`success`。

- [x] Access Token為10分鐘JWT，只包含最少聲明及Session識別。
- [x] Refresh Credential為高強度opaque值，Server只保存hash。
- [x] 每裝置建立獨立family並保存建立、最後活動、idle、absolute及撤銷狀態。
- [x] 每次Refresh成功都輪替Credential。
- [x] Server允許同一輪替結果10秒合理並行容忍，逾期reuse撤銷該family。
- [x] 一般Session閒置30天、絕對90天；特權期限留待Task 15完成。
- [x] 無效、過期、撤銷與reuse使用穩定401錯誤碼。
- [x] Session、Token rotation、Outbox與Audit更新具交易一致性。

---

# 08 — 遷移三平台 Credential Store與Single-flight Refresh

**What to build:** 讓Web、Android及iOS以各自安全的Credential Store維持登入，並在並行401時只執行一次Refresh。

**Blocked by:** 07 — 建立 Opaque Refresh Session Family。

**Status:** DONE

**Evidence:** PR #97已合併至`feature/phase4.5`，其Backend 316項單元／契約、36項MySQL整合、Flutter 190項測試、Analyze、Web／Android Build及OpenAPI CI均通過；Android採最低API 24、compileSdk 36及NDK 27.0.12077973。2026-08-16後續修正將Cookie改為`SameSite=None; Secure`以支援Cloudflare Pages至Railway跨站HTTPS，新增原Request最多重試一次測試；Draft PR #99的Backend unit、MySQL integration、Flutter test＋Android Build及OpenAPI四項CI均通過。iOS Keychain已通過共用contract test，原生實機驗證留待macOS Review環境。

- [x] Web Refresh Credential由`__Host-` HttpOnly／Secure／SameSite Cookie管理，Access Token只存記憶體。
- [x] Web Cookie Auth具可信Origin與CSRF防護，不能只依賴SameSite。
- [x] Android／iOS Refresh Credential存於Keychain／Keystore，Access Token只存記憶體。
- [x] SharedPreferences不再保存Token或完整Login Result。
- [x] 並行401共用single-flight Refresh，成功後每個原request最多重試一次。
- [x] 暫時網路錯誤不得誤清Session；確定失效才清除Credential並導向登入。
- [x] 三平台Adapter通過同一Credential Store contract test。
- [x] Flutter Widget／Repository／Router測試涵蓋恢復、失效與重試。

---

# 09 — 完成裝置管理與三種登出流程

**What to build:** 讓會員查看並控制自己的裝置Session，可只登出目前裝置、保留目前裝置並登出其他裝置，或全部登出。

**Blocked by:** 07 — 建立 Opaque Refresh Session Family；08 — 遷移三平台 Credential Store與Single-flight Refresh。

**Status:** DONE

- [x] 裝置清單只顯示安全的裝置類型、約略資訊、最後活動與目前裝置標記。
- [x] 一般登出只撤銷目前Session Family。
- [x] 登出其他裝置保留目前Session，且需要五分鐘內reauth。
- [x] 全部登出包含目前Session，且需要五分鐘內reauth。
- [x] 登出Command為idempotent，不依賴Client傳入Refresh Token。
- [x] 被撤銷裝置的Access與Refresh後續請求皆被拒絕。
- [x] Flutter完整處理成功、重複操作、網路失敗及目前Session被撤銷。

DONE證據：方案1採分離清單／reauth／撤銷API；同意的測試接縫已由真實MySQL驗證owner範圍、Access／Refresh撤銷、重複登出其他裝置與Web Cookie清除。Flutter以Repository／Provider／Widget接縫驗證無Refresh值、網路失敗不清本地Session、操作去重、全域401導向登入，以及390／600／1199／1200／1440寬度無主畫面捲動或overflow。Penpot Web／Mobile預設與reauth共四個畫板已完成並驗證containment。PR #100已於2026-08-16合併至`feature/phase4.5`，Backend unit、Backend Auth／Member integration、Flutter及OpenAPI四項CI全部通過，Task由`REVIEW`轉`DONE`。

---

# 10 — 完成 Google 既有會員明確連結

**What to build:** 讓會員安全連結Google登入方式，不因相同Email自動合併或讓第三方身分接管既有會員。

**Blocked by:** 05 — 改為 Verified Email 登入並展開 Account Migration；07 — 建立 Opaque Refresh Session Family。

**Status:** DONE

- [x] Google ID Token由Backend驗證issuer、audience、expiration、signature及verified Email。
- [x] 已連結Google帳號以provider與`sub`精確登入。
- [x] 相同Email但尚未連結時不得自動合併或核發一般Session。
- [x] 會員需先reauth既有登入方式，再明確確認連結。
- [x] 連結成功留下安全Audit並依敏感登入方式變更規則處理Session。
- [x] Google ID Token、Email及驗證細節不得進入Log。
- [x] Flutter呈現已連結、需驗證既有方式、衝突及取消流程。

DONE證據：採方案1 Session-first明確連結；匿名Google登入只有已連結`provider + sub`可取得Session，相同Email只回`GOOGLE_ACCOUNT_LINK_REQUIRED`。既有會員以Email／密碼登入後取得綁定目前Session、`LOGIN_METHOD_LINK`用途及300秒期限的reauth credential，再以新ID Token及`confirmed: true`建立關聯；成功保留目前Session、撤銷其他Session並寫不含PII的`LOGIN_METHOD_LINKED` Audit／Outbox。Flutter完成需連結、重新驗證、確認、成功、衝突及取消，Web／Mobile共10個Penpot畫板通過containment。Backend完整321項單元／契約與39項真實MySQL 8.4整合測試、Flutter完整209項測試、Analyze、Web release build及Android debug APK build均通過；PR #101四項CI全綠，已於2026-08-21合併至`feature/phase4.5`，Task由`REVIEW`轉`DONE`。

---

# 11 — 完成 Forgot／Reset Password正式流程

**What to build:** 讓會員透過Email安全重設密碼，公開端無法判斷會員是否存在，重設後所有舊裝置失效。

**Blocked by:** 04 — 導入新密碼政策與 BCrypt 漸進遷移；07 — 建立 Opaque Refresh Session Family。

**Status:** REVIEW

- [x] Forgot Password對所有Email統一回`202`，API不得回reset Token。
- [x] Reset Token有效15分鐘、單次使用且Server只保存hash。
- [x] 新請求使同一會員舊的未使用Token失效。
- [x] 重設密碼套用Task 04密碼政策與Argon2id。
- [x] 重設成功撤銷會員全部Session Family。
- [x] 無效、過期及已使用Token使用穩定錯誤碼且不洩漏會員狀態。
- [x] Email寄送透過可靠Outbox／Worker並具重試、failed狀態及告警。
- [x] Flutter涵蓋已受理、連結無效、過期、成功及重新登入流程。

REVIEW證據：採方案1資源式API，`POST /api/v1/auth/password-reset-requests`對已知與未知Email都回`202 PASSWORD_RESET_REQUEST_ACCEPTED`且不含Token；`POST /api/v1/auth/password-resets`以15分鐘單次Token完成重設。Backend只保存SHA-256 hash，新請求撤銷舊Token，Outbox／Worker於寄送時才產生明文並具重試、FAILED與無PII告警；成功套用Task 04密碼政策與Argon2id，並撤銷全部Session。Penpot Web／Mobile各8個狀態已建立，180個descendant containment通過，並以Chrome實際檢視；另依使用者要求整理35個主畫板，無重疊且466個直屬元件相對位置與尺寸不變。Flutter完成申請受理、無效／過期／已使用、成功、重新登入、鍵盤避讓及舊請求隔離；涵蓋390至1920寬度與矮視窗，不使用主畫面捲動。Backend單元324通過／4個既有OS條件跳過、MySQL 8.4整合42通過、Flutter完整236項通過、Analyze與Web release／Android debug build通過。RegistrationMigrationIntegrationTest的兩項版本斷言已由V8校正至V9。舊`/api/auth/forgot-password`與`/api/auth/reset-password`暫留相同安全契約的deprecated別名，Task 18驗收後移除；完整判定見`PASSWORD_RESET_LEGACY_CLEANUP.md`。Task由`IN PROGRESS`轉`REVIEW`，待Draft PR、CI、使用者Review與合併；不宣告DONE。

---

# 12 — 分離會員一般與敏感資料修改

**What to build:** 讓會員安全修改公開暱稱、Email與生日，並能自行停用或恢復帳號，不以通用Profile Update繞過資格與Session規則。

**Blocked by:** 06 — 完成 Eligibility、Guardian Consent與公開暱稱 Onboarding；07 — 建立 Opaque Refresh Session Family。

**Status:** ready-for-agent

- [ ] 一般Profile、公開暱稱、Email變更、生日更正、停用及恢復使用分離Command與欄位白名單。
- [ ] 所有修改使用optimistic version，舊版本回`409 VERSION_CONFLICT`。
- [ ] Email變更需五分鐘reauth，新Email驗證前保留舊Email。
- [ ] Email切換原子完成、撤銷其他Session並通知新舊Email。
- [ ] 生日更正跨13／18歲邊界時立即採保守資格限制，並進入必要審核／申訴。
- [ ] 本人停用立即撤銷全部Session及公開可見性；恢復後不自動恢復分享。
- [ ] 公開暱稱變更後既有社群內容顯示新暱稱。
- [ ] Flutter呈現修改衝突、驗證中、受限、停用及恢復狀態。

---

# 13 — 完成會員 Data Export

**What to build:** 讓會員經重新驗證後取得自己的可攜資料與原始媒體，下載檔案保持私有並在期限後清除。

**Blocked by:** 07 — 建立 Opaque Refresh Session Family；12 — 分離會員一般與敏感資料修改。

**Status:** ready-for-agent

- [ ] 申請前需五分鐘內reauth；密碼與Google會員使用各自既有登入方式。
- [ ] 停用、停權或資格受限會員仍可由用途受限流程申請。
- [ ] 匯出以opaque request ID非同步執行，狀態可安全查詢。
- [ ] 內容至少包含會員自身machine-readable JSON與原始媒體，不含其他會員個資或內部安全資訊。
- [ ] 匯出檔加密、私有保存，不以Email附件寄送。
- [ ] 七天期限從`READY`時間起算，到期後刪除檔案。
- [ ] 失敗工作可idempotent重試並具安全錯誤碼、failed狀態及告警。
- [ ] 未授權下載、七天邊界、重試及受限會員流程有整合與E2E測試。

---

# 14 — 完成會員 Account Deletion與可重試清除

**What to build:** 讓會員經重新驗證提出帳號刪除，在七天內可取消，期滿後進入不可取消且可追蹤的跨系統清除。

**Blocked by:** 07 — 建立 Opaque Refresh Session Family；12 — 分離會員一般與敏感資料修改。

**Status:** ready-for-agent

- [ ] 申請前需五分鐘內reauth，接受後回opaque deletion request ID。
- [ ] 接受後立即進入`DELETION_PENDING`、撤銷一般Session並取消公開可見性。
- [ ] 七天取消期從Server `acceptedAt`精確起算。
- [ ] 取消刪除需再次reauth，且不自動恢復分享或公開內容。
- [ ] 七天期滿後進入不可取消清除階段。
- [ ] 清除涵蓋正式資料、媒體、搜尋索引、快取及外部處理副本。
- [ ] 可重試失敗進入`PURGE_FAILED_RETRYING`，需人工處理進入`PURGE_REVIEW_REQUIRED`。
- [ ] 部分失敗不得把會員恢復為一般可用狀態。
- [ ] Email僅在永久清除完成後可建立全新會員。

---

# 15 — 建立特權角色、Permission、MFA與權限版本

**What to build:** 在會員本人主線完成後，建立受最小權限、MFA、即時Session撤銷及責任分離保護的特權管理基礎。

**Blocked by:** 02 — 建立會員狀態機與 Continuation Credential；07 — 建立 Opaque Refresh Session Family。

**Status:** ready-for-agent

- [ ] 支援MEMBER、MODERATOR、ADMIN及CONTENT_REVIEWER，Community Eligibility不是Role。
- [ ] 特權能力使用細分Permission，不以單一Admin Role授予全部權限。
- [ ] 所有特權API要求TOTP MFA Session，備援碼單次使用。
- [ ] 特權Session閒置30分鐘、絕對8小時，高風險操作需五分鐘reauth。
- [ ] Role／Permission升級或降級立即撤銷全部特權Session。
- [ ] Backend每次授權檢查帳號狀態、MFA、Session類型及`permissionVersion`。
- [ ] Role／Permission變更需理由、idempotency、Audit及雙人核准，不得自我核准。
- [ ] 交易不得讓有效MFA Admin少於兩位。
- [ ] Break-glass受控、限時、可稽核且不具私人內容權限。

---

# 16 — 完成 Admin會員查詢、PII揭露與Suspension

**What to build:** 讓具權限管理者在不接觸私人內容的前提下精確查詢會員、受控揭露Email並執行可申訴及可複查的停權。

**Blocked by:** 12 — 分離會員一般與敏感資料修改；15 — 建立特權角色、Permission、MFA與權限版本。

**Status:** ready-for-agent

- [ ] 一般會員查詢使用不可推測UUID精確查詢，不接受舊`account`。
- [ ] Email只允許具`MEMBER_PII_LOOKUP`的MFA Session精確搜尋，需理由、限流及Audit。
- [ ] 不支援Email模糊、前綴或批次搜尋。
- [ ] 搜尋結果預設遮罩Email；完整Email使用獨立揭露Command、Permission、理由及Audit。
- [ ] Admin不得查看私人Entry、媒體、自我探索結果、取得會員Token或模擬登入。
- [ ] Suspension使用穩定原因、期限、通知、申訴及複查時間。
- [ ] 停權立即撤銷全部Session，但保留申訴、匯出與刪除入口。
- [ ] 緊急停權需在限定時間內由第二人覆核，解除不得由原執行者自我核准。
- [ ] 不存在、已刪除、無權及owner錯誤依防枚舉規則回一致`404`。

---

# 17 — 完成 Legal Hold、特殊清除與雙人核准

**What to build:** 讓少數依法需要的資料保全與特殊清除具有最小範圍、期限、責任分離及清除續行能力，不讓Admin直接永久刪除會員。

**Blocked by:** 14 — 完成會員 Account Deletion與可重試清除；15 — 建立特權角色、Permission、MFA與權限版本；16 — 完成 Admin會員查詢、PII揭露與Suspension。

**Status:** ready-for-agent

- [ ] 一般Admin不能直接永久刪除會員。
- [ ] 特殊清除需特定Permission、正式理由、高風險reauth及雙人核准。
- [ ] Legal Hold只接受正式具拘束力依據，保存範圍與期限必須最小化。
- [ ] Legal Hold不恢復會員可見性、一般Session或社群內容。
- [ ] 可揭露時顯示安全的清除延遲；不可揭露時使用通用合法限制說明。
- [ ] Hold解除後自動續行清除，不要求會員重新申請。
- [ ] 申請者、核准者、執行者及解除者符合責任分離規則。
- [ ] Restore後重播deletion、unshare、suspension及revocation marker，社群在完成前保持關閉。
- [ ] Audit不得保存私人內容、完整Email、生日、Guardian資料或可逆刪除身分。

---

# 18 — 移除舊契約並完成跨平台 E2E驗收

**What to build:** 在所有新流程可用後，完成expand–migrate–contract的contract階段，移除待淘汰契約並以三平台完整故事證明registration_login主線可正式使用。

**Blocked by:** 05–17 全部完成。

**Status:** ready-for-agent

- [ ] 移除新流程對舊`account`登入及註冊的依賴。
- [ ] 移除JWT Refresh、`revoked_tokens`舊用途及Client明文Refresh response契約。
- [ ] 移除SharedPreferences Credential與完整Login Result。
- [ ] 移除Google相同Email自動連結。
- [ ] 移除deprecated `/api/auth/forgot-password`、`/api/auth/reset-password`相容別名；開發reset Token response已於Task 11移除。
- [ ] 移除Backend server PIN與public avatar upload契約。
- [ ] Flyway空資料庫建立及上一版本升級測試通過，舊資料遷移具可驗證結果。
- [ ] 啟用Security Filter的Auth、Member、Admin及Data Rights HTTP矩陣全部通過。
- [ ] Web、Android、iOS至少完成「註冊→Email驗證→Eligibility→登入→Refresh→登出」E2E。
- [ ] Data Export、Account Deletion、Admin停權、權限變更及Legal Hold關鍵E2E通過。
- [ ] OpenAPI、Project、Database、API、UI、Decision、Task與Log文件同步。
- [ ] 未完成部署、Migration、E2E、Git／PR或工作報告證據前不得標記`DONE`。

## Frontier

目前接續點：

- 01–10 — 已完成；Task 03修正由PR #91整合，Task 10由PR #101於2026-08-21合併。
- 11 — `REVIEW`；Backend、Flutter、Penpot及本機測試／建置已完成。Task分支`feature/phase4.5-password-reset`以`feature/phase4.5`為PR目標；CI、使用者Review及合併為獨立完成門檻。
- 12 — 前置Task 06、07已完成；目前先收尾Task 11，再依使用者指示接續。

後續只處理所有阻擋均已完成的Task，不得為了平行開發跳過狀態機、Migration或安全驗收前置條件。
