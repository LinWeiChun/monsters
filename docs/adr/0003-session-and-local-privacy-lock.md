---
status: accepted
---

# 有狀態工作階段與本機隱私鎖

一般 API 使用 10 分鐘短效 JWT Access Token，Refresh Token 改為可輪替、只保存雜湊的不透明 Token；Web 將 Refresh Token 放在 HttpOnly Cookie，App 放在平台安全儲存區。四位數隱私鎖只存在於各 App 裝置並離線驗證，Web 改用閒置重新驗證；這增加工作階段與平台分流複雜度，但可支援裝置撤銷、重播偵測，並避免伺服器 PIN 成為跨裝置弱密碼。

憑證正確但會員流程未完成時不核發一般 Session，改回傳 32-byte、10 分鐘、只保存 SHA-256 hash 的 Continuation Credential 與 `nextAction`。此憑證只供對應專用流程，狀態或 optimistic version 改變即撤銷，且 Security Filter 不得把它視為 Access Token。
