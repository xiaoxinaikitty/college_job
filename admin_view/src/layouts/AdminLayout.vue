<script setup>
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import AppSidebar from '../components/layout/AppSidebar.vue'
import AppHeader from '../components/layout/AppHeader.vue'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const collapsed = ref(false)

const pageTitle = computed(() => route.meta.title || '管理后台')
const pageSubtitle = computed(() => route.meta.subtitle || '')

const crumbs = computed(() => {
  const list = route.matched
    .filter((item) => item.meta.title)
    .map((item) => ({
      name: item.name,
      title: item.meta.title,
      path: item.path.startsWith('/admin/') ? item.path : null,
    }))
  if (!list.length) {
    return [{ title: '管理后台', path: '/admin/dashboard' }]
  }
  return list
})

function onToggleSidebar() {
  collapsed.value = !collapsed.value
}

function onLogout() {
  authStore.logout()
  router.replace('/login')
}
</script>

<template>
  <div class="admin-shell">
    <AppSidebar :collapsed="collapsed" />
    <div class="admin-main">
      <AppHeader
        :title="pageTitle"
        :subtitle="pageSubtitle"
        :crumbs="crumbs"
        :collapsed="collapsed"
        :user="authStore.user"
        @toggle-sidebar="onToggleSidebar"
        @logout="onLogout"
      />
      <main class="admin-content">
        <RouterView />
      </main>
    </div>
  </div>
</template>

<style scoped>
.admin-shell {
  min-height: 100vh;
  display: flex;
  background: transparent;
}

.admin-main {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.admin-content {
  padding: 20px;
  min-height: 0;
}

@media (max-width: 1024px) {
  .admin-content {
    padding: 14px;
  }
}
</style>
