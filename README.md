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