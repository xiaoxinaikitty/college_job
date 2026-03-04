<script setup>
import { computed, reactive, ref } from 'vue'
import AppModal from '../../components/ui/AppModal.vue'
import PaginationBar from '../../components/ui/PaginationBar.vue'
import StatusBadge from '../../components/ui/StatusBadge.vue'
import { createUsers } from '../../mock/adminData'

const rows = ref(createUsers())
const page = ref(1)
const pageSize = 10

const filters = reactive({
  keyword: '',
  userType: '',
  status: '',
})

const detailVisible = ref(false)
const current = ref(null)

const filteredRows = computed(() =>
  rows.value.filter((row) => {
    const keyword = filters.keyword.trim().toLowerCase()
    const passKeyword =
      !keyword ||
      row.nickname.toLowerCase().includes(keyword) ||
      row.phone.toLowerCase().includes(keyword)
    const passType = !filters.userType || row.userType === filters.userType
    const passStatus = !filters.status || row.status === filters.status
    return passKeyword && passType && passStatus
  }),
)

const displayRows = computed(() => {
  const start = (page.value - 1) * pageSize
  return filteredRows.value.slice(start, start + pageSize)
})

function openDetail(row) {
  current.value = row
  detailVisible.value = true
}

function toggleStatus(row) {
  if (row.status === 'active') {
    row.status = 'disabled'
    row.statusLabel = '已禁用'
    return
  }
  row.status = 'active'
  row.statusLabel = '正常'
}

function freezeUser(row) {
  row.status = 'frozen'
  row.statusLabel = '冻结中'
}

function statusType(status) {
  if (status === 'active') {
    return 'success'
  }
  if (status === 'frozen') {
    return 'danger'
  }
  return 'pending'
}
</script>

<template>
  <section class="page-wrap">
    <article class="card panel">
      <div class="toolbar">
        <input v-model="filters.keyword" class="field" placeholder="搜索昵称/手机号" />
        <select v-model="filters.userType" class="field">
          <option value="">全部类型</option>
          <option value="student">学生</option>
          <option value="enterprise">企业</option>
        </select>
        <select v-model="filters.status" class="field">
          <option value="">全部状态</option>
          <option value="active">正常</option>
          <option value="disabled">已禁用</option>
          <option value="frozen">冻结中</option>
        </select>
      </div>

      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>用户ID</th>
              <th>昵称</th>
              <th>手机号</th>
              <th>类型</th>
              <th>状态</th>
              <th>风险等级</th>
              <th>注册时间</th>
              <th>最后登录</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in displayRows" :key="row.id">
              <td>#{{ row.id }}</td>
              <td>{{ row.nickname }}</td>
              <td>{{ row.phone }}</td>
              <td>{{ row.userTypeLabel }}</td>
              <td>
                <StatusBadge :type="statusType(row.status)" :text="row.statusLabel" />
              </td>
              <td>{{ row.riskLevel }}</td>
              <td>{{ row.registerAt }}</td>
              <td>{{ row.lastLoginAt }}</td>
              <td class="actions">
                <button class="btn btn-default" @click="openDetail(row)">详情</button>
                <button class="btn btn-default" @click="toggleStatus(row)">启用/禁用</button>
                <button class="btn btn-danger" @click="freezeUser(row)">冻结</button>
              </td>
            </tr>
            <tr v-if="!displayRows.length">
              <td colspan="9" class="empty">暂无符合筛选条件的用户</td>
            </tr>
          </tbody>
        </table>
      </div>

      <PaginationBar
        :page="page"
        :page-size="pageSize"
        :total="filteredRows.length"
        @update:page="page = $event"
      />
    </article>

    <AppModal v-model="detailVisible" title="用户详情" width="620px">
      <div v-if="current" class="detail-grid">
        <p><span>昵称：</span>{{ current.nickname }}</p>
        <p><span>手机号：</span>{{ current.phone }}</p>
        <p><span>用户类型：</span>{{ current.userTypeLabel }}</p>
        <p><span>账号状态：</span>{{ current.statusLabel }}</p>
        <p><span>风险等级：</span>{{ current.riskLevel }}</p>
        <p><span>注册时间：</span>{{ current.registerAt }}</p>
        <p><span>最后登录：</span>{{ current.lastLoginAt }}</p>
      </div>
      <template #footer="{ close }">
        <button class="btn btn-default" @click="close">关闭</button>
      </template>
    </AppModal>
  </section>
</template>

<style scoped>
.page-wrap {
  display: grid;
  gap: 14px;
}

.panel {
  padding: 14px;
}

.toolbar {
  margin-bottom: 12px;
  display: grid;
  gap: 10px;
  grid-template-columns: 1.2fr 0.8fr 0.8fr;
}

.actions {
  display: flex;
  gap: 6px;
}

.empty {
  text-align: center;
  color: var(--text-secondary);
  padding: 20px 0;
}

.detail-grid {
  display: grid;
  gap: 8px;
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.detail-grid p {
  margin: 0;
  background: #f8fafc;
  border-radius: 8px;
  padding: 8px 10px;
}

.detail-grid span {
  color: var(--text-secondary);
}

@media (max-width: 1024px) {
  .toolbar {
    grid-template-columns: 1fr;
  }

  .actions {
    flex-wrap: wrap;
  }

  .detail-grid {
    grid-template-columns: 1fr;
  }
}
</style>
