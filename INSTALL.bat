@echo off
REM RFID Cut Station - Full Installer
REM No Unicode characters - Windows CMD safe

title RFID Cut Station - Installer
echo.
echo   ========================================
echo     RFID Cut Station - INSTALLER
echo   ========================================
echo.

REM --- Check Python ---
python --version >nul 2>&1
if errorlevel 1 (
    echo   [FAIL] Python not found!
    echo   Download from https://python.org
    echo   Make sure to check "Add Python to PATH"
    pause
    exit /b 1
)
echo   [OK] Python found

REM --- Install dependencies ---
echo.
echo   [1/5] Installing dependencies...
python -m pip install pyserial pyinstaller --quiet
python -m pip install pyodbc --quiet 2>nul
echo   [OK] Dependencies installed

REM --- Build EXE ---
echo.
echo   [2/5] Building EXE (takes 1-2 minutes)...
echo   Please wait...
echo.

cd /d "%~dp0app"

python -m PyInstaller --noconfirm --onefile --console --name "RFID_CutStation" --add-data "dashboard.html;." --hidden-import serial --hidden-import serial.tools --hidden-import serial.tools.list_ports --hidden-import serial.tools.list_ports_common --hidden-import serial.tools.list_ports_windows main.py

echo.
echo   Checking build result...
if not exist "dist\RFID_CutStation.exe" (
    echo.
    echo   [FAIL] Build failed! EXE not created.
    echo   Check the error messages above.
    echo.
    pause
    exit /b 1
)
echo   [OK] EXE built: %CD%\dist\RFID_CutStation.exe

REM --- Copy to install folder ---
echo.
echo   [3/5] Copying to C:\RFID_CutStation ...

if not exist "C:\RFID_CutStation" mkdir "C:\RFID_CutStation"

copy /Y "dist\RFID_CutStation.exe" "C:\RFID_CutStation\RFID_CutStation.exe"
copy /Y "config.ini" "C:\RFID_CutStation\config.ini"

if not exist "C:\RFID_CutStation\RFID_CutStation.exe" (
    echo.
    echo   [FAIL] Copy failed!
    echo   Try: Right-click INSTALL.bat and "Run as Administrator"
    echo.
    pause
    exit /b 1
)
echo   [OK] Copied to C:\RFID_CutStation

REM --- Desktop shortcut ---
echo.
echo   [4/5] Creating Desktop shortcut...

set "VBS=%TEMP%\rfid_desk.vbs"
echo Set ws = CreateObject("WScript.Shell") > "%VBS%"
echo Set sc = ws.CreateShortcut(ws.SpecialFolders("Desktop") ^& "\RFID Cut Station.lnk") >> "%VBS%"
echo sc.TargetPath = "C:\RFID_CutStation\RFID_CutStation.exe" >> "%VBS%"
echo sc.WorkingDirectory = "C:\RFID_CutStation" >> "%VBS%"
echo sc.Description = "RFID Cut Station" >> "%VBS%"
echo sc.Save >> "%VBS%"
cscript //nologo "%VBS%"
del "%VBS%" 2>nul
echo   [OK] Desktop shortcut created

REM --- Auto-start on boot ---
echo.
echo   [5/5] Adding to Windows Startup...

set "STARTDIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "VBS=%TEMP%\rfid_boot.vbs"
echo Set ws = CreateObject("WScript.Shell") > "%VBS%"
echo Set sc = ws.CreateShortcut("%STARTDIR%\RFID_CutStation.lnk") >> "%VBS%"
echo sc.TargetPath = "C:\RFID_CutStation\RFID_CutStation.exe" >> "%VBS%"
echo sc.WorkingDirectory = "C:\RFID_CutStation" >> "%VBS%"
echo sc.Description = "RFID Cut Station Auto Start" >> "%VBS%"
echo sc.Save >> "%VBS%"
cscript //nologo "%VBS%"
del "%VBS%" 2>nul
echo   [OK] Auto-start on boot enabled

REM --- Cleanup ---
cd /d "%~dp0app"
rmdir /S /Q build 2>nul
rmdir /S /Q __pycache__ 2>nul
del /Q *.spec 2>nul

REM --- Done ---
cd /d "%~dp0"
echo.
echo   ========================================
echo     INSTALLATION COMPLETE!
echo   ========================================
echo.
echo   Location:     C:\RFID_CutStation
echo   Desktop:      Shortcut created
echo   Auto-start:   Runs on Windows boot
echo.
echo   NEXT STEPS:
echo     1. Double-click "RFID Cut Station" on Desktop
echo     2. Browser opens automatically
echo     3. Click Settings gear icon
echo     4. Enter SQL Server details
echo     5. Click Auto-Detect ESP32
echo.

set /p STARTNOW="  Launch now? (Y/N): "
if /i "%STARTNOW%"=="Y" (
    start "" "C:\RFID_CutStation\RFID_CutStation.exe"
)
pause
