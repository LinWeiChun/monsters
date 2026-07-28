---
status: accepted
---

# 版本化平台基礎

正式 API 使用 `/api/v1` 與 OpenAPI 契約，對外資源使用不可推測 UUID；資料庫以 Flyway 管理不可改寫的版本 Migration，背景工作採 MySQL Transactional Outbox。第一版部署於單一亞洲區域的受管理容器與 MySQL，不導入 Kubernetes、跨區多主或專用訊息叢集；這保留清楚的演進與一致性邊界，同時控制首版維運負擔。
