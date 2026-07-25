@echo off
chcp 65001 >nul
title 跨表匹配工具 - 打包中...

echo ============================================
echo   跨表匹配工具 - 打包
echo ============================================
echo.

cd /d "%~dp0"

echo [1/3] 检查依赖...
if not exist "node_modules" (
    echo 依赖未安装，正在安装（使用国内源）...
    call npm install --registry=https://registry.npmmirror.com
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
echo 前端构建完成

echo.
echo [3/3] 打包 Electron 应用（使用国内源）...
set ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
call npm run electron:build
if errorlevel 1 (
    echo 打包失败
    pause
    exit /b 1
)

echo.
echo ============================================
echo   打包完成！
echo   输出目录: release\
echo ============================================

pause
exit