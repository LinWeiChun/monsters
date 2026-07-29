# UI_SPEC.md

# 貘nsters Flutter UI 規格

> Phase 4.5 的 Web／Android／iOS 使用者故事與驗收接縫以 [`PHASE4_5_FOUNDATION_SPEC.md`](PHASE4_5_FOUNDATION_SPEC.md) 為準；註冊、登入、會員管理與公開暱稱 UI 狀態以 [`REGISTRATION_LOGIN_MEMBER_MANAGEMENT_SPEC.md`](REGISTRATION_LOGIN_MEMBER_MANAGEMENT_SPEC.md) 為準；本文件保存正式 UI 行為。

> 狀態說明：2026-07-26 grilling 決策為目標 UI 契約。Phase 2／3 與 `feature/phase4` 的既有畫面敘述仍保留作 Migration 參考；凡涉及 Account 登入、上傳個人頭貼、伺服器密碼鎖、分數／分類必填、boolean 分享、最近七筆、隨機怪獸、公開人氣或深度心理測驗者，必須在基礎安全階段改為本文件的新規則。

## 零、跨功能 UI 邊界

- 第一版正式語言為台灣繁體中文；所有文案、日期、數字與錯誤訊息必須可國際化。
- 核心流程依 WCAG 2.2 AA 實作，支援鍵盤、明確焦點、螢幕閱讀器、系統大字與減少動態效果。
- 不得只以顏色、圖片或怪獸表情表達情緒負荷、錯誤、成功或選取狀態。
- 私人內容不得顯示於 App switcher、鎖定畫面通知、URL、瀏覽器標題、分享預覽、Crash screenshot 或一般系統日誌。
- App 進背景立即顯示隱私遮罩；預設離開一分鐘後需本機 PIN，可選立即、1、5、15 分鐘。
- Web 不顯示本機 PIN，頁籤失焦先遮蔽，閒置 15 分鐘後要求帳號重新驗證。
- 第一版不持久化離線私人資料；尚未同步的本機草稿只在目前 App 執行期間保留，已同步的 owner-scoped 伺服器草稿依 30 天規則保存，送出失敗時可於原畫面重試。
- 通知預設只顯示「貘nsters 有一則新通知」，不得顯示日記、貼文、留言、媒體或情緒負荷。
- 高風險功能由 Backend 功能開關強制；Client 設定無法取得時採關閉狀態，但仍保留資料查看、匯出與刪除入口。

## 一、平台

本專案 UI 使用 Flutter 實作，需支援：

- Android
- iOS
- Web

目前開發與驗收以 Web-first 為主，Web 版需以 Responsive Layout 呈現；Mobile Penpot 畫面與 Android／iOS 相容性仍須保留。

前端功能 Task 預設需以 Flutter 共用程式實作，並確認 Web、Android、iOS 三平台皆可使用。若功能涉及平台差異，例如檔案選取、通知、相機、外部連結或權限，必須在同一 Task 內補齊三平台處理或明確記錄平台限制與替代方案。

### 1.1 Penpot design-first 與 Web-first 驗收

- 自 Phase 4 起，所有包含 UI 的 Phase 必須先在 Penpot 完成或更新 Web／Mobile 畫板與必要狀態，才能進入 Flutter UI 實作。
- Web 畫板是第一實作與驗收來源；先完成 Desktop 與 Responsive Web Design，再沿用同一份 Flutter 業務、狀態與資料層適配 Mobile 畫板。
- Penpot 畫板必須參考已完成頁面的共用視覺語言，包括 Navbar／底部導覽、內容最大寬度、網格、字級、間距、色彩、圓角、陰影、卡片及按鈕層級，不得為單一 Phase 建立不相容的平行樣式。
- 流程、狀態或 UI 決策異動時，先更新 Penpot，再同步本文件與程式；交付前需匯出或實際檢視畫板，確認無溢位、遮擋及錯誤文案。

## 二、主要頁面

### 2.1 初始頁面

用途：進入 App 時顯示 Logo 或品牌視覺。

操作：

- 前往登入頁面
- 判斷是否已登入

### 2.2 登入頁面

功能：

- Email / 密碼登入
- Google 登入
- 前往註冊
- 前往忘記密碼
- 完整登入成功才建立本地 Session 並導向首頁
- 收到 `AUTH_CONTINUATION_REQUIRED` 時停留登入流程、依 `nextAction` 顯示下一步，不得建立一般 Session

### 2.3 註冊頁面

功能：

- 輸入 Email
- 輸入密碼
- 確認密碼
- 不顯示或要求 `account`
- 完成註冊後顯示 Email 驗證狀態與重新寄送入口
- Email 驗證後依序確認台灣服務地區、生日、條款版本與年齡資格
- 13 至 17 歲顯示監護人 Email 同意流程；等待同意期間不得進入完整 App
- 未滿 13 歲或非服務地區顯示無法註冊與資料清除說明

### 2.4 首次 Google 登入設定個人資料

功能：

- 確認 Google Email 已驗證
- Google Email 與既有會員相同時，引導先登入既有方式並明確連結，不自動合併
- 設定公開暱稱、服務地區、生日與必要同意；首次社群公開前另行確認暱稱將跨貼文顯示
- 依年齡進入成人或監護人同意流程

### 2.5 主頁面

功能：

- 顯示目前怪獸與陪伴問候語
- 以「記下現在的心情」作為單一主要操作，進入新增煩惱聊天室
- 日記與歷史記錄在對應 Phase 完成前顯示「即將開放」且不可操作
- 手機版使用共用底部導覽列，「我的」直接進入個人資料；首頁右上角為通知入口，密碼鎖與登出由個人資料頁提供
- Web Desktop 使用 Home／Profile／Annoyance 共用完整導覽，頁面內容依 viewport 以相對 layout 重排

導覽：

- 互動區
- 歷史記錄
- 新增
- 社群
- 圖鑑

首頁使用共用 window class：Mobile `< 600px`、Tablet `600px - 1199px`、Desktop `>= 1200px`。Mobile 保留 390 x 844 Penpot 畫布；Tablet 使用 compact flow layout；Desktop 主要內容最大寬度 1200px，怪獸陪伴區與操作區並列。設計來源為 Penpot Web／Mobile 畫板與現行 Web RWD 規格。

首頁怪獸使用 Flutter 程式動畫，不修改或拆分原始圖片。進入首頁時播放有限次數的輕微呼吸與上下漂浮，點擊怪獸時播放彈跳、縮放及小幅擺動；動畫只作用於怪獸區，不得遮擋或移動主要操作。系統啟用「減少動態效果」時必須停止待機與點擊動畫，並維持靜態圖片與完整操作功能。

### 2.6 抽屜選單

功能：

- 個人資料
- 從已取得的貘怪圖鑑選擇頭貼
- 編輯個人資料
- Android／iOS 設定或更改本機隱私鎖
- 登入裝置管理
- 資料匯出
- 刪除帳號
- 使用說明
- 使用回饋
- 登出

### 2.7 新增煩惱聊天室

下列聊天式結構與媒體能力可沿用 Phase 3，但分類與情緒負荷必須增加「略過」，分享必須改為建立獨立 Community Post 的明確預覽；既有 `isShared` boolean 只作 Migration 參考。

流程：

1. 怪獸引導對話
2. 以結構化選擇元件選擇煩惱類別或略過
3. 選擇文字、錄音、照片或影片其中一種主要記錄方式
4. 輸入文字或選取一個主要媒體，顯示預覽、移除與重選操作
5. 選擇是否畫心情；選擇繪圖時最多附加一張心情圖
6. 以結構化元件選擇 1 至 5 情緒負荷或「這次不評分」
7. 選擇保持私人，或進入公開快照逐項預覽；不得預先勾選分享
8. 檢視摘要並送出；送出中禁止重複操作，失敗時保留伺服器草稿
9. 顯示建立完成頁面，可前往歷史記錄

互動採聊天外觀搭配 `AnnoyanceCategorySelector`、`RecordMethodSelector`、`MediaPreviewCard`、`MoodDrawingCanvas`、`MoodScoreSelector`、`ShareChoiceCard` 與 `AnnoyanceReviewCard`，不得以自由文字比對選項。狀態依 `intro → category → recordMethod → content → drawingDecision → drawing（optional）→ score → sharing → review → submitting → completed` 推進。

前後端媒體限制一致：圖片 jpeg/png/webp，最多 5 MB；錄音 mp4/aac/mpeg/wav，最多 10 MB 或 5 分鐘；影片 mp4/quicktime/webm，最多 50 MB 或 60 秒；心情圖 png/webp，最多 5 MB。Web、Android、iOS 的平台差異集中於媒體 Service／Adapter。

煩惱媒體存放於獨立的 private R2 bucket。Flutter 只能使用 API 回傳的 Backend download URL 並附帶 JWT 讀取，不得組合 R2 bucket URL 或保存 object key；錄音與影片播放器需支援 Backend 的 HTTP Range response。

進入 `/annoyances/new` 時先讀取 owner 的伺服器草稿；存在時還原步驟、文字、選項與暫存媒體，讓重新整理、離開後返回、重新登入或跨裝置繼續。狀態變更後自動暫存，文字輸入使用 debounce；畫面顯示「暫存中」、「草稿已暫存」或可重試錯誤。草稿保存 30 天，媒體仍保持私人；「重新開始」必須先確認，確認後呼叫 DELETE Draft API，不得只清除本機 Provider。

Phase 3 完成頁不顯示假怪獸獎勵，不得沿用舊系統「恭喜你獲得一隻怪獸」或「查看圖鑑」操作；真實獎勵與圖鑑導向於 Phase 6 串接。

聊天室入口使用 `/annoyances/new`，由首頁「新增煩惱」進入。聊天室基礎 Task 建立聊天泡泡、不可變草稿狀態、上一步／重新開始操作，以及 `intro → category → recordMethod → content` 的結構化推進；content 之後的媒體選取、繪圖、分數、分享、摘要與送出依後續 Phase 3 Task 接續同一狀態機，不得另建平行流程。

媒體內容 Task 在 `content` 步驟提供文字輸入、單一圖片或影片的相簿／相機來源、App 內 WAV 錄音，以及圖片、錄音、影片預覽。選取後需顯示檔名、MIME type、大小與可取得的長度，並提供移除及重新選擇；媒體處理集中於 `AnnoyanceMediaService` 與平台 Adapter。圖片只在通過 5 MB 限制後讀入預覽 bytes，錄音與影片保留 `XFile`，避免在草稿中長期複製大型檔案。Android 最低 SDK 依目前 Flutter 預設 24，iOS 必須宣告相簿、相機與麥克風用途；Web 不支援的相機來源需顯示可理解的失敗訊息並保留檔案選取替代操作。

畫心情 Task 在主要內容確認後顯示「想畫／先不用」結構化選項；選擇略過時直接進入分數步驟，選擇繪圖時顯示單一正方形畫布。`MoodDrawingCanvas` 使用正規化座標保存筆畫，提供六色畫筆、2 至 16 的線寬、橡皮擦、復原、清除、取消與完成操作；完成時以白色背景輸出固定 1024×1024 PNG，限制 5 MB，並在聊天紀錄顯示一張心情圖預覽後進入分數步驟。取消繪圖須返回是否繪圖選項，返回上一步或重新選擇主要內容時須清除未提交的繪圖草稿；心情圖不另存至相簿，後續由既有新增煩惱 multipart API 的 `drawingFile` 上傳。

情緒負荷 Task 使用 `MoodScoreSelector` 同時顯示數字與「較輕」至「較重」的非診斷式文字，1 代表較輕、5 代表較重，另提供「這次不評分」。圖片只能作輔助，不得把分數稱為快樂、心理健康或疾病嚴重度；略過時保存 null，情緒足跡不得補零。

分享 Task 使用 `ShareChoiceCard` 顯示「保持私人」與「建立暱稱社群公開快照」。選擇分享後必須逐項預覽實際公開文字、媒體、公開主題與公開暱稱；情緒負荷、私人分類、原始日期與版本歷史預設不公開。首次公開暱稱及每次分享都需主動確認，不能只改 boolean 或沿用上次選擇。

煩惱摘要送出 Task 使用 `AnnoyanceReviewCard` 顯示類別、記錄方式、主要內容、心情圖、分數與分享狀態。送出前完成最後一次草稿同步，再由 `AnnoyanceRepository` 呼叫 `POST /api/annoyances/draft/submit`；送出中進入 `submitting` 狀態並禁止上一步與重複送出。成功後保存 `AnnoyanceResponse` 並顯示 `AnnoyanceCompletedCard`，Phase 3 僅呈現建立成功與分享狀態，不顯示假怪獸獎勵；失敗時返回 `review`、保留伺服器草稿並顯示 API 錯誤訊息。

### 2.8 新增日記聊天室

設計與驗收來源：

- 第一實作與驗收：Penpot `WEB / Diary Flow / Web`，各狀態採 1440×900 Desktop 畫板，Responsive Web 驗收範圍為 1200px 至 1920px。
- 後續 Mobile 適配：Penpot `APP / Diary Flow / Mobile`，基準畫板為 390×844；Mobile 不先於 Web 實作。
- Phase 4 使用 `01` 至 `08` 與 `09 Completed / Phase 4` 畫板；`Future Reward / Phase 6` 僅保留為未來設計，不得在 Phase 4 程式顯示。
- 視覺樣式需對齊已完成的 Penpot `Web / Companion Home` 與 `Annoyance Flow / Web`：共用 Navbar、1200px 內容區、桌面雙欄、暖色卡片、字級階層、間距、圓角、陰影與主要／次要按鈕。

流程與狀態機：

1. 怪獸引導與開始記錄
2. 選擇文字、錄音、照片或影片其中一種主要記錄方式
3. 輸入文字或選取一個主要媒體，並提供預覽、移除與重選
4. 以結構化選項選擇畫心情或先略過
5. 選擇繪圖時顯示心情畫布；略過時直接進入分數
6. 使用 `moodPoint_1.png`～`moodPoint_5.png` 選擇 1 至 5 分
7. 選擇保持私人或分享到社群，預設私人
8. 檢視摘要並送出；送出中禁止重複操作，失敗時保留伺服器草稿
9. 顯示安全保存完成結果，可返回首頁或再寫一篇日記

狀態依 `intro → recordMethod → content → drawingDecision → drawing（optional）→ score → sharing → review → submitting → completed` 推進。聊天室入口使用 `/diaries/new`，Phase 4 完成後首頁「寫一篇日記」需由開發中狀態改為可操作。

Diary 前端需抽出並重用 Phase 3 Entry 共用元件與平台 Adapter，包括記錄方式、媒體預覽、心情畫布、分數、分享選擇及 Responsive flow shell；Diary 仍維持獨立的 draft state、Provider、Repository、DTO、review 與完成元件，不得直接耦合 Annoyance 專屬類別或 API。

Entry 共用前端基礎位於 `frontend/lib/models/entry_*.dart`、`frontend/lib/services/entry_media_*.dart` 與 `frontend/lib/widgets/entry/`。共用 Widget 以 `keyPrefix`、標題與語意文案區分 Annoyance／Diary，媒體 Service 以 `recordingFilePrefix` 區分錄音暫存檔；Annoyance 已改為直接使用這些共用元件並保留原測試 key。Diary 後續只能依賴 Entry 共用層，不得匯入 `widgets/annoyance/` 或 Annoyance 媒體型別。

Flutter Web 實作位於 `frontend/lib/pages/diary_chat_page.dart`，並以 `diary_draft.dart`、`diary_chat_provider.dart`、`diary_repository.dart`、`diary_response.dart` 與 `widgets/diary/` 維持 Diary 專屬狀態、API 與確認／完成畫面。`/diaries/new` 已可直接進入；首頁 Desktop／Tablet／Mobile 的 `homeDiaryChatButton` 統一以 `context.pushNamed(AppRoute.diaryChat)` 導向日記聊天室，不再顯示「即將開放」。Web 已驗收 1200、1440、1920px，不得以固定 1440px canvas 取代 Responsive flow。

進入 `/diaries/new` 時先讀取 owner 的伺服器草稿；還原與自動暫存行為沿用煩惱流程。內容按鈕文字使用「暫存並繼續」，並顯示草稿保存 30 天、可跨裝置繼續的狀態。離開頁面不得刪除草稿；明確重新開始才顯示確認並呼叫 DELETE Draft API。送出前完成最後一次同步，改呼叫 `POST /api/diaries/draft/submit`，成功後由後端刪除草稿。

Flutter Mobile 以 `frontend/lib/widgets/diary/diary_mobile_flow.dart` 實作 Penpot 390×844 單欄畫布，並透過 `ResponsiveFixedCanvas` 在 320px 至 599px 等比例填滿 viewport 寬度；縮放後高度超過 viewport 時允許垂直捲動，不得在 391px 至 599px 保留靠左的固定 390px 留白。Mobile 依 `01` 至 `08` 與 `09 Completed / Phase 4` 呈現品牌、步驟、進度、標題、說明、主要操作及完成頁底部導覽。記錄方式、分數與分享選擇在 Mobile 先保存選項，再由明確的下一步按鈕確認；Web／Tablet 保留既有快速選擇行為，三種 window class 仍共用同一份 `DiaryChatState`、Controller、Repository 與 API contract。

Penpot `Diary / Mobile / 02 記錄方式` 的說明已由「可混合使用」校正為「目前先選擇一種主要記錄方式，之後仍可編輯」，與 Project、Database 及 API 規格一致。Mobile 每篇日記仍只允許文字、圖片、錄音或影片其中一種主要記錄方式，並可另外附加一張 optional 心情圖。

媒體 MIME type、大小、長度、private R2、JWT download URL 與 HTTP Range 規則全部沿用新增煩惱規格；每筆日記限一個主要媒體與一張 optional 心情圖。Web 不支援的來源需提供可理解的替代選取方式，不得阻斷文字日記或檔案上傳。

日記分數固定使用 `moodPoint_1.png`～`moodPoint_5.png` 呈現 1 至 5 分，圖片只作輔助，無障礙名稱使用中性分數。Web／Tablet 選擇後直接前進，Mobile 先保留選項再按鈕確認；三種 window class 共用同一個 1-based 整數狀態。Flutter 送出的 multipart `request` 必須直接帶入 1 至 5，不得轉為 0-based index 或傳送 mood lookup ID；0 與 6 等範圍外值不得改變選擇。

Phase 4 完成頁只顯示日記已安全保存、分數與分享狀態；API `reward` 為 `null`，不得顯示舊系統「恭喜你獲得一隻怪獸」、「查看圖鑑」、連續天數禮物或尚未完成的歷史頁導向。日記獎勵於 Phase 6 串接。

Desktop 以共用 Navbar 與 1200px 內容區呈現雙欄流程；Tablet `600px - 1199px` 使用 compact flow；Mobile `< 600px` 依 Mobile Penpot 改為單欄。三種 window class 必須共用同一狀態機與資料層。

### 2.9 歷史記錄頁面

功能：

- 顯示煩惱與日記列表
- 查看詳細內容
- 建立、更新或取消獨立公開快照
- 將煩惱設為已解決
- 顯示煩惱解決動畫
- 前往心的軌跡圖表

### 2.10 心的軌跡頁面

功能：

- 顯示最近 30 個本地日曆日的情緒負荷
- 同日多筆以平均呈現，缺值留白；點擊日期可查看當日原始分數
- 可合併顯示或依 Diary／Annoyance 篩選
- 不顯示診斷、風險警示、自動解讀或情緒好壞判斷

### 2.11 社群頁面

功能：

- 僅成年且具社群資格的已登入會員可進入；未成年人與未登入者不得預覽內容
- 依時間與公開主題瀏覽 Community Post，不提供全文搜尋或熱門排行
- 顯示會員已確認公開的暱稱；可跨貼文辨識，但不得連結 Email、會員 UUID、生日、私人 Profile 或私人頭貼
- 送出或取消單一「支持」，其他讀者不看到公開總數
- 查看與新增單層留言，不提供私訊、追蹤、標記或巢狀回覆
- 檢舉、封鎖、取消分享與申訴入口
- 封鎖後立即隱藏被封鎖會員的貼文與留言；處置紀錄可顯示當時公開暱稱，但不得顯示其帳號、Email、會員 UUID 或私人 Profile
- 敏感媒體預設遮蔽，音訊不自動播放；顯示「檢舉不是緊急求助管道」
- 作者取消分享後整個討論立即不可用；重新分享不恢復舊留言

### 2.12 圖鑑頁面

功能：

- 顯示所有怪獸
- 區分已取得與未取得
- 查看怪獸詳細資料
- 更改怪獸造型
- 查看透明的固定解鎖里程碑與進度
- 從已取得貘怪中選擇私人個人頭貼
- 不顯示抽取、稀有度競爭、代幣、排行榜或連續登入

### 2.13 互動區頁面

入口：

- 自我探索
- 教育小測驗
- 外部資源
- 解答之書或小遊戲只有在完成內容分類與審閱後才顯示

### 2.14 解答之書頁面

功能：

- 使用者心中想著問題
- 點擊取得解答
- 顯示隨機解答

### 2.15 每日測驗頁面

功能：

- 顯示教育題目、來源與適用年齡
- 選擇答案
- 顯示回答正確 / 錯誤頁面
- 完成符合條件的教育互動可累積固定里程碑，不因答錯扣除
- 累積次數不要求連續日期，不建立能力排名

### 2.16 自我探索頁面

功能：

- 顯示題目版本、適用年齡與非醫療說明
- 作答沒有正確／錯誤
- 顯示描述性回饋與固定「不是醫療診斷」聲明
- 結果完全私人，可逐筆刪除，不提供社群分享、結果圖片或人格徽章

### 2.17 外部資源頁面

功能：

- 顯示經允許清單與內容審閱的網站／影片
- 點擊前顯示離站與第三方資料處理提示
- 由使用者主動在外部瀏覽器開啟，不在背景或內嵌頁面自動載入追蹤資源

### 2.18 紓壓方法頁面

功能：

- 顯示紓壓方法列表
- 查看詳細資料

## 三、Responsive Web 規範

Web 版規則：

- 目前 UI 開發與驗收採 Web-first；共用功能仍需支援 Android 與 iOS。
- 共用 breakpoint 固定為 Mobile `< 600px`、Tablet `600px - 1199px`、Desktop `>= 1200px`，由 `frontend/lib/layout/responsive_layout.dart` 集中管理。
- 瀏覽器視窗跨越 breakpoint 時必須即時 reflow，不得要求重新整理或保存舊 viewport 狀態。
- 表單、聊天室與單一內容流程最大內容寬度建議 480px 至 720px。
- 首頁等資訊架構頁在 Tablet 使用 compact flow layout，Desktop 使用 Web 專用雙欄或多欄版型。
- Web 專用版型不得直接放大或置中顯示完整手機畫面。
- 桌面主要內容需設定最大寬度並置中，避免卡片與文字隨視窗無限延伸。
- 不得讓聊天泡泡、卡片與按鈕過度拉伸。
- Tablet／Desktop 主版面使用 `LayoutBuilder`、`Row`、`Column`、`Wrap`、`Expanded`、`Flexible` 與 `ConstrainedBox`；`Stack`／`Positioned` 僅限 Mobile Penpot 精準畫布或元件內局部疊圖。
- RWD widget test 至少覆蓋 390、600、900、1024、1200、1440 與 1920px，並檢查沒有 overflow、裁切、負 padding 或例外。
- Web 不支援的手機功能需提供替代提示。

## 四、共用元件

建議建立：

- `AppScaffold`
- `PrimaryButton`
- `MonsterAvatar`
- `ChatBubble`
- `MoodScoreSelector`
- `MoodDrawingCanvas`
- `CommunityPostCard`
- `MonsterCard`
- `LoadingView`
- `ErrorView`
- `EmptyView`

## 舊系統 UI 參考與調整原則

`system_data/` 內的舊 Flutter 程式僅作為畫面流程、互動方式與視覺語彙參考，不直接沿用舊版頁面、路由、全域狀態或 Widget 實作。新版 UI 仍需依照本專案 Flutter 架構，使用 Riverpod、Dio、go_router 與共用 Widget。

### 舊 UI 參考檢查表

AI 或開發者參考 `system_data/` 舊 UI 時，應檢查以下項目：

- 舊畫面的使用者目的
- 使用者進入此畫面的路徑
- 主要操作按鈕
- 表單欄位
- 驗證邏輯
- 成功狀態
- 錯誤狀態
- 空資料狀態
- Loading 狀態
- 是否有可重用素材
- 是否需改為新版共用元件

可參考：

- 使用者流程
- 畫面資訊層級
- 怪獸視覺語彙
- 互動方式
- 圖片或動畫素材

不得直接沿用：

- 舊 Widget 結構
- 舊 Router 寫法
- 舊全域狀態
- 舊 API 呼叫方式
- 舊硬編碼尺寸
- 舊未抽共用元件的重複 UI

### `system_data/` UI 參考紀錄格式

| 項目 | 說明 |
|---|---|
| 舊系統參考位置 | `system_data/...` |
| 可參考內容 | 使用者流程 / 視覺語彙 / 素材 / 互動方式 |
| 不可沿用內容 | 舊 Widget 結構 / 舊 Router / 舊全域狀態 / 舊 API 呼叫 |
| 新版調整方式 | 依 Riverpod、go_router、共用 Widget 與 Theme 重新設計 |
| 是否需更新正式規格 | 是 / 否 |

可保留的 UI 方向：

| 舊系統觀察 | 新版調整 |
|---|---|
| 暖黃色背景、棕色主色、白色卡片或內容區塊 | 可整理成 `ThemeData` 色票，不在頁面中硬編碼色碼。 |
| 首頁顯示目前怪獸，並提供新增煩惱、歷史紀錄、互動、社群與設定入口 | 新版首頁維持怪獸與主要功能入口，但改用 `AppScaffold`、go_router 與共用導航元件。 |
| 右側 Drawer 提供個人資料、密碼鎖、使用說明、意見回饋、分享 App、登出 | 新版可保留抽屜功能項目，但登入狀態、登出與分享行為需由 Provider 與 Service 管理。 |
| 煩惱與日記採聊天式建立流程，支援文字、圖片、音訊、心情繪圖與怪獸回應 | 新版可保留聊天式體驗，拆成 `ChatBubble`、`MoodScoreSelector`、`MoodDrawingCanvas`、媒體選擇器等共用元件。 |
| 社群頁以分頁或篩選切換煩惱、日記等貼文類型，支援留言與按讚 | 新版社群需以 API 回傳的 `postId` 與分頁資料驅動，避免前端直接組合資料來源。 |
| 歷史紀錄頁提供煩惱、日記與心情軌跡入口 | 新版維持歷史清單與心情軌跡，但需支援空狀態、錯誤狀態與載入狀態。 |
| 怪獸手冊、怪獸詳情、個人怪獸與換裝 | 新版歸入怪獸模組，怪獸素材由 API 或資產設定提供，不直接依賴舊路徑。 |
| 答案書、每日測驗、心理測驗、心理遊戲、舒壓方式 | 新版歸入互動模組，依 `Interactive API` 拆分頁面與資料模型。 |

不得沿用的舊 UI 實作：

- 不使用全域變數保存登入者、目前頁面或流程狀態。
- 不以 `Navigator.push` 分散在頁面中管理主要路由；新版主要路由統一交由 `go_router`。
- 不在頁面內直接呼叫 API 或 SharedPreferences；需透過 Provider、Repository、Service。
- 不在每個頁面硬編碼顏色、字級、圓角與間距；需集中於 Theme 與共用樣式。
- 不保留過長 Page Widget；聊天、卡片、表單、抽屜項目與狀態畫面需拆成可測試共用元件。
- `system_data` 可保留舊系統圖片與動畫素材作為參考；若要正式納入新版資產，仍需另行整理授權、命名與資產規格。

## Flutter Login Page 實作規範

登入頁位置：

- `frontend/lib/pages/login_page.dart`

登入頁目標支援：

- verified Email / 密碼輸入與前端必填驗證
- 呼叫 `POST /api/v1/auth/login`
- Loading 狀態
- API 錯誤訊息呈現
- 登入成功後導向 `home` route
- 前往註冊頁
- 忘記密碼入口提示
- Google 登入：Android / iOS 由 `google_sign_in` 觸發登入，Web 使用 `google_sign_in_web` 官方按鈕

登入頁 Penpot 對齊規格：

- 本次插隊任務僅調整登入頁，不同步修改註冊、首頁或其他已完成頁面。
- Web 參考 Penpot `PAGES WEB / Account & Access / Web` 的 `Account / Web / 02 Login / 登入`：左側品牌區為 `#FFFDD2`，右側表單區為 `#F7F1E8`，左側保留 logo、怪獸圖與歡迎文字，右側表單寬度 500px。
- App / Mobile 參考 Penpot `PAGES APP / Account & Access / Mobile` 的 `Account / Mobile / 02 Login / 登入`：390x844 畫板、左右 36px 邊距、logo 150x46、欄位與按鈕寬 318px、高 54px。
- 登入頁色票集中於 `frontend/lib/theme/app_colors.dart`，頁面不得直接宣告 `Color(0x...)` 作為設計色票。
- 登入頁圖片使用 `frontend/assets/images/title.png` 作為 logo、`frontend/assets/images/icon.png` 作為 Web 品牌區怪獸圖；Flutter asset 以 `assets/images/` 目錄註冊。
登入頁資料流程：

```text
LoginPage
↓
AuthController
↓
AuthRepository
↓
ApiClient
↓
REST API
```

實作檔案：

| 類型 | 檔案 |
|---|---|
| Page | `frontend/lib/pages/login_page.dart` |
| Provider | `frontend/lib/providers/auth_provider.dart` |
| Repository | `frontend/lib/repositories/auth_repository.dart` |
| Google Sign-In Service | `frontend/lib/services/google_sign_in_service.dart` |
| Web Google Sign-In Button | `frontend/lib/widgets/auth/google_sign_in_web_button.dart` |
| Session Store | `frontend/lib/repositories/auth_session_store.dart` |
| Model | `frontend/lib/models/auth_user.dart`、`frontend/lib/models/auth_user.g.dart`、`frontend/lib/models/login_result.dart`、`frontend/lib/models/login_result.g.dart` |

規則：

- 登入識別欄位顯示「Email」；不得再接受或顯示 `account`。
- 登入頁不得直接呼叫 Dio。
- 登入頁不得直接保存 JWT、Refresh Token 或密碼至 SharedPreferences；登入狀態保存必須集中由 `AuthRepository` 與 `AuthSessionStore` 管理。
- `AUTH_CONTINUATION_REQUIRED` 不視為已登入；`LoginPage` 不導向首頁，`AuthRepository` 不設定 Authorization、不保存 continuation credential，並清除可能殘留的一般 Session。
- `nextAction` 只用於選擇 Email 驗證、資格、帳號恢復、停權處理或刪除處理畫面；第一個對應流程尚未完成時顯示安全提示，不顯示 credential。
- `AuthSessionStore` 必須改為平台 `SessionCredentialStore`：Web Refresh Cookie 由 Backend 管理，App Refresh Token 進 Keychain／Keystore；Access Token 只放記憶體，不得序列化完整 `LoginResult`。
- App 啟動時由 `SplashPage` 透過 `AuthController.restoreSession()` 判斷登入狀態；若本地 session 有效，必須先以 refresh token 換發新 Token、覆蓋舊 session，再套用新 access token 並導向 `home` route。
- 受保護 API 回傳 401 時，並行 request 必須共用單一 refresh request；換發成功後每個原 request 最多重試一次，refresh request 本身不得遞迴重試。
- 若 refresh token 無效／過期／已 rotation／reuse、session 到達 idle／absolute expiry 或使用者登出，必須清除 Credential Store 並導向登入頁；暫時性網路錯誤只顯示連線錯誤，不得誤撤銷 server session。
- 登出需呼叫 `AuthController.logout()`，由 Repository 呼叫登出 API、清除 `ApiClient` Authorization header 與本地 session。
- 密碼、Token、完整 Login Result 與私人會員資料不得保存至 SharedPreferences。
- Google 登入不得假造 Google ID Token、不得沿用舊系統空密碼登入流程、不得在前端自行驗證後傳入 Google 使用者資料。
- Google 登入成功後需呼叫 `POST /api/auth/google-login`，由後端驗證 Google ID Token 並回傳本系統 `LoginResult`。
- Web 版需使用 Google Identity Services 官方按鈕；Android / iOS 可使用共用 Flutter 按鈕觸發 Google SDK。
- Web 版 Google SDK 初始化只傳 `GOOGLE_CLIENT_ID`，不得傳 `serverClientId`，避免官方按鈕停留在 `Getting ready` 狀態。
- Web 本機測試需使用固定 origin `http://localhost:5050`，並透過 `frontend/tool/run_web_local.sh` 或 Windows `frontend/tool/run_web_local.ps1` 啟動，避免每次重啟隨機 port 造成 Google OAuth origin mismatch。
- Google 登入成功後使用相同 server session 與 `SessionCredentialStore`；同 Email 既有會員必須先明確連結，登出時撤銷 server session、清除本機 Credential 並嘗試執行 Google SDK sign-out。

## Flutter Register Page 實作規範

註冊頁位置：

- `frontend/lib/pages/register_page.dart`

註冊頁支援：

- Email 輸入與格式驗證
- 初始註冊不收暱稱；Email 驗證後的 Eligibility 流程才收 2–30 Unicode公開暱稱
- 15 至 128 Unicode 密碼輸入、確認與弱密碼錯誤提示
- 呼叫 `POST /api/v1/auth/register`
- Loading 狀態
- API 錯誤訊息呈現
- 註冊成功後進入 Email 驗證等待頁
- 前往登入頁

註冊頁 Penpot 對齊規格：

- 本次插隊任務僅調整註冊頁，延續 `Account & Access` 登入頁已建立的 Web / Mobile 排版語彙。
- Web 版使用左側品牌區與右側表單區；品牌區使用 `title.png` 與 `icon.png`，表單最大寬度 500px。
- App / Mobile 版以 390px 寬畫面為基準，左右 36px 邊距，logo 150px，欄位與主要按鈕高 54px。
- 註冊頁色票集中於 `frontend/lib/theme/app_colors.dart`，頁面不得直接宣告 `Color(0x...)` 作為設計色票。
- 註冊成功不進入完整 App；完成 Email 驗證、服務地區、生日與必要同意後才可進入私人核心。
註冊頁資料流程：

```text
RegisterPage
↓
AuthController
↓
AuthRepository
↓
ApiClient
↓
REST API
```

實作檔案：

| 類型 | 檔案 |
|---|---|
| Page | `frontend/lib/pages/register_page.dart` |
| Provider | `frontend/lib/providers/auth_provider.dart` |
| Repository | `frontend/lib/repositories/auth_repository.dart` |
| Model | `frontend/lib/models/register_result.dart` |

規則：

- 註冊頁不得直接呼叫 Dio。
- 註冊頁不得保存密碼或 token 至 SharedPreferences。
- 註冊頁不得顯示或傳送 `account`。
- 註冊後顯示重新寄送驗證信、修正 Email 與刪除未完成帳號入口。
- 13 至 17 歲使用者完成 Email 驗證後仍處於 `PENDING_ELIGIBILITY`，以 `nextAction` 進入監護人同意等待頁；未滿 13 歲或非台灣服務地區不得進入 App。
## Flutter Profile Page 實作規範

個人資料頁位置：

- `frontend/lib/pages/profile_page.dart`

個人資料頁支援：

- 呼叫 `GET /api/users/me` 查詢目前登入使用者個人資料
- 顯示已取得貘怪頭貼、公開暱稱、Email、服務地區、生日與資格狀態，不顯示 `account`
- 修改公開暱稱；Email 使用獨立 reauth＋驗證流程。首次社群公開前需預覽並確認暱稱，修改後既有社群內容顯示新暱稱
- 從已取得圖鑑選擇頭貼，不提供圖片上傳
- 生日完成資格確認後鎖定；更正需走 reauth 與人工申請
- 生日欄位為唯讀文字輸入外觀，點擊後開啟 Flutter 內建日曆；不得要求使用者手動輸入日期格式
- 呼叫 `PUT /api/users/me` 儲存個人資料
- 顯示可見的登出按鈕；點擊後先顯示確認對話框，再由 `AuthController.logout()` 完成登出並導向登入頁
- Loading 狀態
- API 錯誤訊息與重試
- 儲存成功提示
- 從首頁進入個人資料頁

個人資料頁資料流程：

```text
ProfilePage
↓
UserProfileController
↓
UserRepository
↓
ApiClient
↓
REST API
```

實作檔案：

| 類型 | 檔案 |
|---|---|
| Page | `frontend/lib/pages/profile_page.dart` |
| Provider | `frontend/lib/providers/user_profile_provider.dart` |
| Repository | `frontend/lib/repositories/user_repository.dart` |
| Model | `frontend/lib/models/user_profile.dart`、`frontend/lib/models/user_profile.g.dart` |

規則：

- 個人資料頁不得直接呼叫 Dio。
- 個人資料頁不得由前端傳入 user id、account 或 owner 進行查詢或修改。
- `userName` 必填，最大長度 80。
- 完成年齡資格後 `birthday` 不可為空，API 格式為 `yyyy-MM-dd`。
- 頭貼只能傳已取得的 monster public ID；不得啟動相機、相簿或上傳流程。
## Flutter Password Lock Page 實作規範

本節現有 server PIN 實作為待移除基線。目標頁面只管理 Android／iOS 本機 Privacy Lock；Web route 應改為閒置重新驗證設定。

密碼鎖頁位置：

- `frontend/lib/pages/password_lock_page.dart`

密碼鎖頁支援：

- 設定或更改四位數密碼鎖
- 透過平台 Local Privacy Lock Adapter 將 PIN 保存於 Keychain／Keystore
- 冷啟動與離開超過設定時間時離線驗證四位數 PIN
- 前端 4 位數字格式驗證
- 設定時需再次輸入確認
- Loading 狀態
- API 錯誤訊息呈現
- 設定成功與驗證成功提示
- 從首頁進入密碼鎖頁

密碼鎖頁資料流程：

```text
PasswordLockPage
↓
LocalPrivacyLockController
↓
Platform Secure Storage Adapter
```

實作檔案：

| 類型 | 檔案 |
|---|---|
| Page | `frontend/lib/pages/password_lock_page.dart` |
| Provider | `frontend/lib/providers/password_lock_provider.dart`（待改為 Local Controller） |
| Adapter | 平台 Keychain／Keystore Local Privacy Lock Adapter |
| Reauth | 忘記 PIN 時呼叫用途受限的 Account Reauthentication API |

規則：

- 密碼鎖頁不得直接呼叫 Dio。
- 密碼鎖頁不得傳送 PIN、user id 或 account 至 Backend。
- 密碼鎖固定為 4 位數字。
- PIN 只能保存於平台安全儲存區，不得保存於 SharedPreferences、一般 Database、一般檔案或 Backend。
- 忘記 PIN 必須先完成帳號 reauth，再清除並重設該裝置 PIN；Backend 永遠不回傳或替換原 PIN。
## Flutter Router 基礎規範

前端路由統一使用 go_router，入口必須使用 `MaterialApp.router`。

路由設定位置：

- `frontend/lib/routes/app_router.dart`
- `frontend/lib/routes/app_routes.dart`

目前基礎路由：

| Path | Name | Page | 用途 |
|---|---|---|---|
| `/` | `splash` | `SplashPage` | App 初始頁 |
| `/home` | `home` | `HomePage` | 首頁容器 |
| `/login` | `login` | `LoginPage` | 登入頁容器 |
| `/register` | `register` | `RegisterPage` | 註冊頁容器 |
| `/profile` | `profile` | `ProfilePage` | 個人資料頁容器 |
| `/password-lock` | `passwordLock` | `PasswordLockPage` | 密碼鎖頁容器 |

頁面不得直接使用 `Navigator.push`。頁面切換應使用 go_router 的 `context.goNamed()` 或集中路由設定。
## Flutter Theme 基礎規範

前端視覺樣式統一使用 `ThemeData`，入口由 `MaterialApp.router` 套用 light / dark theme 與 `ThemeMode.system`。

Theme 設定位置：

- `frontend/lib/theme/app_theme.dart`
- `frontend/lib/theme/app_colors.dart`
- `frontend/lib/theme/app_spacing.dart`

目前 Theme 規範：

| 類別 | 檔案 | 用途 |
|---|---|---|
| AppTheme | `app_theme.dart` | 建立 light / dark `ThemeData` |
| AppColors | `app_colors.dart` | 集中管理色票與 seed color |
| AppSpacing / AppRadius | `app_spacing.dart` | 集中管理間距與圓角 token |

Theme 色票需承接舊版暖黃色與棕色視覺語彙：

| Token | 色值 | 舊版來源 |
|---|---|---|
| `legacyBackgroundLight` / `lightBackground` | `#FFFED4` | `BackgroundColorLight` |
| `legacyBackgroundSoft` | `#FFED97` | `BackgroundColorSoft` |
| `legacyWarm` / `seed` | `#A0522D` | `BackgroundColorWarm` |
| `legacyWarmOpacity` | `#E6A0522D` | `BackgroundColorWarmOpacity` |

頁面不得自行 hard code 共用顏色、字體、圓角與間距；應優先使用 `Theme.of(context)` 與 theme token。
## Flutter App Icon / Logo 資產規範

三平台 App Icon 以根目錄 `icon/icon.png` 作為正式來源素材，產生 Android、iOS 與 Web 所需尺寸。品牌 Logo 以根目錄 `icon/標題.png` 作為正式來源素材，匯入 Flutter asset 後用於啟動畫面、登入頁與註冊頁。

App Icon 規範：

| 平台 | 產出位置 | 規範 |
|---|---|---|
| Android | `frontend/android/app/src/main/res/mipmap-*/ic_launcher.png` | 需替換所有 mipmap density 預設 Flutter 圖示 |
| iOS | `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png` | 需替換全部 `Contents.json` 宣告尺寸，1024 icon 不得含透明背景 |
| Web | `frontend/web/favicon.png`、`frontend/web/icons/*.png`、`frontend/web/manifest.json` | 需替換 favicon、PWA icon、maskable icon，manifest theme/background color 需對齊舊版暖黃色與棕色 |

Logo 規範：

| 用途 | 路徑 | 規則 |
|---|---|---|
| Flutter asset logo | `frontend/assets/images/app_logo.png` | 來源為 `icon/標題.png`，用於品牌露出頁面 |
| Flutter asset icon | `frontend/assets/images/app_icon.png` | 來源為 `icon/icon.png`，保留 1024px square 版本供 Flutter UI 或後續工具重用 |
| 啟動畫面 | `frontend/lib/pages/splash_page.dart` | 需顯示品牌 logo |
| 登入頁 | `frontend/lib/pages/login_page.dart` | 需顯示品牌 logo |
| 註冊頁 | `frontend/lib/pages/register_page.dart` | 需顯示品牌 logo |

產圖原則：

- 背景使用舊版主要背景色 `#FFFED4`。
- 主圖置中並保留安全邊界，避免 Android / iOS / Web 安裝圖示裁切主視覺。
- 不得保留 Flutter 預設藍色 icon 或 manifest theme color。
- 若來源圖尺寸不足或比例不適合，需重新產生可用平台圖示並於 Log 紀錄。
## Flutter Common State Widgets

前端共用狀態元件位置：

- `frontend/lib/widgets/state/loading_view.dart`
- `frontend/lib/widgets/state/error_view.dart`
- `frontend/lib/widgets/state/empty_view.dart`

共用狀態元件：

| Widget | 用途 | 規範 |
|---|---|---|
| LoadingView | 資料載入中 | 顯示 progress indicator 與可選文字 |
| ErrorView | 錯誤狀態 | 顯示錯誤標題、訊息與可選重試按鈕 |
| EmptyView | 空資料狀態 | 顯示空狀態標題、訊息與可選操作按鈕 |

狀態元件只負責 UI 呈現，不得直接呼叫 API、Repository 或 Service。

頁面應將資料狀態轉換為：

- loading：使用 `LoadingView`
- error：使用 `ErrorView`
- empty：使用 `EmptyView`
- data：顯示實際內容

狀態元件必須使用 `Theme.of(context)` 與 `AppSpacing` / `AppRadius`，不得 hard code 共用顏色、間距或圓角。

---

## 2026-07-16 Penpot Web Register Alignment

本次依 Penpot MCP 目前選取 board `Account / Web / 03 Register / 註冊` 修正 Web 註冊頁。

### Penpot Board

| 項目 | 規格 |
|---|---|
| Board | 1440 x 900 |
| Brand panel | x=0, y=0, w=620, h=900, `#FFFDD2` |
| Form area | x=620, y=0, w=820, h=900, `#F7F1E8` |
| Logo | x=54, y=42, w=160, h=50, `assets/images/title.png` |
| Monster | x=130, y=208, w=360, h=360, `assets/images/icon.png` |
| Form left | x=756 |
| Form width | 520 |
| Back link | x=756, y=46, text `‹  返回登入` |
| Heading | x=756, y=96, text `建立新帳號` |
| Subheading | x=756, y=138, text `註冊完成後，請使用新帳號登入。` |
| Fields | x=756, w=520, h=56; y=220 / 312 / 404 / 496 / 588 |
| Rule card | x=756, y=662, w=520, h=64, `#FFFDFC` |
| Submit button | x=756, y=758, w=520, h=56, text `完成註冊` |

### Implementation Notes

- Web 註冊頁維持 Flutter `RegisterPage -> AuthController -> AuthRepository -> ApiClient -> REST API` 流程。
- Web 版使用 620px brand panel 與 520px 表單寬度，在 1440px viewport 對齊 Penpot 座標。
- 顏色 token 必須集中於 `frontend/lib/theme/app_colors.dart`，Page 不得直接新增硬編碼 `Color(0x...)`。
- Mobile 註冊頁不屬於本次 Web 精準修正範圍，僅沿用共用文字與驗證邏輯。
---

## 2026-07-16 Penpot SplashPage Web / App Alignment

本次依 Penpot MCP 讀取 `Account & Access / Web` 與 `Account & Access / Mobile` 的 Splash 畫板，更新 Flutter `SplashPage` 的 Web / App responsive layout。

### Penpot Boards

| Target | Board | Size | Background |
|---|---|---:|---|
| Web | `Account / Web / 01 Splash / 啟動` | 1440 x 900 | `#FFFDD2` |
| App / Mobile | `Account / Mobile / 01 Splash / 啟動` | 390 x 844 | `#FFFDD2` |

### Web Layout

| Element | Position / Size | Note |
|---|---|---|
| Logo | x=570, y=120, w=300, h=92 | `assets/images/app_logo.png` |
| Halo | x=555, y=270, w=330, h=330 | `AppColors.splashHalo` |
| Monster | x=610, y=318, w=220, h=220 | `assets/images/icon.png` |
| Quote | x=500, y=642, w=390, h=36 | `把心裡的重量，先放在這裡。` |
| Status card | x=550, y=724, w=340, h=74 | 顯示登入狀態檢查與 30 天保存提示 |

### App / Mobile Layout

| Element | Position / Size | Note |
|---|---|---|
| Logo | x=92, y=94, w=206, h=64 | `assets/images/app_logo.png` |
| Monster | x=78, y=224, w=234, h=234 | `assets/images/icon.png` |
| Quote | x=68, y=496, w=270, h=24 | `把心裡的重量，先放在這裡。` |
| Status card | x=54, y=586, w=282, h=82 | 顯示登入狀態檢查與 30 天保存提示 |
| Brand note | x=79, y=774, w=162, h=15 | `貘nsters · 陪你整理每一種心情` |

### Implementation Notes

- `SplashPage` 保留 `AuthController.restoreSession()` 流程；有效 session 導向 `home`，無效 session 顯示登入 / 註冊行動。
- Splash 顏色集中於 `frontend/lib/theme/app_colors.dart` 的 `splash*` token，page 不直接宣告色碼。
- Mobile 尺寸以 `_SplashSpec` 記錄 390 x 844 Penpot 座標；Tablet／Desktop 改用置中的 flow layout，不縮放完整 1440 x 900 canvas。
- Splash 導向仍使用 `go_router` 的 `context.goNamed()`；Flutter 不直接存取 Database 或 Auth storage。
### 2026-07-16 SplashPage Redirect Update

- `SplashPage` 僅在 `AuthController.restoreSession()` 檢查期間顯示 Penpot Splash 畫面。
- 若 session 有效，導向 `home` route。
- 若 session 無效、過期或格式錯誤，直接導向 `login` route，不在 Splash 畫面顯示登入 / 註冊按鈕。
- 此行為讓 Splash Web / App 畫面與 Penpot 靜態畫板一致；登入與註冊行動由 LoginPage / RegisterPage 負責。
### 2026-07-16 SplashPage Exact Penpot Correction

- SplashPage Web / Mobile 文字對齊依 Penpot 設為 left，不再使用 center。
- Logo image fill 依 Penpot rectangle fill 呈現，Flutter 改用 `BoxFit.fill`；Monster 保持 `BoxFit.contain`。
- Status card 依 Penpot 移除圓角，維持 `#FFFDFC` fill 與 `#E7C7B5` stroke。
- Status dot、status text、status hint 改為絕對座標定位：
  - Web：dot `(576,753) 16x16`、text `(610,746) 123x17`、hint `(610,770) 118x14`。
  - Mobile：dot `(76,614) 16x16`、text `(108,608) 123x17`、hint `(108,634) 118x14`。
- Widget test 已新增上述內部元素座標驗證，避免再次只檢查外層 card 而漏掉 Penpot 差異。
---

## 2026-07-16 Penpot HomePage Web / App Alignment

本次依 Penpot MCP 讀取 `Web / Companion Home` 與 `Mobile / Companion Home`，重寫 Flutter `HomePage` 的 Web / App responsive layout。

### Penpot Boards

| Target | Board | Size | Background |
|---|---|---:|---|
| Web | `Web / Companion Home` | 1440 x 900 | `#FFFED4` |
| App / Mobile | `Mobile / Companion Home` | 390 x 844 | `#FFFED4` |

### Web Layout

| Element | Relative Layout | Note |
|---|---|---|
| Page shell | `Column` with fixed-height top nav and flexible content area | Web does not use fixed 1440 x 900 canvas scaling |
| Content width | centered `ConstrainedBox`, max width 1200 | horizontal padding derived from viewport width |
| Header | vertical `Column` | title and subtitle use natural text flow |
| Main content | `Row` with flex 19:10 | left companion / collection column, right action column |
| Companion hero | responsive `Row` inside hero panel | monster and greeting card share available width proportionally |
| Action cards | `Column` with responsive gaps | primary / diary / history / interaction use reusable tile widget |
| Collection panel | `Column` + `Row` chips | chip spacing is based on layout flow, not absolute x/y offsets |
| Navbar | `Row` with `Spacer` | menu, CTA, notification and profile buttons align by flex flow |
### App / Mobile Layout

| Element | Position / Size | Note |
|---|---|---|
| App bar | x=0, y=0, w=390, h=72 | white |
| Logo | x=20, y=12, w=96, h=48 | `assets/images/app_logo.png` |
| Notification button | x=338, y=18, w=38, h=38 | 顯示通知；功能未完成前提供「即將開放」回饋 |
| Companion hero | x=16, y=92, w=358, h=294 | `#D9F1F2` |
| Monster | x=119, y=102, w=152, h=152 | animated monster key preserved |
| Greeting card | x=40, y=250, w=310, h=118 | white card |
| Collection panel | x=16, y=402, w=358, h=118 | monster collection summary |
| Primary action | x=16, y=536, w=358, h=54 | routes to `annoyanceChat` |
| Quick actions | x=16 / 138 / 260, y=606, w=114, h=104 | diary / history / interaction |
| Bottom navigation | x=0, y=774, w=390, h=70 | custom Penpot nav, not Material NavigationBar |

### Implementation Notes

- `HomePage` Web 版改為 `LayoutBuilder + Column / Row / Expanded / ConstrainedBox` 的相對 layout；Mobile 版仍保留 390 x 844 Penpot canvas。
- Home 色彩集中於 `frontend/lib/theme/app_colors.dart` 的 `home*` token，page 不直接宣告色碼。
- 主要行動 `homeAnnoyanceChatButton` 使用 `context.pushNamed(AppRoute.annoyanceChat)`，讓明確返回按鈕保留上一頁。
- 日記行動 `homeDiaryChatButton` 在 Desktop／Tablet／Mobile 使用 `context.pushNamed(AppRoute.diaryChat)`，導向 `/diaries/new` 並保留首頁於返回堆疊。
- Mobile 右上角通知按鈕不再重複提供個人資料入口；底部 `mobileNavProfile` 導向 `profile`。
- 尚未開放的 history / collection / community / interaction 入口顯示具名的「即將開放」訊息。
- `homeAnimatedMonster`、`homeAnimatedMonsterIdle`、`homeAnimatedMonsterReacting` 測試 key 保留，降低既有測試與互動行為破壞。
---

## 2026-07-16 Penpot ProfilePage Web / App Alignment

本次依 Penpot `Account / Web / 06 Profile / 個人資料` 與 `Account / Mobile / 06 Profile / 個人資料` 調整 Flutter `ProfilePage`，並保留既有 `UserProfileController -> UserRepository -> ApiClient -> REST API` 流程。

### Penpot Boards

| Target | Board | Size | Background |
|---|---|---:|---|
| Web | `Account / Web / 06 Profile / 個人資料` | 1440 x 900 | `#F7F1E8` |
| App / Mobile | `Account / Mobile / 06 Profile / 個人資料` | 390 x 844 | `#FFFDD2` |

### Implementation Notes

- Profile Mobile 採 390 x 844 Penpot canvas；Tablet／Desktop 使用 scrollable flow layout，不使用整頁 `Stack + FittedBox`。
- Profile、Home 的 Tablet／Desktop 根節點必須使用 stretch／滿寬 constraint，背景、App bar 與底部導覽不得只停在 674px 固定內容寬度而留下右側空白。
- Web 保留上方導覽列、資料卡、avatar、基本資料欄位、唯讀 Email / 帳號欄位與儲存狀態卡，欄位依可用寬度切換單欄／雙欄。
- Mobile 保留 390x844 Profile canvas、App bar、avatar、暱稱 / Email / 帳號 / 生日欄位、登出入口、儲存狀態卡與底部導覽列。
- 生日欄位使用內建日曆並維持 `profileBirthdayField` key；可編輯欄位、儲存與登出分別維持 `profileUserNameField`、`profileSaveButton`、`profileLogoutButton` 測試 key 與既有驗證規則。
- Profile 顏色 token 集中於 `frontend/lib/theme/app_colors.dart` 的 `profile*` token，Page 不直接宣告色碼。
- Penpot canvas widgets 拆至 `frontend/lib/widgets/profile/profile_penpot_canvas.dart`，`ProfilePage` 僅保留狀態、驗證與提交流程。

## 2026-07-18 Profile Calendar／Logout 與 Annoyance Penpot Sync

- Penpot `Profile & Settings / Web / 01 個人首頁`、`02 編輯個人資料` 與 Mobile 對應畫板已加入登出入口及生日日曆欄位；既有 Web／Mobile 登出確認畫板沿用。
- Annoyance 使用 Penpot `Annoyance Flow / Web` 與 `Annoyance Flow / Mobile` 的導覽、進度、陪伴訊息、操作面板、色票與間距；Flutter 狀態機與 API contract 不變。
- Annoyance Mobile `< 600px` 使用單欄；Tablet `600px - 1199px` 使用堆疊 flow；Desktop `>= 1200px` 使用左側陪伴區與右側操作區雙欄，根節點一律填滿 viewport 寬度。
- 測試 viewport 覆蓋 390、600、900、1024、1199、1440 與 1920px，檢查滿寬 shell、主要進度／操作區存在且沒有 overflow 或例外。
- Penpot 雖包含獎勵延伸畫板，本次依 Phase 3 正式規格只同步建立完成狀態，不提前實作怪獸獎勵。

## 2026-07-16 HomePage Full-Bleed Correction（已由 2026-07-18 RWD 規格取代）

- `HomePage` 仍使用 `WEB / Web / Companion Home` 與 `Mobile / Companion Home` 規格。
- 此段保留歷史紀錄；目前僅 Mobile 保留 Penpot canvas，Tablet／Desktop 已改為 flow layout，不再以 `BoxFit.cover` 縮放整張 Web canvas。
## 2026-07-16 HomePage Web Companion Home Refinement

- 本次以 Penpot MCP 選取的 `WEB / Web / Companion Home` 為準，修正 Web HomePage 不應套用舊版 `Web / Companion Home` 近似版型的問題。
- Web HomePage 改為相對 layout：內容最大寬度、水平 padding、區塊 gap 由 viewport 推導，避免使用固定 x/y 座標排列。
- Web 版新增 Penpot navbar、右上 CTA、通知圓鈕與 profile 圓鈕；profile 入口導向 `profile` route，尚未開放入口維持 snackbar placeholder。
- Web collection panel 改為 flow layout，保留 7 個怪獸 chip 與 `+1` more chip。
- 本次僅調整 Web HomePage；Mobile HomePage 規格與座標未變更。

## 2026-07-18 Web-first RWD 共用版型

目前已完成 Penpot 畫面與定位方式盤點，Splash、Login、Register、Home、Profile 均已實作 Mobile／Tablet／Desktop 分級。Mobile 保留 390 x 844 Penpot 精準畫布；Tablet／Desktop 以相對 flow layout 實作，瀏覽器調整視窗寬度時可即時切換。

| Page | Mobile `< 600px` | Tablet `600px - 1199px` | Desktop `>= 1200px` |
|---|---|---|---|
| Splash | Penpot fixed canvas | centered flow | centered flow |
| Login | mobile form flow | compact centered form | Penpot brand／form split flow |
| Register | mobile form flow | compact centered form | Penpot brand／form split flow |
| Home | Penpot fixed canvas | compact companion flow | bounded multi-column flow |
| Profile | Penpot fixed canvas | single-column profile flow | bounded one／two-column profile flow |

實作規則：

- `ResponsiveLayout` 依 `LayoutBuilder` constraints 即時判斷 window class，不快取初次 viewport。
- `ResponsiveContent` 集中管理最大寬度、水平 padding 與對齊方式。
- 390 x 844 Mobile Penpot canvas 必須透過 `ResponsiveFixedCanvas` 依實際 viewport 寬度等比例縮放；391 至 599px 不得維持 390px 固定寬度靠左，縮放後高度超過 viewport 時改為垂直捲動。
- Web 主版面不使用整頁 `FittedBox`、固定 1440 x 900 canvas 或固定 x/y 座標。
- Home 在舊 breakpoint 900／950／1024px 曾發生的負 padding 與 nav overflow，已由 Tablet flow layout 排除。
- Widget tests 覆蓋 breakpoint 邊界與 390 至 1920px 常用 viewport，並驗證同一 widget tree 可在 599／600／1199／1200px 即時切換。

## 2026-07-18 共用導覽與頁面切換規格

### Desktop Navbar（`>= 1200px`）

- Home、Profile、Annoyance 必須共用 `AppTopNavigation`，不得各頁複製 Navbar。
- 固定選項依序為 Logo／陪伴首頁、心的軌跡、怪獸收藏、暱稱社群、互動區、記下現在的心情、通知、個人資料。
- 已完成入口使用正式 route；尚未完成入口顯示具名「即將開放」，不得建立空白頁或假 route。
- Navbar 使用 `Row`、`Spacer` 與 viewport 衍生間距；1200 至 1920px 不得 overflow 或留下固定畫布空白。
- Profile 的儲存與登出為頁面操作，放在共用 Navbar 下方的 Profile action bar，不混入全站導覽設定。
- Profile action bar 底色使用 `profileActionBackground`，色值與 Annoyance 進度列的 `annoyanceBrandBackground` 同為 `#FFFDD2`。

### Mobile Navigation（`< 600px`）

- Home 與 Profile 共用 `MobileAppBottomNavigation`，選項固定為首頁、社群、怪獸、互動、我的。
- 首頁與「我的」為正式 route；其餘未完成項目顯示「即將開放」。
- 首頁右上角只顯示通知，不再重複提供個人資料入口；個人資料一律由底部「我的」進入。

### Page Transition

- 所有一般前進、登入結果、Navbar 與底部選單切換使用零秒進場動畫，直接呈現目的頁。
- Home 進入 Profile／Annoyance、Login 進入 Register 使用 push 保留 navigation stack。
- 明確的返回按鈕優先 pop；返回動畫為 220ms，當前頁面向右退出。若沒有上一頁，才直接導回預設頁。
