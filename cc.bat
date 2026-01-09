@echo off
REM cc.bat - Hive Code Bootstrap with Crash Recovery
REM Version 1.7.0 - Standalone edition

setlocal EnableDelayedExpansion

set "SESSIONS_DIR=%USERPROFILE%\.claude-sessions"
set "SESSIONS_FILE=%SESSIONS_DIR%\sessions.json"
set "LOGS_DIR=%SESSIONS_DIR%\logs"
set "PLATFORM=windows"
set "CC_VERSION=1.7.0"

REM Ensure directories exist
if not exist "%SESSIONS_DIR%" mkdir "%SESSIONS_DIR%"
if not exist "%LOGS_DIR%" mkdir "%LOGS_DIR%"

REM Initialize sessions.json if needed
if not exist "%SESSIONS_FILE%" (
    echo {"version":"1.0","lastUpdated":"","sessions":[]} > "%SESSIONS_FILE%"
)

REM Handle arguments
if "%~1"=="-h" goto :show_help
if "%~1"=="--help" goto :show_help
if "%~1"=="/?" goto :show_help
if "%~1"=="--setup-token" goto :do_setup_token
if "%~1"=="--check-token" goto :do_check_token
if "%~1"=="-c" goto :do_continue
if "%~1"=="--continue" goto :do_continue
if "%~1"=="-r" goto :do_restore
if "%~1"=="--restore" goto :do_restore
if "%~1"=="-l" goto :do_list
if "%~1"=="--list" goto :do_list

REM Generate UUID for session ID
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "[guid]::NewGuid().ToString()"') do set "SESSION_ID=%%a"

REM Set session name
if "%~1"=="" (
    set "SESSION_NAME=Windows : General : %DATE%"
) else (
    set "SESSION_NAME=%~1"
)

REM Set terminal title
title %SESSION_NAME%

REM Display session info
echo.
echo ===================================================
echo   Hive Code Session Starting
echo ===================================================
echo   Session ID: %SESSION_ID%
echo   Name: %SESSION_NAME%
echo   Platform: %PLATFORM%
echo ===================================================
echo.

REM Record session start
powershell -NoProfile -Command ^
    "$f='%SESSIONS_FILE%';$j=Get-Content $f|ConvertFrom-Json;" ^
    "$j.sessions+=@{id='%SESSION_ID%';name='%SESSION_NAME%';started=(Get-Date -Format o);status='running'};" ^
    "$j|ConvertTo-Json -Depth 10|Set-Content $f" 2>nul

echo Starting Hive Code...
echo.

REM Run Claude with session tracking
claude --dangerously-skip-permissions --session-id "%SESSION_ID%"

REM Record session end
powershell -NoProfile -Command ^
    "$f='%SESSIONS_FILE%';$j=Get-Content $f|ConvertFrom-Json;" ^
    "foreach($s in $j.sessions){if($s.id -eq '%SESSION_ID%'){$s.status='stopped';$s.ended=(Get-Date -Format o)}};" ^
    "$j|ConvertTo-Json -Depth 10|Set-Content $f" 2>nul

echo.
echo Session ended.
goto :end

REM ===== COMMANDS =====

:do_continue
echo Continuing most recent session...
claude --dangerously-skip-permissions --continue
goto :end

:do_restore
echo.
echo Recent sessions:
echo.
powershell -NoProfile -Command ^
    "$j=Get-Content '%SESSIONS_FILE%'|ConvertFrom-Json;" ^
    "$i=1;foreach($s in $j.sessions|Sort-Object -Property started -Descending|Select-Object -First 10){" ^
    "Write-Host \"[$i] $($s.status.ToUpper().PadRight(8)) $($s.name)\" -ForegroundColor $(if($s.status -eq 'running'){'Green'}else{'Yellow'});" ^
    "Write-Host \"    $($s.id)\" -ForegroundColor DarkGray;$i++}"
echo.
set /p "CHOICE=Enter session number (or 'q' to quit): "
if "%CHOICE%"=="q" goto :end
if "%CHOICE%"=="Q" goto :end

for /f "tokens=*" %%a in ('powershell -NoProfile -Command ^
    "$j=Get-Content '%SESSIONS_FILE%'|ConvertFrom-Json;" ^
    "$s=$j.sessions|Sort-Object -Property started -Descending|Select-Object -First 10;" ^
    "$s[%CHOICE%-1].id"') do set "RESUME_ID=%%a"

if defined RESUME_ID (
    echo Resuming session: %RESUME_ID%
    claude --dangerously-skip-permissions --resume "%RESUME_ID%"
)
goto :end

:do_list
echo.
echo === All Sessions ===
echo.
powershell -NoProfile -Command ^
    "$j=Get-Content '%SESSIONS_FILE%'|ConvertFrom-Json;" ^
    "foreach($s in $j.sessions|Sort-Object -Property started -Descending){" ^
    "Write-Host \"[$($s.status.ToUpper().PadRight(8))] $($s.name)\" -ForegroundColor $(if($s.status -eq 'running'){'Green'}else{'Gray'});" ^
    "Write-Host \"  ID: $($s.id)\" -ForegroundColor DarkGray;" ^
    "Write-Host \"  Started: $($s.started)\" -ForegroundColor DarkGray;Write-Host ''}"
goto :end

:do_setup_token
echo.
echo Setting up long-lived authentication token...
echo This token lasts 1 year and is required for persistent agents.
echo.
claude setup-token
goto :end

:do_check_token
powershell -NoProfile -Command ^
    "$c='%USERPROFILE%\.claude\.credentials.json';" ^
    "if(Test-Path $c){" ^
    "$j=Get-Content $c|ConvertFrom-Json;" ^
    "$exp=$j.claudeAiOauth.expiresAt;" ^
    "$d=[DateTimeOffset]::FromUnixTimeMilliseconds($exp).LocalDateTime;" ^
    "$left=($d-(Get-Date)).Days;" ^
    "Write-Host \"`nHive Token Status:`n  Expires: $d`n  Days left: $left`n\";" ^
    "if($left -le 30){Write-Host 'WARNING: Token expiring soon!' -ForegroundColor Yellow}" ^
    "else{Write-Host 'Token OK' -ForegroundColor Green}" ^
    "}else{Write-Host 'No credentials found'}"
goto :end

:show_help
echo.
echo ===================================================
echo   Hive Code Bootstrap v%CC_VERSION%
echo ===================================================
echo.
echo USAGE:
echo   cc                    Start new session (auto-named)
echo   cc "Name"             Start session with custom name
echo   cc -c, --continue     Continue most recent session
echo   cc -r, --restore      Interactive session restore
echo   cc -l, --list         List all sessions
echo   cc --setup-token      Set up long-lived token (1 year)
echo   cc --check-token      Check token expiry status
echo   cc -h, --help         Show this help
echo.
echo SESSION NAMING:
echo   Format: "Project : Goal : Task"
echo   Example: cc "MyApp : Build : Feature X"
echo.
echo LONG-LIVED TOKENS:
echo   Run 'cc --setup-token' once per year for persistent agents.
echo   Tokens last 1 year vs 24 hours for regular OAuth.
echo   Run 'cc --check-token' to see days until expiry.
echo.
echo FILES:
echo   Sessions: %SESSIONS_FILE%
echo.
echo ===================================================
goto :end

:end
endlocal
