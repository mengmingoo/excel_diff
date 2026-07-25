@echo off
title 跨表匹配工具 - 启动中...

echo ============================================
echo   跨表匹配工具 - 启动
echo ============================================
echo.

cd /d "%~dp0"

:: 检查 Node.js
echo [0/4] 检查 Node.js 环境...
where node >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 Node.js，请先安装 Node.js
    echo 下载地址: https://nodejs.org/
    pause
    exit /b 1
)
echo Node.js 已就绪

echo.
echo [1/4] 检查依赖...
if not exist "node_modules" (
    echo 依赖未安装，正在安装（使用国内源）...
    call npm install --registry=https://registry.npmmirror.com
    if errorlevel 1 (
        echo [错误] 依赖安装失败，请检查网络连接
        pause
        exit /b 1
    )
    echo 依赖安装完成
) else (
    echo 依赖已就绪
)

echo.
echo [2/4] 构建前端...
call npm run build
if errorlevel 1 (
    echo [错误] 前端构建失败
    pause
    exit /b 1
)
echo 构建完成

echo.
echo [3/4] 检查 Electron...
set ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
call npx electron --version >nul 2>&1
if errorlevel 1 (
    echo Electron 未安装，正在下载（首次约100MB，请耐心等待）...
    call npx install-electron
    if errorlevel 1 (
        echo [错误] Electron 下载失败，请检查网络连接
        pause
        exit /b 1
    )
    echo Electron 安装完成
) else (
    echo Electron 已就绪
)

echo.
echo [4/4] 启动 Electron 应用...
echo 请勿关闭此窗口，关闭此窗口将停止应用
echo ============================================
set NODE_ENV=development
call npx electron . 2>&1
if errorlevel 1 (
    echo.
    echo [错误] 应用启动失败，错误码: %errorlevel%
    echo 请截图此窗口内容并反馈
)
echo.
echo 应用已关闭
pause