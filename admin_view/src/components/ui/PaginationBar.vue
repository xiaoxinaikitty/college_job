<script setup>
const props = defineProps({
  total: {
    type: Number,
    default: 0,
  },
  page: {
    type: Number,
    default: 1,
  },
  pageSize: {
    type: Number,
    default: 10,
  },
})

const emit = defineEmits(['update:page'])

function goPrev() {
  if (props.page <= 1) {
    return
  }
  emit('update:page', props.page - 1)
}

function goNext() {
  const totalPage = Math.max(1, Math.ceil(props.total / props.pageSize))
  if (props.page >= totalPage) {
    return
  }
  emit('update:page', props.page + 1)
}
</script>

<template>
  <div class="pager">
    <span>共 {{ total }} 条</span>
    <button class="btn btn-default" @click="goPrev">上一页</button>
    <span>{{ page }}</span>
    <button class="btn btn-default" @click="goNext">下一页</button>
  </div>
</template>

<style scoped>
.pager {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 8px;
  margin-top: 12px;
  color: var(--text-secondary);
}
</style>
