<template>
  <div class="result-area" v-if="resultRows.length > 0">
    <div class="result-header">
      <span class="result-title">匹配结果（共 {{ filteredRows.length }} 行）</span>
      <div class="result-actions">
        <el-radio-group v-model="filterMode" size="small">
          <el-radio-button value="all">全部</el-radio-button>
          <el-radio-button value="matched">已匹配</el-radio-button>
          <el-radio-button value="unmatched">未匹配</el-radio-button>
        </el-radio-group>
        <el-button type="primary" size="small" @click="handleExport">导出</el-button>
      </div>
    </div>
    <div class="table-wrapper">
      <el-table-v2
        :columns="columns"
        :data="filteredRows"
        :width="tableWidth"
        :height="500"
        :row-height="40"
        :header-height="40"
        fixed
      />
    </div>

    <!-- 浏览器环境导出对话框 -->
    <el-dialog
      v-model="exportDialogVisible"
      title="导出数据"
      width="420px"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
    >
      <el-form label-width="80px">
        <el-form-item label="文件名">
          <el-input v-model="exportFileName" placeholder="请输入文件名" maxlength="50" />
        </el-form-item>
        <el-form-item label="文件格式">
          <el-radio-group v-model="exportFormat">
            <el-radio-button value="xlsx">Excel (.xlsx)</el-radio-button>
            <el-radio-button value="csv">CSV (.csv)</el-radio-button>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="exportDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmExport">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, h, ref, onMounted } from 'vue'
import { ElTableV2, ElButton } from 'element-plus'
import { ElMessage } from 'element-plus'
import { exportFile, exportToBrowser } from '../utils/excel.js'

const props = defineProps({
  resultRows: { type: Array, default: () => [] },
  filterMode: { type: String, default: 'all' },
  mainFormat: { type: String, default: 'xlsx' }
})

const emit = defineEmits(['update:filterMode', 'delete-row'])

const tableWidth = ref(1100)

// 浏览器环境导出对话框状态
const exportDialogVisible = ref(false)
const exportFileName = ref('')
const exportFormat = ref('xlsx')
let pendingExport = null

onMounted(() => {
  tableWidth.value = document.querySelector('.result-area')?.clientWidth - 32 || 1100
})

const filterMode = computed({
  get: () => props.filterMode,
  set: (val) => emit('update:filterMode', val)
})

const UNMATCHED_MARKER = '__unmatched__'

const filteredRows = computed(() => {
  const rows = props.resultRows.map((row, index) => ({ ...row, __rowIndex: index }))
  switch (props.filterMode) {
    case 'matched':
      return rows.filter(r => !r[UNMATCHED_MARKER])
    case 'unmatched':
      return rows.filter(r => r[UNMATCHED_MARKER])
    default:
      return rows
  }
})

const columns = computed(() => {
  if (props.resultRows.length === 0) return []

  const headers = Object.keys(props.resultRows[0]).filter(h => h !== UNMATCHED_MARKER)
  const cols = headers.map(h => ({
    key: h,
    dataKey: h,
    title: h,
    width: 150,
    align: 'center'
  }))

  cols.push({
    key: 'operations',
    title: '操作',
    dataKey: '__rowIndex',
    width: 80,
    align: 'center',
    cellRenderer: ({ rowData }) => {
      return h(ElButton, {
        type: 'danger',
        size: 'small',
        link: true,
        onClick: () => handleDelete(rowData.__rowIndex)
      }, () => '删除')
    }
  })

  return cols
})

function handleDelete(index) {
  emit('delete-row', index)
}

async function handleExport() {
  try {
    const ext = props.mainFormat === 'csv' ? 'csv' : 'xlsx'
    const headers = Object.keys(props.resultRows[0]).filter(h => h !== UNMATCHED_MARKER)
    const rows = filteredRows.value.map(r => {
      const clean = {}
      for (const h of headers) {
        clean[h] = r[h]
      }
      return clean
    })

    if (typeof window !== 'undefined' && window.require) {
      // Electron 环境：弹出保存对话框，写入文件系统
      const { ipcRenderer } = window.require('electron')
      const filterName = ext === 'csv' ? 'CSV Files' : 'Excel Files'
      const result = await ipcRenderer.invoke('show-save-dialog', {
        filters: [{ name: filterName, extensions: [ext] }]
      })
      if (result.canceled || !result.filePath) return

      await exportFile(rows, headers, result.filePath, ext)
    } else {
      // 浏览器环境：弹出 Element 对话框，确认后下载
      exportFormat.value = ext
      const now = new Date()
      exportFileName.value = `匹配结果_${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}${String(now.getMinutes()).padStart(2, '0')}${String(now.getSeconds()).padStart(2, '0')}`
      pendingExport = { rows, headers }
      exportDialogVisible.value = true
      return
    }

    ElMessage.success('导出成功')
  } catch (e) {
    ElMessage.error(e.message || '导出失败，请重试')
  }
}

function confirmExport() {
  if (!pendingExport) return
  const name = exportFileName.value.trim() || '匹配结果'
  exportToBrowser(pendingExport.rows, pendingExport.headers, exportFormat.value, `${name}.${exportFormat.value}`)
  exportDialogVisible.value = false
  pendingExport = null
  ElMessage.success('导出成功')
}
</script>

<style scoped>
.result-area {
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 16px;
  background: #fff;
  margin-top: 16px;
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.result-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.result-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}
</style>