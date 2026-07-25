@echo off
title KuaBiaoPiPei - Stop

echo ============================================
echo   Close App
echo ============================================
echo.

echo Stopping Electron...
taskkill /f /im electron.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo Electron stopped
) else (
    echo No Electron process found
)

echo.
echo Stopping Node.js...
taskkill /f /im node.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo Node.js stopped
) else (
    echo No Node.js process found
)

echo.
echo ============================================
echo   All stopped
echo ============================================

timeout /t 2 >nul
exit
