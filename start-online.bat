@echo off
chcp 65001 >nul
title MusicHub Online
setlocal enabledelayedexpansion

set APP_DIR=%~dp0
set CLOUDFLARED=%APP_DIR%bin\cloudflared.exe
set METRICS_PORT=45678

echo ============================================
echo    MusicHub Online - Starting Services
echo ============================================
echo.

:: Check Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found. Please install Node.js first.
    pause
    exit /b
)

:: Check cloudflared
if not exist "%CLOUDFLARED%" (
    echo [ERROR] cloudflared not found at %CLOUDFLARED%
    pause
    exit /b
)

:: Kill previous instances
taskkill /f /im node.exe /fi "WINDOWTITLE eq MusicHubServer" >nul 2>nul
taskkill /f /im cloudflared.exe >nul 2>nul
timeout /t 2 /nobreak >nul

:: Start Node.js server
echo [..] Starting MusicHub server...
start "MusicHubServer" /min node "%APP_DIR%server.js"
timeout /t 4 /nobreak >nul

:: Verify server
curl -s http://localhost:3000 >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Server is running on http://localhost:3000
) else (
    echo [WARN] Server may not be ready yet, continuing...
)

:: Start Cloudflare Tunnel in a normal (non-minimized) window
echo.
echo [..] Creating Cloudflare Tunnel...
echo.
start "MusicHubTunnel" "%CLOUDFLARED%" tunnel --url http://localhost:3000 --protocol http2 --metrics localhost:%METRICS_PORT%

echo  Waiting for tunnel to connect...
echo.
timeout /t 12 /nobreak >nul

:: Try to extract the tunnel URL from cloudflared's metrics
echo [..] Detecting tunnel URL...
set "TUNNEL_URL="
for /f "tokens=*" %%a in ('curl -s http://localhost:%METRICS_PORT%/metrics 2^>nul ^| findstr "userHostnames="') do (
    set "TUNNEL_LINE=%%a"
)
if defined TUNNEL_LINE (
    :: Extract URL between quotes
    for /f tokens^=2^ delims^=^" %%b in ("!TUNNEL_LINE!") do set "TUNNEL_URL=%%b"
)

echo.
echo ============================================
echo  Your MusicHub is ONLINE!
echo.
if defined TUNNEL_URL (
    echo  Public URL: !TUNNEL_URL!
) else (
    echo  Look in the "MusicHubTunnel" window for the URL
    echo  It looks like: https://xxx.trycloudflare.com
)
echo.
echo  Open the URL on any device to use MusicHub!
echo.
echo  Close THIS window to stop all services.
echo ============================================
echo.
echo [OPEN] Opening local MusicHub...
start "" http://localhost:3000

echo.
echo Press any key to stop all services...
pause >nul

:: Cleanup
echo [..] Stopping services...
taskkill /f /im node.exe /fi "WINDOWTITLE eq MusicHubServer" >nul 2>nul
taskkill /f /im cloudflared.exe >nul 2>nul
echo [OK] Stopped.
timeout /t 2 /nobreak >nul
exit
