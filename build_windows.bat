@echo off
REM ═══════════════════════════════════════════════════════
REM  RFID Cut Station — Windows EXE Builder
REM ═══════════════════════════════════════════════════════
REM  Run this ONCE on the Windows machine to create a
REM  single-folder EXE that anyone can double-click.
REM
REM  Prerequisites:
REM    1. Python 3.8+ installed
REM    2. Run: pip install pyserial pyinstaller
REM    3. (Optional) pip install pyodbc   — if using SQL Server
REM ═══════════════════════════════════════════════════════

echo.
echo ┌─────────────────────────────────────────────┐
echo │   RFID Cut Station — Building EXE...        │
echo └─────────────────────────────────────────────┘
echo.

REM Install dependencies
echo [1/3] Installing dependencies...
pip install pyserial pyinstaller --quiet 2>nul

REM Build EXE
echo [2/3] Building EXE with PyInstaller...
cd app
pyinstaller --noconfirm --onedir --console ^
    --name "RFID_CutStation" ^
    --add-data "dashboard.html;." ^
    --add-data "config.ini;." ^
    --add-data "setup_db.py;." ^
    --hidden-import serial ^
    --hidden-import serial.tools ^
    --hidden-import serial.tools.list_ports ^
    main.py
cd ..

REM Copy config to output (so it's editable)
echo [3/3] Copying config files...
copy /Y app\config.ini app\dist\RFID_CutStation\config.ini >nul 2>nul
copy /Y app\setup_db.py app\dist\RFID_CutStation\setup_db.py >nul 2>nul

echo.
echo ┌─────────────────────────────────────────────┐
echo │   ✅ BUILD COMPLETE!                        │
echo │                                             │
echo │   Output: app\dist\RFID_CutStation\         │
echo │   Run:    RFID_CutStation.exe               │
echo │                                             │
echo │   The browser opens automatically.          │
echo │   Click ⚙️ Settings to configure DB.        │
echo └─────────────────────────────────────────────┘
echo.
pause
