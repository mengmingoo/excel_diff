<template>
  <div class="upload-area">
    <div class="upload-item" v-for="item in uploadItems" :key="item.type">
      <div class="upload-label">{{ item.label }}</div>
      <el-upload
        class="upload-box"
        drag
        :auto-upload="false"
        :on-change="(file) => handleFile(file, item.type)"
        :accept="'.xlsx,.xls,.csv'"
        :limit="1"
        :show-file-list="false"
      >
        <div v-if="item.loading" class="upload-loading">
          <el-icon class="is-loading"><Loading /></el-icon>
          <span>正在解析... 已读取 {{ item.progress }} 行</span>
        </div>
        <div v-else-if="item.fileName" class="upload-done">
          <el-icon color="#67c23a"><CircleCheck /></el-icon>
          <span>{{ item.fileName }}</span>
          <el-button type="danger" link size="small" @click.stop="clearFile(item.type)">移除</el-button>
        </div>
        <div v-else class="upload-placeholder">
          <el-icon class="upload-icon"><UploadFilled /></el-icon>
          <p>点击或拖拽上传</p>
          <p class="upload-hint">支持 .xlsx / .xls / .csv</p>
        </div>
      </el-upload>
    </div>
  </div>
</template>

<script setup>
import { reactive } from 'vue'
import { UploadFilled, CircleCheck, Loading } from '@element-plus/icons-vue'
import { parseFile, validateFormat } from '../utils/excel.js'
import { ElMessage } from 'element-plus'

const emit = defineEmits(['main-loaded', 'cross-loaded'])

const MAX_FILE_SIZE = 100 * 1024 * 1024 // 100MB
const PROGRESS_THRESHOLD = 5000 // 超过此行数显示进度

const uploadItems = reactive([
  { type: 'main', label: '主表', fileName: '', loading: false, progress: 0 },
  { type: 'cross', label: '跨表', fileName: '', loading: false, progress: 0 }
])

function getItem(type) {
  return uploadItems.find(i => i.type === type)
}

async function handleFile(file, type) {
  const item = getItem(type)
  const rawFile = file.raw
  if (!rawFile) return

  // 文件大小校验
  if (rawFile.size > MAX_FILE_SIZE) {
    ElMessage.warning('文件过大（超过100MB），建议拆分后重试')
    return
  }

  // 格式校验
  const filePath = rawFile.path
  try {
    validateFormat(filePath)
  } catch (e) {
    ElMessage.error('仅支持 .xlsx/.xls/.csv 格式')
    return
  }

  // 解析文件
  item.loading = true
  item.progress = 0
  item.fileName = rawFile.name

  try {
    // 大文件分段读取以模拟进度提示
    const result = await parseWithProgress(filePath, item)
    item.fileName = rawFile.name
    item.loading = false

    if (result.rows.length === 0) {
      ElMessage.warning('表格无数据，请重新选择文件')
      item.fileName = ''
      return
    }

    emit(type === 'main' ? 'main-loaded' : 'cross-loaded', {
      headers: result.headers,
      rows: result.rows,
      filePath: filePath
    })
  } catch (e) {
    ElMessage.error(e.message || '文件解析失败，请检查文件是否损坏')
    item.fileName = ''
    item.loading = false
  }
}

async function parseWithProgress(filePath, item) {
  // 先快速解析获取行数
  const result = parseFile(filePath)

  if (result.rows.length > PROGRESS_THRESHOLD) {
    // 大文件模拟分批进度
    const chunkSize = 1000
    for (let i = 0; i < result.rows.length; i += chunkSize) {
      await new Promise(resolve => setTimeout(resolve, 50))
      item.progress = Math.min(i + chunkSize, result.rows.length)
    }
  }

  return result
}

function clearFile(type) {
  const item = getItem(type)
  item.fileName = ''
  item.loading = false
  item.progress = 0
}
</script>

<style scoped>
.upload-area {
  display: flex;
  gap: 24px;
  padding: 20px;
  border: 2px dashed #dcdfe6;
  border-radius: 8px;
  background: #fafafa;
}

.upload-item {
  flex: 1;
  text-align: center;
}

.upload-label {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
}

.upload-box {
  width: 100%;
}

.upload-placeholder {
  padding: 20px;
  color: #909399;
}

.upload-placeholder p {
  margin: 4px 0;
}

.upload-hint {
  font-size: 12px;
  color: #c0c4cc;
}

.upload-icon {
  font-size: 40px;
  color: #c0c4cc;
}

.upload-loading {
  padding: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  color: #409eff;
}

.upload-done {
  padding: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  color: #67c23a;
}
</style>