@echo off
title Stop MusicHub
echo ============================================
echo     Stopping MusicHub API Service
echo ============================================
echo.

taskkill /f /im node.exe /fi "WINDOWTITLE eq NeteaseMusicAPI" >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] API service stopped
) else (
    echo [INFO] No running API service found
)

echo.
echo You can also manually close the NeteaseMusicAPI window
timeout /t 3 /nobreak >nul
exit
