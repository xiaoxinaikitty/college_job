<script setup>
defineProps({
  title: {
    type: String,
    required: true,
  },
  value: {
    type: [String, Number],
    required: true,
  },
  trend: {
    type: String,
    default: '',
  },
  trendUp: {
    type: Boolean,
    default: true,
  },
})
</script>

<template>
  <article class="metric card">
    <p class="metric-title">{{ title }}</p>
    <p class="metric-value">{{ value }}</p>
    <p v-if="trend" :class="['metric-trend', trendUp ? 'up' : 'down']">
      {{ trendUp ? '↑' : '↓' }} {{ trend }}
    </p>
  </article>
</template>

<style scoped>
.metric {
  padding: 14px 16px;
}

.metric-title {
  margin: 0;
  color: var(--text-secondary);
  font-size: 12px;
}

.metric-value {
  margin: 8px 0 0;
  font-size: 28px;
  font-weight: 800;
  line-height: 1;
}

.metric-trend {
  margin: 8px 0 0;
  font-size: 12px;
  font-weight: 700;
}

.metric-trend.up {
  color: var(--success);
}

.metric-trend.down {
  color: var(--danger);
}
</style>
