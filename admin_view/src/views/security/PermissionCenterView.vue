<script setup>
import { computed } from 'vue'
import { adminAccounts, permissionMap, rolePermissions } from '../../mock/adminData'

const roleMatrix = computed(() =>
  rolePermissions.map((role) => ({
    ...role,
    permissionSet: new Set(role.permissions),
  })),
)
</script>

<template>
  <section class="page-wrap">
    <div class="grid-3">
      <article v-for="role in rolePermissions" :key="role.role" class="card role-card">
        <h3>{{ role.roleLabel }}</h3>
        <p>角色标识：{{ role.role }}</p>
        <p>成员数：{{ role.members }}</p>
        <p>权限数：{{ role.permissions.length }}</p>
      </article>
    </div>

    <article class="card panel">
      <h3 class="panel-title">RBAC 权限矩阵</h3>
      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>权限项</th>
              <th v-for="role in rolePermissions" :key="role.role">{{ role.roleLabel }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="permission in permissionMap" :key="permission.key">
              <td>{{ permission.label }}</td>
              <td v-for="role in roleMatrix" :key="`${role.role}-${permission.key}`">
                <span :class="role.permissionSet.has(permission.key) ? 'yes' : 'no'">
                  {{ role.permissionSet.has(permission.key) ? '已授权' : '未授权' }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </article>

    <article class="card panel">
      <h3 class="panel-title">管理员账号</h3>
      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>姓名</th>
              <th>账号</th>
              <th>角色</th>
              <th>最近登录</th>
              <th>状态</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in adminAccounts" :key="item.id">
              <td>#{{ item.id }}</td>
              <td>{{ item.name }}</td>
              <td>{{ item.account }}</td>
              <td>{{ item.roleLabel }}</td>
              <td>{{ item.lastLoginAt }}</td>
              <td>{{ item.status }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </article>
  </section>
</template>

<style scoped>
.page-wrap {
  display: grid;
  gap: 14px;
}

.role-card {
  padding: 16px;
}

.role-card h3 {
  margin: 0;
  font-size: 18px;
}

.role-card p {
  margin: 6px 0 0;
  color: var(--text-secondary);
}

.panel {
  padding: 14px;
}

.panel-title {
  margin: 0 0 12px;
  font-size: 16px;
}

.yes {
  color: #166534;
  font-weight: 700;
}

.no {
  color: #9ca3af;
}
</style>
