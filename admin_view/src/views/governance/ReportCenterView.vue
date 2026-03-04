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
  status: '',
})

const closeVisible = ref(false)
const current = ref(null)
const closeResult = ref('')
const closeWithPenalty = ref(false)
const stats = ref({ pending: 0, processing: 0, closed: 0 })

function normalizeRow(row) {
  return {
    ...row,
    createdAt: formatDateTime(row.createdAt),
  }
}

async function loadRows() {
  loading.value = true
  try {
    const data = await adminApi.listReports({
      page: page.value,
      pageSize,
      keyword: filters.keyword.trim(),
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

async function loadStats() {
  try {
    const [pending, processing, closed] = await Promise.all([
      adminApi.listReports({ page: 1, pageSize: 1, status: 'pending' }),
      adminApi.listReports({ page: 1, pageSize: 1, status: 'processing' }),
      adminApi.listReports({ page: 1, pageSize: 1, status: 'closed' }),
    ])
    stats.value = {
      pending: pending?.total || 0,
      processing: processing?.total || 0,
      closed: closed?.total || 0,
    }
  } catch (error) {
    console.error(error)
  }
}

function statusType(status) {
  if (status === 'pending') {
    return 'pending'
  }
  if (status === 'processing') {
    return 'info'
  }
  return 'success'
}

async function acceptReport(row) {
  try {
    await adminApi.acceptReport(row.id, '已受理，进入核查流程')
    await Promise.all([loadRows(), loadStats()])
  } catch (error) {
    console.error(error)
  }
}

function openClose(row) {
  current.value = row
  closeResult.value = row.result === '-' ? '' : row.result
  closeWithPenalty.value = false
  closeVisible.value = true
}

async function submitClose() {
  if (!current.value || !closeResult.value.trim()) {
    return
  }
  try {
    await adminApi.closeReport(current.value.id, {
      result: closeResult.value.trim(),
      withPenalty: closeWithPenalty.value,
    })
    closeVisible.value = false
    await Promise.all([loadRows(), loadStats()])
  } catch (error) {
    console.error(error)
  }
}

watch(
  () => [filters.keyword, filters.status],
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
  loadStats()
})
</script>

<template>
  <section class="page-wrap">
    <div class="grid-3">
      <article class="card stat-card">
        <p>待受理举报</p>
        <h3>{{ stats.pending }}</h3>
      </article>
      <article class="card stat-card">
        <p>处理中举报</p>
        <h3>{{ stats.processing }}</h3>
      </article>
      <article class="card stat-card">
        <p>已结案</p>
        <h3>{{ stats.closed }}</h3>
      </article>
    </div>

    <article class="card panel">
      <div class="toolbar">
        <input v-model="filters.keyword" class="field" placeholder="搜索举报编号/目标/举报人" />
        <select v-model="filters.status" class="field">
          <option value="">全部状态</option>
          <option value="pending">待处理</option>
          <option value="processing">处理中</option>
          <option value="closed">已结案</option>
        </select>
      </div>

      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>举报编号</th>
              <th>举报人</th>
              <th>举报对象</th>
              <th>举报原因</th>
              <th>状态</th>
              <th>提交时间</th>
              <th>处理人</th>
              <th>处理结论</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.id">
              <td>{{ row.reportNo }}</td>
              <td>{{ row.reporter }}</td>
              <td>{{ row.targetType }} / {{ row.targetName }}</td>
              <td class="reason">{{ row.reason }}</td>
              <td>
                <StatusBadge :type="statusType(row.status)" :text="row.statusLabel" />
              </td>
              <td>{{ row.createdAt }}</td>
              <td>{{ row.processor }}</td>
              <td>{{ row.result }}</td>
              <td class="actions">
                <button
                  class="btn btn-default"
                  :disabled="row.status !== 'pending'"
                  @click="acceptReport(row)"
                >
                  受理
                </button>
                <button
                  class="btn btn-primary"
                  :disabled="row.status === 'closed'"
                  @click="openClose(row)"
                >
                  结案
                </button>
              </td>
            </tr>
            <tr v-if="!rows.length && !loading">
              <td colspan="9" class="empty">暂无符合条件的举报记录</td>
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

    <AppModal v-model="closeVisible" title="举报结案处理" width="560px">
      <div class="close-form">
        <p v-if="current" class="close-target">
          当前举报：{{ current.reportNo }}（{{ current.targetType }} / {{ current.targetName }}）
        </p>
        <textarea
          v-model="closeResult"
          class="field result-input"
          placeholder="请填写结案说明与处理结果"
        ></textarea>
        <label class="checkbox">
          <input v-model="closeWithPenalty" type="checkbox" />
          <span>联动处罚记录</span>
        </label>
      </div>
      <template #footer="{ close }">
        <button class="btn btn-default" @click="close">取消</button>
        <button class="btn btn-primary" @click="submitClose">确认结案</button>
      </template>
    </AppModal>
  </section>
</template>

<style scoped>
.page-wrap {
  display: grid;
  gap: 14px;
}

.stat-card {
  padding: 16px;
}

.stat-card p {
  margin: 0;
  color: var(--text-secondary);
}

.stat-card h3 {
  margin: 8px 0 0;
  font-size: 30px;
  line-height: 1;
}

.panel {
  padding: 14px;
}

.toolbar {
  display: grid;
  grid-template-columns: 1.2fr 0.6fr;
  gap: 10px;
  margin-bottom: 12px;
}

.reason {
  max-width: 280px;
  white-space: normal;
  line-height: 1.4;
}

.actions {
  display: flex;
  gap: 6px;
}

.actions .btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.empty {
  text-align: center;
  color: var(--text-secondary);
  padding: 20px 0;
}

.close-form {
  display: grid;
  gap: 10px;
}

.close-target {
  margin: 0;
  padding: 8px 10px;
  border-radius: 8px;
  background: #f8fafc;
}

.result-input {
  min-height: 130px;
  resize: vertical;
}

.checkbox {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: var(--text-secondary);
}

@media (max-width: 1024px) {
  .toolbar {
    grid-template-columns: 1fr;
  }

  .actions {
    flex-wrap: wrap;
  }
}
</style>
