import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { pinia } from '../stores'

const routes = [
  {
    path: '/',
    redirect: '/admin/dashboard',
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('../views/auth/LoginView.vue'),
    meta: {
      title: '管理员登录',
      guestOnly: true,
    },
  },
  {
    path: '/admin',
    component: () => import('../layouts/AdminLayout.vue'),
    meta: {
      requiresAuth: true,
    },
    children: [
      {
        path: '',
        redirect: '/admin/dashboard',
      },
      {
        path: 'dashboard',
        name: 'dashboard',
        component: () => import('../views/dashboard/DashboardView.vue'),
        meta: {
          title: '运营看板',
          subtitle: '实时掌握平台核心指标与运营动态',
          permission: 'dashboard:view',
        },
      },
      {
        path: 'enterprise-audit',
        name: 'enterprise-audit',
        component: () => import('../views/audit/EnterpriseAuditView.vue'),
        meta: {
          title: '企业资质审核',
          subtitle: '处理企业认证申请，保障平台准入质量',
          permission: 'enterpriseAudit:view',
        },
      },
      {
        path: 'job-audit',
        name: 'job-audit',
        component: () => import('../views/audit/JobAuditView.vue'),
        meta: {
          title: '岗位审核',
          subtitle: '审核岗位合规性并控制上架风险',
          permission: 'jobAudit:view',
        },
      },
      {
        path: 'users',
        name: 'users',
        component: () => import('../views/users/UserManagementView.vue'),
        meta: {
          title: '用户管理',
          subtitle: '学生与企业账号状态管理和风控处置',
          permission: 'users:view',
        },
      },
      {
        path: 'applications',
        name: 'applications',
        component: () => import('../views/operations/ApplicationMonitorView.vue'),
        meta: {
          title: '投递流程监控',
          subtitle: '追踪投递到录用全链路转化与超时预警',
          permission: 'applications:view',
        },
      },
      {
        path: 'reports',
        name: 'reports',
        component: () => import('../views/governance/ReportCenterView.vue'),
        meta: {
          title: '举报处理',
          subtitle: '受理、核查、结案与治理闭环处理',
          permission: 'reports:view',
        },
      },
      {
        path: 'reviews',
        name: 'reviews',
        component: () => import('../views/governance/ReviewManagementView.vue'),
        meta: {
          title: '评价管理',
          subtitle: '查看学生评价并处理异常评价内容',
          permission: 'reviews:view',
        },
      },
      {
        path: 'penalties',
        name: 'penalties',
        component: () => import('../views/governance/PenaltyRecordsView.vue'),
        meta: {
          title: '处罚记录',
          subtitle: '处罚动作留痕与复核管理',
          permission: 'penalties:view',
        },
      },
      {
        path: 'notifications',
        name: 'notifications',
        component: () => import('../views/operations/NotificationCenterView.vue'),
        meta: {
          title: '通知中心',
          subtitle: '站内公告与通知模板的统一配置与发布',
          permission: 'notifications:view',
        },
      },
      {
        path: 'rules',
        name: 'rules',
        component: () => import('../views/security/RuleCenterView.vue'),
        meta: {
          title: '审核策略',
          subtitle: '岗位与企业审核规则配置管理',
          permission: 'rules:view',
        },
      },
      {
        path: 'logs',
        name: 'logs',
        component: () => import('../views/security/SystemLogsView.vue'),
        meta: {
          title: '系统日志',
          subtitle: '关键操作日志与登录审计查询',
          permission: 'logs:view',
        },
      },
      {
        path: 'permissions',
        name: 'permissions',
        component: () => import('../views/security/PermissionCenterView.vue'),
        meta: {
          title: '权限中心',
          subtitle: '基础 RBAC 角色权限配置',
          permission: 'permissions:view',
        },
      },
    ],
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('../views/error/NotFoundView.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})

router.beforeEach(async (to) => {
  const authStore = useAuthStore(pinia)
  const isLoggedIn = authStore.isAuthenticated

  if (to.meta.requiresAuth && !isLoggedIn) {
    return {
      path: '/login',
      query: {
        redirect: to.fullPath,
      },
    }
  }

  if (to.meta.requiresAuth && isLoggedIn) {
    try {
      await authStore.refreshMe()
    } catch {
      await authStore.logout()
      return {
        path: '/login',
        query: {
          redirect: to.fullPath,
        },
      }
    }
  }

  if (to.meta.guestOnly && isLoggedIn) {
    return '/admin/dashboard'
  }

  const permission = to.meta.permission
  if (permission && !authStore.hasPermission(permission)) {
    return '/admin/dashboard'
  }
  return true
})

export default router
