# API_SPEC.md

# 貘nsters REST API 規格

## 一、共通規範

Base URL：

```text
/api
```

成功 Response：

```json
{
  "success": true,
  "message": "操作成功",
  "data": {}
}
```

失敗 Response：

```json
{
  "success": false,
  "message": "錯誤訊息",
  "data": null
}
```

後端共用 Response DTO：

```text
com.monsters.common.dto.ApiResponse<T>
```

Controller 回傳資料時必須使用 `ApiResponse<T>` 包裝，欄位固定為：

| 欄位 | 型別 | 說明 |
|---|---|---|
| success | boolean | 是否成功 |
| message | string | 成功或錯誤訊息 |
| data | object / array / null | 回傳資料，失敗時為 null |

成功預設訊息：

```text
操作成功
```

需要登入的 API 必須帶入：

```text
Authorization: Bearer <token>
```

---

## 二、Auth API

### 2.1 註冊

`POST /api/auth/register`

Request：

```json
{
  "email": "user@example.com",
  "password": "password",
  "userName": "使用者名稱"
}
```

### 2.2 登入

`POST /api/auth/login`

Request：

```json
{
  "email": "user@example.com",
  "password": "password"
}
```

### 2.3 Google 登入

`POST /api/auth/google-login`

Request：

```json
{
  "idToken": "google_id_token"
}
```

### 2.4 忘記密碼

`POST /api/auth/forgot-password`

### 2.5 重設密碼

`POST /api/auth/reset-password`

### 2.6 登出

`POST /api/auth/logout`

---

## 三、User API

### 3.1 查詢個人資料

`GET /api/users/me`

### 3.2 修改個人資料

`PUT /api/users/me`

### 3.3 更改頭貼

`PUT /api/users/me/avatar`

### 3.4 設定密碼鎖

`PUT /api/users/me/password-lock`

### 3.5 驗證密碼鎖

`POST /api/users/me/password-lock/verify`

---

## 四、Annoyance API

### 4.1 新增煩惱

`POST /api/annoyances`

### 4.2 查詢煩惱列表

`GET /api/annoyances`

### 4.3 查詢單筆煩惱

`GET /api/annoyances/{id}`

### 4.4 修改煩惱

`PUT /api/annoyances/{id}`

### 4.5 解決煩惱

`PATCH /api/annoyances/{id}/solve`

### 4.6 分享或取消分享煩惱

`PATCH /api/annoyances/{id}/share`

---

## 五、Diary API

### 5.1 新增日記

`POST /api/diaries`

### 5.2 查詢日記列表

`GET /api/diaries`

### 5.3 查詢單筆日記

`GET /api/diaries/{id}`

### 5.4 修改日記

`PUT /api/diaries/{id}`

### 5.5 分享或取消分享日記

`PATCH /api/diaries/{id}/share`

---

## 六、History API

### 6.1 查詢歷史記錄

`GET /api/history`

### 6.2 查詢心的軌跡

`GET /api/history/mood-trace`

規則：

- 回傳最近七次煩惱或日記的心情分數。
- 依建立時間排序。

---

## 七、Monster API

### 7.1 查詢全部怪獸

`GET /api/monsters`

### 7.2 查詢我的怪獸

`GET /api/users/me/monsters`

### 7.3 隨機取得怪獸

`POST /api/users/me/monsters/random`

### 7.4 更換怪獸造型

`PATCH /api/users/me/monsters/{id}/skin`

---

## 八、Community API

社群文章為煩惱與日記分享內容的聚合顯示。

`postId` 格式：

```text
{type}:{id}
```

範例：

```text
annoyance:1
diary:1
```

### 8.1 查詢社群文章

`GET /api/community/posts`

### 8.2 社群按愛心

`POST /api/community/posts/{postId}/like`

### 8.3 取消愛心

`DELETE /api/community/posts/{postId}/like`

### 8.4 新增留言

`POST /api/community/posts/{postId}/comments`

### 8.5 查詢留言

`GET /api/community/posts/{postId}/comments`

---

## 九、Interactive API

### 9.1 解答之書

`GET /api/interactive/answer-book/random`

### 9.2 每日測驗題目

`GET /api/interactive/daily-test/today`

### 9.3 送出每日測驗答案

`POST /api/interactive/daily-test/answer`

### 9.4 深度心理測驗

`GET /api/interactive/psychological-tests`

### 9.5 心理小遊戲

`GET /api/interactive/mind-games`

### 9.6 紓壓方法

`GET /api/interactive/stress-relief-methods`

---

## 十、Feedback API

### 10.1 新增使用回饋

`POST /api/feedback`

---

## 十一、待確認事項

跨文件決策與待確認事項集中於：

- docs/DECISIONS.md
