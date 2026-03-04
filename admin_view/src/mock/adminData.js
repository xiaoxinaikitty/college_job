export const dashboardMetrics = [
  { key: 'register', label: '今日新增注册', value: 186, trend: '+12.4%', trendUp: true },
  { key: 'jobs', label: '在线岗位数', value: 1248, trend: '+5.1%', trendUp: true },
  { key: 'applications', label: '今日投递量', value: 2896, trend: '+9.6%', trendUp: true },
  { key: 'interviews', label: '今日面试量', value: 362, trend: '+3.2%', trendUp: true },
  { key: 'offers', label: 'Offer 发放量', value: 118, trend: '-1.1%', trendUp: false },
  { key: 'hired', label: '录用达成量', value: 76, trend: '+2.8%', trendUp: true },
]

export const dashboardTrend = [
  { day: '周一', register: 120, application: 2100, offer: 82 },
  { day: '周二', register: 138, application: 2240, offer: 95 },
  { day: '周三', register: 142, application: 2388, offer: 90 },
  { day: '周四', register: 158, application: 2442, offer: 99 },
  { day: '周五', register: 171, application: 2580, offer: 107 },
  { day: '周六', register: 166, application: 2498, offer: 101 },
  { day: '周日', register: 186, application: 2896, offer: 118 },
]

export const dashboardPipeline = [
  { label: '待审核企业', value: 28, type: 'pending' },
  { label: '待审核岗位', value: 64, type: 'pending' },
  { label: '处理中举报', value: 19, type: 'info' },
  { label: '高风险账号', value: 7, type: 'danger' },
]

export const dashboardTodo = [
  { id: 1, title: '处理企业资质审核待办', count: 28, route: '/admin/enterprise-audit' },
  { id: 2, title: '处理岗位审核待办', count: 64, route: '/admin/job-audit' },
  { id: 3, title: '处理举报工单', count: 19, route: '/admin/reports' },
  { id: 4, title: '跟进投递流程预警', count: 12, route: '/admin/applications' },
  { id: 5, title: '发布平台通知公告', count: 3, route: '/admin/notifications' },
]

export function createEnterpriseAudits() {
  return [
    {
      id: 10001,
      enterpriseName: '星河智联科技有限公司',
      creditCode: '91310115MA1K4A9Q2L',
      industry: '互联网',
      city: '上海',
      submitter: '李晓婷',
      submittedAt: '2026-03-04 09:20',
      riskLevel: '低',
      status: 'pending',
      statusLabel: '待审核',
      licenseFileUrl: 'https://mock.example.com/license-10001.jpg',
      note: '首次提交企业资质',
    },
    {
      id: 10002,
      enterpriseName: '华屿智能制造股份有限公司',
      creditCode: '91320594MA1URB7X9W',
      industry: '智能制造',
      city: '苏州',
      submitter: '张宇',
      submittedAt: '2026-03-04 08:53',
      riskLevel: '中',
      status: 'pending',
      statusLabel: '待审核',
      licenseFileUrl: 'https://mock.example.com/license-10002.jpg',
      note: '营业执照变更后重新提交',
    },
    {
      id: 10003,
      enterpriseName: '海岸创客教育科技',
      creditCode: '91440300MA5FTR3P4G',
      industry: '教育培训',
      city: '深圳',
      submitter: '王敏',
      submittedAt: '2026-03-03 18:35',
      riskLevel: '低',
      status: 'approved',
      statusLabel: '已通过',
      licenseFileUrl: 'https://mock.example.com/license-10003.jpg',
      note: '资料齐全，历史记录正常',
    },
    {
      id: 10004,
      enterpriseName: '天宸文化传媒有限公司',
      creditCode: '91330110MA2CGX0E8E',
      industry: '传媒',
      city: '杭州',
      submitter: '赵晴',
      submittedAt: '2026-03-03 15:10',
      riskLevel: '高',
      status: 'rejected',
      statusLabel: '已驳回',
      licenseFileUrl: 'https://mock.example.com/license-10004.jpg',
      note: '证件照片模糊，法人信息不一致',
    },
  ]
}

export function createJobAudits() {
  return [
    {
      id: 21001,
      title: 'Flutter 客户端实习生',
      enterpriseName: '星河智联科技有限公司',
      city: '上海',
      category: '移动开发',
      salaryRange: '5k-8k',
      submittedAt: '2026-03-04 09:40',
      status: 'pending',
      statusLabel: '待审核',
      riskLevel: '低',
      reason: '',
    },
    {
      id: 21002,
      title: 'Java 后端开发实习生',
      enterpriseName: '华屿智能制造股份有限公司',
      city: '苏州',
      category: '后端开发',
      salaryRange: '6k-9k',
      submittedAt: '2026-03-04 09:01',
      status: 'pending',
      statusLabel: '待审核',
      riskLevel: '低',
      reason: '',
    },
    {
      id: 21003,
      title: '短视频运营实习生',
      enterpriseName: '天宸文化传媒有限公司',
      city: '杭州',
      category: '运营',
      salaryRange: '面议',
      submittedAt: '2026-03-03 17:22',
      status: 'rejected',
      statusLabel: '已驳回',
      riskLevel: '中',
      reason: '岗位职责描述含有兼职引流内容，存在风险',
    },
    {
      id: 21004,
      title: 'AI 算法实习生',
      enterpriseName: '海岸创客教育科技',
      city: '深圳',
      category: '算法',
      salaryRange: '8k-12k',
      submittedAt: '2026-03-03 14:50',
      status: 'approved',
      statusLabel: '已上线',
      riskLevel: '低',
      reason: '',
    },
  ]
}

export function createUsers() {
  return [
    {
      id: 30001,
      nickname: '林同学',
      phone: '13800138001',
      userType: 'student',
      userTypeLabel: '学生',
      status: 'active',
      statusLabel: '正常',
      registerAt: '2026-02-10 10:20',
      lastLoginAt: '2026-03-04 09:10',
      riskLevel: '低',
    },
    {
      id: 30002,
      nickname: '王同学',
      phone: '13800138002',
      userType: 'student',
      userTypeLabel: '学生',
      status: 'disabled',
      statusLabel: '已禁用',
      registerAt: '2026-01-28 18:11',
      lastLoginAt: '2026-02-26 21:08',
      riskLevel: '中',
    },
    {
      id: 30003,
      nickname: '星河智联科技有限公司',
      phone: '13900139001',
      userType: 'enterprise',
      userTypeLabel: '企业',
      status: 'active',
      statusLabel: '正常',
      registerAt: '2026-01-05 08:33',
      lastLoginAt: '2026-03-04 08:58',
      riskLevel: '低',
    },
    {
      id: 30004,
      nickname: '天宸文化传媒有限公司',
      phone: '13900139002',
      userType: 'enterprise',
      userTypeLabel: '企业',
      status: 'frozen',
      statusLabel: '冻结中',
      registerAt: '2025-12-17 16:09',
      lastLoginAt: '2026-03-01 10:00',
      riskLevel: '高',
    },
  ]
}

export function createReports() {
  return [
    {
      id: 41001,
      reportNo: 'RP20260304001',
      reporter: '林同学',
      targetType: '岗位',
      targetName: '短视频运营实习生',
      reason: '岗位描述与实际面试不一致，疑似引流',
      status: 'pending',
      statusLabel: '待处理',
      createdAt: '2026-03-04 08:55',
      processor: '-',
      result: '-',
    },
    {
      id: 41002,
      reportNo: 'RP20260304002',
      reporter: '王同学',
      targetType: '企业',
      targetName: '天宸文化传媒有限公司',
      reason: '存在恶意收集个人隐私信息行为',
      status: 'processing',
      statusLabel: '处理中',
      createdAt: '2026-03-04 08:20',
      processor: '陈审核员',
      result: '正在补充证据',
    },
    {
      id: 41003,
      reportNo: 'RP20260303087',
      reporter: '赵同学',
      targetType: '消息',
      targetName: '会话#9032',
      reason: '消息中包含侮辱性内容',
      status: 'closed',
      statusLabel: '已结案',
      createdAt: '2026-03-03 14:03',
      processor: '陈审核员',
      result: '确认违规，已处罚',
    },
  ]
}

export function createPenalties() {
  return [
    {
      id: 51001,
      target: '天宸文化传媒有限公司',
      targetType: '企业',
      action: '冻结账号 7 天',
      severity: '高',
      status: 'effective',
      statusLabel: '生效中',
      operator: '系统管理员',
      createdAt: '2026-03-03 15:12',
      reason: '岗位违规引流 + 多次投诉',
    },
    {
      id: 51002,
      target: '王同学',
      targetType: '学生',
      action: '警告并限制发言 24 小时',
      severity: '中',
      status: 'expired',
      statusLabel: '已结束',
      operator: '陈审核员',
      createdAt: '2026-02-27 11:08',
      reason: '多次发布不实举报信息',
    },
    {
      id: 51003,
      target: '海岸创客教育科技',
      targetType: '企业',
      action: '下架相关岗位',
      severity: '中',
      status: 'effective',
      statusLabel: '生效中',
      operator: '系统管理员',
      createdAt: '2026-03-01 09:26',
      reason: '岗位薪资描述不合规',
    },
  ]
}

export function createApplicationMonitors() {
  return [
    {
      id: 61001,
      applicationNo: 'AP20260304001',
      studentName: '林同学',
      enterpriseName: '星河智联科技有限公司',
      jobTitle: 'Flutter 客户端实习生',
      currentStage: '沟通中',
      stageStatus: 'processing',
      submittedAt: '2026-03-01 14:22',
      lastActionAt: '2026-03-04 09:20',
      overdueHours: 0,
    },
    {
      id: 61002,
      applicationNo: 'AP20260303098',
      studentName: '王同学',
      enterpriseName: '华屿智能制造股份有限公司',
      jobTitle: 'Java 后端开发实习生',
      currentStage: '面试中',
      stageStatus: 'info',
      submittedAt: '2026-02-28 10:01',
      lastActionAt: '2026-03-03 16:30',
      overdueHours: 18,
    },
    {
      id: 61003,
      applicationNo: 'AP20260302117',
      studentName: '赵同学',
      enterpriseName: '海岸创客教育科技',
      jobTitle: 'AI 算法实习生',
      currentStage: 'Offer阶段',
      stageStatus: 'pending',
      submittedAt: '2026-02-25 11:12',
      lastActionAt: '2026-03-04 08:50',
      overdueHours: 0,
    },
    {
      id: 61004,
      applicationNo: 'AP20260302088',
      studentName: '陈同学',
      enterpriseName: '天宸文化传媒有限公司',
      jobTitle: '短视频运营实习生',
      currentStage: '已淘汰',
      stageStatus: 'danger',
      submittedAt: '2026-02-24 09:45',
      lastActionAt: '2026-03-02 13:10',
      overdueHours: 0,
    },
  ]
}

export function createReviews() {
  return [
    {
      id: 71001,
      reviewer: '林同学',
      enterpriseName: '星河智联科技有限公司',
      rating: 5,
      content: '面试流程规范，沟通及时，岗位信息与描述一致。',
      status: 'normal',
      statusLabel: '正常',
      createdAt: '2026-03-03 18:23',
    },
    {
      id: 71002,
      reviewer: '王同学',
      enterpriseName: '天宸文化传媒有限公司',
      rating: 1,
      content: '岗位存在诱导行为，且面试中出现不当言论。',
      status: 'risk',
      statusLabel: '风险',
      createdAt: '2026-03-03 20:08',
    },
    {
      id: 71003,
      reviewer: '赵同学',
      enterpriseName: '海岸创客教育科技',
      rating: 4,
      content: '整体体验不错，建议增加线上答疑环节。',
      status: 'normal',
      statusLabel: '正常',
      createdAt: '2026-03-02 12:11',
    },
  ]
}

export function createNotifications() {
  return [
    {
      id: 81001,
      title: '清明节系统维护公告',
      channel: '全站公告',
      audience: '全体用户',
      status: 'published',
      statusLabel: '已发布',
      publishAt: '2026-03-04 09:00',
    },
    {
      id: 81002,
      title: '企业审核资料补充提醒',
      channel: '站内消息',
      audience: '待审核企业',
      status: 'draft',
      statusLabel: '草稿',
      publishAt: '-',
    },
    {
      id: 81003,
      title: 'Offer 处理时效提示',
      channel: '站内消息',
      audience: '学生用户',
      status: 'published',
      statusLabel: '已发布',
      publishAt: '2026-03-03 16:20',
    },
  ]
}

export function createReviewRules() {
  return [
    {
      id: 91001,
      module: '企业资质审核',
      ruleName: '营业执照清晰度校验',
      hitCondition: '图片分辨率低于 800x800',
      action: '标记高风险并转人工复核',
      enabled: true,
      updatedAt: '2026-03-04 08:50',
    },
    {
      id: 91002,
      module: '岗位审核',
      ruleName: '引流关键词识别',
      hitCondition: '命中联系方式/返利等敏感词',
      action: '直接驳回并记录风控日志',
      enabled: true,
      updatedAt: '2026-03-04 09:00',
    },
    {
      id: 91003,
      module: '举报治理',
      ruleName: '重复举报聚合',
      hitCondition: '同对象 24h 内举报 >= 3 次',
      action: '自动升级为优先工单',
      enabled: false,
      updatedAt: '2026-03-02 14:35',
    },
  ]
}

export function createSystemLogs() {
  return [
    {
      id: 100001,
      operator: 'admin',
      action: '通过企业资质审核',
      target: '星河智联科技有限公司',
      module: '企业审核',
      ip: '192.168.1.120',
      result: '成功',
      createdAt: '2026-03-04 09:18:22',
    },
    {
      id: 100002,
      operator: 'admin',
      action: '驳回岗位审核',
      target: '短视频运营实习生',
      module: '岗位审核',
      ip: '192.168.1.120',
      result: '成功',
      createdAt: '2026-03-04 09:10:03',
    },
    {
      id: 100003,
      operator: 'audit_chen',
      action: '举报工单结案',
      target: 'RP20260303087',
      module: '举报处理',
      ip: '192.168.1.121',
      result: '成功',
      createdAt: '2026-03-04 08:58:09',
    },
  ]
}

export const rolePermissions = [
  {
    role: 'super_admin',
    roleLabel: '超级管理员',
    members: 1,
    permissions: [
      'dashboard:view',
      'enterpriseAudit:view',
      'jobAudit:view',
      'users:view',
      'applications:view',
      'reports:view',
      'reviews:view',
      'penalties:view',
      'notifications:view',
      'rules:view',
      'logs:view',
      'permissions:view',
    ],
  },
  {
    role: 'auditor',
    roleLabel: '审核专员',
    members: 4,
    permissions: [
      'dashboard:view',
      'enterpriseAudit:view',
      'jobAudit:view',
      'applications:view',
      'reports:view',
      'reviews:view',
      'logs:view',
    ],
  },
  {
    role: 'operator',
    roleLabel: '运营专员',
    members: 3,
    permissions: [
      'dashboard:view',
      'users:view',
      'applications:view',
      'reports:view',
      'reviews:view',
      'penalties:view',
      'notifications:view',
    ],
  },
]

export const permissionMap = [
  { key: 'dashboard:view', label: '查看运营看板' },
  { key: 'enterpriseAudit:view', label: '企业资质审核' },
  { key: 'jobAudit:view', label: '岗位审核' },
  { key: 'users:view', label: '用户管理' },
  { key: 'applications:view', label: '投递流程监控' },
  { key: 'reports:view', label: '举报处理' },
  { key: 'reviews:view', label: '评价管理' },
  { key: 'penalties:view', label: '处罚记录' },
  { key: 'notifications:view', label: '通知中心' },
  { key: 'rules:view', label: '审核策略' },
  { key: 'logs:view', label: '系统日志' },
  { key: 'permissions:view', label: '权限中心' },
]

export const adminAccounts = [
  {
    id: 1,
    name: '系统管理员',
    account: 'admin',
    roleLabel: '超级管理员',
    lastLoginAt: '2026-03-04 09:02',
    status: '正常',
  },
  {
    id: 2,
    name: '陈审核员',
    account: 'audit_chen',
    roleLabel: '审核专员',
    lastLoginAt: '2026-03-04 08:58',
    status: '正常',
  },
]
