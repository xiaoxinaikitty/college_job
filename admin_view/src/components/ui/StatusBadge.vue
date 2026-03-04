<script setup>
import { computed } from 'vue'

const props = defineProps({
  type: {
    type: String,
    default: 'info',
  },
  text: {
    type: String,
    required: true,
  },
})

const cls = computed(() => {
  if (props.type === 'success') {
    return 'status-success'
  }
  if (props.type === 'danger') {
    return 'status-danger'
  }
  if (props.type === 'pending') {
    return 'status-pending'
  }
  return 'status-info'
})
</script>

<template>
  <span :class="['status-badge', cls]">{{ text }}</span>
</template>
