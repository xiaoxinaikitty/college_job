<script setup>
defineProps({
  title: {
    type: String,
    default: '',
  },
  subtitle: {
    type: String,
    default: '',
  },
  crumbs: {
    type: Array,
    default: () => [],
  },
  user: {
    type: Object,
    default: null,
  },
  collapsed: {
    type: Boolean,
    default: false,
  },
})

defineEmits(['toggle-sidebar', 'logout'])
</script>

<template>
  <header class="header card">
    <div class="header-left">
      <button class="menu-toggle btn btn-default" @click="$emit('toggle-sidebar')">
        {{ collapsed ? '展开菜单' : '收起菜单' }}
      </button>

      <div class="header-title-wrap">
        <div class="crumbs">
          <template v-for="(crumb, index) in crumbs" :key="`${crumb.title}-${index}`">
            <RouterLink v-if="crumb.path" :to="crumb.path" class="crumb-link">{{ crumb.title }}</RouterLink>
            <span v-else class="crumb-current">{{ crumb.title }}</span>
            <span v-if="index !== crumbs.length - 1" class="crumb-divider">/</span>
          </template>
        </div>
        <h1 class="header-title">{{ title }}</h1>
        <p class="header-subtitle">{{ subtitle }}</p>
      </div>
    </div>

    <div class="header-right">
      <div class="user-card">
        <div class="user-avatar">{{ user?.avatarText || 'AD' }}</div>
        <div class="user-meta">
          <p class="user-name">{{ user?.name || '管理员' }}</p>
          <p class="user-role">{{ user?.roleLabel || '-' }}</p>
        </div>
      </div>
      <button class="btn btn-default" @click="$emit('logout')">退出登录</button>
    </div>
  </header>
</template>

<style scoped>
.header {
  margin: 14px 20px 0;
  padding: 16px 18px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 14px;
  min-width: 0;
}

.header-title-wrap {
  min-width: 0;
}

.crumbs {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 2px;
  color: var(--text-muted);
  font-size: 12px;
}

.crumb-link {
  color: #64748b;
}

.crumb-link:hover {
  color: var(--brand);
}

.crumb-current {
  color: var(--text-secondary);
}

.crumb-divider {
  color: #cbd5e1;
}

.header-title {
  margin: 0;
  font-size: 20px;
  line-height: 1.25;
}

.header-subtitle {
  margin: 4px 0 0;
  color: var(--text-secondary);
  font-size: 12px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 10px;
}

.user-card {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 10px;
  border: 1px solid var(--line-color);
  border-radius: 12px;
  background: #f8fafc;
}

.user-avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: var(--brand);
  color: #fff;
  font-size: 12px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
}

.user-meta p {
  margin: 0;
  line-height: 1.3;
}

.user-name {
  font-size: 12px;
  font-weight: 700;
}

.user-role {
  color: var(--text-secondary);
  font-size: 11px;
}

.menu-toggle {
  white-space: nowrap;
}

@media (max-width: 1024px) {
  .header {
    margin: 10px 12px 0 90px;
    padding: 12px;
  }

  .header-subtitle,
  .user-meta {
    display: none;
  }
}
</style>
