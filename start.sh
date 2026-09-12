#!/usr/bin/env bash
# 启动应用（Linux）
set -u

# 切换到脚本所在目录
cd "$(dirname "$0")" || exit 1

echo "============================================"
echo "  跨表匹配工具 - 启动"
echo "============================================"
echo ""

# [0/4] 检查 Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "[错误] 未找到 Node.js，请先安装 Node.js"
    echo "下载地址: https://nodejs.org/"
    exit 1
fi
echo "Node.js OK"

echo ""
# [1/4] 检查依赖
if [ ! -d "node_modules" ]; then
    echo "安装依赖（国内源）..."
    npm install --registry=https://registry.npmmirror.com || { echo "[错误] npm install 失败"; exit 1; }
    echo "依赖安装完成"
else
    echo "依赖 OK"
fi

echo ""
# [2/4] 构建前端
npm run build || { echo "[错误] 构建失败"; exit 1; }
echo "构建 OK"

echo ""
# [3/4] 启动 Electron
echo "请勿关闭此窗口"
echo "============================================"
export ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
npx electron .

echo ""
echo "应用已关闭"
exit 0
