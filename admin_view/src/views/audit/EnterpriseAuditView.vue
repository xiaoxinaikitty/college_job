<script setup>
import { computed, reactive, ref } from 'vue'
import AppModal from '../../components/ui/AppModal.vue'
import PaginationBar from '../../components/ui/PaginationBar.vue'
import StatusBadge from '../../components/ui/StatusBadge.vue'
import { createEnterpriseAudits } from '../../mock/adminData'

const rows = ref(createEnterpriseAudits())
const page = ref(1)
const pageSize = 10

const filters = reactive({
  keyword: '',
  status: '',
  riskLevel: '',
})

const detailVisible = ref(false)
const rejectVisible = ref(false)
const current = ref(null)
const rejectReason = ref('')

const filteredRows = computed(() =>
  rows.value.filter((row) => {
    const keyword = filters.keyword.trim().toLowerCase()
    const passKeyword =
      !keyword ||
      row.enterpriseName.toLowerCase().includes(keyword) ||
      row.creditCode.toLowerCase().includes(keyword)
    const passStatus = !filters.status || row.status === filters.status
    const passRisk = !filters.riskLevel || row.riskLevel === filters.riskLevel
    return passKeyword && passStatus && passRisk
  }),
)

const displayRows = computed(() => {
  const start = (page.value - 1) * pageSize
  return filteredRows.value.slice(start, start + pageSize)
})

const stats = computed(() => ({
  pending: rows.value.filter((item) => item.status === 'pending').length,
  approved: rows.value.filter((item) => item.status === 'approved').length,
  rejected: rows.value.filter((item) => item.status === 'rejected').length,
}))

function openDetail(row) {
  current.value = row
  detailVisible.value = true
}

function approveRow(row) {
  row.status = 'approved'
  row.statusLabel = '已通过'
  row.note = '管理员审核通过'
}

function openReject(row) {
  current.value = row
  rejectReason.value = row.note && row.status === 'rejected' ? row.note : ''
  rejectVisible.value = true
}

function submitReject() {
  if (!current.value) {
    return
  }
  const reason = rejectReason.value.trim()
  if (!reason) {
    return
  }
  current.value.status = 'rejected'
  current.value.statusLabel = '已驳回'
  current.value.note = reason
  rejectVisible.value = false
}

function statusType(status) {
  if (status === 'approved') {
    return 'success'
  }
  if (status === 'rejected') {
    return 'danger'
  }
  return 'pending'
}
</script>

<template>
  <section class="page-wrap">
    <div class="grid-3">
      <article class="card stat-card">
        <p>待审核企业</p>
        <h3>{{ stats.pending }}</h3>
      </article>
      <article class="card stat-card">
        <p>已通过</p>
        <h3>{{ stats.approved }}</h3>
      </article>
      <article class="card stat-card">
        <p>已驳回</p>
        <h3>{{ stats.rejected }}</h3>
      </article>
    </div>

    <article class="card panel">
      <div class="toolbar">
        <input v-model="filters.keyword" class="field" placeholder="搜索企业名称/信用代码" />
        <select v-model="filters.status" class="field">
          <option value="">全部审核状态</option>
          <option value="pending">待审核</option>
          <option value="approved">已通过</option>
          <option value="rejected">已驳回</option>
        </select>
        <select v-model="filters.riskLevel" class="field">
          <option value="">全部风险等级</option>
          <option value="低">低</option>
          <option value="中">中</option>
          <option value="高">高</option>
        </select>
      </div>

      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>申请单号</th>
              <th>企业名称</th>
              <th>统一社会信用代码</th>
              <th>行业/城市</th>
              <th>风险等级</th>
              <th>提交时间</th>
              <th>状态</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in displayRows" :key="row.id">
              <td>#{{ row.id }}</td>
              <td>{{ row.enterpriseName }}</td>
              <td>{{ row.creditCode }}</td>
              <td>{{ row.industry }} / {{ row.city }}</td>
              <td>{{ row.riskLevel }}</td>
              <td>{{ row.submittedAt }}</td>
              <td>
                <StatusBadge :type="statusType(row.status)" :text="row.statusLabel" />
              </td>
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
              <td colspan="8" class="empty">暂无符合条件的数据</td>
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

    <AppModal v-model="detailVisible" title="企业资质详情" width="680px">
      <div v-if="current" class="detail-grid">
        <p><span>企业名称：</span>{{ current.enterpriseName }}</p>
        <p><span>信用代码：</span>{{ current.creditCode }}</p>
        <p><span>行业：</span>{{ current.industry }}</p>
        <p><span>城市：</span>{{ current.city }}</p>
        <p><span>提交人：</span>{{ current.submitter }}</p>
        <p><span>提交时间：</span>{{ current.submittedAt }}</p>
        <p><span>文件地址：</span>{{ current.licenseFileUrl }}</p>
        <p><span>备注：</span>{{ current.note || '-' }}</p>
      </div>
      <template #footer="{ close }">
        <button class="btn btn-default" @click="close">关闭</button>
      </template>
    </AppModal>

    <AppModal v-model="rejectVisible" title="驳回原因" width="520px">
      <textarea
        v-model="rejectReason"
        class="field reason"
        placeholder="请填写驳回原因，便于企业修正后重新提交"
      ></textarea>
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
  grid-template-columns: 1.2fr 0.8fr 0.8fr;
  gap: 10px;
  margin-bottom: 12px;
}

.actions {
  display: flex;
  gap: 6px;
}

.actions .btn:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.empty {
  text-align: center;
  color: var(--text-secondary);
  padding: 20px 0;
}

.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.detail-grid p {
  margin: 0;
  background: #f8fafc;
  padding: 8px 10px;
  border-radius: 8px;
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
