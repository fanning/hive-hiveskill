@echo off
REM Hive Code Installer for Windows
REM Double-click this file to install

echo.
echo ===================================================
echo   Hive Code Installer
echo ===================================================
echo.

set "INSTALL_PATH=%USERPROFILE%\cc.bat"
set "SESSIONS_DIR=%USERPROFILE%\.claude-sessions"
set "SCRIPT_URL=https://raw.githubusercontent.com/fanning/hive-hiveskill/master/cc.bat"

REM Check if Claude CLI is installed
where claude >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Claude CLI not found. Checking for npm...
    where npm >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo ===================================================
        echo   ERROR: Node.js is required
        echo ===================================================
        echo.
        echo   Please install Node.js first:
        echo   https://nodejs.org/
        echo.
        echo   Then run this installer again.
        echo ===================================================
        echo.
        pause
        exit /b 1
    )
    echo Installing Claude CLI via npm...
    echo This may take a minute...
    call npm install -g @anthropic-ai/claude-code
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo Failed to install Claude CLI. Please run manually:
        echo   npm install -g @anthropic-ai/claude-code
        echo.
        pause
        exit /b 1
    )
    echo Claude CLI installed successfully.
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
    echo   Open a NEW terminal and run:
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
