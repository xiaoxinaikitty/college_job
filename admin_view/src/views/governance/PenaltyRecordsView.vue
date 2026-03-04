<script setup>
import { computed, reactive, ref } from 'vue'
import AppModal from '../../components/ui/AppModal.vue'
import PaginationBar from '../../components/ui/PaginationBar.vue'
import StatusBadge from '../../components/ui/StatusBadge.vue'
import { createPenalties } from '../../mock/adminData'

const rows = ref(createPenalties())
const page = ref(1)
const pageSize = 10

const filters = reactive({
  keyword: '',
  targetType: '',
  status: '',
})

const createVisible = ref(false)
const createForm = reactive({
  target: '',
  targetType: '企业',
  action: '',
  severity: '中',
  reason: '',
})

const filteredRows = computed(() =>
  rows.value.filter((row) => {
    const keyword = filters.keyword.trim().toLowerCase()
    const passKeyword =
      !keyword ||
      row.target.toLowerCase().includes(keyword) ||
      row.action.toLowerCase().includes(keyword)
    const passType = !filters.targetType || row.targetType === filters.targetType
    const passStatus = !filters.status || row.status === filters.status
    return passKeyword && passType && passStatus
  }),
)

const displayRows = computed(() => {
  const start = (page.value - 1) * pageSize
  return filteredRows.value.slice(start, start + pageSize)
})

function statusType(status) {
  if (status === 'effective') {
    return 'danger'
  }
  return 'success'
}

function revoke(row) {
  row.status = 'expired'
  row.statusLabel = '已结束'
}

function openCreate() {
  createForm.target = ''
  createForm.targetType = '企业'
  createForm.action = ''
  createForm.severity = '中'
  createForm.reason = ''
  createVisible.value = true
}

function submitCreate() {
  if (!createForm.target.trim() || !createForm.action.trim() || !createForm.reason.trim()) {
    return
  }
  rows.value.unshift({
    id: Date.now(),
    target: createForm.target.trim(),
    targetType: createForm.targetType,
    action: createForm.action.trim(),
    severity: createForm.severity,
    status: 'effective',
    statusLabel: '生效中',
    operator: '系统管理员',
    createdAt: new Date().toLocaleString('zh-CN', { hour12: false }),
    reason: createForm.reason.trim(),
  })
  createVisible.value = false
}
</script>

<template>
  <section class="page-wrap">
    <article class="card panel">
      <div class="toolbar">
        <div class="toolbar-left">
          <input v-model="filters.keyword" class="field" placeholder="搜索处罚目标/动作" />
          <select v-model="filters.targetType" class="field">
            <option value="">全部对象类型</option>
            <option value="学生">学生</option>
            <option value="企业">企业</option>
          </select>
          <select v-model="filters.status" class="field">
            <option value="">全部状态</option>
            <option value="effective">生效中</option>
            <option value="expired">已结束</option>
          </select>
        </div>
        <button class="btn btn-primary" @click="openCreate">新增处罚</button>
      </div>

      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>记录ID</th>
              <th>处罚对象</th>
              <th>对象类型</th>
              <th>处罚动作</th>
              <th>严重等级</th>
              <th>状态</th>
              <th>处理人</th>
              <th>创建时间</th>
              <th>原因</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in displayRows" :key="row.id">
              <td>#{{ row.id }}</td>
              <td>{{ row.target }}</td>
              <td>{{ row.targetType }}</td>
              <td>{{ row.action }}</td>
              <td>{{ row.severity }}</td>
              <td>
                <StatusBadge :type="statusType(row.status)" :text="row.statusLabel" />
              </td>
              <td>{{ row.operator }}</td>
              <td>{{ row.createdAt }}</td>
              <td class="reason">{{ row.reason }}</td>
              <td>
                <button
                  class="btn btn-default"
                  :disabled="row.status !== 'effective'"
                  @click="revoke(row)"
                >
                  撤销
                </button>
              </td>
            </tr>
            <tr v-if="!displayRows.length">
              <td colspan="10" class="empty">暂无处罚记录</td>
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

    <AppModal v-model="createVisible" title="新增处罚记录" width="620px">
      <div class="form-grid">
        <label>
          <span>处罚对象</span>
          <input v-model="createForm.target" class="field" />
        </label>
        <label>
          <span>对象类型</span>
          <select v-model="createForm.targetType" class="field">
            <option value="学生">学生</option>
            <option value="企业">企业</option>
          </select>
        </label>
        <label>
          <span>处罚动作</span>
          <input v-model="createForm.action" class="field" />
        </label>
        <label>
          <span>严重等级</span>
          <select v-model="createForm.severity" class="field">
            <option value="低">低</option>
            <option value="中">中</option>
            <option value="高">高</option>
          </select>
        </label>
        <label class="full">
          <span>处罚原因</span>
          <textarea v-model="createForm.reason" class="field reason-area"></textarea>
        </label>
      </div>
      <template #footer="{ close }">
        <button class="btn btn-default" @click="close">取消</button>
        <button class="btn btn-primary" @click="submitCreate">确认新增</button>
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
  margin-bottom: 12px;
  display: flex;
  gap: 10px;
  justify-content: space-between;
}

.toolbar-left {
  flex: 1;
  display: grid;
  grid-template-columns: 1.2fr 0.7fr 0.7fr;
  gap: 10px;
}

.reason {
  max-width: 250px;
  white-space: normal;
  line-height: 1.4;
}

.empty {
  text-align: center;
  color: var(--text-secondary);
  padding: 20px 0;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
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

.reason-area {
  min-height: 120px;
  resize: vertical;
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
