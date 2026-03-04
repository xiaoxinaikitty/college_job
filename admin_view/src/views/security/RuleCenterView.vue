<script setup>
import { onMounted, ref } from 'vue'
import { adminApi, formatDateTime } from '../../services/adminApi'

const rows = ref([])

function normalizeRow(row) {
  return {
    ...row,
    updatedAt: formatDateTime(row.updatedAt),
  }
}

async function loadRows() {
  try {
    const data = await adminApi.listRules()
    rows.value = Array.isArray(data) ? data.map(normalizeRow) : []
  } catch (error) {
    console.error(error)
    rows.value = []
  }
}

async function toggleRule(row) {
  try {
    await adminApi.toggleRule(row.id, !row.enabled)
    await loadRows()
  } catch (error) {
    console.error(error)
  }
}

onMounted(() => {
  loadRows()
})
</script>

<template>
  <section class="page-wrap">
    <article class="card panel">
      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>规则ID</th>
              <th>所属模块</th>
              <th>规则名称</th>
              <th>触发条件</th>
              <th>处理动作</th>
              <th>状态</th>
              <th>更新时间</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.id">
              <td>#{{ row.id }}</td>
              <td>{{ row.module }}</td>
              <td>{{ row.ruleName }}</td>
              <td class="content">{{ row.hitCondition }}</td>
              <td class="content">{{ row.action }}</td>
              <td>
                <span :class="row.enabled ? 'enabled' : 'disabled'">
                  {{ row.enabled ? '启用中' : '已停用' }}
                </span>
              </td>
              <td>{{ row.updatedAt }}</td>
              <td>
                <button class="btn btn-default" @click="toggleRule(row)">
                  {{ row.enabled ? '停用' : '启用' }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
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

.content {
  white-space: normal;
  line-height: 1.4;
  max-width: 260px;
}

.enabled {
  color: var(--success);
  font-weight: 700;
}

.disabled {
  color: var(--text-secondary);
  font-weight: 700;
}
</style>
