# 會員資料舊式寫法清理清單

本清單記錄Task 12採方案1資源式API後，舊通用Profile Update與伺服器PIN寫法的使用狀態、能否刪除及刪除條件。正式契約以`API_SPEC.md`、`UI_SPEC.md`與`openapi/registration-login.yaml`為準。

## Task 12已切換

| 範圍 | 舊式寫法 | Task 12結果 |
|---|---|---|
| Flutter route | `/profile` 直接使用`ProfilePage` | 已改為`MemberDataPage` |
| Flutter資料流 | `UserProfileController -> UserRepository -> PUT /api/users/me` | 新畫面已改用`MemberDataController -> MemberDataRepository -> /api/v1/members/me/*` |
| 修改欄位 | 公開暱稱與生日可在同一DTO儲存 | 已分為公開暱稱、Email、生日、停用與恢復獨立Command |
| 併發控制 | 舊Profile Update沒有Client `expectedVersion` | 新Command強制optimistic version；Email驗證與恢復由版本綁定credential檢查 |
| 敏感資料 | 生日可作一般欄位修改 | 已改為用途限定reauth、原因、待審與保守限制流程 |

## 暫時保留，Task 18才可刪除

| 舊式寫法 | 目前使用狀態 | 能否現在刪除 | 刪除條件 |
|---|---|---|---|
| Backend `GET /api/users/me`、`PUT /api/users/me` | 新Flutter已不呼叫；GET保留讀取，PUT依2026-09-03核准方案只回`409 CLIENT_UPGRADE_REQUIRED`，不再提供寫入相容 | 否 | Web、Android、iOS都已使用v1資源式API，完成E2E、部署版本與回滾檢查後由Task 18移除 |
| Backend `UpdateUserProfileRequest`、`UserProfileResponse`與`UserService` Profile methods | 只服務上述legacy path | 否 | 與legacy Controller path、測試及舊API章節同步刪除 |
| Flutter `ProfilePage`與`widgets/profile/profile_penpot_canvas.dart` | `/profile`route已不再參照，僅保留歷史回歸測試 | 技術上無runtime呼叫，治理上暫不刪 | 三平台契約移轉完成後，連同`profile_page_test.dart`由Task 18刪除 |
| Flutter `UserProfileController`、`user_profile_provider.dart` | Profile舊畫面使用，而`userRepositoryProvider`仍被`PasswordLockController`共用 | 否 | 先將密碼鎖改為本機Privacy Lock並分離Repository，再移除Profile state |
| Flutter `UserRepository.getProfile()`、`updateProfile()` | 新Profile route已不呼叫，但同類別仍承載server PIN methods | 不建議單獨整理 | Task 18一次拆除Profile與server PIN legacy contract，避免本Task擴大重構 |
| `PUT /api/users/me/avatar` 與public `avatarUrl` | 新Task 12未呼叫，正式方向是選擇已取得貘怪 | 否 | Monster頭貼契約、三平台遷移與Task 18契約階段完成 |
| `PUT /api/users/me/password-lock`、`POST /api/users/me/password-lock/verify` | 目前`PasswordLockPage`仍呼叫Backend server PIN | 否 | Android、iOS改用Keychain／Keystore本機Privacy Lock，Web改用閒置reauth後才能移除 |

## 不可在Task 12刪除

| 項目 | 原因 |
|---|---|
| `system_data/`舊前後端參考程式 | Repository規範將其定義為只讀參考，未經使用者明確授權不得修改、搬移或刪除 |
| `users.account`、public avatar欄位與server PIN資料表 | 屬於Phase 4.5整體expand–migrate–contract與Task 18，不是Task 12單一功能可安全刪除 |
| 舊API文件的historical baseline章節 | 上一版本升級、相容測試與契約移轉仍需對照；必須標記deprecated，不得假裝不存在 |

## 刪除原則

- 保留程式碼不等於保留危險行為：舊PUT已停止寫入，既有Client必須升級，不能繞過新敏感流程。

- 不以新Flutter專案搜尋不到呼叫者作為唯一刪除證據。
- 刪除legacy path時必須同步移除Security allowlist、Controller、DTO、Service methods、測試與historical API章節。
- 完成條件至少包含OpenAPI、Web／Android／iOS E2E、空資料庫與上版升級、部署版本、回滾／forward-fix檢查。
