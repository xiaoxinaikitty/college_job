<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { adminNavItems } from '../../constants/navigation'
import { useAuthStore } from '../../stores/auth'

defineProps({
  collapsed: {
    type: Boolean,
    default: false,
  },
})

const route = useRoute()
const authStore = useAuthStore()

const navItems = computed(() =>
  adminNavItems.filter((item) => authStore.hasPermission(item.permission)),
)

function isActive(path) {
  return route.path === path
}
</script>

<template>
  <aside :class="['sidebar', collapsed ? 'collapsed' : '']">
    <div class="brand">
      <div class="brand-icon">CJ</div>
      <div v-if="!collapsed" class="brand-text">
        <p class="brand-title">实习通管理后台</p>
        <p class="brand-subtitle">College Job Admin</p>
      </div>
    </div>

    <nav class="menu-list">
      <RouterLink
        v-for="item in navItems"
        :key="item.key"
        :to="item.path"
        :class="['menu-item', isActive(item.path) ? 'active' : '']"
      >
        <span class="menu-icon">{{ item.icon }}</span>
        <span v-if="!collapsed" class="menu-label">{{ item.label }}</span>
      </RouterLink>
    </nav>
  </aside>
</template>

<style scoped>
.sidebar {
  width: 244px;
  border-right: 1px solid rgba(148, 163, 184, 0.2);
  background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%);
  color: #cbd5e1;
  padding: 18px 14px;
  transition: width 0.24s ease;
}

.sidebar.collapsed {
  width: 84px;
}

.brand {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 18px;
  padding: 6px 4px 14px;
  border-bottom: 1px solid rgba(148, 163, 184, 0.2);
}

.brand-icon {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  color: #fff;
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
}

.brand-title {
  margin: 0;
  color: #f8fafc;
  font-size: 14px;
  font-weight: 700;
}

.brand-subtitle {
  margin: 2px 0 0;
  font-size: 12px;
  color: #94a3b8;
}

.menu-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 10px;
  border-radius: 10px;
  padding: 9px 10px;
  color: #cbd5e1;
  transition: background-color 0.2s ease;
}

.menu-item:hover {
  background: rgba(148, 163, 184, 0.2);
}

.menu-item.active {
  background: rgba(37, 99, 235, 0.25);
  color: #eff6ff;
}

.menu-icon {
  width: 28px;
  height: 28px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  background: rgba(148, 163, 184, 0.2);
}

.menu-item.active .menu-icon {
  background: rgba(255, 255, 255, 0.24);
}

.menu-label {
  font-weight: 600;
}

@media (max-width: 1024px) {
  .sidebar {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    z-index: 20;
    width: 76px;
    padding: 14px 10px;
  }

  .sidebar .brand-text,
  .sidebar .menu-label {
    display: none;
  }
}
</style>
