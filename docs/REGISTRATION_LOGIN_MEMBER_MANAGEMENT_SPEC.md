# 註冊、登入與會員管理完整需求規格

> 狀態：REVIEW
> 日期：2026-07-28
> 來源：2026-07-28 需求訪談第 1–38 題確認結果
> 適用範圍：Phase 4.5 Identity／Eligibility／Session／Authorization／Data Rights
> 前置條件：Phase 4 候選成果已完成 Review、整合測試並合併至 `develop`

## 一、文件目的與優先順序

本文件將註冊、登入、會員生命週期、會員資料、特權管理、匯出與刪除的已確認需求，整理為可驗收、可拆 Task 的正式規格。本文不代表功能已實作，也不授權開放社群。

規格解讀順序如下：

1. `AGENTS.md` 的產品與資料邊界。
2. `CONTEXT.md` 的共同語言。
3. `docs/adr/` 與 `docs/DECISIONS.md` 的難以逆轉決策。
4. 本文件的註冊、登入與會員管理完整需求。
5. `docs/PROJECT_SPEC.md`、`docs/DATABASE_SPEC.md`、`docs/API_SPEC.md`、`docs/UI_SPEC.md` 的分層契約。
6. 現有程式只作 Migration baseline，不得反向弱化目標規格。

## 二、範圍與角色邊界

### 2.1 產品邊界

- 第一版只服務台灣，最低年齡 13 歲。
- 13 至 17 歲會員需完成 Guardian Consent，只能使用私人核心，不得使用社群。
- 社群只對具 Community Eligibility 的成年會員開放，且 Governance Gate 與特權 MFA 未完成前 Server feature flag 必須關閉。
- Admin、Moderator、Content Reviewer 與客服不得查看私人 Entry、媒體、自我探索結果，不得模擬會員登入或取得會員 Token。
- 會員資料不得用於生成式 AI 訓練、廣告、跨站追蹤、敏感分群或未另行同意的研究。

### 2.2 建立與管理會員的邊界

- 採公開註冊、會員本人自助、Admin metadata 管理三個邊界。
- Admin 不直接建立一般會員，不替會員設定密碼或登入方式。
- 會員本人一般修改、本人敏感修改、Admin 管理修改使用分離 Command 與欄位白名單。
- Admin 一般只管理會員狀態、角色、資格、營運 metadata 與正式處置。
- Admin 不得直接永久刪除會員；特殊清除使用雙人核准流程。

## 三、會員身分與生命週期

### 3.1 正式會員狀態

| 狀態 | 說明 | 可取得的 Credential |
|---|---|---|
| `PENDING_EMAIL_VERIFICATION` | 已建立空會員，Email 尚未驗證 | Email 驗證用途受限 credential |
| `PENDING_ELIGIBILITY` | Email 已驗證，地區、生日、必要同意或 Guardian Consent 尚未完成 | Eligibility continuation credential |
| `ACTIVE` | 會員資格完整，可使用私人核心 | 一般 Session；社群另檢查 Community Eligibility |
| `USER_DEACTIVATED` | 會員本人停用，資料保留且公開可見性取消 | 恢復、匯出、刪除用途受限 credential |
| `ADMIN_SUSPENDED` | 由正式管理流程停權 | 通知、申訴、匯出、刪除用途受限 credential |
| `DELETION_PENDING` | 已提出帳號刪除，仍在七天取消期或清除準備階段 | 進度、匯出、取消、申訴用途受限 credential |
| `DELETED` | 正式資料已依生命週期完成清除 | 不核發 Credential |

- Community Restriction 與 Community Eligibility 獨立於會員狀態，不以 Role 代替。
- 狀態轉換、Outbox 與 Audit 必須在同一交易提交。
- 所有 Aggregate 修改使用 optimistic version。
- 可安全重試的 Command 使用 Server idempotency。

### 3.2 相同 Email 的處理

- Email 依明確正規化規則進行精確比對；不得擅自套用 Gmail 點號或 `+tag` 合併。
- 相同 Email 已存在時，依會員狀態進入驗證、資格、恢復或刪除等待流程。
- 註冊、忘記密碼與重寄驗證信的公開回應不得揭露 Email 是否存在。
- 只有會員資料完成永久清除後，該 Email 才能建立全新會員。
- 舊 `account` 只用於一次性 Migration，不得成為新會員登入或 Admin 查詢條件。

## 四、註冊與 Email 驗證

### 4.1 初始註冊資料

初始註冊只收：

- Email。
- 密碼。
- 當下必要的 Terms／Privacy 同意版本。

初始註冊不收：

- `account`。
- 生日。
- 服務地區。
- 暱稱。
- Guardian Email。
- 使用者上傳頭貼。

### 4.2 註冊流程

1. 接受公開註冊請求並回傳通用 `202 REGISTRATION_ACCEPTED`。
2. 建立或恢復 `PENDING_EMAIL_VERIFICATION` 流程，不揭露 Email 是否既存。
3. 寄送單次 Email 驗證 Token。
4. Email 驗證完成後，進入服務地區、生日、暱稱及必要同意流程。
5. 完成台灣地區、年齡與必要同意後，才可核發完整 Session。
6. 13 至 17 歲會員進入 Guardian Consent；未滿 13 歲不得取得一般功能資格。

### 4.3 Email 驗證 Token

- 有效期 24 小時。
- 單次使用，Server 只保存 Token hash。
- 重寄新 Token 時淘汰舊 Token。
- 重寄冷卻 60 秒，並套用多維度限流。
- 七天未完成驗證且沒有私人資料的空會員自動清除。
- 無效、已使用與過期使用穩定錯誤碼，不回傳 Token 原文或內部狀態。

## 五、密碼、登入與登入方式

### 5.1 密碼規則

- 長度 15–128 個 Unicode code points。
- 密碼不 trim。
- 驗證前執行 NFC 正規化。
- 不強制大小寫、數字或特殊字元組合。
- 使用弱密碼 blocklist。
- 新密碼使用 Argon2id。
- 既有 BCrypt 密碼在成功登入後漸進 rehash。
- 密碼、hash、blocklist 命中內容不得進入 Log、Audit 或分析事件。

### 5.2 登入識別

- v1 Email／密碼登入只接受 verified Email。
- Google 登入使用已連結且已驗證的 Google `sub`。
- 舊 `account` 只提供一次性 Migration，不保留為永久雙軌登入。
- 先驗證憑證，再決定回傳完整 Session 或用途受限 continuation credential。
- 帳號不存在、密碼錯誤或不可揭露狀態統一回 `401 AUTH_INVALID_CREDENTIALS`。

### 5.3 未完成或受限流程

憑證正確但會員處於下列狀態時，回 `200`、`nextAction` 與用途受限 continuation credential，不回一般 Session：

- Email 尚未驗證。
- Eligibility 尚未完成。
- Guardian Consent 尚未完成或已撤回。
- 本人停用。
- Admin 停權。
- 刪除等待。

Continuation credential：

- 只允許指定流程。
- 短效、可撤銷、不得存取一般會員 API。
- 必須由 Backend 逐項授權，不能只由 Flutter 隱藏功能。

### 5.4 登入防護

- 使用 IP、Email hash、Session／風險訊號等多維度漸進限流。
- 使用短期冷卻，不永久鎖帳號。
- CAPTCHA 只在高風險情況啟用，且需通過隱私審查。
- 不建立持久裝置指紋。
- 對外回應不得揭露 Email、會員狀態、限流規則或風控判斷。

### 5.5 Google Linking

- Google 回傳的 Email 必須為 verified。
- 相同 Email 不自動建立連結或合併會員。
- 會員必須先證明既有登入方式，再明確確認連結 Google。
- 連結登入方式屬敏感修改，需五分鐘 reauth、Session 管理與 Audit。

### 5.6 Forgot／Reset Password

- Forgot Password 永遠回通用 `202`，API 不回 reset Token。
- 對既存且可處理的會員，內部寄送 15 分鐘、單次、只存 hash 的重設連結。
- 重設成功後撤銷該會員全部 Session。
- 無效、過期、已使用 Token 使用穩定錯誤碼。
- 停用、停權或刪除等待會員依狀態執行安全流程，不以公開回應揭露。

## 六、Session、Refresh 與登出

### 6.1 Session 模型

- 一般 Access Token：10 分鐘 JWT，只保存在記憶體。
- Refresh Credential：不透明隨機值，Server 只保存 hash。
- 每個裝置使用獨立 Refresh family。
- Web Refresh Credential 使用 `__Host-` HttpOnly／Secure／SameSite Cookie。
- Android／iOS Refresh Credential 使用 Keychain／Keystore。
- SharedPreferences 不得保存 Token 或完整 Login Result。
- 一般 Session：閒置 30 天、絕對 90 天。
- 特權 Session：閒置 30 分鐘、絕對 8 小時。

### 6.2 Refresh Rotation

- 每次成功 Refresh 輪替 Refresh Credential。
- Client 只允許一個共用 single-flight Refresh request，原 request 最多重試一次。
- Server 提供 10 秒並行容忍期，處理同一裝置的合理競態。
- 超過容忍期的 Refresh reuse 撤銷該 family。
- 網路暫時失敗不得誤清 Session；無效、過期、撤銷或 reuse 才進入失效流程。

### 6.3 登出

- 一般登出只撤銷目前裝置 Session／Refresh family。
- 「登出其他裝置」保留目前 Session，需五分鐘 reauth。
- 「全部登出」撤銷包含目前裝置的所有 Session，需五分鐘 reauth。
- 登出命令必須 idempotent，不依賴 Client 傳入 Refresh Token。
- 密碼重設、Email 變更、Refresh reuse、本人停用、Admin 停權與刪除，由 Server 強制撤銷相應 Session。

### 6.4 權限版本

- 特權帳號保存 `permissionVersion`。
- Backend 授權不可只相信 Token 內的 Role，需同時檢查帳號狀態、MFA、Session 類型與 `permissionVersion`。
- Role／Permission 升級或降級都立即撤銷全部特權 Session。
- 權限升級後必須重新登入並完成 MFA，不擴張既有 Session。
- 權限變更後，相關未執行高風險核准失效。

## 七、會員資料、暱稱與 Email 變更

### 7.1 一般會員資料修改

- 一般欄位與敏感欄位使用不同 Command。
- 每個 Command 使用欄位白名單與 optimistic version。
- Admin 不得透過通用 update DTO 修改會員本人欄位。
- 生日、Email、密碼、登入方式、匯出與刪除均屬敏感流程。

### 7.2 公開暱稱

公開暱稱是會員在私人介面與社群中使用的顯示名稱：

- 完成 Eligibility 資料時必填，初始註冊與 Email 驗證階段不要求。
- 長度 2–30 個 Unicode code points。
- 儲存前執行 NFC 正規化並移除首尾空白，中間空白保留。
- 允許多語言文字、數字、一般標點與 Emoji。
- 禁止控制字元、換行、雙向文字控制字元、純空白及不可見字元組成的名稱。
- 不要求唯一，不能用於登入、資源 owner 判斷或永久識別會員。
- 禁止「管理員」「官方」「客服」「Admin」及可造成官方身分混淆的變體。
- 社群首次啟用或首次發文前，會員必須明確確認暱稱會公開顯示，並可先修改。
- 未確認公開前不得發布 Community Post 或 Comment。
- 暱稱變更後，既有社群內容顯示新暱稱，避免保留多個歷史顯示名稱。
- 取消分享、停用或刪除仍依正式資料生命週期處理，不得只隱藏暱稱。

公開暱稱會形成跨貼文可辨識的社群身分，因此社群不再宣稱作者「對外不可連結」。平台仍不得公開 Email、`account`、會員 UUID、私人 Profile、生日或私人頭貼。

### 7.3 Email 變更

- 變更前需五分鐘 reauth。
- 新 Email 驗證完成前，舊 Email 保持有效。
- 驗證成功後原子切換 Email。
- 切換後撤銷其他 Session，通知新舊 Email。
- 新 Email 與既有會員衝突時不得自動合併。

## 八、年齡、Guardian Consent 與生日更正

### 8.1 Eligibility

- Email 驗證後才收服務地區、生日、公開暱稱與必要 Guardian Email。
- 台灣地區與年齡由 Backend 強制。
- 未滿 13 歲停止一般功能，只保留必要的匯出、刪除及申訴入口。
- 13 至 17 歲需 Guardian Consent，且不得瀏覽、搜尋、發布或互動於社群。
- 成年後需重新同意適用條款，才取得 Community Eligibility。

### 8.2 Guardian Consent

- Guardian Email 只用於同意流程，不建立 Parent Dashboard。
- 同意綁定明確條款版本、會員與時間。
- Guardian 不得查看會員私人內容。
- 撤回後會員進入受限 Eligibility，停止私人核心，但保留匯出、刪除與重新取得同意。

### 8.3 生日更正

- Eligibility 完成後生日不可直接覆寫，只能提出更正申請。
- 不跨越 13／18 歲或 Guardian Consent 邊界的合理更正，可經風險檢查後自動核准。
- 跨越資格邊界的更正必須人工審核。
- 申報新生日若使會員未滿 18 歲，立即暫停 Community Eligibility。
- 申報新生日若使會員未滿 13 歲，立即停止一般功能。
- 通過後重新計算年齡、Guardian Consent 與 Community Eligibility，不自動恢復先前分享。
- 拒絕需回安全原因代碼，會員可補充資料後申訴。
- Admin 不得直接替會員任意改生日。
- 證明文件只在必要時收集，採最小權限、期限保存及到期清除，不得寫入一般 Log 或 Audit 內容。

## 九、本人停用與 Admin Suspension

### 9.1 本人停用

- 保留會員資料。
- 立即撤銷全部 Session。
- 立即取消公開可見性。
- 恢復需完整登入與 reauth。
- 恢復後不自動恢復任何分享。

### 9.2 Admin Suspension

- 必須使用穩定原因代碼與內部說明，不得只填自由文字。
- 會員可見安全且可理解的原因、開始時間、期限與申訴方式。
- 不揭露檢舉人、內部風控規則或安全細節。
- 支援固定期限及無固定期限；無固定期限必須有人工複查日期，不等於永久停權。
- 停權立即撤銷全部 Session，禁止核發一般 Session。
- 會員保留通知、申訴、匯出及刪除入口。
- 固定期限到期後重新檢查狀態、年齡、同意與其他限制，符合條件才恢復。
- 提前解除需填寫原因並留下 Audit；執行者不得審核自己的高風險決定。
- 緊急事件可先暫時停權，但必須在限定時間內由第二人覆核。
- 停權與解除均需通知；若安全理由需延遲，必須記錄理由及核准者。
- 停權不是刪除，不得清除資料或剝奪可行使的資料權利。

## 十、Admin 查詢、Permission 與核准

### 10.1 Admin 會員查詢

- 主要查詢鍵為不可推測的會員 UUID，只支援精確查詢。
- 完整 Email 只允許具 `MEMBER_PII_LOOKUP` Permission 的特權 MFA Session 精確搜尋。
- Email 搜尋必須填寫理由、受限流並留下 Audit。
- 不支援 Email 模糊、前綴或批次搜尋。
- 搜尋結果預設只顯示遮罩 Email。
- 顯示完整 Email 使用獨立 Permission、獨立揭露 Command、理由與 Audit。
- 不允許以舊 `account` 查詢。

### 10.2 特權安全

- 採細分 Permission，不以單一 Admin Role 取得所有能力。
- 所有會員管理 API 需要特權 MFA Session。
- 高風險操作需要五分鐘 reauth。
- 高風險操作需雙人核准，不得自我核准。
- Role／Permission 變更、特殊清除與其他指定操作需理由、idempotency、Audit 與責任分離。
- 系統至少維持兩位有效 MFA Admin；交易不得讓有效 Admin 低於兩位。
- Break-glass 帳號受控、可稽核、限時，不具有私人內容權限。

### 10.3 資源不可枚舉

- 不存在、已刪除、無權與 owner 錯誤，對一般資源統一 `404`。
- 會員資源使用 `404 MEMBER_NOT_FOUND` 或對應通用資源代碼。
- Auth 使用 `401 AUTH_INVALID_CREDENTIALS`，不得使用停權專用 Status 洩漏帳號狀態。
- 刪除進度只能以 opaque deletion request ID 查詢。

## 十一、Data Export

- 申請前需五分鐘內 reauth。
- 密碼會員重新輸入密碼；Google 會員重新完成 Google 驗證。
- 停用、停權或受限會員仍可從用途受限流程申請。
- 使用非同步工作與 opaque export request ID。
- 匯出包含會員自己的帳號資料、私人內容、原始媒體、同意紀錄及可合理提供的活動紀錄。
- 不包含其他會員個資、內部風控規則或安全機密。
- 匯出格式至少包含 machine-readable JSON 與原始媒體 ZIP。
- 檔案加密且私有保存，不以 Email 附件寄送。
- 下載需有效 Session；高風險時再次 reauth。
- 七天期限從 `READY` 時間起算，不從申請時間起算。
- 到期刪除檔案，只保留不含私人內容的最小稽核紀錄。
- 失敗使用安全錯誤碼並可重試，不產生無人管理的重複檔案。
- 使用頻率限制避免資源耗盡。

## 十二、Account Deletion 與 Legal Hold

### 12.1 刪除流程

- 申請前需五分鐘 reauth。
- 接受後立即進入 `DELETION_PENDING`、撤銷全部一般 Session並取消公開可見性。
- 七天冷靜期從 Server `acceptedAt` 精確起算。
- 冷靜期內只允許進度、匯出、取消及申訴。
- 取消需再次 reauth；取消後不自動恢復分享或公開內容。
- 七天期滿後進入不可取消清除階段。
- 清除工作只能以 opaque deletion request ID 查詢。
- 清除完成後 Email 才可重新註冊為全新會員。
- 備份依保存週期自然淘汰，期間不得恢復至正式環境供一般使用。

### 12.2 清除失敗

- 可重試失敗進入 `PURGE_FAILED_RETRYING`。
- 需人工處理進入 `PURGE_REVIEW_REQUIRED`。
- Server 使用 idempotent Worker 安全重試並告警。
- 部分失敗不得將會員恢復為一般可用狀態。
- Restore 後必須重播 deletion、unshare、suspension 與 revocation marker。

### 12.3 Legal Hold

- 只有特定 Permission 與正式具拘束力依據可以建立。
- 保全範圍與期限必須最小化，不保留無關資料。
- Legal Hold 不恢復會員可見性或使用權。
- 可揭露時顯示清除延遲；不可揭露時使用通用合法限制說明。
- Hold 解除後自動續行清除，不要求會員重新申請。

## 十三、API 回應與錯誤契約

### 13.1 共用 Envelope

所有 API 維持既有 envelope，並統一包含：

- 穩定 `code`。
- 安全的本地化訊息鍵或訊息。
- 安全且完整的 `fieldErrors`。
- opaque `requestId`。
- 成功資料或非同步工作狀態。

Flutter 依穩定 `code` 本地化，不解析自由文字決定流程。

### 13.2 Auth Status Matrix

| 情境 | HTTP Status | Code／結果 |
|---|---:|---|
| 註冊安全受理 | `202` | `REGISTRATION_ACCEPTED` |
| 完整登入成功 | `200` | `AUTHENTICATED` |
| 憑證正確但需後續流程 | `200` | `nextAction`＋continuation credential |
| 無效憑證或不可揭露狀態 | `401` | `AUTH_INVALID_CREDENTIALS` |
| Refresh 無效、過期或撤銷 | `401` | `AUTH_SESSION_INVALID` |
| Refresh reuse | `401` | `AUTH_REFRESH_REUSE_DETECTED` |
| 欄位驗證失敗 | `400` | `VALIDATION_FAILED` |
| Email Verification Token 無效 | `400` | `EMAIL_VERIFICATION_TOKEN_INVALID` |
| Email Verification Token 過期 | `400` | `EMAIL_VERIFICATION_TOKEN_EXPIRED` |
| 狀態衝突 | `409` | `MEMBER_STATE_CONFLICT` |
| Version 衝突 | `409` | `VERSION_CONFLICT` |
| Idempotency 同鍵異內容 | `409` | `IDEMPOTENCY_KEY_REUSED` |
| 限流或冷卻 | `429` | `RATE_LIMITED`＋安全 `retryAfter` |
| 暫時無法服務 | `503` | `SERVICE_TEMPORARILY_UNAVAILABLE` |

### 13.3 Member／Admin／Data Rights Matrix

| 情境 | HTTP Status | Code／結果 |
|---|---:|---|
| 查詢或修改成功 | `200` | 對應成功結果 |
| 無內容命令成功 | `204` | 無 body |
| 非同步工作受理 | `202` | opaque request ID |
| 不存在、已刪除、owner 錯誤或不可揭露 | `404` | 通用 not-found code |
| Permission 不足 | `403` | `PERMISSION_DENIED` |
| 缺少特權 MFA | `403` | `PRIVILEGED_MFA_REQUIRED` |
| 需重新驗證 | `403` | `REAUTH_REQUIRED` |
| 不允許的狀態轉換 | `409` | `MEMBER_STATE_CONFLICT` |
| Version 過期 | `409` | `VERSION_CONFLICT` |
| 核准衝突或自我核准 | `409` | `APPROVAL_CONFLICT` |
| 工作進行中 | `200` | `PENDING`／`PROCESSING` |
| 匯出已過期 | `410` | `EXPORT_EXPIRED` |
| 刪除不可取消 | `409` | `DELETION_NO_LONGER_CANCELABLE` |
| Legal Hold 延遲且可揭露 | `200` | `DELETION_DELAYED` |
| 頻率限制 | `429` | `RATE_LIMITED` |
| 暫時依賴失敗 | `503` | `SERVICE_TEMPORARILY_UNAVAILABLE` |
| 未預期錯誤 | `500` | `INTERNAL_ERROR` |

## 十四、驗收條件

### 14.1 功能驗收

| ID | 驗收條件 |
|---|---|
| AC-001 | 初始註冊只接收 Email、密碼及必要條款，回通用 `202`，不揭露 Email 是否存在。 |
| AC-002 | 未完成 Email 驗證、Eligibility 或 Guardian Consent 時不能建立私人內容或取得一般 Session。 |
| AC-003 | 會員狀態與 Community Eligibility／Restriction 分離，所有限制由 Backend 強制。 |
| AC-004 | 新密碼符合 15–128 Unicode、NFC、blocklist與 Argon2id；舊 BCrypt 登入後可安全 rehash。 |
| AC-005 | verified Email 是 v1 密碼登入識別；舊 `account` 不再出現在新註冊、登入或 Admin 查詢契約。 |
| AC-006 | Google 相同 Email 不自動合併，需驗證既有登入方式及明確連結。 |
| AC-007 | Forgot Password 不回 Token，重設成功撤銷全部 Session。 |
| AC-008 | 每裝置獨立 Refresh family，Rotation、10 秒容忍與 reuse family revocation 可驗證。 |
| AC-009 | 一般、其他裝置與全部登出符合不同撤銷範圍且命令 idempotent。 |
| AC-010 | 本人一般、本人敏感及 Admin 修改使用分離 Command、欄位白名單、version及必要 reauth。 |
| AC-011 | 公開暱稱規則由 Backend 驗證；社群首次公開前取得明確確認，禁止官方冒充名稱。 |
| AC-012 | 年齡與 Guardian Consent 由 Backend 計算；生日降低時立即採保守資格限制。 |
| AC-013 | 本人停用、Admin Suspension、恢復及解除不自動恢復既有分享。 |
| AC-014 | Admin 查詢預設遮罩 Email；完整 Email 搜尋與揭露使用獨立 Permission、理由、MFA及 Audit。 |
| AC-015 | Role／Permission 變更立即撤銷特權 Session，且任何交易不得讓有效 MFA Admin 少於兩位。 |
| AC-016 | Data Export 經 reauth 非同步產生，七天從 `READY` 起算，過期檔案確實清除。 |
| AC-017 | Account Deletion 立即撤銷 Session與公開可見性，七天後不可取消並進入可重試清除。 |
| AC-018 | Legal Hold 僅保留必要範圍，解除後自動續行清除。 |
| AC-019 | 所有 Status／error code、requestId、fieldErrors與防枚舉規則符合本文件矩陣。 |
| AC-020 | Private content、Token、完整 Email、生日、Guardian資料及媒體路徑不進入 Log、Audit、Outbox payload或第三方監控。 |

### 14.2 完成門檻

下列證據全部具備前，相關 Task 不得標記 `DONE`：

- Backend Service 單元測試通過。
- 啟用真實 Security Filter 的 HTTP 整合測試通過。
- 使用正式相同 MySQL major version 的整合測試通過，不以 H2 取代主要驗收。
- Flutter Repository、Session Store、Widget 與 Router 測試通過。
- 至少一條「註冊 → Email 驗證 → Eligibility → 登入 → Refresh → 登出」完整 E2E 通過。
- Flyway 空資料庫建立與上一版本升級測試通過。
- OpenAPI contract test 通過。
- 文件、Task、CHANGE_LOG 與 CHANGE_HISTORY 同步。
- Git／PR 流程及工作報告完成。

## 十五、測試矩陣

| 類別 | 必測情境 | 主要驗收層 |
|---|---|---|
| 密碼長度 | 14／15／128／129 code points | Service＋HTTP＋Flutter |
| 密碼 Unicode | NFC、Emoji、空白、不 trim、弱密碼 blocklist | Service＋HTTP |
| 舊密碼遷移 | BCrypt 成功登入 rehash、失敗登入不修改 | Service＋MySQL integration |
| Email | 大小寫、首尾空白、Unicode domain、重複註冊 | Service＋HTTP |
| 防枚舉 | 未註冊、各會員狀態的註冊／忘記密碼回應一致 | Security HTTP integration |
| Email 驗證 | 有效、過期、已使用、重寄淘汰、60 秒冷卻、七天清理 | Service＋MySQL＋Worker |
| Google | verified／unverified Email、相同 Email未連結、完成 reauth linking | Service＋HTTP＋E2E |
| Login continuation | Pending Email、Eligibility、停用、停權、刪除等待 | Security HTTP integration |
| Refresh | 正常 rotation、10 秒內並行、逾期 reuse、不同 device family | Security HTTP＋MySQL |
| Client refresh | single-flight、原 request 一次重試、網路錯誤不誤清 Session | Flutter Repository |
| Session 期限 | 一般 idle／absolute、特權 idle／absolute | Service＋clock-controlled integration |
| 登出 | 目前裝置、其他裝置、全部、重複命令 | HTTP＋MySQL＋Flutter |
| 權限變更 | 升級、降級、舊 Access Token、permissionVersion | Security HTTP integration |
| Eligibility | 台灣／非台灣、12／13／17／18 歲、時區日期邊界 | Service＋HTTP |
| Guardian | 同意、撤回、重新取得、條款版本、不可查看內容 | Service＋Security HTTP |
| 生日更正 | 不跨界、跨 13／18、立即限制、拒絕、申訴 | Service＋HTTP＋MySQL |
| 公開暱稱 | 1／2／30／31 code points、Emoji、控制字元、雙向控制、純空白 | Service＋HTTP＋Flutter |
| 暱稱冒充 | 管理員、官方、客服、Admin及 Unicode／大小寫混淆變體 | Service＋HTTP |
| 暱稱公開 | 首次確認、拒絕確認、修改後既有貼文顯示、停用／刪除 | HTTP＋Flutter＋E2E |
| Admin 查詢 | UUID 精確、Email 精確、模糊拒絕、遮罩、揭露與 Audit | Security HTTP＋MySQL |
| Admin MFA | 無 MFA、過期 MFA、reauth、backup code重放 | Security HTTP integration |
| 雙人核准 | 正常核准、自我核准、重複核准、權限變更後失效 | Service＋MySQL integration |
| 最少 Admin | 嘗試移除倒數第二位有效 MFA Admin | Service＋MySQL integration |
| Suspension | 固定期限、無期限複查、緊急覆核、解除、通知失敗 | Service＋Worker＋HTTP |
| Optimistic lock | 舊 version、同時修改、刪除競態 | MySQL integration＋HTTP |
| Idempotency | 同鍵同內容、同鍵不同內容、重試與逾期 | MySQL integration＋HTTP |
| Export | 產生、失敗、重試、未授權下載、七天邊界、受限會員 | Worker＋Storage＋HTTP＋E2E |
| Deletion | 七天邊界、取消競態、不可取消、部分清除失敗、重複執行 | Worker＋MySQL＋Storage＋E2E |
| Legal Hold | 建立、範圍限制、不可揭露、解除後續行 | Service＋Worker＋Audit |
| Error contract | 每個 Status、code、fieldErrors、requestId | OpenAPI contract＋HTTP |
| 隱私 | Log、Audit、Outbox、錯誤及監控無敏感欄位 | Integration＋log capture |
| Migration | account、BCrypt、JWT Refresh、Google linking、server PIN、public avatar | Flyway empty／upgrade MySQL |
| Security Filter | 跨會員 UUID、無權、已刪除與 owner錯誤統一 `404` | 真實 Filter HTTP integration |
| 完整故事 | 註冊至登出、匯出與刪除的核心旅程 | Web／Android／iOS E2E |

## 十六、現況差距

以下差距以 2026-07-28 `develop` 的程式與 Schema 為準：

| 領域 | 現況 | 目標差距 |
|---|---|---|
| Auth API | 已有 `/api/auth/register`、`login`、`google-login`、`refresh`、`forgot-password`、`reset-password`、`logout` | 尚未統一 `/api/v1`、Email Verification、continuation credential與完整 error matrix |
| 登入識別 | 仍保留使用者可見 `account` 與 Account／Email相容登入 | v1 只接受 verified Email，account只作 Migration |
| 密碼 | BCrypt、8–72 字元基線 | 需 15–128 Unicode、NFC、blocklist、Argon2id與漸進 rehash |
| Email 驗證 | 無正式狀態與 Token工作流 | 需 24 小時單次 hash Token、重寄淘汰、冷卻與七天空會員清除 |
| Forgot Password | 現有開發回應可帶 reset Token | 正式回應不得回 Token，需 Email outbox與統一 `202` |
| Google | 相同 Email 可自動連結或建立本地會員 | 需既有登入方式 reauth與明確 linking |
| Session | JWT Refresh、rolling 30天、`revoked_tokens` | 需 opaque family、device session、10秒容忍、reuse detection、idle／absolute期限 |
| Client Credential | SharedPreferences保存完整 Login Result與Refresh Token | Web Cookie、App Keychain／Keystore、Access只存記憶體 |
| 會員狀態 | `is_deleted`、`deleted_at`，無正式狀態機 | 需七狀態、Eligibility、Restriction與轉換約束 |
| 個人資料 | `/api/users/me`查詢／修改，生日可一般修改 | 需一般／敏感 Command分離、生日更正工作流與 version |
| 公開暱稱 | 現有 `nickname`／`userName`偏私人欄位，無正式社群公開同意 | 需 Unicode規則、保留名稱、公開確認與社群呈現契約 |
| 頭貼 | 仍有 public avatar upload與R2公開URL | v1只允許已取得貘怪素材 |
| Privacy Lock | Backend仍有 server PIN API | App本機PIN；Web idle reauth；Backend移除PIN |
| Admin | 無正式單一會員管理 API、細分 Permission或遮罩／揭露流程 | 需 UUID查詢、PII lookup、MFA、reauth、Audit與雙人核准 |
| Role | 無完整 Role／Permission／permissionVersion | 需角色、細分權限、至少兩位MFA Admin及Session即時撤銷 |
| Suspension | 無完整 reason、期限、通知、申訴與複查工作流 | 需狀態、覆核、解除與用途受限入口 |
| Guardian／年齡 | 無正式 Guardian Consent與Eligibility模型 | 需 13／18歲邊界、條款版本、撤回與生日更正 |
| Export | 無正式 Data Export | 需 reauth、非同步JSON＋媒體ZIP、私有七天下載 |
| Deletion | 只有 soft-delete欄位 | 需七天取消期、不可取消清除、Legal Hold、marker與失敗重試 |
| Outbox／Worker | 無完整共用 transactional outbox與failed queue | Email、Export、Deletion、通知需一致可靠執行 |
| 測試 | 已有 Auth／User Service、Controller、Flutter Repository／Widget | 主要Controller測試部分關閉Filter；缺真實MySQL、權限狀態、MFA、生命週期與完整E2E |
| Migration | `database/init/01_schema.sql`及手動migration基線 | 需 Flyway baseline、空庫與上一版升級、expand／migrate／contract |
| 文件 | Phase 4.5已有總體基礎規格 | 需以本文件拆解Identity／Session／Member Management可交付Task |

## 十七、建議實作順序

實作採小步 Migration，不一次替換全部 Auth 與會員功能。

### Stage 0：契約與測試骨架

1. 凍結本文件、OpenAPI error schema、狀態機與資料辭典。
2. 建立真實 MySQL integration test、啟用 Security Filter的HTTP測試及 clock／Email／Google替身。
3. 導入 Flyway baseline、空庫與上一版本升級驗證。
4. 建立 Transactional Outbox、idempotent Worker、retry、failed queue與alert基礎。

完成條件：測試骨架可證明 Migration、Security Filter、Outbox與錯誤契約。

### Stage 1：Identity 與 Email Verification

1. 建立會員狀態機、UUID public ID與optimistic version。
2. 移除新註冊的 `account`，初始註冊只收 Email、密碼與必要條款。
3. 建立 Email Verification Token、重寄冷卻、七天空會員清除。
4. 建立 `nextAction`與continuation credential。
5. 建立 Argon2id、blocklist及BCrypt漸進rehash。

完成條件：未驗證會員不能建立私人內容，既有會員仍可安全Migration登入。

### Stage 2：Eligibility、Guardian 與會員資料

1. 建立台灣地區、生日、Guardian Consent與Community Eligibility。
2. 建立公開暱稱驗證、保留名稱與首次社群公開確認。
3. 分離一般資料、Email變更、生日更正及其他敏感Command。
4. 建立本人停用與恢復流程。

完成條件：13／18歲邊界、Guardian撤回、生日降低及暱稱公開均由Backend強制。

### Stage 3：Session 與登入方式

1. 將 Refresh 改為opaque family、hash儲存、rotation與reuse detection。
2. 建立每裝置Session、目前／其他／全部登出。
3. 建立Web Cookie、CSRF與App Keychain／Keystore Adapter。
4. 移除SharedPreferences Credential與server PIN依賴。
5. 修正Google linking及Forgot／Reset Password正式寄信流程。

完成條件：三平台Credential Store contract與Session撤銷矩陣通過。

### Stage 4：Authorization 與 Admin Management

1. 建立Role、Permission、permissionVersion及特權MFA。
2. 建立UUID精確查詢、遮罩Email、受控PII lookup與揭露。
3. 建立Admin Suspension、申訴、複查與解除。
4. 建立雙人核准、至少兩位有效MFA Admin與break-glass控制。

完成條件：舊特權Token在權限變更後立即失效，Admin無法查看私人內容。

### Stage 5：Data Rights

1. 建立reauth Data Export、私有檔案、七天到期清理。
2. 建立Account Deletion七天取消、不可取消清除與opaque status。
3. 建立Legal Hold、清除失敗狀態、跨儲存清除與restore marker。

完成條件：匯出、刪除、Legal Hold及失敗重試E2E通過。

### Stage 6：跨平台 E2E 與舊契約移除

1. 執行完整Auth／Eligibility／Session／Admin／Data Rights矩陣。
2. 執行Web、Android、iOS核心E2E。
3. 移除舊account、JWT Refresh、SharedPreferences Credential、Google自動連結、server PIN、public avatar及開發reset Token契約。
4. 同步所有Spec、Task、Log、Migration runbook與rollback／forward-fix證據。

完成條件：第十四章完成門檻全部具備，才可將相關Task標記`DONE`。

## 十八、DoR、DoD 與非目標

### 18.1 DoR

每個實作 Task 開始前必須具備：

- 明確狀態轉換與前置 Task。
- API request／response／status／error code。
- Database owner、constraint、version、retention與Migration方式。
- UI loading／success／error／restricted／expired狀態。
- 年齡、Guardian、Permission、Session撤銷、Audit、retry與失敗狀態。
- 真實Security Filter與MySQL驗收案例。

### 18.2 DoD

- 功能、Compile、Test、文件、Log、Git／PR及工作報告完成。
- Task依序經過`TODO → IN PROGRESS → REVIEW → DONE`。
- 未完成部署或E2E證據時不得宣告`DONE`。

### 18.3 本文件非目標

- 本文件不實作API、Schema、Flutter畫面、Email服務、CAPTCHA或部署。
- 本文件不開放社群feature flag。
- 不修改`system_data/`。
- 不導入E2EE、Kubernetes、跨區多主、專用Message Broker或持久裝置指紋。
- 不允許私人內容進入Admin、Log、Audit、Outbox或第三方監控。

## 十九、訪談決策追溯

| 題號 | 已確認決策 |
|---:|---|
| 1–5 | 會員建立邊界、狀態機、完整Session門檻、相同Email恢復、密碼政策 |
| 6–10 | verified Email登入、continuation credential、Refresh family、Admin個資遮罩、Command分離 |
| 11–15 | 特殊清除、404／401防枚舉、error envelope、登入防護、Permission與MFA |
| 16–20 | version／idempotency／Outbox、主要測試接縫、Google linking、Forgot Password、分階段收集資料 |
| 21–25 | 本人停用、Email變更、Guardian撤回、Admin安全門檻、Email驗證Token |
| 26 | 目前裝置、其他裝置、全部登出及Session期限 |
| 27 | UUID與受控完整Email精確查詢 |
| 28–29 | 公開暱稱規則與首次社群公開確認 |
| 30 | 生日更正分級審核及資格立即限制 |
| 31 | Admin Suspension原因、期限、通知、申訴與解除 |
| 32 | Role／Permission變更立即撤銷特權Session |
| 33 | Data Export reauth與從`READY`起算七天 |
| 34 | Account Deletion七天取消、Legal Hold及清除失敗 |
| 35–36 | Auth、Member、Admin與Data Rights Status／error matrix |
| 37 | 最終驗收門檻與邊界測試矩陣 |
| 38 | 使用者確認已達成共同理解並結束訪談 |
