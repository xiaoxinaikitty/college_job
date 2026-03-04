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
  status: '',
  rating: '',
})

function stars(num) {
  return '★'.repeat(num) + '☆'.repeat(5 - num)
}

function normalizeRow(row) {
  return {
    ...row,
    createdAt: formatDateTime(row.createdAt),
  }
}

async function loadRows() {
  loading.value = true
  try {
    const data = await adminApi.listReviews({
      page: page.value,
      pageSize,
      keyword: filters.keyword.trim(),
      status: filters.status,
      rating: filters.rating || undefined,
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

async function markRisk(row) {
  try {
    await adminApi.updateReviewStatus(row.id, {
      status: 'risk',
      note: '包含风险内容，已标记',
    })
    await loadRows()
  } catch (error) {
    console.error(error)
  }
}

async function markNormal(row) {
  try {
    await adminApi.updateReviewStatus(row.id, {
      status: 'normal',
      note: '复核无风险',
    })
    await loadRows()
  } catch (error) {
    console.error(error)
  }
}

watch(
  () => [filters.keyword, filters.status, filters.rating],
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
        <input v-model="filters.keyword" class="field" placeholder="搜索评价内容/评价人/企业" />
        <select v-model="filters.status" class="field">
          <option value="">全部状态</option>
          <option value="normal">正常</option>
          <option value="risk">风险</option>
        </select>
        <select v-model="filters.rating" class="field">
          <option value="">全部评分</option>
          <option value="5">5分</option>
          <option value="4">4分</option>
          <option value="3">3分</option>
          <option value="2">2分</option>
          <option value="1">1分</option>
        </select>
      </div>

      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>评价ID</th>
              <th>评价人</th>
              <th>企业</th>
              <th>评分</th>
              <th>评价内容</th>
              <th>状态</th>
              <th>时间</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.id">
              <td>#{{ row.id }}</td>
              <td>{{ row.reviewer }}</td>
              <td>{{ row.enterpriseName }}</td>
              <td class="stars">{{ stars(row.rating) }}</td>
              <td class="content">{{ row.content }}</td>
              <td>
                <StatusBadge :type="row.status === 'risk' ? 'danger' : 'success'" :text="row.statusLabel" />
              </td>
              <td>{{ row.createdAt }}</td>
              <td class="actions">
                <button class="btn btn-default" @click="markNormal(row)">标记正常</button>
                <button class="btn btn-danger" @click="markRisk(row)">标记风险</button>
              </td>
            </tr>
            <tr v-if="!rows.length && !loading">
              <td colspan="8" class="empty">暂无符合条件的评价记录</td>
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
}

.panel {
  padding: 14px;
}

.toolbar {
  display: grid;
  grid-template-columns: 1.2fr 0.7fr 0.7fr;
  gap: 10px;
  margin-bottom: 12px;
}

.stars {
  color: #d97706;
  font-weight: 700;
}

.content {
  max-width: 280px;
  white-space: normal;
  line-height: 1.4;
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

@media (max-width: 1024px) {
  .toolbar {
    grid-template-columns: 1fr;
  }

  .actions {
    flex-wrap: wrap;
  }
}
</style>
