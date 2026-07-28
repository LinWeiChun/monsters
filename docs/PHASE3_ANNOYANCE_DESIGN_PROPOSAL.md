# PHASE3_ANNOYANCE_DESIGN_PROPOSAL.md

# Phase 3 煩惱功能業務邏輯與 UI 互動提案

> 歷史文件：本提案記錄 Phase 3 當時核准的交付範圍。2026-07-26 後，分類與情緒負荷改為選填、分享改為獨立 Community Post、獎勵改為固定里程碑；`isShared`、必填 score／category 與隨機獎勵只供 Migration 參考。

> 狀態：HISTORICAL - 原 Phase 3 已核准，目標規格已由 2026-07-26 決策部分取代
> 提案日期：2026-07-11
> 確認日期：2026-07-11

---

## 一、目的與邊界

本文件將 `docs/SYSTEM_DATA_REFERENCE.md` 的舊系統稽核結果轉成新版可決策方案。使用者確認前，本文件不視為正式 API、Database 或 UI 規格，且不開始 Backend／Flutter 實作。

依據優先順序：`PROJECT_SPEC.md`、`DATABASE_SPEC.md`、`API_SPEC.md`、`UI_SPEC.md`、`CODING_STANDARD.md`、`SYSTEM_DATA_REFERENCE.md`、`system_data/`。

## 二、共同適用的業務規則

### 2.1 建立煩惱流程

| 步驟 | 使用者行為 | 系統行為 |
|---:|---|---|
| 1 | 進入怪獸聊天室 | 顯示目前怪獸、問候語與流程說明 |
| 2 | 選擇煩惱類別 | 以 Chip／Button 顯示六種類別 |
| 3 | 選擇記錄方式 | 顯示文字、圖片、錄音、影片選項 |
| 4 | 輸入或選取內容 | 顯示預覽、移除與重新選擇 |
| 5 | 選擇是否畫心情 | 可開啟畫板，也可跳過 |
| 6 | 選擇 1 至 5 分 | 1 為煩惱程度最低，5 為最高 |
| 7 | 選擇是否分享 | 預設私人，使用者明確選擇後才分享 |
| 8 | 檢視摘要並送出 | 防止重複送出；失敗時保留草稿 |
| 9 | 查看完成結果 | Phase 3 可前往歷史記錄；怪獸獎勵於 Phase 6 串接 |

### 2.2 查詢與權限

- 所有 Annoyance API 均需登入，userId 只來自 JWT principal。
- Client 不得傳入 userId、account、owner 或任意 monsterId。
- 列表只回傳目前使用者未刪除的 ANNOYANCE entry，使用 `page`、`size`、`sort` 分頁。
- 單筆查詢、修改、解決與分享均需驗證 owner；不存在或不屬於目前使用者時回傳 404。
- `PATCH /solve` 只處理解決狀態；`PATCH /share` 接受明確 boolean 目標狀態，不使用無參數 toggle。

## 三、Flutter UI 與狀態管理建議

```text
AnnoyanceChatPage
→ AnnoyanceDraftController (Riverpod)
→ AnnoyanceRepository
→ ApiClient
→ REST API
```

建議狀態機：

```text
intro → category → recordMethod → content
→ drawingDecision → drawing (optional)
→ score → sharing → review → submitting
→ completed
```

狀態使用 enum／sealed model 與型別化 `AnnoyanceDraft`，不得使用舊版整數 chatRound 或非型別化 List。

`AnnoyanceDraft` 建議包含 `categoryCode`、`recordMethod`、`textContent`、`contentFile`、`drawingFile`、`score`、`isShared`、`occurredAt`。

建議共用 Widget：`ChatBubble`、`AnnoyanceCategorySelector`、`RecordMethodSelector`、`MediaPreviewCard`、`MoodDrawingCanvas`、`MoodScoreSelector`、`ShareChoiceCard`、`AnnoyanceReviewCard`、`AnnoyanceCompletedCard`。`RewardDialog` 延至 Phase 6。

錯誤處理原則：

- API 失敗時保留草稿並提供重試。
- 離開未送出流程時顯示放棄草稿確認。
- 不記錄煩惱內容、媒體路徑、JWT 或個人資料。
- Web、Android、iOS 共用流程，平台差異集中於媒體 Service／Adapter。

---

## 四、決策項目

### D1：Phase 3 是否支援影片

| 方案 | 優點 | 缺點／風險 |
|---|---|---|
| A：Phase 3 完整支援影片（建議） | 符合 Project／UI Spec，三平台需求一致 | 需擴充 media constraint、R2、選取、預覽、大小與相容性測試 |
| B：Phase 3 不支援影片 | 與目前 Database constraint 一致，範圍較小 | 必須縮減既有需求；後續仍需 API／DB／UI migration |

### D2：一筆煩惱的內容組合

| 方案 | 優點 | 缺點／風險 |
|---|---|---|
| A：一種主要記錄方式 + 可選心情圖（建議） | 延續逐步聊天流程，Request 與驗證單純 | 暫不支援文字加多種媒體混合 |
| B：文字 + 多筆不同媒體自由組合 | 表達彈性最高，充分利用 entry_media 一對多 | UI、排序、上傳進度、失敗恢復與修改流程複雜 |

### D3：媒體上傳方式

| 方案 | 優點 | 缺點／風險 |
|---|---|---|
| A：`POST /api/annoyances` 使用 multipart（建議） | 單一業務請求，前端流程單純，適合 D2-A | 後端需處理 R2、DB transaction 與失敗 object 清理；影片 request 較大 |
| B：先上傳媒體，再用 JSON 建立煩惱 | 可逐檔顯示進度與重試，最終 JSON 較小 | 需新增上傳 API、暫存授權與孤兒檔案清理 |

### D4：Lookup contract

| 方案 | 優點 | 缺點／風險 |
|---|---|---|
| A：Client 傳 code／score，後端解析 ID（建議） | 不綁定各環境 seed ID，contract 穩定 | 後端需查詢與驗證；公開 code 不應任意改名 |
| B：Client 直接傳 Database ID | Request 與 Repository 處理直接 | 所有環境 seed ID 必須完全一致，匯入或重建容易錯配 |

建議類別 seed：

| code | 名稱 | displayOrder |
|---|---|---:|
| `ACADEMIC` | 課業 | 1 |
| `CAREER` | 事業 | 2 |
| `LOVE` | 愛情 | 3 |
| `FRIENDSHIP` | 友情 | 4 |
| `FAMILY` | 親情 | 5 |
| `OTHER` | 其他 | 6 |

心情分數建議由 Client 傳 1 至 5 的 `score`，後端解析對應 `moods.id`。

### D5：怪獸獎勵的 Phase 歸屬

| 方案 | 優點 | 缺點／風險 |
|---|---|---|
| A：Phase 3 實作最小怪獸獎勵垂直切片（建議） | 完整符合新增煩惱與獎勵流程，不需假獎勵頁 | 需前移部分 Phase 6 Entity、Repository、seed、抽取與重複處理 |
| B：Phase 3 只建立煩惱，獎勵延後至 Phase 6 | 維持目前 Task 順序與模組邊界 | Phase 3 流程不完整；Phase 6 需修改已穩定的 Response 與 Flutter flow |

已選擇 D5-B：Phase 3 Response 不發放怪獸，完成頁不顯示假獎勵；Phase 6 再串接真實獎勵與圖鑑流程。

### D6：列表分頁

| 方案 | 優點 | 缺點／風險 |
|---|---|---|
| A：`page`、`size`、`sort`（建議） | 符合 Coding Standard，Spring Data JPA 與 Flutter 實作直接 | 新增資料時頁碼內容可能移動；極深頁 offset 效能較差 |
| B：Cursor pagination | 時間軸資料穩定，深頁效能較好 | 偏離現行規範，contract 較複雜，可能過早最佳化 |

### D7：聊天室選擇互動

| 方案 | 優點 | 缺點／風險 |
|---|---|---|
| A：聊天外觀 + 結構化選擇元件（建議） | 保留陪伴感，避免字串比對錯誤，無障礙與測試性較好 | 需設計各步驟 selector Widget |
| B：自由文字回答 | 接近舊聊天室，Widget 種類較少 | 是／否、類別、分數需字串驗證，輸入法與同義字造成不一致 |

### D8：媒體限制

| 類型 | 數量 | MIME type | 方案 A 建議上限 |
|---|---:|---|---|
| 圖片 | 1 | jpeg、png、webp | 5 MB |
| 錄音 | 1 | mp4、aac、mpeg、wav | 10 MB／5 分鐘 |
| 影片 | 1 | mp4、quicktime、webm | 50 MB／60 秒 |
| 心情圖 | 1 | png、webp | 5 MB |

- 方案 A（建議）：前後端採上述一致限制；優點是可直接驗證與測試，風險是需依真實裝置輸出補充 MIME type。
- 方案 B：只依平台預設限制；優點是初期較快，風險是前後端不一致、超大上傳與成本不可預期。

---

## 五、核准方案組合

```text
D1-A  完整支援影片
D2-A  一種主要記錄方式 + 可選心情圖
D3-A  multipart 新增
D4-A  code / score contract
D5-B  Phase 3 只建立煩惱，獎勵延至 Phase 6
D6-A  page / size / sort
D7-A  聊天外觀 + 結構化選擇
D8-A  統一保守媒體限制
```

此組合將舊系統的陪伴感轉成可驗證、可測試、可維護的新版流程，同時維持 Phase 模組邊界。Phase 3 需完整處理影片，但不建立怪獸獎勵的暫時實作；Phase 6 必須補上新增煩惱後的獎勵串接。

## 六、確認結果與後續

使用者已確認 `D1-A、D2-A、D3-A、D4-A、D5-B、D6-A、D7-A、D8-A`。本 Task 已將決策同步至 `DECISIONS.md`、Project／Database／API／UI Spec 與 `TASKS.md`，接續進行 Annoyance 實作 DoR 檢查。

---

## 七、文件資訊

| 項目 | 內容 |
|---|---|
| 文件 | `docs/PHASE3_ANNOYANCE_DESIGN_PROPOSAL.md` |
| 狀態 | APPROVED - 已同步正式規格 |
| 來源 | `docs/SYSTEM_DATA_REFERENCE.md` Phase 3 稽核結果 |
| 後續 | 決策同步後進行 Annoyance 實作 DoR 檢查 |
