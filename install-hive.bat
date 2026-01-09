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

echo Creating directories...
if not exist "%SESSIONS_DIR%" mkdir "%SESSIONS_DIR%"
if not exist "%SESSIONS_DIR%\logs" mkdir "%SESSIONS_DIR%\logs"

echo Downloading Hive Code...
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
