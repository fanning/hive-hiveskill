@echo off
REM Hive Code Installer for Windows
REM Double-click this file to install - fully automated

echo.
echo ===================================================
echo   Hive Code Installer
echo ===================================================
echo.

set "INSTALL_PATH=%USERPROFILE%\cc.bat"
set "SESSIONS_DIR=%USERPROFILE%\.claude-sessions"
set "SCRIPT_URL=https://raw.githubusercontent.com/fanning/hive-hiveskill/master/cc.bat"
set "NODE_INSTALLER=%TEMP%\node-installer.msi"
set "NODE_URL=https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi"

REM Check if Node.js is installed
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Node.js not found. Downloading installer...
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
)

REM Check if Claude CLI is installed
where claude >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Installing Claude CLI...
    echo This may take a minute...
    call "C:\Program Files\nodejs\npm.cmd" install -g @anthropic-ai/claude-code
    if %ERRORLEVEL% NEQ 0 (
        call npm install -g @anthropic-ai/claude-code
    )
    echo Claude CLI installed.
    echo.
)

echo Creating directories...
if not exist "%SESSIONS_DIR%" mkdir "%SESSIONS_DIR%"
if not exist "%SESSIONS_DIR%\logs" mkdir "%SESSIONS_DIR%\logs"

echo Downloading Hive Code bootstrap...
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%SCRIPT_URL%' -OutFile '%INSTALL_PATH%'"

if exist "%INSTALL_PATH%" (
    echo.
    echo ===================================================
    echo   Installation complete!
    echo ===================================================
    echo.
    echo   Location: %INSTALL_PATH%
    echo.
    echo   IMPORTANT: Close this window and open a NEW
    echo   Command Prompt or PowerShell, then run:
    echo.
    echo     cc -h          Show help
    echo     cc "Project"   Start a session
    echo     cc -r          Restore a session
    echo.
    echo ===================================================
) else (
    echo.
    echo Installation failed. Please try again.
)

echo.
pause
