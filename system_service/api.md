# 后端接口文档（认证 + 学生端MVP）

## 1. 基础说明
- 服务地址：`http://localhost:8080`
- 返回结构：

```json
{
  "code": 0,
  "message": "OK",
  "data": {}
}
```

- `code = 0` 成功，`code != 0` 失败。
- 学生业务接口统一使用请求头：

```http
X-User-Id: 1
```

> 当前版本先用 `X-User-Id` 标识学生身份，后续可切换到 JWT 鉴权拦截。

---

## 2. 认证接口（/api/auth）

### 2.1 学生注册
- `POST /api/auth/register/student`

请求：
```json
{
  "phone": "13800138000",
  "password": "123456",
  "nickname": "张三"
}
```

### 2.2 企业注册
- `POST /api/auth/register/enterprise`

请求：
```json
{
  "phone": "13900139000",
  "password": "123456",
  "enterpriseName": "示例科技有限公司",
  "unifiedCreditCode": "9133XXXXXXXXXXXXXX"
}
```

### 2.3 登录
- `POST /api/auth/login`

请求：
```json
{
  "phone": "13800138000",
  "password": "123456",
  "userType": 1
}
```

---

## 3. 学生端接口（/api/student）

### 3.1 简历模块

#### 3.1.1 创建简历
- `POST /api/student/resumes`

请求头：
```http
X-User-Id: 1
```

请求体：
```json
{
  "title": "Java后端实习简历",
  "resumeContentJson": "{\"education\":[],\"skills\":[\"Java\",\"SpringBoot\"]}",
  "completionScore": 78.5
}
```

#### 3.1.2 更新简历
- `PUT /api/student/resumes/{resumeId}`

#### 3.1.3 查询我的简历列表
- `GET /api/student/resumes`

#### 3.1.4 设置默认简历
- `PUT /api/student/resumes/{resumeId}/default`

#### 3.1.5 一键上传简历文件
- `POST /api/student/resumes/upload`
- `Content-Type: multipart/form-data`

请求头：
```http
X-User-Id: 1
```

表单参数：
- `file`：简历文件（必填，支持 `pdf/doc/docx`，最大 `10MB`）
- `title`：简历标题（选填）

返回：
- `resumeId`
- `downloadUrl`
- `fileName`
- `fileSize`

#### 3.1.6 下载已上传简历文件
- `GET /api/student/resumes/{resumeId}/file`

请求头：
```http
X-User-Id: 1
```

说明：
- 仅允许下载当前学生本人上传的简历文件。

---

### 3.2 岗位模块

#### 3.2.1 岗位列表（分页 + 搜索筛选）
- `GET /api/student/jobs?keyword=java&city=上海&category=后端&page=0&size=10`

参数：
- `keyword` 关键词（可选）
- `city` 城市（可选）
- `category` 分类（可选）
- `page` 页码，从0开始
- `size` 每页条数

#### 3.2.2 岗位详情
- `GET /api/student/jobs/{jobId}`

---

### 3.3 投递模块

#### 3.3.1 一键投递
- `POST /api/student/applications`

请求头：
```http
X-User-Id: 1
```

请求体：
```json
{
  "jobId": 1001,
  "resumeId": 2001
}
```

#### 3.3.2 我的投递记录
- `GET /api/student/applications`

#### 3.3.3 投递详情（含状态流转日志）
- `GET /api/student/applications/{applicationId}`

---

### 3.4 沟通模块

#### 3.4.1 我的会话列表
- `GET /api/student/chats`

#### 3.4.2 会话消息列表
- `GET /api/student/chats/{conversationId}/messages`

#### 3.4.3 发送消息
- `POST /api/student/chats/{conversationId}/messages`

请求体：
```json
{
  "messageType": 1,
  "contentText": "您好，我想确认一下面试时间。",
  "fileUrl": null
}
```

说明：
- `messageType`: `1-text 2-image 3-file 4-system`
- 文本消息时，`contentText` 必填。

---

### 3.5 面试与Offer模块

#### 3.5.1 我的面试安排
- `GET /api/student/interviews`

#### 3.5.2 提交面试确认操作
- `POST /api/student/interviews/{interviewId}/confirm`

请求体：
```json
{
  "action": "confirm",
  "note": "我会准时参加",
  "expectedRescheduleAt": null
}
```

或（申请改期）：
```json
{
  "action": "reschedule",
  "note": "当天有课程冲突，申请改期",
  "expectedRescheduleAt": "2026-03-06T15:00:00"
}
```

或（无法参加）：
```json
{
  "action": "decline",
  "note": "已签约其他实习，无法参加",
  "expectedRescheduleAt": null
}
```

说明：
- `action` 仅支持 `confirm / reschedule / decline`
- `reschedule` 必须传 `expectedRescheduleAt`
- `decline` 必须填写 `note`

#### 3.5.3 查询我的面试确认详情
- `GET /api/student/interviews/{interviewId}/confirm`

说明：
- 若未提交过确认，返回 `submitted=false`
- 若已提交，返回 `action/actionLabel/note/submittedAt` 等信息

#### 3.5.4 我的Offer列表
- `GET /api/student/offers`

#### 3.5.5 处理Offer（接受/拒绝）
- `POST /api/student/offers/{offerId}/decision`

请求体：
```json
{
  "action": "accept",
  "rejectReason": ""
}
```

或

```json
{
  "action": "reject",
  "rejectReason": "综合考虑后不匹配"
}
```

说明：
- `action` 只支持 `accept` / `reject`
- 处理后会同步写入 Offer 状态日志，并更新投递状态流转日志。

---

### 3.6 评价与举报模块

#### 3.6.1 提交企业评价
- `POST /api/student/reviews`

请求体：
```json
{
  "applicationId": 3001,
  "enterpriseId": 4001,
  "rating": 5,
  "content": "面试流程规范，沟通顺畅"
}
```

说明：
- 仅投递流程结束（已录用/已淘汰）可评价。
- 同一投递仅允许评价一次。

#### 3.6.2 我的评价列表
- `GET /api/student/reviews`

#### 3.6.3 提交举报
- `POST /api/student/reports`

请求体：
```json
{
  "targetType": 1,
  "targetId": 1001,
  "reason": "岗位描述与实际不符",
  "evidenceUrl": "https://example.com/evidence.png"
}
```

说明：
- `targetType`: `1-job 2-enterprise 3-user 4-message`

#### 3.6.4 我的举报列表
- `GET /api/student/reports`

---

## 4. 状态值约定

### 4.1 岗位状态
- `1-draft 2-pending 3-online 4-rejected 5-offline`

### 4.2 投递状态
- `1-submitted 2-viewed 3-communicating 4-interview 5-offer 6-hired 7-rejected 8-withdrawn`

### 4.3 Offer状态
- `1-sent 2-accepted 3-rejected 4-expired`

### 4.4 举报状态
- `1-pending 2-processing 3-closed`

---

## 5. 错误码
- `4001` 参数错误
- `4002` 手机号已注册
- `4003` 账号不存在
- `4004` 密码错误
- `4005` 账号不可用
- `4006` 账号角色不匹配/学生身份无效
- `4007` 数据不存在
- `4008` 岗位不存在或未上线
- `4009` 简历不存在
- `4010` 重复投递
- `4011` Offer状态不可处理
- `4012` 投递状态不允许当前操作
- `5000` 系统异常

---

## 6. 联调建议流程（学生闭环）
1. 调用认证接口注册并登录，拿到 `userId`。  
2. 使用 `X-User-Id=userId` 创建并设置默认简历。  
3. 查询岗位列表，查看岗位详情。  
4. 发起投递，查询投递记录与状态日志。  
5. 进入会话发送消息。  
6. 查看面试安排、查看Offer并处理。  
7. 流程结束后提交评价或举报。  

