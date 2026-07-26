@echo off
chcp 65001 >nul
title KuaBiaoPiPei - GuanBi

echo ============================================
echo   GuanBi YingYong
echo ============================================
echo.

echo TingZhi Electron...
taskkill /f /im electron.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo Electron YiTingZhi
) else (
    echo WeiZhaoDao Electron JinCheng
)

echo.
echo TingZhi Node.js...
taskkill /f /im node.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo Node.js YiTingZhi
) else (
    echo WeiZhaoDao Node.js JinCheng
)

echo.
echo ============================================
echo   SuoYou JinCheng YiGuanBi
echo ============================================

timeout /t 2 >nul 2>&1
pause
exit