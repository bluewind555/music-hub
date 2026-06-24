@echo off
chcp 65001 >nul
title MusicHub
setlocal enabledelayedexpansion

set APP_DIR=%~dp0
set API_DIR=%APP_DIR%node_modules\NeteaseCloudMusicApi
set HTML_FILE=%APP_DIR%index.html

echo ============================================
echo       MusicHub - Starting Services
echo ============================================
echo.

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found. Please install Node.js first.
    echo         https://nodejs.org
    pause
    exit /b
)

curl -s http://localhost:3000 >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] API server already running on port 3000
) else (
    echo [..] Starting Netease Music API server...
    start /min "NeteaseMusicAPI" node "%API_DIR%\app.js"

    set WAIT_COUNT=0
    :WAIT_LOOP
    curl -s http://localhost:3000 >nul 2>nul
    if !errorlevel! neq 0 (
        set /a WAIT_COUNT+=1
        if !WAIT_COUNT! lss 15 (
            timeout /t 1 /nobreak >nul
            goto WAIT_LOOP
        )
        echo [WARN] Server start may be slow, opening browser anyway
    ) else (
        echo [OK] API server ready!
    )
)

echo.
echo [OPEN] Launching MusicHub...
start "" "%HTML_FILE%"

echo.
echo ============================================
echo  Server: http://localhost:3000
echo  Close this window - server stays running
echo  To stop: close the NeteaseMusicAPI cmd window
echo  Location: %APP_DIR%
echo ============================================
timeout /t 5 /nobreak >nul
exit
