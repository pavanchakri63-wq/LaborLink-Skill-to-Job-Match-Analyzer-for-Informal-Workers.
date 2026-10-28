@echo off
setlocal EnableDelayedExpansion
title LaborLink Web Application Launcher

:: 1. Navigate to the project directory
cd /d "%~dp0"

echo ==============================================================================
echo                      LABORLINK - STARTING SERVICES
echo ==============================================================================
echo.

:: 2. Ensure Node.js is located in PATH
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
    echo [ERROR] Node.js was not detected on this machine.
    echo Please install Node.js LTS from: https://nodejs.org
    echo Or run Setup_LaborLink.bat if Node.js was recently installed.
    echo.
    pause
    exit /b 1
)

:: 3. Check for dependencies
if not exist "node_modules\" (
    echo [INFO] Project dependencies missing. Installing packages...
    call npm install
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] npm install failed. Please check internet connection and try again.
        pause
        exit /b 1
    )
)

:: 4. Release port 3000 if previously occupied
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3000 ^| findstr LISTENING') do (
    taskkill /f /pid %%a >nul 2>&1
)

:: 5. Compile TypeScript server to executable ES module
echo [1/3] Building application bundle...
call npx esbuild server.ts --platform=node --format=esm --outfile=server.js >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Server build failed. Check server.ts for compilation errors.
    pause
    exit /b 1
)

:: 6. Launch background server process
echo [2/3] Launching LaborLink server on port 3000...
start "LaborLink-Backend" /min cmd /c "node server.js"

:: 7. Wait for web server to become ready via HTTP probe
echo [3/3] Waiting for server to initialize...
node -e "const http=require('http');function check(r){if(r<=0)process.exit(1);http.get('http://localhost:3000/api/admin/stats',res=>{if(res.statusCode===200)process.exit(0);else setTimeout(()=>check(r-1),400);}).on('error',()=>setTimeout(()=>check(r-1),400));}check(50);"

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Server did not become ready in time.
    echo Run Stop_LaborLink.bat and restart Start_LaborLink.bat.
    pause
    exit /b 1
)

:: 8. Automatically open web browser
echo [SUCCESS] Server is online! Opening LaborLink in your default browser...
start http://localhost:3000

:: 9. Display Teacher Presentation Guide & Credentials
cls
echo ==============================================================================
echo                      LABORLINK - APPLICATION ACTIVE
echo ==============================================================================
echo.
echo   * Web Address: http://localhost:3000
echo   * Status:      ONLINE (Vite + Express Backend)
echo   * Offline:     Fully functional offline without external APIs
echo.
echo ------------------------------------------------------------------------------
echo   PRE-CONFIGURED DEMO ACCOUNTS (Click the quick buttons on the Login page):
echo ------------------------------------------------------------------------------
echo   1. Worker Portal:
echo      Email:    worker@laborlink.com
echo      Password: worker123
echo      Profile:  Ramesh Kumar (Bangalore - Electrician, Plumber, 5 yrs exp)
echo.
echo   2. Recruiter Portal:
echo      Email:    recruiter@laborlink.com
echo      Password: recruiter123
echo      Profile:  Ananya Sharma (Apex BuildTech - Bangalore)
echo.
echo   3. Admin Dashboard:
echo      Email:    admin@laborlink.com
echo      Password: admin123
echo.
echo ------------------------------------------------------------------------------
echo   RECOMMENDED DEMONSTRATION FLOW:
echo   - Worker:    Browse verified jobs, filter by skill, view Leaflet map,
echo                save/bookmark jobs, apply with simulated instant UPI fee.
echo   - Recruiter: Post new job, switch tabs to Browse Workers, inspect profiles,
echo                review job applicants, accept or reject candidates.
echo   - Admin:     View platform metrics, revenue charts, approve pending jobs,
echo                and export full system transactions to CSV.
echo ------------------------------------------------------------------------------
echo.
echo   [!] KEEP THIS WINDOW OPEN while demonstrating to your teacher.
echo   [!] Press any key to stop the server and close this window...
echo.
echo ==============================================================================
pause >nul

echo Stopping LaborLink services...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3000 ^| findstr LISTENING') do (
    taskkill /f /pid %%a >nul 2>&1
)
echo LaborLink server stopped safely.
ping 127.0.0.1 -n 3 >nul
exit /b 0
