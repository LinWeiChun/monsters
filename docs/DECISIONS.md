# DECISIONS.md

# 貘nsters 技術決策紀錄

本文件記錄已定案與待確認的跨文件決策。

Phase 4.5 已核准決策的可交付規格與測試接縫整理於 [`PHASE4_5_FOUNDATION_SPEC.md`](PHASE4_5_FOUNDATION_SPEC.md)；該文件不得反向弱化本文件、`CONTEXT.md` 或 ADR。

註冊、登入與會員管理第 1–38 題確認結果以 [`REGISTRATION_LOGIN_MEMBER_MANAGEMENT_SPEC.md`](REGISTRATION_LOGIN_MEMBER_MANAGEMENT_SPEC.md) 為準；其中 2026-07-28 公開暱稱決策由 ADR-0009 取代 ADR-0006 的跨貼文匿名身分。

## 零、2026-07-26 Grilling 核准基線

本章決策已由使用者逐項確認。若與後續既有決策、舊系統或目前程式衝突，以本章、`CONTEXT.md` 與 `docs/adr/` 為目標規格；衝突程式須列入 Phase 4 後的基礎安全階段，不得把舊實作反向視為新規格。

### 0.1 產品、地區與年齡

| 項目 | 決策 |
|---|---|
| 產品定位 | 非醫療情緒記錄與自我照顧工具；不診斷、不治療、不提供臨床風險判讀 |
| 私人內容分析 | Diary、Annoyance、媒體、情緒負荷與 Self Exploration 不做 AI、關鍵字或人工後台自動分析 |
| 第一版地區 | 只面向台灣；其他地區不開放正式註冊 |
| 最低年齡 | 13 歲 |
| 13–17 歲 | 需監護人 Email 同意，只能使用私人核心，不能瀏覽或使用社群 |
| Guardian Consent | 一次性短效 hash Token；保存條款版本、時間、狀態與撤回，不收證件、不提供 Parent Dashboard |
| 成年轉換 | 依已確認生日自動判斷，需重新同意成人條款後才可取得 Community Eligibility |
| 生日修改 | 資格確認後鎖定；更正需 reauth、理由與人工稽核，降低年齡立即套用限制 |
| Terms Versioning | Terms、Privacy、Community Rules、Minor Notice、Guardian Consent 分別版本化；重大變更需重新同意，拒絕時仍可匯出／刪除 |
| 服務語言 | 第一版台灣繁體中文；架構需可國際化 |
| 付費 | 第一版免費，不含訂閱、內購、代幣、付費容量或付費怪獸 |

### 0.2 身分、驗證與隱私鎖

| 項目 | 決策 |
|---|---|
| `account` | 移除使用者可見 account；Email／密碼以 verified Email 登入 |
| Email 驗證 | 驗證前不得建立私人內容；七天未驗證空帳號清除 |
| Email Delivery | 正式 SMTP 供應商選定 Resend；Backend 保持 Spring Boot Mail provider-neutral Adapter，使用 `smtp.resend.com:587` STARTTLS、帳號 `resend`，API Key 僅由環境 Secret 注入，寄件網域需先驗證 |
| Member State | 七態狀態機：Email 待驗證、資格待完成、啟用、本人停用、管理停權、刪除等待、已刪除；Community Eligibility／Restriction 分離 |
| State Priority | `DELETED > DELETION_PENDING > ADMIN_SUSPENDED > USER_DEACTIVATED > pending > ACTIVE`；`DELETED` terminal，恢復使用專用 Command |
| State Command | 不提供泛用 `targetState` API；Email 驗證、資格、停用、停權與刪除由分離 Command 經內部狀態機處理 |
| Continuation Credential | 32-byte 隨機不透明值、10 分鐘、只回傳一次、Server 只存 SHA-256 hash；狀態或 version 改變即撤銷，不能存取一般 API |
| Google Linking | 相同 Email 不自動合併；需先驗證既有登入方式並明確連結 |
| 忘記密碼 | 正式 Email reset link，15 分鐘單次 hash Token、統一對外回應、成功後撤銷全部工作階段 |
| Email 變更 | reauth、新 Email 驗證、新舊 Email 通知、撤銷其他工作階段 |
| Password Policy | 15–128 Unicode、弱密碼 blocklist、無固定 composition、無定期強制更換；參考 [NIST SP 800-63B](https://pages.nist.gov/800-63-4/sp800-63b.html) |
| Password Hash | 新密碼使用 Argon2id PHC hash（m=19456 KiB、t=2、p=1，Bouncy Castle 1.84）；既有 BCrypt 只在成功登入後於同一交易漸進 rehash；參考 [OWASP Password Storage](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html) |
| Access Token | 10 分鐘 JWT，只放記憶體 |
| Refresh Token | 不透明隨機值、Server 只存 hash；rotation、family 與 reuse detection |
| Web Credential | Refresh 使用 `__Host-` HttpOnly／Secure／SameSite Cookie；Access 只放記憶體 |
| App Credential | Refresh 存 Keychain／Keystore；Access 只放記憶體；SharedPreferences 不得保存敏感憑證 |
| Web Session Transport | 採方案1：沿用`/api/v1/auth/login`與`/api/v1/auth/session-refreshes`；`X-Session-Transport: COOKIE`搭配可信Origin及`X-CSRF-Protection: 1`，Backend設定`__Host-monsters-refresh`且Web response不回Refresh值 |
| App Credential Store | 採方案1：`flutter_secure_storage 10.3.1`；Android API 23使用Keystore預設RSA-OAEP＋AES-GCM，iOS使用不可同步且不可跨裝置遷移的Keychain項目，敏感資料不進備份 |
| Session Expiry | 一般閒置 30 天／絕對 90 天；特權後台閒置 30 分鐘／絕對 8 小時 |
| Device Management | 顯示裝置類型與約略資訊，可撤銷單一或全部其他工作階段 |
| Sensitive Reauth | 刪除、匯出、密碼／Email／登入方式／本機鎖重設等需五分鐘用途受限 reauth |
| App Privacy Lock | 每台裝置本機四位 PIN；背景立即遮蔽，預設一分鐘後鎖，可選立即／1／5／15 分鐘 |
| Web Privacy | 無四位 PIN；頁籤失焦遮蔽，閒置 15 分鐘後 reauth |
| Account Recovery | 客服不得繞過驗證；失去所有登入與備援方式時不能人工接管 |
| Privileged MFA | Moderator、Admin、Content Reviewer 強制 TOTP＋單次備援碼 |
| Admin Impersonation | 禁止模擬會員、產生會員 Token 或查看私人內容 |

### 0.3 Entry、媒體與資料權利

| 項目 | 決策 |
|---|---|
| Entry Model | Diary／Annoyance 共用 Entry 核心，保留分離 Use Case／Command |
| Emotional Load | 1 代表較輕、5 代表較重；Diary／Annoyance 共用且皆選填 |
| Private Category | 由本人選擇且選填；不自動推論、不直接公開 |
| Emotional Trace | 最近 30 個本地日曆日，同日平均、缺值留白，可查看原始分數與依類型篩選 |
| Time Model | 保存 UTC、建立當下本地日期、IANA timezone 與 offset；時區變更不移動舊 Entry 日期 |
| Concurrency | optimistic version；衝突不自動合併，刪除優先，建立命令需 idempotency |
| Offline | 第一版不持久化離線私人資料；尚未同步的本機草稿只在目前執行期間保留，已同步的 owner-scoped 伺服器草稿依 30 天規則保存 |
| Private Search | 本人主動傳統關鍵字／metadata 篩選；不保存搜尋詞、不做 semantic／AI search |
| E2EE | 第一版不採端對端加密；使用 HTTPS、private R2、at-rest encryption、最小權限與稽核 |
| Media Limits | 圖片／drawing 5 MB；錄音 10 MB／5 分鐘；影片 50 MB／60 秒 |
| Media Safety | 隔離、真實格式解析、重新處理、metadata 移除、malware scan 通過後才可用 |
| Account Quota | 每會員正式媒體 1 GB；達上限只拒絕新增媒體，不刪除或壓縮舊資料 |
| Text Limits | Entry 20,000 Unicode 字元、Community Post 10,000、留言 1,000 |
| Avatar | 不接受使用者圖片；只能從已取得的貘怪圖鑑素材選擇 |
| Item Deletion | 立即不可見，MySQL 內容／metadata 與 R2 object 七天內清除，backup 最長 30 天 |
| Account Deletion | reauth、立即停用與取消分享、七天取消期，之後清除全部帳號與內容資料 |
| Inactive Account | 三年未成功登入，於 90／30／7 天通知後進入刪除流程 |
| Data Export | 第一版上線條件；reauth 後以背景工作產生 JSON＋原始媒體 ZIP 與短效下載 |
| Legal Hold | 只有正式且具拘束力要求可最小、隔離、限期保全；一般檢舉不能延長刪除 |
| Content License | 只為提供功能與主動分享所需；取消分享／刪除終止，不得用於 AI、廣告、宣傳或未另同意研究 |

### 0.4 社群與治理

| 項目 | 決策 |
|---|---|
| Community Boundary | 封閉、需登入、只對具資格成人開放；不公開索引、外部嵌入或永久媒體 URL |
| Identity | 以非唯一公開暱稱形成跨貼文可辨識身分、平台內可問責；不顯示 account、Email、會員 UUID、私人頭貼或私人 Profile |
| Public Snapshot | 分享建立獨立 Community Post；私人 Entry 修改不得自動同步 |
| Public Fields | 只公開逐項確認文字、媒體與 Public Topic；不帶 Emotional Load、Private Category、原始日期或歷史 |
| Post Version | 編輯建立版本並標示已編輯；報告與互動保持關聯，審核中／下架時不得藉編輯重發 |
| Public Nickname | 2–30 Unicode code points、NFC、禁止控制／雙向字元與官方冒充名稱；首次公開前明確確認，不用於登入或 owner 判斷 |
| Interaction | 單層留言；無私訊、追蹤、好友、標記或巢狀回覆 |
| Support | 只有一種正向支持；作者可看 aggregate，其他讀者不見公開總數；不做排行 |
| Ranking | 第一版依時間與安全條件，不以支持／留言量建立熱門排行 |
| Governance Gate | Report、Block、Unshare／Delete、Takedown、Restriction、Audit、Appeal 與 privileged MFA 完成前不得開放 |
| Reports | 對 reporter 立即隱藏；不因檢舉數自動下架，不做 premoderation、AI 或 keyword moderation |
| Block | blocker 不再看到 blocked member 的 Community Post／Comment；不公開或建立可追蹤的被封鎖身分資訊 |
| High-risk Report | 自傷／傷人疑慮進人工優先佇列；平台不是緊急救援或 24 小時監控服務 |
| Content Policy | 允許談困難經驗；禁止騷擾、威脅、個資揭露、危險教學、剝削、詐騙與冒充專業 |
| Sensitive Warning | 作者或 Moderator 可人工標示；媒體預設遮蔽，警示不是診斷也不能代替下架 |
| Appeals | 處置需理由；14 天內一次申訴，原則由不同 Moderator 複核，申訴期間內容不公開 |
| Sanction Boundary | Community Restriction 不影響私人記錄、匯出與刪除；帳號層級停用另有明確原因 |
| Unshare Cascade | Post、留言、支持立即不可見，七天內清除；重新分享建立新討論 |
| Roles | MEMBER、MODERATOR、ADMIN、CONTENT_REVIEWER；Community Eligibility 不是 Role |
| Moderator | 只處理已檢舉公開內容與社群限制 |
| Admin | 管理帳號狀態、角色、設定與正式停權，不能查看私人內容或修改 Audit |
| Content Reviewer | 只審閱版本化內容，不能查看會員資料或社群案件 |

### 0.5 內容、怪獸與通知

| 項目 | 決策 |
|---|---|
| Self Exploration | 無對錯、描述性回饋、非醫療、結果完全私人、可逐筆刪除、不可分享到社群 |
| Educational Quiz | 有正確答案、說明、來源與適用年齡；不排名、不因答錯扣獎勵 |
| External Resource | allowlist＋離站提示；不在 App 內背景載入第三方追蹤資源 |
| Content Review | Admin 建草稿，獨立 Content Reviewer 核准特定版本；修改後重新審閱 |
| Monster Response | 只從經審閱固定內容庫選取，不讀取私人內容、分類或情緒負荷 |
| Monster Unlock | Starter 自選＋公開固定里程碑；不隨機、不重複、不連續登入、不依情緒內容 |
| Notification | 安全事件用 Email；社群與一般事件用 App 內通知；Push 最少揭露 |
| Behavioral Nudging | 不發送「心情不好」「很久沒記錄」等推測式或施壓式提醒 |
| Analytics | 無廣告、跨站追蹤、裝置廣告 ID 或敏感分群；兒少不啟用非必要分析 |
| Feedback | 與 Report 分離；第一版文字＋opaque request ID，無附件，關閉 90 天後清除 |

### 0.6 平台、營運與發布

| 項目 | 決策 |
|---|---|
| API | `/api/v1`、OpenAPI、穩定 error code／requestId、UUID public ID |
| Database Migration | Flyway immutable version、prod schema validate、expand／migrate／contract、forward fix |
| Async Work | MySQL Transactional Outbox＋idempotent Worker；retry、backoff、failed queue、alert |
| Environment | Development／Staging／Production 的 DB、R2、OAuth、Email、keys 與 domains 完全隔離 |
| Production Data | 不複製到非正式環境；Staging／CI 只用 synthetic data |
| Deployment | 單一亞洲區域 managed container＋managed MySQL＋private R2；第一版無 Kubernetes／multi-primary |
| Backup | 每日加密完整備份＋交易紀錄，RPO 15 分鐘、RTO 24 小時、最長 30 天 |
| Restore | 重播 deletion／unshare／suspension／revocation marker；社群在完成重播前保持關閉 |
| Audit Retention | 一般 Log 30 天、安全 180 天、管理／審核一年；不得保存私人內容或可逆刪除身分 |
| Abuse Protection | Edge＋Backend 分層限流；不建持久 device fingerprint；CAPTCHA 只在高風險且經隱私審查 |
| Monitoring | allowlist fields only；無 body、content、Email、Token、media path、search query 或 screenshot |
| Emergency Flags | Server 強制關閉 register、Google login、upload、share、comment、notification、export 等高風險功能 |
| Incident Response | 封測前完成 Token key leak 與 cross-account access 演練；之後每半年演練 |
| CI Gate | Backend、Flutter、Web／Android／iOS Build、real MySQL Flyway、OpenAPI、security scan、E2E |
| Release Order | 先 Phase 4 候選成果整合，再做基礎安全階段；完成前暫停 Phase 5 以後功能 |
| Private Beta | 三平台核心一致、正式資料等級、至少穩定四週；不以活躍度或負面內容量決定擴張 |
| Community Release | 私人核心穩定且治理、安全與 MFA 門檻全部通過後，才開啟社群 server flag |

## 一、既有已定案（受零章 supersession）

本章保留既有 Phase 的歷史決策。若內容與零章衝突，代表現有程式需要 Migration，而不是零章決策尚未確認。

| 項目 | 決策 |
|------|------|
| 前端框架 | Flutter |
| 後端框架 | Spring Boot |
| 後端 Java 版本 | JDK 18 |
| 後端 Build Tool | Gradle |
| Database | MySQL |
| API 架構 | REST API |
| 本機容器環境 | Docker Compose |
| `system_data/` 定位 | `system_data/` 僅作為舊系統參考來源，不作為新版規格來源 |
| 舊程式使用方式 | 可參考流程、資料結構、UI 行為與業務邏輯，但不得直接複製舊程式 |
| 規格衝突處理 | 當 `system_data/` 與正式文件衝突時，以正式文件為準 |
| AI 回報要求 | AI 若參考 `system_data/`，需於工作報告中說明參考內容與轉換方式 |
| Google 登入 Client ID | 後端透過 `GOOGLE_CLIENT_IDS` 設定允許的 Google Client ID，可用逗號支援 Web / App 多組 Client ID |
| 忘記密碼流程 | 歷史基線；開發 API 回傳 resetToken 的方式已由 0.2 正式 Email reset link 決策取代 |
| 登出流程 | 歷史基線；JWT Refresh revocation 已由 0.2 不透明 Token family 與 session 撤銷模型取代 |
| Token Refresh | 歷史基線；30 天 JWT rotation 已由 0.2 的 10 分鐘 Access、30 天 idle、90 天 absolute 與 opaque Refresh 模型取代 |
| Profile 生日選擇器 | 採方案 A：使用 Flutter 內建 `showDatePicker`，不新增第三方套件；選擇範圍為 1900-01-01 至當日，送出格式維持 `yyyy-MM-dd` |
| 檔案上傳儲存方式 | 歷史基線；public avatar upload 已移除，Entry media 依 0.3 使用 quarantine＋private R2 安全流程 |
| Web 管理後台 | 需要建立 Web 管理後台；角色、MFA、私人資料禁止存取與稽核範圍依 0.4／0.6 |
| 正式寄信服務 | 忘記密碼正式環境使用 SMTP 寄送 reset link |
| 舊資料庫相容性 | 不直接沿用舊錯字表名；以新版 schema 為準，必要時以 mapping 文件將舊資料概念結合至新版資料庫 |
| 舊系統素材沿用 | 可沿用舊系統圖片或影片素材；不得沿用舊程式邏輯，素材授權與命名需於資產整理 Task 檢查 |
| 舊資料庫 migration | 不建立舊資料庫自動 migration；舊資料僅作欄位 mapping 與新版資料模型參考 |
| 舊 API 對照表 | 需要建立完整舊 API 對照表，比對 path、method、request、response 與錯誤情境 |
| 舊 Flutter UI 對照清單 | 需要建立舊 Flutter UI 畫面對照清單，比對流程、元件、狀態與素材 |
| Phase 分支流程 | 所有後續 Phase 均由 `develop` 建立 `feature/phase<n>` 整合分支；Phase 內 Task 由該 Phase 分支切出獨立分支，Task PR 先合併回 Phase 分支，Phase 完成後再由 Phase 分支 PR 至 `develop` |
| Phase 3 煩惱記錄方式 | 支援文字、圖片、錄音與影片；每筆使用一種主要記錄方式，另可附一張心情圖（D1-A、D2-A） |
| Phase 3 煩惱上傳契約 | 歷史基線；multipart 可沿用，但分類與情緒負荷依 0.3 改為選填 |
| Phase 3 怪獸獎勵 | Phase 3 只建立煩惱並顯示完成結果；新增煩惱後的真實怪獸獎勵延至 Phase 6 串接（D5-B） |
| Phase 3 煩惱列表 | 使用 `page`、`size`、`sort` offset pagination；Database 不新增頁碼欄位（D6-A） |
| Phase 3 聊天互動 | 採聊天外觀搭配結構化 selector Widget，不以自由文字解析類別、記錄方式、分數或分享選項（D7-A） |
| Phase 3 媒體限制 | 圖片與心情圖 5 MB；錄音 10 MB／5 分鐘；影片 50 MB／60 秒；前後端使用相同 MIME type 白名單（D8-A） |
| Phase 3 煩惱媒體存取 | 使用獨立且不可公開存取的 R2 entry media bucket，Database 只保存 object key；Backend 驗證 owner 或分享權限後串流，API 不回傳 object key（D9-A） |
| Phase 3 媒體長度驗證 | Backend 使用 `ffprobe` 驗證錄音最多 5 分鐘、影片最多 60 秒；Backend runtime 必須安裝 FFmpeg（D10-A） |
| Phase 3 Entry 領域模型 | Annoyance 與後續 Diary 共用 `Entry` Entity 與 Repository，Annoyance 模組使用獨立 DTO、Mapper、Service 與 Controller（D11-A） |
| Phase 3 Annoyance Core 範圍 | Core Task 建立領域基礎、lookup、DTO、Mapper、Service 驗證與 Controller 骨架；實際 API endpoint 依後續 Task 逐一完成（D12-A） |
| Phase 3 R2 規格用語 | Entry media 在 Database 只保存 private R2 object key，不保存 public URL（D13-A） |
| Phase 3 Mood seed | Annoyance 與 Diary 共用 1 至 5；依 0.3 正式語意為 Emotional Load，1 較輕、5 較重，且可略過 |
| Phase 3 煩惱分數 UI | 歷史圖片可作輔助；依 0.3／UI Spec 必須同時顯示文字語意與略過，不得只以笑臉或難過圖定義 |
| Backend package layout | 全面採 layer-first `com.monsters.<layer>.<module>`；`common` 作為共用模組名，`MonstersApplication` 維持在 `com.monsters` |
| Web／Mobile 導覽 | 採使用者選定 Web 方案 A、Mobile 方案 1：Desktop Home／Profile／Annoyance 共用完整 Navbar；Mobile 保留共用底部選單，「我的」為 Profile 唯一主要入口，首頁右上角改為通知 |
| 頁面切換效果 | 一般前進與導覽切換直接換頁、無左右位移；明確返回按鈕使用 navigation pop，當前頁面以 220ms 向右退出 |
| Phase 4 日記獎勵 | 採方案 A：Phase 4 只保存日記並顯示完成結果，API `reward` 固定回傳 `null`；真實怪獸或其他獎勵延至 Phase 6 串接 |
| Phase 4 Entry 前端重用 | 採方案 A：抽出並重用 Annoyance 的 Entry 共用 UI 元件、Responsive flow shell 與媒體 Adapter；Diary 維持獨立 draft state、Provider、Repository、DTO、review 與完成元件 |
| Phase 4 日記繪圖 | 採方案 A：心情圖為 optional；使用者可選擇繪圖或略過，每筆最多一張心情圖 |
| Phase 4 起 UI 設計流程 | 採 Penpot design-first；所有後續含 UI 的 Phase 先完成或更新 Web／Mobile 畫板及狀態，再同步 UI 規格與 Flutter 實作 |
| Phase 4 起 UI 驗收順序 | 採 Web-first：Penpot Web 畫板為第一實作與驗收來源，Mobile 畫板保留並於 Web 驗收後適配；新畫面需對齊已完成頁面的導覽、版型與視覺 token |
| 日記／煩惱持久草稿 | 採獨立 `entry_drafts`／`entry_draft_media`，每位使用者每種類型最多一份草稿；草稿與 private R2 媒體保留 30 天，完成送出時在同一 Database transaction 轉為正式 Entry，放棄或逾期時清理媒體 |

## 二、已核准套件與工具

### Frontend

| 類型 | 套件 / 工具 |
|------|-------------|
| State Management | Riverpod |
| HTTP Client | Dio |
| JSON | json_serializable |
| Routing | go_router |
| 非敏感 Local Storage | SharedPreferences；Credential、Login Result 與私人內容依 0.2 禁止保存 |
| 敏感 Credential Storage | flutter_secure_storage 10.3.1；只限Android Refresh Credential與iOS Refresh Credential |
| Google Sign-In | google_sign_in、google_sign_in_web |
| 媒體選取 | image_picker；Android 實作固定 image_picker_android 0.8.12+24 以相容 AGP 8.7 |
| 錄音 | record |
| 影音預覽 | video_player、just_audio |

### Backend

| 類型 | 套件 / 工具 |
|------|-------------|
| Framework | Spring Boot |
| ORM | Spring Data JPA |
| Validation | Jakarta Validation |
| Security | Spring Security + JWT |
| Email Adapter | Spring Boot Mail Starter + provider-neutral SMTP Adapter；正式 provider 為 Resend |
| Build Tool | Gradle |

## 三、待細化事項

| 項目 | 目前狀態 |
|------|----------|
| Web 管理後台 UI | 權限模型已由 0.4 定案；實際路由、畫面與 provider 待管理後台 Task 細化 |
| 舊 API 對照表 | 待建立：需依 `system_data/` 舊後端與舊前端呼叫整理完整對照 |
| 舊 Flutter UI 對照清單 | 待建立：需依 `system_data/` 舊 Flutter 頁面整理流程、元件、狀態與素材 |
| 舊系統素材清單 | 待建立：需確認可沿用圖片 / 影片清單、檔名規則、資產目錄與授權備註 |
