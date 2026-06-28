@echo off
:: Valheim Mod Installer — Windows launcher
:: Double-click this file to install mods.
:: It runs install_valheim_mods.ps1 with the correct permissions.

echo.
echo  Starting Valheim Mod Installer...
echo.

:: Check if PowerShell is available
where powershell >nul 2>&1
if errorlevel 1 (
    echo  ERROR: PowerShell is not installed. Please install it from:
    echo  https://aka.ms/PSWindows
    pause
    exit /b 1
)

:: Run the installer script, bypassing execution policy for this session only
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_valheim_mods.ps1"

if errorlevel 1 (
    echo.
    echo  Something went wrong. See error above.
    pause
)
