# Password Reset 舊式寫法清理清單

本清單記錄Task 11採方案1後，舊式Forgot／Reset Password寫法的處理結果與刪除時機。正式契約以`API_SPEC.md`與`openapi/registration-login.yaml`為準。

## 已於Task 11刪除

| 舊式寫法 | 原因 | 結果 |
|---|---|---|
| `ForgotPasswordResponse`在API回傳`resetToken`與`expiresIn` | 會暴露可直接使用的重設憑證，違反正式Email流程 | 已刪除DTO與所有raw Token response測試 |
| `ForgotPasswordRequest`、`ResetPasswordRequest`舊DTO | 欄位與正式resource契約分散，舊完成欄位使用`resetToken` | 已改為`PasswordResetEmailRequest`與`PasswordResetCompletionRequest` |
| `AuthController.forgotPassword()`／`resetPassword()` | 舊Auth Controller混合legacy與正式流程 | 已移除，正式流程由`PasswordResetController`負責 |
| `AuthService.forgotPassword()`／`resetPassword()` | 直接發Token、刪除舊Token及修改密碼，未納入正式Outbox、限流與Session撤銷 | 已移除，改由`PasswordResetService`與`PasswordResetOutboxWorker`負責 |
| Repository直接刪除同會員未使用Token | 刪除無法保留撤銷狀態，難以穩定區分安全流程 | 已改為寫入`revoked_at` |
| Login頁「忘記密碼尚未開放」Snackbar | 無法連到正式流程 | 已改為`go_router`連到`/forgot-password` |

## 暫時保留，Task 18可刪除

| 舊式寫法 | 目前處理 | 可刪除條件 |
|---|---|---|
| `POST /api/auth/forgot-password` | `LegacyPasswordResetController`提供相同通用`202`安全response，不回Token | Web／Android／iOS皆已改用`/api/v1/auth/password-reset-requests`並完成E2E後，由Task 18移除 |
| `POST /api/auth/reset-password` | 接受正式`token`／`newPassword`欄位並共用相同Service | 三平台皆已改用`/api/v1/auth/password-resets`並完成E2E後，由Task 18移除 |
| Legacy Password Reset Controller測試 | 證明過渡Path沒有恢復raw Token或不同安全行為 | 刪除上述兩個Path時同步刪除 |

## 不屬於Task 11，不可在本Task刪除

| 項目 | 原因 | 後續處理 |
|---|---|---|
| `password_reset_tokens` | 已升級為正式15分鐘單次hash Token資料表，不是legacy table | 保留並依資料生命週期清理過期／已用／已撤銷資料 |
| `system_data/`內舊Client產生驗證碼、account欄位與直接呼叫Repository的實作 | Repository規範要求只作歷史參考，不得修改、搬移或刪除 | 未經使用者明確授權不得刪除；正式程式不得複製其安全做法 |
| `revoked_tokens`、JWT Refresh與其他`/api/auth`舊登入契約 | 屬Phase 4.5整體expand–migrate–contract範圍，不是Password Reset單一Task | 依Task 18遷移證據與跨平台E2E後集中移除 |
| Legacy register／login／Google路徑 | 仍服務其他尚未完成的相容流程 | 不在Task 11刪除，依對應Task與Task 18處理 |

## 刪除原則

- 只有已證明Web、Android、iOS都不再呼叫的legacy Path才可刪除。
- 刪除Path時須同步移除Security allowlist、Controller、測試、API舊章節與Task 18待辦。
- 不以grep沒有呼叫者作為唯一刪除證據；需包含OpenAPI、三平台E2E、部署版本與回滾／forward-fix檢查。
