<script setup>
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const form = reactive({
  account: 'admin',
  password: '123456',
})
const loading = ref(false)
const errorText = ref('')

async function handleLogin() {
  errorText.value = ''
  loading.value = true
  try {
    authStore.login(form.account, form.password)
    const redirectPath = route.query.redirect?.toString() || '/admin/dashboard'
    await router.replace(redirectPath)
  } catch (error) {
    errorText.value = error instanceof Error ? error.message : '登录失败，请稍后重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <div class="login-bg-shape shape-one"></div>
    <div class="login-bg-shape shape-two"></div>
    <section class="login-card card">
      <aside class="login-aside">
        <h1>大学生实习求职管理后台</h1>
        <p>统一处理企业审核、岗位审核、用户治理、举报处置与运营数据监控。</p>
        <ul>
          <li>企业资质审核闭环</li>
          <li>岗位风险审核控制</li>
          <li>用户与举报治理</li>
          <li>运营核心指标看板</li>
        </ul>
      </aside>

      <main class="login-main">
        <h2>管理员登录</h2>
        <p class="login-tip">测试账号：admin / 123456</p>
        <form class="form" @submit.prevent="handleLogin">
          <label>
            <span>账号</span>
            <input v-model="form.account" class="field" type="text" autocomplete="username" />
          </label>
          <label>
            <span>密码</span>
            <input v-model="form.password" class="field" type="password" autocomplete="current-password" />
          </label>
          <p v-if="errorText" class="error-text">{{ errorText }}</p>
          <button :disabled="loading" class="btn btn-primary login-btn" type="submit">
            {{ loading ? '登录中...' : '登录管理后台' }}
          </button>
        </form>
      </main>
    </section>
  </div>
</template>

<style scoped>
.login-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #eff6ff 0%, #f8fafc 50%, #ecfeff 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  position: relative;
  overflow: hidden;
}

.login-bg-shape {
  position: absolute;
  border-radius: 999px;
  filter: blur(2px);
}

.shape-one {
  width: 360px;
  height: 360px;
  background: rgba(59, 130, 246, 0.16);
  top: -120px;
  left: -80px;
}

.shape-two {
  width: 320px;
  height: 320px;
  background: rgba(14, 116, 144, 0.2);
  right: -90px;
  bottom: -120px;
}

.login-card {
  width: min(980px, 100%);
  min-height: 560px;
  display: grid;
  grid-template-columns: 1.1fr 0.9fr;
  overflow: hidden;
  position: relative;
  z-index: 1;
}

.login-aside {
  padding: 44px 38px;
  background: linear-gradient(155deg, #1d4ed8 0%, #0f172a 100%);
  color: #e2e8f0;
}

.login-aside h1 {
  margin: 0;
  font-size: 30px;
  line-height: 1.25;
  color: #fff;
}

.login-aside p {
  margin: 16px 0 0;
  color: #cbd5e1;
}

.login-aside ul {
  margin: 26px 0 0;
  padding: 0;
  list-style: none;
  display: grid;
  gap: 10px;
}

.login-aside li {
  position: relative;
  padding-left: 22px;
}

.login-aside li::before {
  content: '';
  position: absolute;
  left: 0;
  top: 7px;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #93c5fd;
}

.login-main {
  padding: 44px 38px;
  background: #fff;
}

.login-main h2 {
  margin: 0;
  font-size: 26px;
}

.login-tip {
  margin: 8px 0 0;
  color: var(--text-secondary);
}

.form {
  margin-top: 28px;
  display: grid;
  gap: 14px;
}

.form label {
  display: grid;
  gap: 6px;
}

.form span {
  font-size: 13px;
  color: var(--text-secondary);
}

.error-text {
  margin: 0;
  color: var(--danger);
  font-size: 13px;
}

.login-btn {
  margin-top: 4px;
  min-height: 42px;
}

@media (max-width: 880px) {
  .login-card {
    grid-template-columns: 1fr;
  }

  .login-aside {
    padding: 26px 22px;
  }

  .login-main {
    padding: 26px 22px;
  }
}
</style>
