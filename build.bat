@echo off
title KuaBiaoPiPei - Build

echo ============================================
echo   Build App
echo ============================================
echo.

cd /d "%~dp0"

echo [0/3] Check Node.js...
where node >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js not found. Please install Node.js first.
    echo Download: https://nodejs.org/
    pause
    exit /b 1
)
echo Node.js OK

echo.
echo [1/3] Check dependencies...
if not exist "node_modules" (
    echo Installing dependencies (CN mirror)...
    call npm install --registry=https://registry.npmmirror.com
    if errorlevel 1 (
        echo [ERROR] npm install failed.
        pause
        exit /b 1
    )
    echo Dependencies installed
) else (
    echo Dependencies OK
)

echo.
echo [2/3] Build frontend...
call npm run build
if errorlevel 1 (
    echo [ERROR] Build failed.
    pause
    exit /b 1
)
echo Build OK

echo.
echo [3/3] Package Electron app (CN mirror)...
echo This may take several minutes...
set ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
call npm run electron:build
if errorlevel 1 (
    echo [ERROR] Package failed.
    pause
    exit /b 1
)

echo.
echo ============================================
echo   Build complete!
echo   Output: release\
echo ============================================

pause
exit
