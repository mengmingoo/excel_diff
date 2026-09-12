#!/usr/bin/env bash
# 打包应用（Linux）
set -u

# 切换到脚本所在目录
cd "$(dirname "$0")" || exit 1

echo "============================================"
echo "  打包应用"
echo "============================================"
echo ""

# [0/2] 检查 Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "[错误] 未找到 Node.js，请先安装 Node.js"
    echo "下载地址: https://nodejs.org/"
    exit 1
fi
echo "Node.js OK"

echo ""
# [1/2] 检查依赖
if [ ! -d "node_modules" ]; then
    echo "安装依赖（国内源）..."
    npm install --registry=https://registry.npmmirror.com || { echo "[错误] npm install 失败"; exit 1; }
    echo "依赖安装完成"
else
    echo "依赖 OK"
fi

echo ""
# [2/2] 打包 Electron 应用（国内源）
echo "这可能需要几分钟..."
export ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
export ELECTRON_BUILDER_BINARIES_MIRROR=https://npmmirror.com/mirrors/electron-builder-binaries/
npm run electron:build || { echo "[错误] 打包失败"; exit 1; }

echo ""
echo "============================================"
echo "  打包完成!"
echo "  输出目录: release/"
echo "============================================"
exit 0
