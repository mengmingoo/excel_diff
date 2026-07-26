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
  </div>
</template>

<script setup>
import { computed, h, ref, onMounted } from 'vue'
import { ElTableV2, ElButton } from 'element-plus'
import { ElMessage } from 'element-plus'
import { exportFile } from '../utils/excel.js'

const props = defineProps({
  resultRows: { type: Array, default: () => [] },
  filterMode: { type: String, default: 'all' },
  mainFormat: { type: String, default: 'xlsx' }
})

const emit = defineEmits(['update:filterMode', 'delete-row'])

const tableWidth = ref(1100)

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
    const { ipcRenderer } = window.require('electron')
    const ext = props.mainFormat === 'csv' ? 'csv' : 'xlsx'
    const filterName = ext === 'csv' ? 'CSV Files' : 'Excel Files'
    const result = await ipcRenderer.invoke('show-save-dialog', {
      filters: [{ name: filterName, extensions: [ext] }]
    })

    if (result.canceled || !result.filePath) return

    const headers = Object.keys(props.resultRows[0]).filter(h => h !== UNMATCHED_MARKER)
    const rows = filteredRows.value.map(r => {
      const clean = {}
      for (const h of headers) {
        clean[h] = r[h]
      }
      return clean
    })

    await exportFile(rows, headers, result.filePath, ext)
    ElMessage.success('导出成功')
  } catch (e) {
    ElMessage.error(e.message || '导出失败，请重试')
  }
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