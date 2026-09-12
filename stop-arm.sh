#!/usr/bin/env bash
# 停止应用（麒麟 V10 / ARM64）
set -u

# 切换到脚本所在目录
APP_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "============================================"
echo "  关闭应用"
echo "============================================"
echo ""

# 停止 Electron 进程（匹配项目目录下的 electron）
if pkill -f "$APP_DIR/node_modules/electron" >/dev/null 2>&1; then
    echo "Electron 已停止"
else
    echo "未找到 Electron 进程"
fi

echo ""
# 停止 Vite dev server（如正在运行）
if pkill -f "$APP_DIR/node_modules/.bin/vite" >/dev/null 2>&1; then
    echo "Vite dev server 已停止"
else
    echo "未找到 Vite dev server 进程"
fi

echo ""
echo "============================================"
echo "  所有进程已关闭"
echo "============================================"
sleep 2
exit 0
