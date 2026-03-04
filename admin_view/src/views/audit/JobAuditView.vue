<script setup>
import { computed, reactive, ref } from 'vue'
import AppModal from '../../components/ui/AppModal.vue'
import PaginationBar from '../../components/ui/PaginationBar.vue'
import StatusBadge from '../../components/ui/StatusBadge.vue'
import { createJobAudits } from '../../mock/adminData'

const rows = ref(createJobAudits())
const page = ref(1)
const pageSize = 10

const filters = reactive({
  keyword: '',
  status: '',
  city: '',
})

const rejectVisible = ref(false)
const detailVisible = ref(false)
const current = ref(null)
const rejectReason = ref('')

const filteredRows = computed(() =>
  rows.value.filter((row) => {
    const keyword = filters.keyword.trim().toLowerCase()
    const passKeyword =
      !keyword ||
      row.title.toLowerCase().includes(keyword) ||
      row.enterpriseName.toLowerCase().includes(keyword)
    const passStatus = !filters.status || row.status === filters.status
    const passCity = !filters.city || row.city === filters.city
    return passKeyword && passStatus && passCity
  }),
)

const displayRows = computed(() => {
  const start = (page.value - 1) * pageSize
  return filteredRows.value.slice(start, start + pageSize)
})

const cities = computed(() => Array.from(new Set(rows.value.map((item) => item.city))))

function statusType(status) {
  if (status === 'approved') {
    return 'success'
  }
  if (status === 'rejected') {
    return 'danger'
  }
  return 'pending'
}

function openDetail(row) {
  current.value = row
  detailVisible.value = true
}

function approveRow(row) {
  row.status = 'approved'
  row.statusLabel = '已上线'
  row.reason = ''
}

function openReject(row) {
  current.value = row
  rejectReason.value = row.reason || ''
  rejectVisible.value = true
}

function submitReject() {
  if (!current.value || !rejectReason.value.trim()) {
    return
  }
  current.value.status = 'rejected'
  current.value.statusLabel = '已驳回'
  current.value.reason = rejectReason.value.trim()
  rejectVisible.value = false
}
</script>

<template>
  <section class="page-wrap">
    <article class="card panel">
      <div class="toolbar">
        <input v-model="filters.keyword" class="field" placeholder="搜索岗位/企业" />
        <select v-model="filters.status" class="field">
          <option value="">全部状态</option>
          <option value="pending">待审核</option>
          <option value="approved">已上线</option>
          <option value="rejected">已驳回</option>
        </select>
        <select v-model="filters.city" class="field">
          <option value="">全部城市</option>
          <option v-for="city in cities" :key="city" :value="city">{{ city }}</option>
        </select>
      </div>

      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>岗位ID</th>
              <th>岗位名称</th>
              <th>企业名称</th>
              <th>城市</th>
              <th>分类</th>
              <th>薪资</th>
              <th>风险等级</th>
              <th>提交时间</th>
              <th>状态</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in displayRows" :key="row.id">
              <td>#{{ row.id }}</td>
              <td>{{ row.title }}</td>
              <td>{{ row.enterpriseName }}</td>
              <td>{{ row.city }}</td>
              <td>{{ row.category }}</td>
              <td>{{ row.salaryRange }}</td>
              <td>{{ row.riskLevel }}</td>
              <td>{{ row.submittedAt }}</td>
              <td><StatusBadge :type="statusType(row.status)" :text="row.statusLabel" /></td>
              <td class="actions">
                <button class="btn btn-default" @click="openDetail(row)">查看</button>
                <button
                  class="btn btn-primary"
                  :disabled="row.status !== 'pending'"
                  @click="approveRow(row)"
                >
                  通过
                </button>
                <button class="btn btn-danger" @click="openReject(row)">驳回</button>
              </td>
            </tr>
            <tr v-if="!displayRows.length">
              <td colspan="10" class="empty">暂无符合条件的岗位审核数据</td>
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

    <AppModal v-model="detailVisible" title="岗位审核详情" width="720px">
      <div v-if="current" class="detail-grid">
        <p><span>岗位：</span>{{ current.title }}</p>
        <p><span>企业：</span>{{ current.enterpriseName }}</p>
        <p><span>城市：</span>{{ current.city }}</p>
        <p><span>分类：</span>{{ current.category }}</p>
        <p><span>薪资：</span>{{ current.salaryRange }}</p>
        <p><span>风险：</span>{{ current.riskLevel }}</p>
        <p><span>提交：</span>{{ current.submittedAt }}</p>
        <p><span>驳回原因：</span>{{ current.reason || '-' }}</p>
      </div>
      <template #footer="{ close }">
        <button class="btn btn-default" @click="close">关闭</button>
      </template>
    </AppModal>

    <AppModal v-model="rejectVisible" title="岗位驳回原因" width="520px">
      <textarea v-model="rejectReason" class="field reason" placeholder="请输入驳回原因"></textarea>
      <template #footer="{ close }">
        <button class="btn btn-default" @click="close">取消</button>
        <button class="btn btn-danger" @click="submitReject">确认驳回</button>
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
  grid-template-columns: 1.2fr 0.8fr 0.8fr;
  gap: 10px;
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

.detail-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px;
}

.detail-grid p {
  margin: 0;
  padding: 8px 10px;
  border-radius: 8px;
  background: #f8fafc;
}

.detail-grid span {
  color: var(--text-secondary);
}

.reason {
  min-height: 120px;
  resize: vertical;
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
