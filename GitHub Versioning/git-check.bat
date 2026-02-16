@echo off
setlocal enabledelayedexpansion

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

REM Read configuration from config.txt
set "CONFIG_FILE=%SCRIPT_DIR%config.txt"

if not exist "%CONFIG_FILE%" exit /b 9

REM Read config silently
for /f "usebackq tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
    if "%%A"=="GIT" set "GIT=%%B"
    if "%%A"=="REPO" set "REPO=%%B"
)

REM Verify variables were loaded
if not defined GIT exit /b 9
if not defined REPO exit /b 9

REM Test if git works
"!GIT!" --version >nul 2>&1
if errorlevel 1 exit /b 9

REM Change to repository directory
cd /d "!REPO!" >nul 2>&1
if errorlevel 1 exit /b 9

REM Fetch remote changes
"!GIT!" fetch >nul 2>&1
if errorlevel 1 exit /b 9

REM Count local commits ahead
set LOCAL_AHEAD=0
for /f "tokens=*" %%A in ('"!GIT!" rev-list --count @{u}..HEAD 2^>nul') do set LOCAL_AHEAD=%%A

REM Count remote commits ahead
set REMOTE_AHEAD=0
for /f "tokens=*" %%A in ('"!GIT!" rev-list --count HEAD..@{u} 2^>nul') do set REMOTE_AHEAD=%%A

REM Return exit code based on status
if !LOCAL_AHEAD! gtr 0 if !REMOTE_AHEAD! gtr 0 exit /b 3
if !LOCAL_AHEAD! gtr 0 exit /b 1
if !REMOTE_AHEAD! gtr 0 exit /b 2
exit /b 0