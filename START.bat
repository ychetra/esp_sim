@echo off
REM ═══════════════════════════════════════════════════════
REM  RFID Cut Station — One-Click Launcher
REM  Double-click this to start the station.
REM ═══════════════════════════════════════════════════════

title RFID Cut Station
echo.
echo   ╔═══════════════════════════════════════════╗
echo   ║   🏭 RFID Cut Station — Starting...       ║
echo   ╚═══════════════════════════════════════════╝
echo.

REM Install dependencies (only first run)
pip install pyserial --quiet 2>nul

REM Start the app
cd /d "%~dp0app"
python main.py

REM Keep window open if error
pause
