<script setup>
import { onMounted, reactive, ref, watch } from 'vue'
import AppModal from '../../components/ui/AppModal.vue'
import PaginationBar from '../../components/ui/PaginationBar.vue'
import StatusBadge from '../../components/ui/StatusBadge.vue'
import { adminApi, formatDateTime } from '../../services/adminApi'

const rows = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 10
const loading = ref(false)

const filters = reactive({
  keyword: '',
  userType: '',
  status: '',
})

const detailVisible = ref(false)
const current = ref(null)

function normalizeRow(row) {
  return {
    ...row,
    registerAt: formatDateTime(row.registerAt),
    lastLoginAt: formatDateTime(row.lastLoginAt),
  }
}

async function loadRows() {
  loading.value = true
  try {
    const data = await adminApi.listUsers({
      page: page.value,
      pageSize,
      keyword: filters.keyword.trim(),
      userType: filters.userType,
      status: filters.status,
    })
    rows.value = Array.isArray(data?.records) ? data.records.map(normalizeRow) : []
    total.value = data?.total || 0
  } catch (error) {
    console.error(error)
    rows.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

async function openDetail(row) {
  try {
    const detail = await adminApi.userDetail(row.id)
    current.value = normalizeRow(detail)
    detailVisible.value = true
  } catch (error) {
    console.error(error)
  }
}

async function toggleStatus(row) {
  const nextStatus = row.status === 'active' ? 'disabled' : 'active'
  try {
    await adminApi.updateUserStatus(row.id, nextStatus)
    await loadRows()
  } catch (error) {
    console.error(error)
  }
}

async function freezeUser(row) {
  try {
    await adminApi.freezeUser(row.id, {
      durationDays: 7,
      reason: '违规行为处理',
    })
    await loadRows()
  } catch (error) {
    console.error(error)
  }
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

watch(
  () => [filters.keyword, filters.userType, filters.status],
  () => {
    page.value = 1
    loadRows()
  },
)

watch(page, () => {
  loadRows()
})

onMounted(() => {
  loadRows()
})
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
            <tr v-for="row in rows" :key="row.id">
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
            <tr v-if="!rows.length && !loading">
              <td colspan="9" class="empty">暂无符合筛选条件的用户</td>
            </tr>
          </tbody>
        </table>
      </div>

      <PaginationBar
        :page="page"
        :page-size="pageSize"
        :total="total"
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
