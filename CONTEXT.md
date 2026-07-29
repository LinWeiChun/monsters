# 貘nsters Domain Context

貘nsters 是面向台灣使用者的非醫療情緒記錄與自我照顧產品。本文件只定義專案共同語言；需求、介面與技術細節分別以 `docs/` 內正式規格為準。

## 產品與身分

**會員（Member）**：
已建立貘nsters 使用者身分的人；會員以驗證過的登入方式存取自己的資料。
_Avoid_: 病患、個案、帳號名稱

**會員狀態（Member State）**：
描述會員身分生命週期的七態狀態機；它不包含社群資格或社群限制。
_Avoid_: 角色、社群資格、單一刪除旗標

**延續憑證（Continuation Credential）**：
憑證正確但會員尚須完成 Email 驗證、資格、恢復、停權處理或刪除流程時核發的短效用途受限憑證；它不是一般 Session，也不能存取會員 API。
_Avoid_: Access Token、Refresh Token、登入 Session

**未成年會員（Minor Member）**：
年滿 13 歲但未滿 18 歲，且必須取得監護人同意才能使用私人核心功能的會員。
_Avoid_: 兒童使用者、一般成年會員

**監護人同意（Guardian Consent）**：
監護人針對特定版本兒少條款作出的可撤回同意；它不授予監護人查看會員內容的權限。
_Avoid_: 家長帳號、內容監看權

**社群資格（Community Eligibility）**：
成年、已完成必要同意且未受社群限制的會員所具有的社群使用資格。
_Avoid_: 角色、會員等級

**特權角色（Privileged Role）**：
Moderator、Admin 或 Content Reviewer 等具有受限後台職責的角色；任何特權角色都不能查看私人內容。
_Avoid_: 超級使用者、私人資料管理員

**公開暱稱（Public Nickname）**：
會員在私人介面與封閉社群共同使用、可跨貼文辨識但不具唯一性的顯示名稱；它不能用於登入、owner 判斷或取得私人 Profile。
_Avoid_: 帳號、匿名代號、會員 ID

## 私人記錄

**紀錄（Entry）**：
會員擁有的一筆私人日記或煩惱，是文字、媒體、情緒負荷與生命週期的共同核心。
_Avoid_: 社群文章、心理檔案

**日記（Diary）**：
以自由記錄與回顧為目的的 Entry 使用情境。
_Avoid_: 公開貼文

**煩惱（Annoyance）**：
以引導式流程記錄當下困擾的 Entry 使用情境。
_Avoid_: 症狀、診斷

**情緒負荷（Emotional Load）**：
會員自願填寫的 1 至 5 分主觀感受，1 代表較輕、5 代表較重。
_Avoid_: 快樂分數、心理健康分數、疾病嚴重度

**情緒足跡（Emotional Trace）**：
以 Entry 當時本地日期整理的最近 30 日情緒負荷趨勢。
_Avoid_: 心理評估、風險預測

**私人分類（Private Category）**：
會員自行選擇、只供本人整理 Entry 的選填分類。
_Avoid_: 自動標籤、公開主題

## 分享與社群

**公開快照（Community Post）**：
會員逐項確認後，從 Entry 發布到封閉暱稱社群的獨立內容版本。
_Avoid_: Entry 分享旗標、同步副本

**公開主題（Public Topic）**：
會員為 Community Post 另行選擇的社群分類，不等同於 Private Category。
_Avoid_: 私人分類

**取消分享（Unshare）**：
立即停止 Community Post 及其討論公開可見，並開始公開資料清除生命週期。
_Avoid_: 刪除私人原文

**暱稱社群（Nickname Community）**：
只對具 Community Eligibility 的會員開放、以公開暱稱形成可辨識身分且平台內部可問責的封閉空間；不公開 Email、會員 UUID 或私人 Profile。
_Avoid_: 匿名社群、公開論壇、真實姓名社群、無法追責的匿名網路

**支持（Support Reaction）**：
不公開人氣總數、沒有負向評分的單一正向社群反應。
_Avoid_: 按讚排行、人氣分數

**社群限制（Community Restriction）**：
只限制分享、留言等社群能力，不剝奪會員存取、匯出或刪除私人資料的權利。
_Avoid_: 帳號全面停權

## 內容與陪伴

**自我探索（Self Exploration）**：
沒有正確答案、只提供描述性回饋且結果完全私人的內容活動。
_Avoid_: 深度心理測驗、診斷測驗

**教育小測驗（Educational Quiz）**：
具有可驗證答案、說明、來源與適用年齡的一般知識內容。
_Avoid_: 自我探索、心理診斷

**外部資源（External Resource）**：
經允許清單與內容審閱後，由會員主動離開貘nsters 開啟的網站或影片。
_Avoid_: 內嵌追蹤內容

**貘怪回應（Monster Response）**：
不讀取私人內容或情緒負荷、由已審閱固定內容庫選出的陪伴文案。
_Avoid_: AI 分析、心理建議

**解鎖里程碑（Unlock Milestone）**：
以透明且固定的自我照顧行動進度取得貘怪或造型的條件。
_Avoid_: 隨機抽取、連續登入獎勵

## 資料權利

**刪除申請（Deletion Request）**：
會員經重新驗證後提出、具有七天取消期的帳號永久清除流程。
_Avoid_: 一般登出、社群停權

**資料匯出（Data Export）**：
會員經重新驗證後取得自己資料與原始媒體的可攜副本。
_Avoid_: 管理員備份、客服附件

**法律保全（Legal Hold）**：
只在正式且具拘束力要求下，對明確範圍資料實施的隔離、限期保存例外。
_Avoid_: 一般檢舉保留、永久封存
