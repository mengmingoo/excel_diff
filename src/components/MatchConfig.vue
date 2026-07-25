<template>
  <div class="match-config">
    <div class="config-title">匹配配置</div>
    <div class="config-body">
      <div class="select-group">
        <label>主表匹配列</label>
        <el-select v-model="mainCol" placeholder="选择列名" :disabled="!mainHeaders.length">
          <el-option
            v-for="h in mainHeaders"
            :key="h"
            :label="h"
            :value="h"
          />
        </el-select>
      </div>
      <span class="equal-sign">=</span>
      <div class="select-group">
        <label>跨表匹配列</label>
        <el-select v-model="crossCol" placeholder="选择列名" :disabled="!crossHeaders.length">
          <el-option
            v-for="h in crossHeaders"
            :key="h"
            :label="h"
            :value="h"
          />
        </el-select>
      </div>
      <el-button
        type="primary"
        :disabled="!mainCol || !crossCol"
        @click="handleMatch"
      >
        开始匹配
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  mainHeaders: { type: Array, default: () => [] },
  crossHeaders: { type: Array, default: () => [] }
})

const emit = defineEmits(['match'])

const mainCol = ref('')
const crossCol = ref('')

// 当 headers 变化时重置选择
watch(() => props.mainHeaders, () => { mainCol.value = '' })
watch(() => props.crossHeaders, () => { crossCol.value = '' })

function handleMatch() {
  if (mainCol.value && crossCol.value) {
    emit('match', { mainCol: mainCol.value, crossCol: crossCol.value })
  }
}
</script>

<style scoped>
.match-config {
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 16px;
  background: #fff;
  margin-top: 16px;
}

.config-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
}

.config-body {
  display: flex;
  gap: 16px;
  align-items: flex-end;
}

.select-group {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.select-group label {
  font-size: 12px;
  color: #909399;
}

.equal-sign {
  font-size: 20px;
  color: #909399;
  padding-bottom: 4px;
}
</style>