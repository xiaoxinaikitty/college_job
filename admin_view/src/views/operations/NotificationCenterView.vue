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

const createVisible = ref(false)
const createForm = reactive({
  title: '',
  channel: '站内消息',
  audience: '全体用户',
})

function normalizeRow(row) {
  return {
    ...row,
    publishAt: formatDateTime(row.publishAt),
  }
}

async function loadRows() {
  loading.value = true
  try {
    const data = await adminApi.listNotifications({
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

function statusType(status) {
  if (status === 'published') {
    return 'success'
  }
  return 'pending'
}

async function publish(row) {
  try {
    await adminApi.publishNotification(row.id)
    await loadRows()
  } catch (error) {
    console.error(error)
  }
}

function openCreate() {
  createForm.title = ''
  createForm.channel = '站内消息'
  createForm.audience = '全体用户'
  createVisible.value = true
}

async function submitCreate() {
  if (!createForm.title.trim()) {
    return
  }
  try {
    await adminApi.createNotification({
      title: createForm.title.trim(),
      channel: createForm.channel,
      audience: createForm.audience,
    })
    createVisible.value = false
    page.value = 1
    await loadRows()
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
})
</script>

<template>
  <section class="page-wrap">
    <article class="card panel">
      <div class="toolbar">
        <div class="toolbar-left">
          <input v-model="filters.keyword" class="field" placeholder="搜索标题/接收范围" />
          <select v-model="filters.status" class="field">
            <option value="">全部状态</option>
            <option value="draft">草稿</option>
            <option value="published">已发布</option>
          </select>
        </div>
        <button class="btn btn-primary" @click="openCreate">新建通知</button>
      </div>

      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>标题</th>
              <th>渠道</th>
              <th>接收范围</th>
              <th>状态</th>
              <th>发布时间</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.id">
              <td>#{{ row.id }}</td>
              <td>{{ row.title }}</td>
              <td>{{ row.channel }}</td>
              <td>{{ row.audience }}</td>
              <td><StatusBadge :type="statusType(row.status)" :text="row.statusLabel" /></td>
              <td>{{ row.publishAt }}</td>
              <td>
                <button
                  class="btn btn-default"
                  :disabled="row.status === 'published'"
                  @click="publish(row)"
                >
                  发布
                </button>
              </td>
            </tr>
            <tr v-if="!rows.length && !loading">
              <td colspan="7" class="empty">暂无通知数据</td>
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

    <AppModal v-model="createVisible" title="新建通知" width="560px">
      <div class="form-grid">
        <label>
          <span>通知标题</span>
          <input v-model="createForm.title" class="field" />
        </label>
        <label>
          <span>通知渠道</span>
          <select v-model="createForm.channel" class="field">
            <option value="站内消息">站内消息</option>
            <option value="全站公告">全站公告</option>
          </select>
        </label>
        <label class="full">
          <span>接收范围</span>
          <select v-model="createForm.audience" class="field">
            <option value="全体用户">全体用户</option>
            <option value="学生用户">学生用户</option>
            <option value="企业用户">企业用户</option>
            <option value="待审核企业">待审核企业</option>
          </select>
        </label>
      </div>
      <template #footer="{ close }">
        <button class="btn btn-default" @click="close">取消</button>
        <button class="btn btn-primary" @click="submitCreate">保存草稿</button>
      </template>
    </AppModal>
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
  display: flex;
  justify-content: space-between;
  gap: 10px;
  margin-bottom: 12px;
}

.toolbar-left {
  flex: 1;
  display: grid;
  grid-template-columns: 1.2fr 0.7fr;
  gap: 10px;
}

.empty {
  text-align: center;
  color: var(--text-secondary);
  padding: 20px 0;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.form-grid label {
  display: grid;
  gap: 6px;
}

.form-grid span {
  color: var(--text-secondary);
  font-size: 12px;
}

.form-grid .full {
  grid-column: 1 / -1;
}

@media (max-width: 1024px) {
  .toolbar {
    flex-direction: column;
  }

  .toolbar-left {
    grid-template-columns: 1fr;
  }

  .form-grid {
    grid-template-columns: 1fr;
  }
}
</style>
