<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import MetricCard from '../../components/ui/MetricCard.vue'
import StatusBadge from '../../components/ui/StatusBadge.vue'
import {
  dashboardMetrics,
  dashboardPipeline,
  dashboardTodo,
  dashboardTrend,
} from '../../mock/adminData'

const router = useRouter()

const maxApplication = computed(() =>
  Math.max(...dashboardTrend.map((item) => item.application), 1),
)

function openTodo(routePath) {
  router.push(routePath)
}

function toStatusType(type) {
  if (type === 'pending') {
    return 'pending'
  }
  if (type === 'danger') {
    return 'danger'
  }
  if (type === 'success') {
    return 'success'
  }
  return 'info'
}
</script>

<template>
  <section class="dashboard-page">
    <div class="grid-3 metric-grid">
      <MetricCard
        v-for="item in dashboardMetrics"
        :key="item.key"
        :title="item.label"
        :value="item.value"
        :trend="item.trend"
        :trend-up="item.trendUp"
      />
    </div>

    <div class="grid-2">
      <article class="card panel">
        <div class="panel-header">
          <h3>核心趋势（近 7 日）</h3>
          <span class="panel-subtitle">投递量越高，柱体越长</span>
        </div>
        <div class="trend-list">
          <div v-for="row in dashboardTrend" :key="row.day" class="trend-row">
            <div class="trend-label">{{ row.day }}</div>
            <div class="trend-bar-wrap">
              <div
                class="trend-bar"
                :style="{ width: `${(row.application / maxApplication) * 100}%` }"
              ></div>
            </div>
            <div class="trend-values">
              <span>注册 {{ row.register }}</span>
              <span>投递 {{ row.application }}</span>
              <span>Offer {{ row.offer }}</span>
            </div>
          </div>
        </div>
      </article>

      <article class="card panel">
        <div class="panel-header">
          <h3>审核与治理状态</h3>
          <span class="panel-subtitle">平台风险与待办实时分布</span>
        </div>
        <div class="pipeline-list">
          <div v-for="item in dashboardPipeline" :key="item.label" class="pipeline-row">
            <p>{{ item.label }}</p>
            <div class="pipeline-right">
              <StatusBadge :type="toStatusType(item.type)" :text="`${item.value}`" />
            </div>
          </div>
        </div>
      </article>
    </div>

    <div class="grid-2">
      <article class="card panel">
        <div class="panel-header">
          <h3>管理待办</h3>
          <span class="panel-subtitle">可快速进入对应处理模块</span>
        </div>
        <div class="todo-list">
          <button
            v-for="item in dashboardTodo"
            :key="item.id"
            class="todo-item"
            @click="openTodo(item.route)"
          >
            <div>
              <p class="todo-title">{{ item.title }}</p>
              <p class="todo-desc">点击进入处理流程</p>
            </div>
            <span class="todo-count">{{ item.count }}</span>
          </button>
        </div>
      </article>

      <article class="card panel">
        <div class="panel-header">
          <h3>运维通知</h3>
          <span class="panel-subtitle">系统公告与审核策略提醒</span>
        </div>
        <ul class="notice-list">
          <li>
            <p>03-04 09:00</p>
            <span>岗位审核策略已升级，新增“引流关键词”风险识别规则。</span>
          </li>
          <li>
            <p>03-04 08:30</p>
            <span>企业认证资料上传链路恢复正常，当前无异常告警。</span>
          </li>
          <li>
            <p>03-03 18:00</p>
            <span>举报结案新增处罚模板，建议治理专员按模板执行。</span>
          </li>
        </ul>
      </article>
    </div>
  </section>
</template>

<style scoped>
.dashboard-page {
  display: grid;
  gap: 14px;
}

.metric-grid {
  grid-template-columns: repeat(6, minmax(0, 1fr));
}

.panel {
  padding: 14px 16px;
}

.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  margin-bottom: 12px;
}

.panel-header h3 {
  margin: 0;
  font-size: 16px;
}

.panel-subtitle {
  color: var(--text-secondary);
  font-size: 12px;
}

.trend-list {
  display: grid;
  gap: 10px;
}

.trend-row {
  display: grid;
  grid-template-columns: 44px 1fr auto;
  align-items: center;
  gap: 8px;
}

.trend-label {
  margin: 0;
  color: var(--text-secondary);
}

.trend-bar-wrap {
  height: 12px;
  border-radius: 999px;
  background: #eff6ff;
  overflow: hidden;
}

.trend-bar {
  height: 100%;
  border-radius: 999px;
  background: linear-gradient(90deg, #2563eb 0%, #0ea5e9 100%);
}

.trend-values {
  display: flex;
  gap: 8px;
  color: var(--text-secondary);
  font-size: 12px;
}

.pipeline-list {
  display: grid;
  gap: 10px;
}

.pipeline-row {
  border: 1px solid var(--line-color);
  border-radius: 10px;
  padding: 10px 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.pipeline-row p {
  margin: 0;
  font-weight: 600;
}

.todo-list {
  display: grid;
  gap: 10px;
}

.todo-item {
  width: 100%;
  border: 1px solid var(--line-color);
  border-radius: 12px;
  background: #fff;
  padding: 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  cursor: pointer;
  transition: border-color 0.2s ease;
}

.todo-item:hover {
  border-color: var(--brand);
}

.todo-title {
  margin: 0;
  text-align: left;
  font-weight: 700;
}

.todo-desc {
  margin: 4px 0 0;
  text-align: left;
  color: var(--text-secondary);
  font-size: 12px;
}

.todo-count {
  min-width: 34px;
  height: 34px;
  padding: 0 8px;
  border-radius: 999px;
  background: var(--brand-weak);
  color: var(--brand);
  font-weight: 700;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.notice-list {
  margin: 0;
  padding: 0;
  list-style: none;
  display: grid;
  gap: 10px;
}

.notice-list li {
  border-left: 3px solid #bfdbfe;
  background: #f8fafc;
  border-radius: 8px;
  padding: 8px 10px;
}

.notice-list p {
  margin: 0;
  color: #1d4ed8;
  font-size: 12px;
  font-weight: 700;
}

.notice-list span {
  margin-top: 3px;
  display: inline-block;
}

@media (max-width: 1400px) {
  .metric-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 860px) {
  .metric-grid {
    grid-template-columns: 1fr;
  }

  .trend-row {
    grid-template-columns: 40px 1fr;
  }

  .trend-values {
    grid-column: 1 / -1;
  }
}
</style>
