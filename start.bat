@echo off
title KuaBiaoPiPei - QiDong

echo ============================================
echo   KuaBiaoPiPei - QiDong
echo ============================================
echo.

cd /d "%~dp0"

echo [0/4] Check Node.js...
where node >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js not found. Please install Node.js first.
    echo Download: https://nodejs.org/
    pause
    exit /b 1
)
echo Node.js OK

echo.
echo [1/4] Check dependencies...
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
echo [2/4] Build frontend...
call npm run build
if errorlevel 1 (
    echo [ERROR] Build failed.
    pause
    exit /b 1
)
echo Build OK

echo.
echo [3/4] Check Electron...
set ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
call npx electron --version >nul 2>&1
if errorlevel 1 (
    echo Downloading Electron (first time ~100MB, please wait)...
    call npx install-electron
    if errorlevel 1 (
        echo [ERROR] Electron download failed.
        pause
        exit /b 1
    )
    echo Electron installed
) else (
    echo Electron OK
)

echo.
echo [4/4] Launch Electron app...
echo DO NOT close this window while app is running
echo ============================================
set NODE_ENV=development
call npx electron .
if errorlevel 1 (
    echo.
    echo [ERROR] App launch failed, error code: %errorlevel%
)
echo.
echo App closed
pause
