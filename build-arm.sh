#!/usr/bin/env bash
# 打包应用（麒麟 V10 / ARM64）
set -u

# 切换到脚本所在目录
cd "$(dirname "$0")" || exit 1

echo "============================================"
echo "  打包应用 (麒麟 ARM64)"
echo "============================================"
echo ""

# 检查 CPU 架构
ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64) echo "架构: ARM64 OK" ;;
  *) echo "[警告] 当前架构为 $ARCH，非 ARM64，本脚本可能不适用" ;;
esac

# [0/3] 检查 Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "[错误] 未找到 Node.js，请先安装 ARM64 版 Node.js"
    echo "下载地址: https://nodejs.org/"
    exit 1
fi
echo "Node.js OK ($(node -v))"

echo ""
# [1/3] 检查依赖
export ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
if [ ! -d "node_modules" ]; then
    echo "安装依赖（国内源）..."
    npm install --registry=https://registry.npmmirror.com || { echo "[错误] npm install 失败"; exit 1; }
    echo "依赖安装完成"
else
    echo "依赖 OK"
fi

echo ""
# [2/3] 提示麒麟打包依赖
# 打 deb 包需要 fpm，electron-builder 会自动下载；
# 若失败，请先安装：sudo apt install ruby ruby-dev 或 sudo apt install fpm

echo ""
# [3/3] 打包 ARM64 安装包（国内源）
echo "这可能需要几分钟..."
export ELECTRON_BUILDER_BINARIES_MIRROR=https://npmmirror.com/mirrors/electron-builder-binaries/
npm run electron:build -- --arm64 || { echo "[错误] 打包失败"; exit 1; }

echo ""
echo "============================================"
echo "  打包完成!"
echo "  输出目录: release/"
echo "============================================"
exit 0
