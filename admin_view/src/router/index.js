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

router.beforeEach((to) => {
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
