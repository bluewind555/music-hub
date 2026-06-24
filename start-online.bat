@echo off
chcp 65001 >nul
title MusicHub Online
setlocal enabledelayedexpansion

set APP_DIR=%~dp0
set CLOUDFLARED=%APP_DIR%bin\cloudflared.exe

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

:: Start Node.js server (serves both frontend + API)
echo [..] Starting MusicHub server...
start "MusicHubServer" /min node "%APP_DIR%server.js"
timeout /t 4 /nobreak >nul

:: Check server is running
curl -s http://localhost:3000 >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Server is running on http://localhost:3000
) else (
    echo [WARN] Server may not be ready yet
)

:: Start Cloudflare Tunnel
echo.
echo [..] Creating Cloudflare Tunnel (free, no account needed)...
echo.
echo ============================================
echo  The tunnel URL will appear below (xxx.trycloudflare.com)
echo  Share this URL with other devices to access MusicHub
echo  Close this window to stop the tunnel
echo ============================================
echo.

start "MusicHubTunnel" /min "%CLOUDFLARED%" tunnel --url http://localhost:3000 --protocol http2 --metrics localhost:33333

timeout /t 5 /nobreak >nul

:: Try to detect the tunnel URL by querying the metrics endpoint
echo [..] Detecting tunnel URL...
for /f "tokens=*" %%a in ('curl -s http://localhost:33333/metrics 2^>nul ^| findstr "userHostnames"') do (
    set "TUNNEL_URL=%%a"
)
if defined TUNNEL_URL (
    echo [OK] Tunnel URL detected
) else (
    echo [INFO] Open the MusicHubTunnel window to see the URL
)

echo.
echo ============================================
echo  Your MusicHub is now ONLINE!
echo.
echo  Step 1: Find the tunnel URL in "MusicHubTunnel" window
echo         It looks like: https://xxx.trycloudflare.com
echo.
echo  Step 2: Open that URL on any device (phone, other PC)
echo         The music search and playback will work!
echo.
echo  NOTE: This PC must stay on for others to access
echo ============================================
echo.
echo [OPEN] Opening local MusicHub...
start "" http://localhost:3000

echo.
echo Press any key to stop all services...
pause >nul

:: Cleanup on exit
echo [..] Stopping services...
taskkill /f /im node.exe /fi "WINDOWTITLE eq MusicHubServer" >nul 2>nul
taskkill /f /im cloudflared.exe >nul 2>nul
echo [OK] All services stopped.
timeout /t 2 /nobreak >nul
exit
