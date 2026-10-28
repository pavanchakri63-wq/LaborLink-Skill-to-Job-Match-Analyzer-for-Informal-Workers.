@echo off
setlocal EnableDelayedExpansion
title LaborLink Setup and Installation

cd /d "%~dp0"

echo ==============================================================================
echo                      LABORLINK - ENVIRONMENT SETUP
echo ==============================================================================
echo.

where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    if exist "%LOCALAPPDATA%\Programs\nodejs\node.exe" (
        set "PATH=%LOCALAPPDATA%\Programs\nodejs;%PATH%"
    ) else if exist "C:\Program Files\nodejs\node.exe" (
        set "PATH=C:\Program Files\nodejs;%PATH%"
    ) else if exist "C:\Program Files (x86)\nodejs\node.exe" (
        set "PATH=C:\Program Files (x86)\nodejs;%PATH%"
    )
)

where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js is required but was not found.
    echo Please install Node.js (v18 or higher) from https://nodejs.org
    echo After installing Node.js, run this script again.
    echo.
    pause
    exit /b 1
)

echo [1/3] Node.js detected:
node -v
echo.

echo [2/3] Installing and verifying NPM dependencies...
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Dependency installation failed. Please check your network connection.
    pause
    exit /b 1
)

echo.
echo [3/3] Compiling production build and backend server...
call npm run build
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build step encountered an error.
    pause
    exit /b 1
)

echo.
echo ==============================================================================
echo                     SETUP COMPLETED SUCCESSFULLY!
echo ==============================================================================
echo.
echo You are now ready to demonstrate the application to your teacher!
echo Simply double-click "Start_LaborLink.bat" to start LaborLink.
echo.
echo ==============================================================================
pause
exit /b 0
