@echo off
REM ═══════════════════════════════════════════════════════
REM  RFID Cut Station — Full Installer
REM ═══════════════════════════════════════════════════════
setlocal enabledelayedexpansion

title RFID Cut Station - Installer
echo.
echo   ========================================
echo     RFID Cut Station - INSTALLER
echo   ========================================
echo.

REM ─── Check Python ──────────────────────────────────────
python --version >nul 2>&1
if errorlevel 1 (
    echo   ERROR: Python not found!
    echo   Download from https://python.org
    echo   Check "Add Python to PATH" during install!
    echo.
    pause
    exit /b 1
)
echo   [OK] Python found

REM ─── Install dependencies ──────────────────────────────
echo   [1/5] Installing dependencies...
pip install pyserial pyinstaller --quiet
pip install pyodbc --quiet 2>nul
echo   [OK] Dependencies installed

REM ─── Build EXE ─────────────────────────────────────────
echo   [2/5] Building EXE (takes 1-2 minutes)...

REM Save the project root
set "PROJECT_ROOT=%~dp0"

cd /d "%PROJECT_ROOT%app"

pyinstaller --noconfirm --onefile --console ^
    --name "RFID_CutStation" ^
    --add-data "dashboard.html;." ^
    --hidden-import serial ^
    --hidden-import serial.tools ^
    --hidden-import serial.tools.list_ports ^
    --hidden-import serial.tools.list_ports_common ^
    --hidden-import serial.tools.list_ports_windows ^
    main.py

if not exist "%PROJECT_ROOT%app\dist\RFID_CutStation.exe" (
    echo   ERROR: Build failed! Check errors above.
    pause
    exit /b 1
)
echo   [OK] EXE built successfully

REM ─── Copy to install location ──────────────────────────
echo   [3/5] Installing to C:\RFID_CutStation ...

if not exist "C:\RFID_CutStation" mkdir "C:\RFID_CutStation"

copy /Y "%PROJECT_ROOT%app\dist\RFID_CutStation.exe" "C:\RFID_CutStation\RFID_CutStation.exe" >nul
copy /Y "%PROJECT_ROOT%app\config.ini" "C:\RFID_CutStation\config.ini" >nul

REM Verify the copy worked
if not exist "C:\RFID_CutStation\RFID_CutStation.exe" (
    echo   ERROR: Copy failed! Try running as Administrator.
    pause
    exit /b 1
)
echo   [OK] Files installed

REM ─── Desktop shortcut ─────────────────────────────────
echo   [4/5] Creating Desktop shortcut...

set "VBS_FILE=%TEMP%\rfid_desktop.vbs"
> "%VBS_FILE%" echo Set ws = CreateObject("WScript.Shell")
>> "%VBS_FILE%" echo Set sc = ws.CreateShortcut(ws.SpecialFolders("Desktop") ^& "\RFID Cut Station.lnk")
>> "%VBS_FILE%" echo sc.TargetPath = "C:\RFID_CutStation\RFID_CutStation.exe"
>> "%VBS_FILE%" echo sc.WorkingDirectory = "C:\RFID_CutStation"
>> "%VBS_FILE%" echo sc.Description = "RFID Cut Station"
>> "%VBS_FILE%" echo sc.Save
cscript //nologo "%VBS_FILE%"
del "%VBS_FILE%" 2>nul
echo   [OK] Desktop shortcut created

REM ─── Auto-start on boot ───────────────────────────────
echo   [5/5] Adding to Windows Startup...

set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "VBS_FILE=%TEMP%\rfid_startup.vbs"
> "%VBS_FILE%" echo Set ws = CreateObject("WScript.Shell")
>> "%VBS_FILE%" echo Set sc = ws.CreateShortcut("%STARTUP_FOLDER%\RFID_CutStation.lnk")
>> "%VBS_FILE%" echo sc.TargetPath = "C:\RFID_CutStation\RFID_CutStation.exe"
>> "%VBS_FILE%" echo sc.WorkingDirectory = "C:\RFID_CutStation"
>> "%VBS_FILE%" echo sc.Description = "RFID Cut Station Auto Start"
>> "%VBS_FILE%" echo sc.Save
cscript //nologo "%VBS_FILE%"
del "%VBS_FILE%" 2>nul
echo   [OK] Auto-start enabled

REM ─── Cleanup build artifacts ───────────────────────────
cd /d "%PROJECT_ROOT%app"
rmdir /S /Q build 2>nul
rmdir /S /Q __pycache__ 2>nul
del /Q *.spec 2>nul
REM Keep dist folder as backup
cd /d "%PROJECT_ROOT%"

REM ─── Done ──────────────────────────────────────────────
echo.
echo   ========================================
echo     INSTALLATION COMPLETE!
echo   ========================================
echo.
echo   Location:    C:\RFID_CutStation
echo   Desktop:     Shortcut created
echo   Auto-start:  Enabled (runs on boot)
echo.
echo   NEXT STEPS:
echo     1. Double-click "RFID Cut Station" on Desktop
echo     2. Browser opens automatically
echo     3. Click Settings gear icon
echo     4. Enter SQL Server details
echo     5. Click Auto-Detect ESP32
echo.
echo   To remove: run UNINSTALL.bat
echo.

set /p "STARTNOW=  Launch now? (Y/N): "
if /i "%STARTNOW%"=="Y" (
    start "" "C:\RFID_CutStation\RFID_CutStation.exe"
)

endlocal
pause
