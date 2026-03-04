<script setup>
import { computed, reactive, ref } from 'vue'
import AppModal from '../../components/ui/AppModal.vue'
import PaginationBar from '../../components/ui/PaginationBar.vue'
import StatusBadge from '../../components/ui/StatusBadge.vue'
import { createReports } from '../../mock/adminData'

const rows = ref(createReports())
const page = ref(1)
const pageSize = 10

const filters = reactive({
  keyword: '',
  status: '',
})

const closeVisible = ref(false)
const current = ref(null)
const closeResult = ref('')
const closeWithPenalty = ref(false)

const filteredRows = computed(() =>
  rows.value.filter((row) => {
    const keyword = filters.keyword.trim().toLowerCase()
    const passKeyword =
      !keyword ||
      row.reportNo.toLowerCase().includes(keyword) ||
      row.targetName.toLowerCase().includes(keyword) ||
      row.reporter.toLowerCase().includes(keyword)
    const passStatus = !filters.status || row.status === filters.status
    return passKeyword && passStatus
  }),
)

const displayRows = computed(() => {
  const start = (page.value - 1) * pageSize
  return filteredRows.value.slice(start, start + pageSize)
})

const stats = computed(() => ({
  pending: rows.value.filter((item) => item.status === 'pending').length,
  processing: rows.value.filter((item) => item.status === 'processing').length,
  closed: rows.value.filter((item) => item.status === 'closed').length,
}))

function statusType(status) {
  if (status === 'pending') {
    return 'pending'
  }
  if (status === 'processing') {
    return 'info'
  }
  return 'success'
}

function acceptReport(row) {
  row.status = 'processing'
  row.statusLabel = '处理中'
  row.processor = '系统管理员'
  row.result = '已受理，进入核查流程'
}

function openClose(row) {
  current.value = row
  closeResult.value = row.result === '-' ? '' : row.result
  closeWithPenalty.value = false
  closeVisible.value = true
}

function submitClose() {
  if (!current.value || !closeResult.value.trim()) {
    return
  }
  current.value.status = 'closed'
  current.value.statusLabel = '已结案'
  current.value.processor = '系统管理员'
  current.value.result = closeWithPenalty.value
    ? `${closeResult.value.trim()}（已联动处罚）`
    : closeResult.value.trim()
  closeVisible.value = false
}
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
            <tr v-for="row in displayRows" :key="row.id">
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
            <tr v-if="!displayRows.length">
              <td colspan="9" class="empty">暂无符合条件的举报记录</td>
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
