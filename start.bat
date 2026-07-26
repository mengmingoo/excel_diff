@echo off
chcp 65001 >nul
title KuaBiaoPiPei - QiDong
setlocal enabledelayedexpansion

echo ============================================
echo   KuaBiaoPiPei - QiDong
echo ============================================
echo.

cd /d "%~dp0"

echo [0/4] JianCha Node.js...
where node >nul 2>&1
if errorlevel 1 (
    echo [CUOWU] WeiZhaoDao Node.js, QingXianAnZhuang Node.js
    echo XiaZai: https://nodejs.org/
    goto :end
)
echo Node.js OK

echo.
echo [1/4] JianCha YiLai...
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
echo [2/4] GouJian QianDuan...
call npm run build
if errorlevel 1 (
    echo [CUOWU] GouJian ShiBai
    goto :end
)
echo GouJian OK

echo.
echo [3/4] QiDong Electron...
echo QingWuGuanBi CiChuangKou
echo ============================================
set ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
call npx electron .
if errorlevel 1 (
    echo.
    echo [CUOWU] Electron QiDong ShiBai, CuoWuMa: !errorlevel!
)

echo.
echo YingYong YiGuanBi

:end
echo.
pause