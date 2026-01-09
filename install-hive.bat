@echo off
REM Hive Code Installer for Windows
REM Double-click this file to install - fully automated
REM Installs: Node.js, Claude CLI, Hive Agent
REM Then connects to agent.hiveskill.com

setlocal EnableDelayedExpansion

echo.
echo ===================================================
echo   Hive Code Installer
echo ===================================================
echo.

set "AGENT_DIR=%USERPROFILE%\.hive-agent"
set "PACKAGE_DIR=%AGENT_DIR%\package"
set "CONFIG_FILE=%AGENT_DIR%\config.json"
set "NODE_INSTALLER=%TEMP%\node-installer.msi"
set "NODE_URL=https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi"
set "REPO_ZIP=%TEMP%\ai-web-interface.zip"
set "REPO_URL=https://github.com/fanning/ai-web-interface/archive/refs/heads/main.zip"

REM Check if Node.js is installed
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [1/5] Installing Node.js...
    echo.
    powershell -NoProfile -Command "Invoke-WebRequest -Uri '%NODE_URL%' -OutFile '%NODE_INSTALLER%'"

    if not exist "%NODE_INSTALLER%" (
        echo Failed to download Node.js installer.
        pause
        exit /b 1
    )

    echo Installing Node.js (this may take a minute)...
    echo You may see a UAC prompt - please click Yes.
    echo.
    msiexec /i "%NODE_INSTALLER%" /qn /norestart

    if %ERRORLEVEL% NEQ 0 (
        echo Trying interactive install...
        msiexec /i "%NODE_INSTALLER%"
    )

    REM Refresh PATH
    set "PATH=%PATH%;C:\Program Files\nodejs"

    REM Clean up
    del "%NODE_INSTALLER%" 2>nul

    echo Node.js installed.
    echo.
) else (
    echo [1/5] Node.js already installed.
)

REM Check if Claude CLI is installed
where claude >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [2/5] Installing Claude CLI...
    echo This may take a minute...
    call "C:\Program Files\nodejs\npm.cmd" install -g @anthropic-ai/claude-code
    if %ERRORLEVEL% NEQ 0 (
        call npm install -g @anthropic-ai/claude-code
    )
    echo Claude CLI installed.
    echo.
) else (
    echo [2/5] Claude CLI already installed.
)

REM Create agent directory
echo [3/5] Setting up Hive Agent...
if not exist "%AGENT_DIR%" mkdir "%AGENT_DIR%"

REM Download and extract the agent package
echo Downloading Hive Agent package...
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%REPO_URL%' -OutFile '%REPO_ZIP%'"

if not exist "%REPO_ZIP%" (
    echo Failed to download Hive Agent package.
    pause
    exit /b 1
)

REM Extract the zip
echo Extracting...
if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"
powershell -NoProfile -Command "Expand-Archive -Path '%REPO_ZIP%' -DestinationPath '%AGENT_DIR%' -Force"

REM Rename extracted folder
if exist "%AGENT_DIR%\ai-web-interface-main" (
    move "%AGENT_DIR%\ai-web-interface-main" "%PACKAGE_DIR%" >nul
)

REM Clean up zip
del "%REPO_ZIP%" 2>nul

REM Install dependencies
echo [4/5] Installing dependencies...
cd /d "%PACKAGE_DIR%"
call "C:\Program Files\nodejs\npm.cmd" install --production
if %ERRORLEVEL% NEQ 0 (
    call npm install --production
)

REM Initialize agent (generate password)
echo [5/5] Initializing Hive Agent...
for /f "usebackq tokens=*" %%a in (`node scripts\init-agent.js --json`) do set "CONFIG_JSON=%%a"

REM Extract password from config
for /f "tokens=2 delims=:," %%a in ('echo !CONFIG_JSON! ^| findstr /C:"password"') do (
    set "PASSWORD=%%~a"
    set "PASSWORD=!PASSWORD:"=!"
    set "PASSWORD=!PASSWORD: =!"
)

REM Start agent in background
echo.
echo Starting Hive Agent...
start /B "HiveAgent" cmd /c "cd /d "%PACKAGE_DIR%" && node server\agent.js > "%AGENT_DIR%\agent.log" 2>&1"

REM Wait a moment for agent to connect
timeout /t 3 /nobreak >nul

echo.
echo ===================================================
echo   Installation complete!
echo ===================================================
echo.
echo   Your Hive Code agent is now running and connected.
echo.
echo   Opening your dashboard in the browser...
echo.
echo ===================================================
echo   YOUR PASSWORD (save this!)
echo ===================================================
echo.
echo   Password: !PASSWORD!
echo.
echo   You will need this password to access your
echo   sessions at https://agent.hiveskill.com
echo.
echo ===================================================
echo.

REM Open browser to hub
start "" "https://agent.hiveskill.com/?password=!PASSWORD!"

echo Press any key to close this window...
pause >nul
