# 跨表匹配工具 — 设计文档

> 日期：2026-07-25  
> 状态：已确认

---

## 1. 概述

一个桌面端跨表数据匹配工具。用户导入主表和跨表，选择匹配列，系统按精确匹配逻辑将两表数据合并，结果在网页中展示，支持筛选、删除和导出。

**技术栈：** Vue 3 + Element Plus + SheetJS + Electron

**目标平台：** Windows / macOS / Linux / 麒麟（Kylin）

---

## 2. 功能规格

### 2.1 文件导入

- 同时支持主表和跨表各一个文件的上传
- 支持格式：`.xlsx`、`.xls`、`.csv`
- 上传后自动解析，显示表头列名
- 大文件（> 5000 行）解析时显示进度提示："正在解析... 已读取 XXX 行"

### 2.2 匹配配置

- 主表匹配列和跨表匹配列通过下拉框选择，下拉选项来自各自文件解析出的列名
- 匹配逻辑：精确匹配（VLOOKUP 风格），主表字段值 == 跨表字段值
- 上传完成前"开始匹配"按钮禁用

### 2.3 匹配结果

- 主表行在跨表中有多条匹配时，全部带过来（主表行复制多行）
- 主表行无匹配时，保留该行，跨表字段为空
- 列名冲突时自动加前缀：`主表_xxx` / `跨表_xxx`
- 空值匹配规则：空 == 空匹配，空 != 非空不匹配

### 2.4 结果操作

- 筛选：全部 / 已匹配 / 未匹配
- 删除：支持删除不需要的行
- 导出：导出格式与导入主表格式一致（.xlsx → .xlsx, .xls → .xls, .csv → .csv）
- 结果表格使用虚拟滚动，支持 10 万+ 行流畅显示

### 2.5 后续扩展（记录在 README TODO）

- 支持一个主表 + 多个跨表
- 支持模糊匹配
- 支持多条件组合匹配

---

## 3. 架构设计

### 3.1 整体架构

```
┌─────────────────────────────────────┐
│           Electron Shell            │
│  ┌───────────────────────────────┐  │
│  │        Vue 3 前端             │  │
│  │  ┌─────┐ ┌─────┐ ┌───────┐  │  │
│  │  │上传区│ │配置区│ │结果区 │  │  │
│  │  └─────┘ └─────┘ └───────┘  │  │
│  │        ↕ SheetJS              │  │
│  └───────────────────────────────┘  │
│         Node.js fs (文件读写)       │
└─────────────────────────────────────┘
```

### 3.2 项目结构

```
excel_manage/
├── electron/
│   └── main.js                # Electron 主进程
├── src/
│   ├── App.vue                # 容器组件，持有全部状态
│   ├── components/
│   │   ├── FileUpload.vue     # 文件上传区
│   │   ├── MatchConfig.vue    # 匹配配置区
│   │   └── ResultTable.vue    # 结果展示区
│   ├── utils/
│   │   ├── excel.js           # SheetJS 封装（解析/导出）
│   │   └── matcher.js         # 匹配逻辑
│   └── main.js
├── package.json
└── README.md
```

### 3.3 组件职责

| 组件 | 职责 | 依赖 |
|------|------|------|
| App.vue | 容器组件，持有全部共享状态，协调子组件通信 | 无 |
| FileUpload | 文件选择、格式校验、调用 excel.js 解析、进度提示 | excel.js |
| MatchConfig | 列名下拉选择、触发匹配 | matcher.js |
| ResultTable | 虚拟滚动表格、筛选、删除、导出 | excel.js |

---

## 4. 数据流与状态管理

### 4.1 状态定义（App.vue）

| 状态 | 类型 | 说明 |
|------|------|------|
| `mainFile` | string | 主表文件路径 |
| `crossFile` | string | 跨表文件路径 |
| `mainHeaders` | string[] | 主表列名 |
| `mainRows` | object[] | 主表所有行数据 |
| `crossHeaders` | string[] | 跨表列名 |
| `crossRows` | object[] | 跨表所有行数据 |
| `mainMatchCol` | string | 选中的主表匹配列 |
| `crossMatchCol` | string | 选中的跨表匹配列 |
| `resultRows` | object[] | 匹配结果 |
| `filterMode` | `'all' \| 'matched' \| 'unmatched'` | 筛选模式 |
| `mainLoading` | boolean | 主表解析进度状态 |
| `crossLoading` | boolean | 跨表解析进度状态 |

### 4.2 数据流向

```
FileUpload → emit(parsedData) → App.vue (持有)
App.vue → props(headers) → MatchConfig
MatchConfig → emit({ mainCol, crossCol }) → App.vue
App.vue → 调用 matcher.js → 得到 resultRows
App.vue → props(resultRows, filterMode) → ResultTable
ResultTable → emit('delete-row', index) → App.vue
ResultTable → emit('export') → App.vue 调用 excel.js 导出
```

### 4.3 接口契约

```js
// excel.js
parseFile(filePath: string): Promise<{ headers: string[], rows: object[] }>
exportFile(rows: object[], headers: string[], filePath: string, format: string): Promise<void>

// matcher.js
match(mainRows: object[], crossRows: object[], mainCol: string, crossCol: string): object[]
// 返回：主表 + 跨表合并后的行数组，列名冲突时加前缀
```

---

## 5. UI 布局

单页全流程，从上到下三个区域：

1. **上传区** — 左右并列，主表和跨表各一个上传入口，支持点击和拖拽
2. **配置区** — 两个下拉框选择匹配列，中间 `=` 连接，右侧"开始匹配"按钮
3. **结果区** — 顶部筛选按钮 + 导出按钮，下方虚拟滚动表格，每行有删除操作

---

## 6. 错误处理

### 6.1 文件层面

| 场景 | 处理 |
|------|------|
| 格式不支持 | 上传时校验后缀，Toast："仅支持 .xlsx/.xls/.csv" |
| 解析失败 | 捕获异常，Toast："文件解析失败，请检查文件是否损坏" |
| 表格为空 | Toast："表格无数据，请重新选择文件" |
| 文件过大（>100MB） | 上传前校验，Toast："文件过大，建议拆分后重试" |

### 6.2 匹配层面

| 场景 | 处理 |
|------|------|
| 未上传文件就匹配 | 按钮禁用 |
| 列名冲突 | 自动加前缀：`主表_xxx` / `跨表_xxx` |
| 匹配列为空值 | 空=空匹配，空≠非空不匹配 |

### 6.3 导出层面

| 场景 | 处理 |
|------|------|
| 结果为空 | Toast："没有可导出的数据" |
| 文件已存在 | Electron 对话框自带覆盖确认 |
| 导出失败 | 捕获异常，Toast："导出失败，请重试" |

### 6.4 运行时

| 场景 | 处理 |
|------|------|
| 大文件解析 | 显示进度提示，完成后更新 UI |
| 异常崩溃 | Electron 主进程捕获，显示错误对话框 |

---

## 7. 测试策略

| 测试类型 | 范围 | 工具 |
|----------|------|------|
| 单元测试 | `utils/matcher.js` — 精确匹配、空值、多匹配、无匹配、空输入 | Vitest |
| 单元测试 | `utils/excel.js` — xlsx/xls/csv 解析、损坏文件、导出正确性 | Vitest |

**matcher.js 测试用例：**
- 正常精确匹配（1对1）
- 跨表多条匹配（1对多，全部带过来）
- 主表行无匹配（保留，跨表字段为空）
- 空值匹配（空=空匹配，空≠非空不匹配）
- 空输入（主表为空/跨表为空）

**excel.js 测试用例：**
- 正常 .xlsx 解析
- 正常 .xls 解析
- 正常 .csv 解析（含逗号分隔、UTF-8 编码）
- 损坏文件解析异常
- 导出文件内容正确性

---

## 8. 打包方案

- 使用 **Electron** 打包
- 目标平台：Windows（.exe）、macOS（.dmg）、Linux（.AppImage）、麒麟（.deb）
- 打包工具：electron-builder

---

## 9. 依赖清单

| 包名 | 用途 |
|------|------|
| vue | 前端框架 |
| element-plus | UI 组件库 |
| xlsx (SheetJS) | Excel 解析与导出 |
| electron | 桌面壳 |
| electron-builder | 打包 |
| vite | 构建工具 |
| vitest | 测试框架 |