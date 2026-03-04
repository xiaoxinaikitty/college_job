<script setup>
import { onMounted, reactive, ref, watch } from 'vue'
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
  stage: '',
})

const stats = ref({
  total: 0,
  inProgress: 0,
  offer: 0,
  warning: 0,
})

function normalizeRow(row) {
  return {
    ...row,
    submittedAt: formatDateTime(row.submittedAt),
    lastActionAt: formatDateTime(row.lastActionAt),
  }
}

async function loadRows() {
  loading.value = true
  try {
    const data = await adminApi.listApplicationMonitors({
      page: page.value,
      pageSize,
      keyword: filters.keyword.trim(),
      stage: filters.stage,
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
    const [totalResp, progressResp, offerResp, warningResp] = await Promise.all([
      adminApi.listApplicationMonitors({ page: 1, pageSize: 1 }),
      adminApi.listApplicationMonitors({ page: 1, pageSize: 1, stage: '沟通中' }),
      adminApi.listApplicationMonitors({ page: 1, pageSize: 1, stage: 'Offer阶段' }),
      adminApi.listApplicationMonitors({ page: 1, pageSize: 500 }),
    ])
    const warningCount = Array.isArray(warningResp?.records)
      ? warningResp.records.filter((item) => Number(item.overdueHours || 0) > 0).length
      : 0
    stats.value = {
      total: totalResp?.total || 0,
      inProgress: progressResp?.total || 0,
      offer: offerResp?.total || 0,
      warning: warningCount,
    }
  } catch (error) {
    console.error(error)
  }
}

watch(
  () => [filters.keyword, filters.stage],
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
    <div class="grid-4">
      <article class="card stat-card">
        <p>流程总量</p>
        <h3>{{ stats.total }}</h3>
      </article>
      <article class="card stat-card">
        <p>进行中</p>
        <h3>{{ stats.inProgress }}</h3>
      </article>
      <article class="card stat-card">
        <p>Offer阶段</p>
        <h3>{{ stats.offer }}</h3>
      </article>
      <article class="card stat-card warning">
        <p>超时预警</p>
        <h3>{{ stats.warning }}</h3>
      </article>
    </div>

    <article class="card panel">
      <div class="toolbar">
        <input v-model="filters.keyword" class="field" placeholder="搜索投递编号/学生/企业" />
        <select v-model="filters.stage" class="field">
          <option value="">全部阶段</option>
          <option value="沟通中">沟通中</option>
          <option value="面试中">面试中</option>
          <option value="Offer阶段">Offer阶段</option>
          <option value="已淘汰">已淘汰</option>
        </select>
      </div>

      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>投递编号</th>
              <th>学生</th>
              <th>企业</th>
              <th>岗位</th>
              <th>当前阶段</th>
              <th>投递时间</th>
              <th>最近操作</th>
              <th>超时预警</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.id">
              <td>{{ row.applicationNo }}</td>
              <td>{{ row.studentName }}</td>
              <td>{{ row.enterpriseName }}</td>
              <td>{{ row.jobTitle }}</td>
              <td>
                <StatusBadge :type="row.stageStatus" :text="row.currentStage" />
              </td>
              <td>{{ row.submittedAt }}</td>
              <td>{{ row.lastActionAt }}</td>
              <td>
                <span :class="row.overdueHours > 0 ? 'overdue' : 'normal'">
                  {{ row.overdueHours > 0 ? `超时 ${row.overdueHours}h` : '正常' }}
                </span>
              </td>
            </tr>
            <tr v-if="!rows.length && !loading">
              <td colspan="8" class="empty">暂无符合条件的流程数据</td>
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
}

.stat-card.warning {
  background: linear-gradient(145deg, #fff, #fff7ed);
}

.panel {
  padding: 14px;
}

.toolbar {
  display: grid;
  grid-template-columns: 1.2fr 0.8fr;
  gap: 10px;
  margin-bottom: 12px;
}

.overdue {
  color: var(--danger);
  font-weight: 700;
}

.normal {
  color: var(--success);
  font-weight: 700;
}

.empty {
  text-align: center;
  color: var(--text-secondary);
  padding: 20px 0;
}

@media (max-width: 1024px) {
  .toolbar {
    grid-template-columns: 1fr;
  }
}
</style>
