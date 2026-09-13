# 跨表匹配工具

桌面端跨表数据精确匹配工具，基于 Electron + Vue 3 构建。

## 功能

- 支持 .xlsx / .xls / .csv 文件导入
- 精确匹配（VLOOKUP 风格），主表 + 跨表 1 对 1 匹配
- 多条匹配全部带回，无匹配行保留但跨表字段为空
- 结果筛选（全部/已匹配/未匹配）、删除、导出（桌面版弹系统保存框，网页版弹 Element UI 对话框，支持自定义文件名和格式）
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

### Windows

双击 `start.bat`，脚本会自动检查环境、安装依赖、构建前端并启动 Electron 应用窗口。
双击 `stop.bat` 关闭应用，双击 `build.bat` 打包安装包到 `release/` 目录。

### Linux（通用）

```bash
chmod +x start.sh stop.sh build.sh   # 首次使用赋予执行权限
./start.sh    # 启动应用
./stop.sh     # 停止应用
./build.sh    # 打包安装包
```

### 麒麟 V10（ARM64）

针对飞腾 / 鲲鹏等 ARM64 架构提供专用脚本（自动检测架构、配置国内镜像、禁用沙箱）：

```bash
chmod +x start-arm.sh stop-arm.sh build-arm.sh
./start-arm.sh    # 启动应用
./stop-arm.sh     # 停止应用
./build-arm.sh    # 打包 ARM64 安装包
```

### 启动网页版

```bash
npm install
npm run dev
```

浏览器访问 `http://localhost:5173`，即可在网页中使用全部功能。

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

### Linux（通用）

执行 `./build.sh`，或：

```bash
npm run electron:build -- --linux
```

输出：`release/跨表匹配工具-1.0.0.AppImage` 和 `release/跨表匹配工具-1.0.0.deb`

### 麒麟 V10（ARM64）

执行 `./build-arm.sh`，脚本会自动以 `--arm64` 目标架构打包并配置国内镜像源：

```bash
./build-arm.sh
```

等价命令：

```bash
npm run electron:build -- --linux --arm64
```

## 注意事项

1. **执行权限**：Linux / 麒麟下首次运行脚本前需执行 `chmod +x *.sh`；若以 `bash start.sh` 方式运行则无需执行权限。
2. **麒麟运行依赖**：启动若报缺少动态库（如 `libgtk-3.so.0`），请先安装：
   ```bash
   sudo apt install libgtk-3-0 libnss3 libasound2
   ```
3. **麒麟沙箱**：麒麟国产化环境普遍存在 Electron sandbox 权限问题，`start-arm.sh` 已通过 `ELECTRON_DISABLE_SANDBOX=1` 自动禁用；手动启动可执行 `ELECTRON_DISABLE_SANDBOX=1 npx electron .`。
4. **ARM 架构匹配**：若之前安装过 x64 版依赖，`start-arm.sh` 会检测并警告；此时删除 `node_modules` 后重新运行脚本，npm 会自动下载 arm64 版 Electron 二进制。
5. **deb 打包依赖**：打 deb 包需要 fpm，electron-builder 会自动下载；若下载失败请先安装 `sudo apt install ruby ruby-dev`。
6. **网页版缓存**：使用 `npm run dev` 调试时若页面显示旧功能，请强制刷新（Ctrl+Shift+R）或使用无痕窗口，避免浏览器缓存旧代码。
7. **国内网络**：脚本已默认使用国内镜像源（`registry.npmmirror.com`、Electron 镜像等），确保依赖下载稳定。

## TODO

- [ ] 支持一个主表 + 多个跨表
- [ ] 支持模糊匹配
- [ ] 支持多条件组合匹配
