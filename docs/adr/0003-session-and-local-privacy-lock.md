---
status: accepted
---

# 有狀態工作階段與本機隱私鎖

一般 API 使用 10 分鐘短效 JWT Access Token，Refresh Token 改為可輪替、只保存雜湊的不透明 Token；Web 將 Refresh Token 放在 HttpOnly Cookie，App 放在平台安全儲存區。四位數隱私鎖只存在於各 App 裝置並離線驗證，Web 改用閒置重新驗證；這增加工作階段與平台分流複雜度，但可支援裝置撤銷、重播偵測，並避免伺服器 PIN 成為跨裝置弱密碼。
