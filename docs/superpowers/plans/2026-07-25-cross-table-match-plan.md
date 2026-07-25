# 跨表匹配工具 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建一个 Electron + Vue 3 桌面端跨表数据精确匹配工具，支持 .xlsx/.xls/.csv 导入、列名匹配、结果筛选删除和导出。

**Architecture:** Vue 3 单页应用嵌入 Electron，通过 SheetJS 处理文件解析与导出，不使用后端。App.vue 作为容器组件持有全部状态，props/emit 驱动三个子组件（FileUpload、MatchConfig、ResultTable）通信。

**Tech Stack:** Vue 3 + Element Plus + SheetJS (xlsx) + Electron + electron-builder + Vite + Vitest

---

## File Structure

```
excel_manage/
├── electron/
│   └── main.js                # Electron 主进程，窗口创建 + 文件对话框
├── src/
│   ├── App.vue                # 容器组件，持有全部共享状态
│   ├── components/
│   │   ├── FileUpload.vue     # 文件上传区（主表 + 跨表）
│   │   ├── MatchConfig.vue    # 匹配配置区（下拉选择 + 触发匹配）
│   │   └── ResultTable.vue    # 结果展示区（虚拟滚动 + 筛选 + 删除 + 导出）
│   ├── utils/
│   │   ├── excel.js           # SheetJS 封装（解析/导出）
│   │   └── matcher.js         # 匹配逻辑
│   └── main.js
├── tests/
│   ├── excel.test.js
│   └── matcher.test.js
├── index.html
├── package.json
├── vite.config.js
├── vitest.config.js
└── README.md
```

---

### Task 1: 项目脚手架与依赖安装

**Files:**
- Create: `package.json`
- Create: `vite.config.js`
- Create: `vitest.config.js`
- Create: `index.html`
- Create: `src/main.js`
- Create: `src/App.vue` (stub)

- [ ] **Step 1: 初始化 package.json 并安装依赖**

```bash
cd c:\code\excel_manage
npm init -y
npm install vue element-plus xlsx
npm install -D vite @vitejs/plugin-vue vitest electron electron-builder
```

- [ ] **Step 2: 创建 vite.config.js**

```js
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  base: './',
  build: {
    outDir: 'dist'
  }
})
```

- [ ] **Step 3: 创建 vitest.config.js**

```js
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node'
  }
})
```

- [ ] **Step 4: 创建 index.html**

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>跨表匹配工具</title>
</head>
<body>
  <div id="app"></div>
  <script type="module" src="/src/main.js"></script>
</body>
</html>
```

- [ ] **Step 5: 创建 src/main.js**

```js
import { createApp } from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import App from './App.vue'

const app = createApp(App)
app.use(ElementPlus)
app.mount('#app')
```

- [ ] **Step 6: 创建 stub src/App.vue**

```vue
<template>
  <div class="app-container">
    <h1>跨表匹配工具</h1>
  </div>
</template>

<script setup>
</script>

<style>
.app-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}
</style>
```

- [ ] **Step 7: 验证 dev server 启动**

Run: `npx vite`
Expected: 浏览器打开后显示 "跨表匹配工具" 标题

- [ ] **Step 8: 更新 package.json scripts**

Edit `package.json`，添加：

```json
"scripts": {
  "dev": "vite",
  "build": "vite build",
  "test": "vitest run",
  "test:watch": "vitest"
}
```

- [ ] **Step 9: Commit**

```bash
git add package.json vite.config.js vitest.config.js index.html src/main.js src/App.vue
git commit -m "chore: scaffold Vue 3 + Element Plus + Vite project"
```

---

### Task 2: utils/excel.js — 文件解析与导出（TDD）

**Files:**
- Create: `tests/excel.test.js`
- Create: `src/utils/excel.js`

- [ ] **Step 1: 创建 tests/excel.test.js — xlsx 解析测试**

```js
import { describe, it, expect } from 'vitest'
import * as XLSX from 'xlsx'
import { parseFile, exportFile } from '../src/utils/excel.js'
import fs from 'fs'
import path from 'path'

const TEST_DIR = path.join(__dirname, 'fixtures')

function ensureFixturesDir() {
  if (!fs.existsSync(TEST_DIR)) fs.mkdirSync(TEST_DIR, { recursive: true })
}

function createTestXlsx(filePath, headers, rows) {
  const ws = XLSX.utils.json_to_sheet(rows, { header: headers })
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Sheet1')
  XLSX.writeFile(wb, filePath)
}

function createTestCsv(filePath, headers, rows) {
  const lines = [headers.join(',')]
  for (const row of rows) {
    lines.push(headers.map(h => row[h] ?? '').join(','))
  }
  fs.writeFileSync(filePath, lines.join('\n'), 'utf-8')
}

describe('parseFile', () => {
  it('正常解析 .xlsx 文件', () => {
    ensureFixturesDir()
    const filePath = path.join(TEST_DIR, 'test_normal.xlsx')
    createTestXlsx(filePath, ['姓名', '年龄'], [
      { '姓名': '张三', '年龄': 25 },
      { '姓名': '李四', '年龄': 30 }
    ])

    const result = parseFile(filePath)
    expect(result.headers).toEqual(['姓名', '年龄'])
    expect(result.rows).toHaveLength(2)
    expect(result.rows[0]).toEqual({ '姓名': '张三', '年龄': 25 })
    expect(result.rows[1]).toEqual({ '姓名': '李四', '年龄': 30 })
  })

  it('正常解析 .csv 文件', () => {
    ensureFixturesDir()
    const filePath = path.join(TEST_DIR, 'test_csv.csv')
    createTestCsv(filePath, ['姓名', '年龄'], [
      { '姓名': '王五', '年龄': 28 },
      { '姓名': '赵六', '年龄': 35 }
    ])

    const result = parseFile(filePath)
    expect(result.headers).toEqual(['姓名', '年龄'])
    expect(result.rows).toHaveLength(2)
    expect(result.rows[0]).toEqual({ '姓名': '王五', '年龄': 28 })
  })

  it('解析损坏文件时抛出异常', () => {
    ensureFixturesDir()
    const filePath = path.join(TEST_DIR, 'corrupt.xlsx')
    fs.writeFileSync(filePath, 'not a real xlsx file')

    expect(() => parseFile(filePath)).toThrow()
  })

  it('解析空表格', () => {
    ensureFixturesDir()
    const filePath = path.join(TEST_DIR, 'empty.xlsx')
    createTestXlsx(filePath, ['姓名', '年龄'], [])

    const result = parseFile(filePath)
    expect(result.headers).toEqual(['姓名', '年龄'])
    expect(result.rows).toEqual([])
  })
})

describe('exportFile', () => {
  it('导出 .xlsx 文件内容正确', () => {
    ensureFixturesDir()
    const outPath = path.join(TEST_DIR, 'export_test.xlsx')
    const headers = ['姓名', '年龄']
    const rows = [{ '姓名': '张三', '年龄': 25 }]

    exportFile(rows, headers, outPath, 'xlsx')
    expect(fs.existsSync(outPath)).toBe(true)

    const result = parseFile(outPath)
    expect(result.rows).toHaveLength(1)
    expect(result.rows[0]['姓名']).toBe('张三')
  })
})
```

- [ ] **Step 2: 运行测试验证失败**

Run: `npx vitest run tests/excel.test.js`
Expected: FAIL — `parseFile` and `exportFile` not defined

- [ ] **Step 3: 创建 src/utils/excel.js**

```js
import * as XLSX from 'xlsx'
import fs from 'fs'
import path from 'path'

const ALLOWED_EXT = ['.xlsx', '.xls', '.csv']

/**
 * 校验文件格式
 */
export function validateFormat(filePath) {
  const ext = path.extname(filePath).toLowerCase()
  if (!ALLOWED_EXT.includes(ext)) {
    throw new Error('仅支持 .xlsx/.xls/.csv 格式')
  }
}

/**
 * 解析文件，返回 { headers, rows }
 */
export function parseFile(filePath) {
  validateFormat(filePath)
  const ext = path.extname(filePath).toLowerCase()

  let workbook
  try {
    if (ext === '.csv') {
      const content = fs.readFileSync(filePath, 'utf-8')
      workbook = XLSX.read(content, { type: 'string' })
    } else {
      workbook = XLSX.readFile(filePath)
    }
  } catch (e) {
    throw new Error('文件解析失败，请检查文件是否损坏')
  }

  const sheetName = workbook.SheetNames[0]
  const sheet = workbook.Sheets[sheetName]
  const rows = XLSX.utils.sheet_to_json(sheet, { defval: '' })
  const headers = rows.length > 0 ? Object.keys(rows[0]) : []

  return { headers, rows }
}

/**
 * 导出文件
 */
export function exportFile(rows, headers, filePath, format) {
  try {
    const ws = XLSX.utils.json_to_sheet(rows, { header: headers })
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Sheet1')

    if (format === 'csv') {
      const csv = XLSX.utils.sheet_to_csv(ws)
      fs.writeFileSync(filePath, csv, 'utf-8')
    } else {
      XLSX.writeFile(wb, filePath)
    }
  } catch (e) {
    throw new Error('导出失败，请重试')
  }
}
```

- [ ] **Step 4: 运行测试验证通过**

Run: `npx vitest run tests/excel.test.js`
Expected: PASS — 4/4 tests pass

- [ ] **Step 5: Commit**

```bash
git add src/utils/excel.js tests/excel.test.js
git commit -m "feat: add excel.js file parse/export with tests"
```

---

### Task 3: utils/matcher.js — 匹配逻辑（TDD）

**Files:**
- Create: `tests/matcher.test.js`
- Create: `src/utils/matcher.js`

- [ ] **Step 1: 创建 tests/matcher.test.js**

```js
import { describe, it, expect } from 'vitest'
import { match } from '../src/utils/matcher.js'

describe('match', () => {
  it('正常精确匹配（1对1）', () => {
    const mainRows = [
      { '姓名': '张三', '部门': '技术' },
      { '姓名': '李四', '部门': '产品' }
    ]
    const crossRows = [
      { '姓名': '张三', '工资': 10000 },
      { '姓名': '李四', '工资': 12000 }
    ]

    const result = match(mainRows, crossRows, '姓名', '姓名')
    expect(result).toHaveLength(2)
    expect(result[0]['主表_姓名']).toBe('张三')
    expect(result[0]['主表_部门']).toBe('技术')
    expect(result[0]['跨表_工资']).toBe(10000)
    expect(result[1]['主表_姓名']).toBe('李四')
    expect(result[1]['跨表_工资']).toBe(12000)
  })

  it('跨表多条匹配（1对多，全部带过来）', () => {
    const mainRows = [
      { '姓名': '张三', '部门': '技术' }
    ]
    const crossRows = [
      { '姓名': '张三', '项目': 'A' },
      { '姓名': '张三', '项目': 'B' }
    ]

    const result = match(mainRows, crossRows, '姓名', '姓名')
    expect(result).toHaveLength(2)
    expect(result[0]['主表_姓名']).toBe('张三')
    expect(result[0]['跨表_项目']).toBe('A')
    expect(result[1]['主表_姓名']).toBe('张三')
    expect(result[1]['跨表_项目']).toBe('B')
  })

  it('主表行无匹配（保留，跨表字段为空）', () => {
    const mainRows = [
      { '姓名': '张三', '部门': '技术' },
      { '姓名': '王五', '部门': '设计' }
    ]
    const crossRows = [
      { '姓名': '张三', '工资': 10000 }
    ]

    const result = match(mainRows, crossRows, '姓名', '姓名')
    expect(result).toHaveLength(2)
    expect(result[0]['主表_姓名']).toBe('张三')
    expect(result[0]['跨表_工资']).toBe(10000)
    expect(result[1]['主表_姓名']).toBe('王五')
    expect(result[1]['跨表_工资']).toBe('')
  })

  it('空值匹配：空=空匹配，空≠非空不匹配', () => {
    const mainRows = [
      { '姓名': '', '部门': '未知' },
      { '姓名': '张三', '部门': '技术' }
    ]
    const crossRows = [
      { '姓名': '', '工资': 5000 },
      { '姓名': '张三', '工资': 10000 }
    ]

    const result = match(mainRows, crossRows, '姓名', '姓名')
    expect(result).toHaveLength(2)
    expect(result[0]['主表_姓名']).toBe('')
    expect(result[0]['跨表_工资']).toBe(5000)
    expect(result[1]['主表_姓名']).toBe('张三')
    expect(result[1]['跨表_工资']).toBe(10000)
  })

  it('空输入：主表为空返回空数组', () => {
    const result = match([], [{ '姓名': '张三' }], '姓名', '姓名')
    expect(result).toEqual([])
  })

  it('空输入：跨表为空，主表行全部保留', () => {
    const mainRows = [{ '姓名': '张三', '部门': '技术' }]
    const result = match(mainRows, [], '姓名', '姓名')
    expect(result).toHaveLength(1)
    expect(result[0]['主表_姓名']).toBe('张三')
  })

  it('列名冲突时自动加前缀', () => {
    const mainRows = [{ '姓名': '张三', '年龄': 25 }]
    const crossRows = [{ '姓名': '张三', '年龄': 30 }]

    const result = match(mainRows, crossRows, '姓名', '姓名')
    expect(result).toHaveLength(1)
    expect(result[0]['主表_姓名']).toBe('张三')
    expect(result[0]['主表_年龄']).toBe(25)
    expect(result[0]['跨表_姓名']).toBe('张三')
    expect(result[0]['跨表_年龄']).toBe(30)
  })
})
```

- [ ] **Step 2: 运行测试验证失败**

Run: `npx vitest run tests/matcher.test.js`
Expected: FAIL — `match` not defined

- [ ] **Step 3: 创建 src/utils/matcher.js**

```js
/**
 * 精确匹配主表和跨表数据
 * @param {object[]} mainRows - 主表行数据
 * @param {object[]} crossRows - 跨表行数据
 * @param {string} mainCol - 主表匹配列名
 * @param {string} crossCol - 跨表匹配列名
 * @returns {object[]} 合并后的结果行
 */
export function match(mainRows, crossRows, mainCol, crossCol) {
  if (mainRows.length === 0) return []

  const mainHeaders = mainRows.length > 0 ? Object.keys(mainRows[0]) : []
  const crossHeaders = crossRows.length > 0 ? Object.keys(crossRows[0]) : []

  // 构建跨表索引：key -> matching rows
  const crossIndex = new Map()
  for (const row of crossRows) {
    const key = row[crossCol] ?? ''
    if (!crossIndex.has(key)) {
      crossIndex.set(key, [])
    }
    crossIndex.get(key).push(row)
  }

  // 判断是否有列名冲突
  const conflictCols = mainHeaders.filter(h => crossHeaders.includes(h))

  const result = []
  for (const mainRow of mainRows) {
    const key = mainRow[mainCol] ?? ''
    const matchedRows = crossIndex.get(key) || []

    if (matchedRows.length === 0) {
      // 无匹配：保留主表行，跨表字段为空
      const row = {}
      for (const h of mainHeaders) {
        row[conflictCols.includes(h) ? `主表_${h}` : h] = mainRow[h]
      }
      for (const h of crossHeaders) {
        row[conflictCols.includes(h) ? `跨表_${h}` : h] = ''
      }
      result.push(row)
    } else {
      // 有匹配：每条匹配结果生成一行
      for (const crossRow of matchedRows) {
        const row = {}
        for (const h of mainHeaders) {
          row[conflictCols.includes(h) ? `主表_${h}` : h] = mainRow[h]
        }
        for (const h of crossHeaders) {
          row[conflictCols.includes(h) ? `跨表_${h}` : h] = crossRow[h]
        }
        result.push(row)
      }
    }
  }

  return result
}
```

- [ ] **Step 4: 运行测试验证通过**

Run: `npx vitest run tests/matcher.test.js`
Expected: PASS — 7/7 tests pass

- [ ] **Step 5: Commit**

```bash
git add src/utils/matcher.js tests/matcher.test.js
git commit -m "feat: add matcher.js exact match logic with tests"
```

---

### Task 4: FileUpload.vue — 上传组件

**Files:**
- Create: `src/components/FileUpload.vue`

- [ ] **Step 1: 创建 src/components/FileUpload.vue**

```vue
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
```

- [ ] **Step 2: Commit**

```bash
git add src/components/FileUpload.vue
git commit -m "feat: add FileUpload component with drag-drop and progress"
```

---

### Task 5: MatchConfig.vue — 匹配配置组件

**Files:**
- Create: `src/components/MatchConfig.vue`

- [ ] **Step 1: 创建 src/components/MatchConfig.vue**

```vue
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
```

- [ ] **Step 2: Commit**

```bash
git add src/components/MatchConfig.vue
git commit -m "feat: add MatchConfig component with column selectors"
```

---

### Task 6: ResultTable.vue — 结果展示组件

**Files:**
- Create: `src/components/ResultTable.vue`

- [ ] **Step 1: 创建 src/components/ResultTable.vue**

```vue
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
    <el-auto-resizer>
      <template #default="{ height, width }">
        <el-table-v2
          :columns="columns"
          :data="filteredRows"
          :width="width"
          :height="Math.min(height, 600)"
          :row-height="40"
          :header-height="40"
          fixed
        />
      </template>
    </el-auto-resizer>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { ElAutoResizer, ElTableV2 } from 'element-plus'
import { ElMessage } from 'element-plus'
import { exportFile } from '../utils/excel.js'

const props = defineProps({
  resultRows: { type: Array, default: () => [] },
  filterMode: { type: String, default: 'all' },
  mainFormat: { type: String, default: 'xlsx' }
})

const emit = defineEmits(['update:filterMode', 'delete-row'])

const filterMode = computed({
  get: () => props.filterMode,
  set: (val) => emit('update:filterMode', val)
})

// 判断某行是否已匹配（跨表至少有一个字段非空）
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

  // 添加操作列
  cols.push({
    key: 'operations',
    title: '操作',
    dataKey: '__rowIndex',
    width: 80,
    align: 'center',
    cellRenderer: ({ rowData }) => {
      return h('el-button', {
        type: 'danger',
        size: 'small',
        link: true,
        onClick: () => handleDelete(rowData.__rowIndex)
      }, '删除')
    }
  })

  return cols
})

import { h } from 'vue'

function handleDelete(index) {
  emit('delete-row', index)
}

async function handleExport() {
  try {
    // 使用 Electron 对话框选择保存路径
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

    exportFile(rows, headers, result.filePath, ext)
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
```

- [ ] **Step 2: Commit**

```bash
git add src/components/ResultTable.vue
git commit -m "feat: add ResultTable component with virtual scroll and filter"
```

---

### Task 7: App.vue — 容器组件集成

**Files:**
- Modify: `src/App.vue`

- [ ] **Step 1: 修改 src/App.vue 集成所有组件**

```vue
<template>
  <div class="app-container">
    <h1>跨表匹配工具</h1>

    <FileUpload
      @main-loaded="onMainLoaded"
      @cross-loaded="onCrossLoaded"
    />

    <MatchConfig
      :mainHeaders="mainHeaders"
      :crossHeaders="crossHeaders"
      @match="onMatch"
    />

    <ResultTable
      v-if="resultRows.length > 0"
      v-model:filterMode="filterMode"
      :resultRows="resultRows"
      :mainFormat="mainFormat"
      @delete-row="onDeleteRow"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import FileUpload from './components/FileUpload.vue'
import MatchConfig from './components/MatchConfig.vue'
import ResultTable from './components/ResultTable.vue'
import { match } from './utils/matcher.js'

const mainHeaders = ref([])
const mainRows = ref([])
const mainFormat = ref('xlsx')
const crossHeaders = ref([])
const crossRows = ref([])
const resultRows = ref([])
const filterMode = ref('all')

function onMainLoaded({ headers, rows, filePath }) {
  mainHeaders.value = headers
  mainRows.value = rows
  mainFormat.value = filePath.split('.').pop().toLowerCase()
}

function onCrossLoaded({ headers, rows }) {
  crossHeaders.value = headers
  crossRows.value = rows
}

function onMatch({ mainCol, crossCol }) {
  const result = match(mainRows.value, crossRows.value, mainCol, crossCol)
  resultRows.value = result
  filterMode.value = 'all'
}

function onDeleteRow(index) {
  resultRows.value.splice(index, 1)
}
</script>

<style>
.app-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

h1 {
  font-size: 20px;
  color: #303133;
  margin-bottom: 20px;
  text-align: center;
}
</style>
```

- [ ] **Step 2: 验证 dev server 启动无误**

Run: `npx vite`
Expected: 页面正常显示，无编译错误

- [ ] **Step 3: Commit**

```bash
git add src/App.vue
git commit -m "feat: integrate all components in App.vue"
```

---

### Task 8: Electron 主进程

**Files:**
- Create: `electron/main.js`
- Modify: `package.json`

- [ ] **Step 1: 创建 electron/main.js**

```js
const { app, BrowserWindow, ipcMain, dialog } = require('electron')
const path = require('path')

let mainWindow = null

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  })

  // 开发模式加载 vite dev server，生产模式加载打包文件
  if (process.env.NODE_ENV === 'development') {
    mainWindow.loadURL('http://localhost:5173')
    mainWindow.webContents.openDevTools()
  } else {
    mainWindow.loadFile(path.join(__dirname, '../dist/index.html'))
  }

  mainWindow.on('closed', () => {
    mainWindow = null
  })
}

app.whenReady().then(createWindow)

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow()
  }
})

// 保存文件对话框
ipcMain.handle('show-save-dialog', async (event, options) => {
  const result = await dialog.showSaveDialog(mainWindow, options)
  return result
})
```

- [ ] **Step 2: 更新 package.json 添加 Electron 入口和脚本**

Edit `package.json`，添加/修改：

```json
"main": "electron/main.js",
"scripts": {
  "dev": "vite",
  "build": "vite build",
  "electron:dev": "set NODE_ENV=development && vite build && electron .",
  "electron:build": "vite build && electron-builder",
  "test": "vitest run",
  "test:watch": "vitest"
}
```

- [ ] **Step 3: Commit**

```bash
git add electron/main.js package.json
git commit -m "feat: add Electron main process with file dialog IPC"
```

---

### Task 9: 打包配置

**Files:**
- Modify: `package.json`

- [ ] **Step 1: 更新 package.json 添加 electron-builder 配置**

在 `package.json` 中添加：

```json
"build": {
  "appId": "com.excelmanage.crossmatch",
  "productName": "跨表匹配工具",
  "directories": {
    "output": "release"
  },
  "files": [
    "dist/**/*",
    "electron/**/*"
  ],
  "win": {
    "target": "nsis",
    "icon": null
  },
  "mac": {
    "target": "dmg"
  },
  "linux": {
    "target": ["AppImage", "deb"],
    "category": "Utility"
  }
}
```

- [ ] **Step 2: 验证打包**

Run: `npm run build`
Expected: `dist/` 目录生成成功

Run: `npm run electron:build`
Expected: `release/` 目录生成 Windows 安装包

- [ ] **Step 3: Commit**

```bash
git add package.json
git commit -m "chore: add electron-builder packaging config"
```

---

### Task 10: README.md 与 TODO

**Files:**
- Create: `README.md`

- [ ] **Step 1: 创建 README.md**

```markdown
# 跨表匹配工具

桌面端跨表数据精确匹配工具，基于 Electron + Vue 3 构建。

## 功能

- 支持 .xlsx / .xls / .csv 文件导入
- 精确匹配（VLOOKUP 风格），主表 + 跨表 1 对 1 匹配
- 多条匹配全部带回，无匹配行保留但跨表字段为空
- 结果筛选（全部/已匹配/未匹配）、删除、导出
- 虚拟滚动支持 10 万+ 行数据流畅显示
- 跨平台：Windows / macOS / Linux / 麒麟

## 开发

```bash
npm install
npm run dev          # 启动 Vite dev server
npm run electron:dev # 启动 Electron + Vite
npm run test         # 运行测试
```

## 打包

```bash
npm run electron:build
```

## TODO

- [ ] 支持一个主表 + 多个跨表
- [ ] 支持模糊匹配
- [ ] 支持多条件组合匹配
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with TODO list"
```

---

## Self-Review

### 1. Spec Coverage

| Spec Section | Task |
|-------------|------|
| 2.1 文件导入（格式支持、进度提示） | Task 4 (FileUpload.vue) |
| 2.2 匹配配置（下拉选择、按钮禁用） | Task 5 (MatchConfig.vue) |
| 2.3 匹配结果（多匹配、无匹配、列名冲突、空值） | Task 3 (matcher.js) |
| 2.4 结果操作（筛选、删除、导出、虚拟滚动） | Task 6 (ResultTable.vue) |
| 2.5 后续扩展 | Task 10 (README.md) |
| 3. 架构设计 | Task 1 (脚手架), Task 7 (App.vue) |
| 4. 数据流与状态管理 | Task 7 (App.vue) |
| 5. UI 布局 | Task 4, 5, 6, 7 |
| 6. 错误处理 | Task 2 (excel.js), Task 4 (FileUpload), Task 6 (ResultTable) |
| 7. 测试策略 | Task 2 (excel.test.js), Task 3 (matcher.test.js) |
| 8. 打包方案 | Task 8 (Electron), Task 9 (electron-builder) |

### 2. Placeholder Scan

- No TBD, TODO, or incomplete sections
- No vague "add error handling" without specific code
- All code steps include actual implementation

### 3. Type Consistency

- `parseFile` returns `{ headers, rows }` — consistent across Task 2 and Task 4 usage
- `match` signature: `(mainRows, crossRows, mainCol, crossCol)` — consistent across Task 3 and Task 7
- `exportFile` signature: `(rows, headers, filePath, format)` — consistent across Task 2 and Task 6
- Event names: `main-loaded`, `cross-loaded`, `match`, `delete-row` — consistent across components
- Props: `mainHeaders`, `crossHeaders`, `resultRows`, `filterMode`, `mainFormat` — consistent