#!/usr/bin/env bash
# 启动应用（麒麟 V10 / ARM64）
set -u

# 切换到脚本所在目录
cd "$(dirname "$0")" || exit 1

echo "============================================"
echo "  跨表匹配工具 - 启动 (麒麟 ARM64)"
echo "============================================"
echo ""

# 检查 CPU 架构
ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64) echo "架构: ARM64 OK" ;;
  *) echo "[警告] 当前架构为 $ARCH，非 ARM64，本脚本可能不适用" ;;
esac

# [0/4] 检查 Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "[错误] 未找到 Node.js，请先安装 ARM64 版 Node.js"
    echo "下载地址: https://nodejs.org/"
    exit 1
fi
echo "Node.js OK ($(node -v))"

# 检查已安装的 electron 二进制架构是否匹配
if [ -f "node_modules/electron/dist/electron" ]; then
    ELEC_ARCH=$(node -e "console.log(process.arch)")
    if [ "$ELEC_ARCH" != "arm64" ]; then
        echo "[警告] 当前 electron 为 $ELEC_ARCH 架构，与 ARM64 不匹配"
        echo "请删除 node_modules 后重新执行本脚本（将自动下载 arm64 版 electron）"
    fi
fi

echo ""
# [1/4] 检查依赖
export ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
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
# 麒麟国产化环境常见无 root 权限的 sandbox 问题，故通过 ELECTRON_DISABLE_SANDBOX 禁用沙箱
echo "请勿关闭此窗口"
echo "============================================"
export ELECTRON_DISABLE_SANDBOX=1
npx electron .

echo ""
echo "应用已关闭"
exit 0
