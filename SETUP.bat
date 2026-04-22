@echo off
REM ═══════════════════════════════════════════════════════
REM  RFID Cut Station — First Time Setup
REM  Run this ONCE on a new Windows machine.
REM ═══════════════════════════════════════════════════════

title RFID Cut Station - Setup
echo.
echo   ╔═══════════════════════════════════════════╗
echo   ║   🏭 RFID Cut Station — First Time Setup  ║
echo   ╚═══════════════════════════════════════════╝
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo   ❌ Python not found!
    echo   Download from: https://python.org
    echo   IMPORTANT: Check "Add Python to PATH" during install!
    echo.
    pause
    exit /b
)

echo   ✅ Python found
python --version
echo.

REM Install dependencies
echo   📦 Installing dependencies...
pip install pyserial --quiet
echo   ✅ pyserial installed

REM Optional: SQL Server driver
echo.
echo   Do you need SQL Server? (for production database)
set /p SQLSERVER="  Type Y or N: "
if /i "%SQLSERVER%"=="Y" (
    echo   📦 Installing pyodbc...
    pip install pyodbc --quiet
    echo   ✅ pyodbc installed
)

echo.
echo   ╔═══════════════════════════════════════════╗
echo   ║   ✅ SETUP COMPLETE!                      ║
echo   ║                                           ║
echo   ║   Now double-click START.bat to run.      ║
echo   ╚═══════════════════════════════════════════╝
echo.
pause
