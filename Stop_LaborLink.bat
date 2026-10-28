@echo off
setlocal
title LaborLink Shutdown

echo ==============================================================================
echo                      STOPPING LABORLINK SERVICES
echo ==============================================================================
echo.

set FOUND=0
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3000 ^| findstr LISTENING') do (
    echo Terminating process on port 3000 [PID: %%a]...
    taskkill /f /pid %%a >nul 2>&1
    set FOUND=1
)

if "%FOUND%"=="1" (
    echo [SUCCESS] LaborLink server on port 3000 has been stopped.
) else (
    echo [INFO] No active LaborLink process found on port 3000.
)

echo.
echo ==============================================================================
echo Application shut down successfully.
echo ==============================================================================
ping 127.0.0.1 -n 3 >nul
exit /b 0
