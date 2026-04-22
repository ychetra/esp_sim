@echo off
REM ═══════════════════════════════════════════════════════
REM  RFID Cut Station — Full Installer
REM  
REM  This script:
REM    1. Installs Python dependencies
REM    2. Builds the EXE
REM    3. Copies to C:\RFID_CutStation
REM    4. Adds to Windows Startup (auto-run on boot)
REM    5. Creates Desktop shortcut
REM ═══════════════════════════════════════════════════════

title RFID Cut Station — Installer
echo.
echo   ╔═══════════════════════════════════════════════╗
echo   ║   🏭 RFID Cut Station — INSTALLER             ║
echo   ╚═══════════════════════════════════════════════╝
echo.

REM ─── Check Python ──────────────────────────────────────
python --version >nul 2>&1
if errorlevel 1 (
    echo   ❌ Python not found!
    echo   Download from https://python.org
    echo   ✅ Check "Add Python to PATH" during install!
    echo.
    pause
    exit /b
)
echo   ✅ Python found
python --version

REM ─── Install dependencies ──────────────────────────────
echo.
echo   [1/5] Installing dependencies...
pip install pyserial pyinstaller --quiet
pip install pyodbc --quiet 2>nul
echo   ✅ Dependencies installed

REM ─── Build EXE ─────────────────────────────────────────
echo   [2/5] Building EXE (this takes ~2 minutes)...
cd /d "%~dp0app"

pyinstaller --noconfirm --onefile --console ^
    --name "RFID_CutStation" ^
    --add-data "dashboard.html;." ^
    --hidden-import serial ^
    --hidden-import serial.tools ^
    --hidden-import serial.tools.list_ports ^
    --hidden-import serial.tools.list_ports_common ^
    --hidden-import serial.tools.list_ports_windows ^
    main.py

if not exist "dist\RFID_CutStation.exe" (
    echo   ❌ Build failed!
    pause
    exit /b
)
echo   ✅ EXE built successfully

REM ─── Install to C:\RFID_CutStation ────────────────────
echo   [3/5] Installing to C:\RFID_CutStation...
set INSTALL_DIR=C:\RFID_CutStation

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
copy /Y dist\RFID_CutStation.exe "%INSTALL_DIR%\RFID_CutStation.exe" >nul
copy /Y config.ini "%INSTALL_DIR%\config.ini" >nul
copy /Y setup_db.py "%INSTALL_DIR%\setup_db.py" >nul
echo   ✅ Installed to %INSTALL_DIR%

REM ─── Add to Windows Startup ────────────────────────────
echo   [4/5] Adding to Windows Startup (auto-run on boot)...
set STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set SHORTCUT_VBS=%TEMP%\create_startup_shortcut.vbs

echo Set ws = CreateObject("WScript.Shell") > "%SHORTCUT_VBS%"
echo Set sc = ws.CreateShortcut("%STARTUP_DIR%\RFID_CutStation.lnk") >> "%SHORTCUT_VBS%"
echo sc.TargetPath = "%INSTALL_DIR%\RFID_CutStation.exe" >> "%SHORTCUT_VBS%"
echo sc.WorkingDirectory = "%INSTALL_DIR%" >> "%SHORTCUT_VBS%"
echo sc.Description = "RFID Cut Station - Auto Start" >> "%SHORTCUT_VBS%"
echo sc.Save >> "%SHORTCUT_VBS%"
cscript //nologo "%SHORTCUT_VBS%"
del "%SHORTCUT_VBS%"
echo   ✅ Added to Startup folder

REM ─── Create Desktop shortcut ───────────────────────────
echo   [5/5] Creating Desktop shortcut...
set DESKTOP_VBS=%TEMP%\create_desktop_shortcut.vbs

echo Set ws = CreateObject("WScript.Shell") > "%DESKTOP_VBS%"
echo Set sc = ws.CreateShortcut(ws.SpecialFolders("Desktop") ^& "\RFID Cut Station.lnk") >> "%DESKTOP_VBS%"
echo sc.TargetPath = "%INSTALL_DIR%\RFID_CutStation.exe" >> "%DESKTOP_VBS%"
echo sc.WorkingDirectory = "%INSTALL_DIR%" >> "%DESKTOP_VBS%"
echo sc.Description = "RFID Cut Station" >> "%DESKTOP_VBS%"
echo sc.Save >> "%DESKTOP_VBS%"
cscript //nologo "%DESKTOP_VBS%"
del "%DESKTOP_VBS%"
echo   ✅ Desktop shortcut created

REM ─── Cleanup build files ───────────────────────────────
cd /d "%~dp0app"
rmdir /S /Q build >nul 2>nul
rmdir /S /Q dist >nul 2>nul
rmdir /S /Q __pycache__ >nul 2>nul
del /Q *.spec >nul 2>nul
cd /d "%~dp0"

REM ─── Done ──────────────────────────────────────────────
echo.
echo   ╔═══════════════════════════════════════════════╗
echo   ║   ✅ INSTALLATION COMPLETE!                   ║
echo   ║                                               ║
echo   ║   Installed to: C:\RFID_CutStation            ║
echo   ║                                               ║
echo   ║   ✅ Desktop shortcut created                  ║
echo   ║   ✅ Auto-starts on Windows boot               ║
echo   ║                                               ║
echo   ║   To configure:                               ║
echo   ║     1. Double-click desktop shortcut          ║
echo   ║     2. Click ⚙️ Settings in browser            ║
echo   ║     3. Enter your SQL Server details          ║
echo   ║     4. Save + Restart                         ║
echo   ║                                               ║
echo   ║   To REMOVE auto-start:                       ║
echo   ║     Run UNINSTALL.bat                         ║
echo   ╚═══════════════════════════════════════════════╝
echo.

REM Ask to start now
set /p STARTNOW="   Start now? (Y/N): "
if /i "%STARTNOW%"=="Y" (
    start "" "%INSTALL_DIR%\RFID_CutStation.exe"
)

pause
