# 大学生实习求职系统 管理后台联调文档

更新时间：2026-03-04  
适用前端：`admin_view`（Vue3 管理后台）  
适用后端：`system_service`（SpringBoot）

---

## 1. 文档目标

本文件用于管理员后台页面与后端接口联调，按“页面字段 + 页面操作”输出完整接口清单。  
管理员前端路由如下：

- `/login`
- `/admin/dashboard`
- `/admin/enterprise-audit`
- `/admin/job-audit`
- `/admin/users`
- `/admin/applications`
- `/admin/reports`
- `/admin/reviews`
- `/admin/penalties`
- `/admin/notifications`
- `/admin/rules`
- `/admin/logs`
- `/admin/permissions`

---

## 2. 当前后端现状

`system_service/api.md` 当前已覆盖学生端与企业端接口；管理员端 `/api/admin/**` 尚未落地。  
本联调文档即为管理员端后续开发规范，建议直接按本清单实现。

---

## 3. 统一接口规范

### 3.1 Base URL

`http://localhost:8080`

### 3.2 鉴权

请求头统一：

```http
Authorization: Bearer <admin_jwt_token>
```

可选审计头（建议）：

```http
X-Request-Id: <uuid>
```

### 3.3 返回结构

```json
{
  "code": 0,
  "message": "OK",
  "data": {}
}
```

- `code=0`：成功
- `code!=0`：失败

### 3.4 分页结构

```json
{
  "records": [],
  "page": 1,
  "pageSize": 10,
  "total": 100
}
```

---

## 4. 登录与会话

### 4.1 管理员登录

- `POST /api/admin/auth/login`

请求：

```json
{
  "account": "admin",
  "password": "123456"
}
```

返回：

```json
{
  "token": "jwt-token",
  "expiresIn": 7200,
  "user": {
    "id": 1,
    "name": "系统管理员",
    "role": "super_admin",
    "roleLabel": "超级管理员",
    "avatarText": "AD"
  },
  "permissions": [
    "dashboard:view",
    "enterpriseAudit:view",
    "jobAudit:view"
  ]
}
```

### 4.2 当前管理员信息

- `GET /api/admin/auth/me`

### 4.3 退出登录

- `POST /api/admin/auth/logout`

---

## 5. 运营看板（`/admin/dashboard`）

### 5.1 核心指标卡

- `GET /api/admin/dashboard/metrics`

返回字段：
- `register`
- `jobs`
- `applications`
- `interviews`
- `offers`
- `hired`
- 每项含 `value/trend/trendUp`

### 5.2 7日趋势

- `GET /api/admin/dashboard/trend?days=7`

返回字段：
- `day`
- `register`
- `application`
- `offer`

### 5.3 审核治理概览

- `GET /api/admin/dashboard/pipeline`

返回字段：
- `label`
- `value`
- `type`（`pending|info|danger|success`）

### 5.4 管理待办

- `GET /api/admin/dashboard/todos`

返回字段：
- `id`
- `title`
- `count`
- `route`

---

## 6. 企业资质审核（`/admin/enterprise-audit`）

### 6.1 列表查询

- `GET /api/admin/enterprise-audits`

查询参数：
- `page`
- `pageSize`
- `keyword`（企业名称/信用代码）
- `status`（`pending|approved|rejected`）
- `riskLevel`（`低|中|高`）

记录字段：
- `id`
- `enterpriseName`
- `creditCode`
- `industry`
- `city`
- `submitter`
- `submittedAt`
- `riskLevel`
- `status`
- `statusLabel`
- `licenseFileUrl`
- `note`

### 6.2 详情

- `GET /api/admin/enterprise-audits/{id}`

### 6.3 审核通过

- `POST /api/admin/enterprise-audits/{id}/approve`

请求：

```json
{
  "note": "资料齐全，审核通过"
}
```

### 6.4 审核驳回

- `POST /api/admin/enterprise-audits/{id}/reject`

请求：

```json
{
  "reason": "证件照片模糊，法人信息不一致"
}
```

---

## 7. 岗位审核（`/admin/job-audit`）

### 7.1 列表查询

- `GET /api/admin/job-audits`

查询参数：
- `page`
- `pageSize`
- `keyword`（岗位/企业）
- `status`（`pending|approved|rejected`）
- `city`

记录字段：
- `id`
- `title`
- `enterpriseName`
- `city`
- `category`
- `salaryRange`
- `submittedAt`
- `status`
- `statusLabel`
- `riskLevel`
- `reason`

### 7.2 详情

- `GET /api/admin/job-audits/{id}`

### 7.3 审核通过（上线）

- `POST /api/admin/job-audits/{id}/approve`

### 7.4 审核驳回

- `POST /api/admin/job-audits/{id}/reject`

请求：

```json
{
  "reason": "岗位职责描述含有兼职引流内容"
}
```

---

## 8. 用户管理（`/admin/users`）

### 8.1 用户列表

- `GET /api/admin/users`

查询参数：
- `page`
- `pageSize`
- `keyword`（昵称/手机号）
- `userType`（`student|enterprise`）
- `status`（`active|disabled|frozen`）

字段：
- `id`
- `nickname`
- `phone`
- `userType`
- `userTypeLabel`
- `status`
- `statusLabel`
- `registerAt`
- `lastLoginAt`
- `riskLevel`

### 8.2 用户详情

- `GET /api/admin/users/{id}`

### 8.3 启用/禁用

- `POST /api/admin/users/{id}/status`

请求：

```json
{
  "status": "active"
}
```

或

```json
{
  "status": "disabled"
}
```

### 8.4 冻结账号

- `POST /api/admin/users/{id}/freeze`

请求：

```json
{
  "durationDays": 7,
  "reason": "违规行为处理"
}
```

---

## 9. 投递流程监控（`/admin/applications`）

### 9.1 列表

- `GET /api/admin/application-monitors`

查询参数：
- `page`
- `pageSize`
- `keyword`（投递编号/学生/企业）
- `stage`（`沟通中|面试中|Offer阶段|已淘汰|已录用`）

字段：
- `id`
- `applicationNo`
- `studentName`
- `enterpriseName`
- `jobTitle`
- `currentStage`
- `stageStatus`（`processing|info|pending|danger|success`）
- `submittedAt`
- `lastActionAt`
- `overdueHours`

### 9.2 详情（可选）

- `GET /api/admin/application-monitors/{id}`

---

## 10. 举报处理（`/admin/reports`）

### 10.1 举报列表

- `GET /api/admin/reports`

查询参数：
- `page`
- `pageSize`
- `keyword`（举报编号/目标/举报人）
- `status`（`pending|processing|closed`）

字段：
- `id`
- `reportNo`
- `reporter`
- `targetType`
- `targetName`
- `reason`
- `status`
- `statusLabel`
- `createdAt`
- `processor`
- `result`

### 10.2 受理

- `POST /api/admin/reports/{id}/accept`

请求：

```json
{
  "note": "已受理，进入核查流程"
}
```

### 10.3 结案

- `POST /api/admin/reports/{id}/close`

请求：

```json
{
  "result": "确认违规，已处罚",
  "withPenalty": true
}
```

---

## 11. 评价管理（`/admin/reviews`）

### 11.1 评价列表

- `GET /api/admin/reviews`

查询参数：
- `page`
- `pageSize`
- `keyword`（评价内容/评价人/企业）
- `status`（`normal|risk`）
- `rating`（`1-5`）

字段：
- `id`
- `reviewer`
- `enterpriseName`
- `rating`
- `content`
- `status`
- `statusLabel`
- `createdAt`

### 11.2 更新评价状态

- `POST /api/admin/reviews/{id}/status`

请求：

```json
{
  "status": "risk",
  "note": "包含风险内容，已标记"
}
```

---

## 12. 处罚记录（`/admin/penalties`）

### 12.1 列表

- `GET /api/admin/penalties`

查询参数：
- `page`
- `pageSize`
- `keyword`（处罚目标/动作）
- `targetType`（`学生|企业`）
- `status`（`effective|expired`）

字段：
- `id`
- `target`
- `targetType`
- `action`
- `severity`（`低|中|高`）
- `status`
- `statusLabel`
- `operator`
- `createdAt`
- `reason`

### 12.2 新增处罚

- `POST /api/admin/penalties`

请求：

```json
{
  "target": "天宸文化传媒有限公司",
  "targetType": "企业",
  "action": "冻结账号 7 天",
  "severity": "高",
  "reason": "岗位违规引流 + 多次投诉"
}
```

### 12.3 撤销处罚

- `POST /api/admin/penalties/{id}/revoke`

请求：

```json
{
  "reason": "复核后撤销"
}
```

---

## 13. 通知中心（`/admin/notifications`）

### 13.1 通知列表

- `GET /api/admin/notifications`

查询参数：
- `page`
- `pageSize`
- `keyword`（标题/接收范围）
- `status`（`draft|published`）

字段：
- `id`
- `title`
- `channel`（`站内消息|全站公告`）
- `audience`（`全体用户|学生用户|企业用户|待审核企业`）
- `status`
- `statusLabel`
- `publishAt`

### 13.2 新建通知（保存草稿）

- `POST /api/admin/notifications`

请求：

```json
{
  "title": "清明节系统维护公告",
  "channel": "全站公告",
  "audience": "全体用户"
}
```

### 13.3 发布通知

- `POST /api/admin/notifications/{id}/publish`

---

## 14. 审核策略（`/admin/rules`）

### 14.1 策略列表

- `GET /api/admin/rules`

字段：
- `id`
- `module`
- `ruleName`
- `hitCondition`
- `action`
- `enabled`
- `updatedAt`

### 14.2 启用/停用策略

- `POST /api/admin/rules/{id}/toggle`

请求：

```json
{
  "enabled": true
}
```

---

## 15. 系统日志（`/admin/logs`）

### 15.1 日志列表

- `GET /api/admin/logs`

查询参数：
- `page`
- `pageSize`
- `keyword`（操作人/动作/目标）
- `module`
- `result`（`成功|失败`）
- `startAt`
- `endAt`

字段：
- `id`
- `operator`
- `action`
- `target`
- `module`
- `ip`
- `result`
- `createdAt`

---

## 16. 权限中心（`/admin/permissions`）

### 16.1 权限项列表

- `GET /api/admin/permissions`

字段：
- `key`
- `label`

### 16.2 角色列表（含权限）

- `GET /api/admin/roles`

字段：
- `role`
- `roleLabel`
- `members`
- `permissions[]`

### 16.3 更新角色权限

- `PUT /api/admin/roles/{role}/permissions`

请求：

```json
{
  "permissions": [
    "dashboard:view",
    "users:view",
    "reports:view"
  ]
}
```

### 16.4 管理员账号列表

- `GET /api/admin/accounts`

字段：
- `id`
- `name`
- `account`
- `roleLabel`
- `lastLoginAt`
- `status`

---

## 17. 状态字典建议

### 17.1 审核状态

- `pending`：待审核
- `approved`：已通过
- `rejected`：已驳回

### 17.2 用户状态

- `active`：正常
- `disabled`：已禁用
- `frozen`：冻结中

### 17.3 举报状态

- `pending`：待处理
- `processing`：处理中
- `closed`：已结案

### 17.4 处罚状态

- `effective`：生效中
- `expired`：已结束

### 17.5 通知状态

- `draft`：草稿
- `published`：已发布

---

## 18. 联调顺序建议

1. 登录鉴权：`/api/admin/auth/login` + 路由守卫可用  
2. 看板：`metrics/trend/pipeline/todos`  
3. 审核主链路：企业审核 + 岗位审核  
4. 治理主链路：举报处理 + 处罚记录 + 用户管理  
5. 运营扩展：流程监控 + 评价管理 + 通知中心  
6. 管理支撑：审核策略 + 系统日志 + 权限中心

---

## 19. 与当前前端字段对齐说明

当前 `admin_view/src/mock/adminData.js` 已作为字段基准。  
后端返回字段名建议与该文件保持一致，可最大程度减少前端改动与联调成本。

