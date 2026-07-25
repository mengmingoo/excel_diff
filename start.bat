@echo off
chcp 65001 >nul
title 跨表匹配工具 - 启动中...

echo ============================================
echo   跨表匹配工具 - 启动
echo ============================================
echo.

cd /d "%~dp0"

echo [1/3] 检查依赖...
if not exist "node_modules" (
    echo 依赖未安装，正在安装...
    call npm install
    if errorlevel 1 (
        echo 依赖安装失败，请检查网络连接
        pause
        exit /b 1
    )
    echo 依赖安装完成
) else (
    echo 依赖已就绪
)

echo.
echo [2/3] 构建前端...
call npm run build
if errorlevel 1 (
    echo 前端构建失败
    pause
    exit /b 1
)

echo.
echo [3/3] 启动 Electron 应用...
echo 请勿关闭此窗口，关闭此窗口将停止应用
echo ============================================
set NODE_ENV=development
npx electron .
echo.
echo 应用已关闭
pause