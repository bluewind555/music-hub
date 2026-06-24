@echo off
chcp 65001 >nul
title Stop MusicHub
echo ============================================
echo     Stopping MusicHub Services
echo ============================================
echo.

taskkill /f /im node.exe /fi "WINDOWTITLE eq MusicHubServer" >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Server stopped
) else (
    taskkill /f /im node.exe >nul 2>nul
    if %errorlevel% equ 0 ( echo [OK] Node.js processes stopped ) else ( echo [INFO] No server running )
)

taskkill /f /im cloudflared.exe >nul 2>nul
if %errorlevel% equ 0 ( echo [OK] Tunnel stopped ) else ( echo [INFO] No tunnel running )

echo.
echo All services stopped.
timeout /t 3 /nobreak >nul
exit
