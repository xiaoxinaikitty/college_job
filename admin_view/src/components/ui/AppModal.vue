<script setup>
const model = defineModel({ type: Boolean, default: false })

defineProps({
  title: {
    type: String,
    default: '',
  },
  width: {
    type: String,
    default: '620px',
  },
})

function close() {
  model.value = false
}
</script>

<template>
  <teleport to="body">
    <div v-if="model" class="modal-mask" @click.self="close">
      <div class="modal-panel card" :style="{ width }">
        <header class="modal-header">
          <h3>{{ title }}</h3>
          <button class="modal-close" @click="close">✕</button>
        </header>
        <section class="modal-body">
          <slot />
        </section>
        <footer class="modal-footer">
          <slot name="footer" :close="close" />
        </footer>
      </div>
    </div>
  </teleport>
</template>

<style scoped>
.modal-mask {
  position: fixed;
  inset: 0;
  z-index: 1100;
  background: rgba(2, 6, 23, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 18px;
}

.modal-panel {
  max-height: calc(100vh - 36px);
  display: flex;
  flex-direction: column;
}

.modal-header {
  padding: 14px 16px;
  border-bottom: 1px solid var(--line-color);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  font-size: 16px;
}

.modal-close {
  border: none;
  background: transparent;
  font-size: 16px;
  cursor: pointer;
  color: var(--text-secondary);
}

.modal-body {
  padding: 14px 16px;
  overflow-y: auto;
}

.modal-footer {
  border-top: 1px solid var(--line-color);
  padding: 12px 16px;
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>
