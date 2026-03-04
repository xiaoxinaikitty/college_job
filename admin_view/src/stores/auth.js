import { computed, ref } from 'vue'
import { defineStore } from 'pinia'

const AUTH_KEY = 'college-job-admin-auth'

const SUPER_ADMIN_PERMISSIONS = [
  'dashboard:view',
  'enterpriseAudit:view',
  'jobAudit:view',
  'users:view',
  'reports:view',
  'penalties:view',
  'permissions:view',
]

export const useAuthStore = defineStore('auth', () => {
  const token = ref('')
  const user = ref(null)
  const permissions = ref([])

  const isAuthenticated = computed(() => Boolean(token.value))

  function hydrate() {
    const raw = localStorage.getItem(AUTH_KEY)
    if (!raw) {
      return
    }
    try {
      const parsed = JSON.parse(raw)
      token.value = parsed.token || ''
      user.value = parsed.user || null
      permissions.value = Array.isArray(parsed.permissions) ? parsed.permissions : []
    } catch {
      localStorage.removeItem(AUTH_KEY)
    }
  }

  function login(account, password) {
    const cleanAccount = account.trim()
    const cleanPassword = password.trim()
    if (cleanAccount !== 'admin' || cleanPassword !== '123456') {
      throw new Error('账号或密码错误，请使用管理员测试账号登录')
    }
    token.value = `mock-token-${Date.now()}`
    user.value = {
      id: 1,
      name: '平台系统管理员',
      role: 'super_admin',
      roleLabel: '超级管理员',
      avatarText: 'AD',
    }
    permissions.value = [...SUPER_ADMIN_PERMISSIONS]
    persist()
  }

  function logout() {
    token.value = ''
    user.value = null
    permissions.value = []
    localStorage.removeItem(AUTH_KEY)
  }

  function hasPermission(permissionKey) {
    if (!permissionKey) {
      return true
    }
    if (user.value?.role === 'super_admin') {
      return true
    }
    return permissions.value.includes(permissionKey)
  }

  function persist() {
    localStorage.setItem(
      AUTH_KEY,
      JSON.stringify({
        token: token.value,
        user: user.value,
        permissions: permissions.value,
      }),
    )
  }

  hydrate()

  return {
    token,
    user,
    permissions,
    isAuthenticated,
    login,
    logout,
    hasPermission,
  }
})
