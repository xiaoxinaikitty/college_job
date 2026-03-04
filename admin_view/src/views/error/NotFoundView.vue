<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()
</script>

<template>
  <div class="not-found card">
    <h1>404</h1>
    <p>页面不存在或已被移动</p>
    <button class="btn btn-primary" @click="router.push('/admin/dashboard')">返回首页</button>
  </div>
</template>

<style scoped>
.not-found {
  min-height: 100vh;
  margin: 0;
  border-radius: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 10px;
}

h1 {
  margin: 0;
  font-size: 64px;
}

p {
  margin: 0;
  color: var(--text-secondary);
}
</style>
