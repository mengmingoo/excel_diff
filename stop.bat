@echo off
chcp 65001 >nul
title 跨表匹配工具 - 关闭

echo ============================================
echo   跨表匹配工具 - 关闭
echo ============================================
echo.

echo 正在关闭 Electron 应用...
taskkill /f /im electron.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo Electron 进程已关闭
) else (
    echo 没有正在运行的 Electron 进程
)

echo.
echo 正在关闭 Node.js 进程...
taskkill /f /im node.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo Node.js 进程已关闭
) else (
    echo 没有正在运行的 Node.js 进程
)

echo.
echo ============================================
echo   所有进程已关闭
echo ============================================

timeout /t 2 >nul
exit