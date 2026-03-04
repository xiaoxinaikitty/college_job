import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { adminApi } from '../services/adminApi'

const AUTH_KEY = 'college-job-admin-auth'

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

  async function login(account, password) {
    const result = await adminApi.login({
      account: account.trim(),
      password: password.trim(),
    })
    token.value = result?.token || ''
    user.value = result?.user || null
    permissions.value = Array.isArray(result?.permissions) ? result.permissions : []
    persist()
  }

  async function logout() {
    try {
      await adminApi.logout()
    } catch {
      // ignore logout request failures
    }
    token.value = ''
    user.value = null
    permissions.value = []
    localStorage.removeItem(AUTH_KEY)
  }

  async function refreshMe() {
    if (!token.value) {
      return
    }
    const result = await adminApi.me()
    user.value = result?.user || user.value
    if (Array.isArray(result?.permissions)) {
      permissions.value = result.permissions
    }
    persist()
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
    refreshMe,
    hasPermission,
  }
})
