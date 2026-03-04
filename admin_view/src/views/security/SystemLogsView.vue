<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import PaginationBar from '../../components/ui/PaginationBar.vue'
import { adminApi, formatDateTime } from '../../services/adminApi'

const rows = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 10
const loading = ref(false)

const filters = reactive({
  keyword: '',
  module: '',
  result: '',
})

const modules = computed(() => Array.from(new Set(rows.value.map((item) => item.module).filter(Boolean))))

function normalizeRow(row) {
  return {
    ...row,
    createdAt: formatDateTime(row.createdAt),
  }
}

async function loadRows() {
  loading.value = true
  try {
    const data = await adminApi.listLogs({
      page: page.value,
      pageSize,
      keyword: filters.keyword.trim(),
      module: filters.module,
      result: filters.result,
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

watch(
  () => [filters.keyword, filters.module, filters.result],
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
        <input v-model="filters.keyword" class="field" placeholder="搜索操作人/动作/目标" />
        <select v-model="filters.module" class="field">
          <option value="">全部模块</option>
          <option v-for="moduleName in modules" :key="moduleName" :value="moduleName">
            {{ moduleName }}
          </option>
        </select>
        <select v-model="filters.result" class="field">
          <option value="">全部结果</option>
          <option value="成功">成功</option>
          <option value="失败">失败</option>
        </select>
      </div>

      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>日志ID</th>
              <th>操作人</th>
              <th>模块</th>
              <th>动作</th>
              <th>操作目标</th>
              <th>IP</th>
              <th>结果</th>
              <th>时间</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.id">
              <td>#{{ row.id }}</td>
              <td>{{ row.operator }}</td>
              <td>{{ row.module }}</td>
              <td>{{ row.action }}</td>
              <td>{{ row.target }}</td>
              <td>{{ row.ip }}</td>
              <td>
                <span :class="row.result === '成功' ? 'success' : 'danger'">{{ row.result }}</span>
              </td>
              <td>{{ row.createdAt }}</td>
            </tr>
            <tr v-if="!rows.length && !loading">
              <td colspan="8" class="empty">暂无日志数据</td>
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
  grid-template-columns: 1.2fr 0.8fr 0.8fr;
  gap: 10px;
  margin-bottom: 12px;
}

.success {
  color: var(--success);
  font-weight: 700;
}

.danger {
  color: var(--danger);
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
