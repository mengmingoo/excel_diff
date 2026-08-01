# 跨表匹配工具

桌面端跨表数据精确匹配工具，基于 Electron + Vue 3 构建。

## 功能

- 支持 .xlsx / .xls / .csv 文件导入
- 精确匹配（VLOOKUP 风格），主表 + 跨表 1 对 1 匹配
- 多条匹配全部带回，无匹配行保留但跨表字段为空
- 结果筛选（全部/已匹配/未匹配）、删除、导出
- 虚拟滚动支持 10 万+ 行数据流畅显示
- 自定义表头行：列名不在第一行时可指定行号
- 跨平台：Windows / macOS / Linux / 麒麟

## 配置

软件信息通过 `app.config.json` 集中管理，可自定义：

```json
{
  "appName": "跨表匹配工具",
  "appVersion": "1.0.0",
  "developer": "mengming",
  "icon": "assets/icon.png"
}
```

- `appName`：软件名称
- `appVersion`：软件版本
- `developer`：开发者
- `icon`：应用图标路径（可替换 `assets/icon.png` 自定义图标）

## 快速开始

### 启动桌面应用（Electron）

双击 `start.bat`，脚本会自动检查环境、安装依赖、构建前端并启动 Electron 应用窗口。

### 启动网页版

```bash
npm install
npm run dev
```

浏览器访问 `http://localhost:5173`，即可在网页中使用全部功能。

### 关闭项目

双击 `stop.bat`，自动终止 Electron 和 Node.js 进程。

### 打包项目

双击 `build.bat`，生成安装包到 `release/` 目录。

## 开发

```bash
npm install
npm run dev          # 启动 Vite dev server（浏览器访问 http://localhost:5173）
npm run electron:dev # 启动 Electron + Vite
npm run test         # 运行测试
```

## 打包

### Windows

双击 `build.bat`，或执行：

```bash
npm run electron:build
```

输出目录：`release/`
- `跨表匹配工具 Setup 1.0.0.exe` — Windows 安装包
- `win-unpacked/` — 绿色免安装版

### macOS

```bash
npm run electron:build -- --mac
```

输出：`release/跨表匹配工具-1.0.0.dmg`

### Linux

```bash
npm run electron:build -- --linux
```

输出：`release/跨表匹配工具-1.0.0.AppImage` 和 `release/跨表匹配工具-1.0.0.deb`

### 麒麟（Kylin）

麒麟系统基于 Linux，使用 Linux 打包命令即可：

```bash
npm run electron:build -- --linux
```

如需指定架构（如飞腾 ARM64）：

```bash
npm run electron:build -- --linux --arm64
```

## TODO

- [ ] 支持一个主表 + 多个跨表
- [ ] 支持模糊匹配
- [ ] 支持多条件组合匹配
