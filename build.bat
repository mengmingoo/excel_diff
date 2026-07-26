@echo off
chcp 65001 >nul
title KuaBiaoPiPei - DaBao
setlocal enabledelayedexpansion

echo ============================================
echo   DaBao YingYong
echo ============================================
echo.

cd /d "%~dp0"

echo [0/2] JianCha Node.js...
where node >nul 2>&1
if errorlevel 1 (
    echo [CUOWU] WeiZhaoDao Node.js, QingXianAnZhuang Node.js
    echo XiaZai: https://nodejs.org/
    goto :end
)
echo Node.js OK

echo.
echo [1/2] JianCha YiLai...
if not exist "node_modules" goto :install_deps
echo YiLai OK
goto :skip_install

:install_deps
echo AnZhuang YiLai (GuoNeiYuan)...
call npm install --registry=https://registry.npmmirror.com
if errorlevel 1 (
    echo [CUOWU] npm install ShiBai
    goto :end
)
echo YiLai AnZhuang WanCheng

:skip_install
echo.
echo [2/2] DaBao Electron YingYong (GuoNeiYuan)...
echo ZheKeNeng XuYao JiFenZhong...
set ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
set ELECTRON_BUILDER_BINARIES_MIRROR=https://npmmirror.com/mirrors/electron-builder-binaries/
call npm run electron:build
if errorlevel 1 (
    echo [CUOWU] DaBao ShiBai
    goto :end
)

echo.
echo ============================================
echo   DaBao WanCheng!
echo   ShuChu MuLu: release\
echo ============================================

:end
echo.
pause