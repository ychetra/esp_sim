@echo off
REM ═══════════════════════════════════════════════════════
REM  RFID Cut Station — Quick Deploy (no Python needed)
REM  
REM  USB drive contents:
REM    DEPLOY.bat
REM    RFID_CutStation.exe
REM    config.ini
REM ═══════════════════════════════════════════════════════
setlocal

title RFID Cut Station - Deploy
echo.
echo   ========================================
echo     RFID Cut Station - Quick Deploy
echo   ========================================
echo.

set "SOURCE=%~dp0"

REM Check EXE exists
if not exist "%SOURCE%RFID_CutStation.exe" (
    echo   ERROR: RFID_CutStation.exe not found!
    echo   Put this script next to the EXE file.
    pause
    exit /b 1
)

REM ─── Copy files ────────────────────────────────────────
echo   [1/3] Copying files to C:\RFID_CutStation ...
if not exist "C:\RFID_CutStation" mkdir "C:\RFID_CutStation"
copy /Y "%SOURCE%RFID_CutStation.exe" "C:\RFID_CutStation\RFID_CutStation.exe" >nul
copy /Y "%SOURCE%config.ini" "C:\RFID_CutStation\config.ini" >nul

if not exist "C:\RFID_CutStation\RFID_CutStation.exe" (
    echo   ERROR: Copy failed! Try running as Administrator.
    pause
    exit /b 1
)
echo   [OK] Files installed

REM ─── Desktop shortcut ─────────────────────────────────
echo   [2/3] Creating Desktop shortcut...
set "VBS=%TEMP%\rfid_desk.vbs"
> "%VBS%" echo Set ws = CreateObject("WScript.Shell")
>> "%VBS%" echo Set sc = ws.CreateShortcut(ws.SpecialFolders("Desktop") ^& "\RFID Cut Station.lnk")
>> "%VBS%" echo sc.TargetPath = "C:\RFID_CutStation\RFID_CutStation.exe"
>> "%VBS%" echo sc.WorkingDirectory = "C:\RFID_CutStation"
>> "%VBS%" echo sc.Description = "RFID Cut Station"
>> "%VBS%" echo sc.Save
cscript //nologo "%VBS%"
del "%VBS%" 2>nul
echo   [OK] Desktop shortcut created

REM ─── Auto-start on boot ───────────────────────────────
echo   [3/3] Adding to Windows Startup...
set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "VBS=%TEMP%\rfid_boot.vbs"
> "%VBS%" echo Set ws = CreateObject("WScript.Shell")
>> "%VBS%" echo Set sc = ws.CreateShortcut("%STARTUP%\RFID_CutStation.lnk")
>> "%VBS%" echo sc.TargetPath = "C:\RFID_CutStation\RFID_CutStation.exe"
>> "%VBS%" echo sc.WorkingDirectory = "C:\RFID_CutStation"
>> "%VBS%" echo sc.Description = "RFID Cut Station Auto Start"
>> "%VBS%" echo sc.Save
cscript //nologo "%VBS%"
del "%VBS%" 2>nul
echo   [OK] Auto-start enabled

REM ─── Done ──────────────────────────────────────────────
echo.
echo   ========================================
echo     DONE! Installed on this PC.
echo   ========================================
echo.
echo   Desktop shortcut: ready
echo   Auto-start on boot: enabled
echo.
echo   First time setup:
echo     1. Double-click desktop icon
echo     2. Click Settings in browser
echo     3. Enter your SQL Server details
echo     4. Click Auto-Detect ESP32
echo.

set /p "STARTNOW=  Launch now? (Y/N): "
if /i "%STARTNOW%"=="Y" (
    start "" "C:\RFID_CutStation\RFID_CutStation.exe"
)

endlocal
pause
