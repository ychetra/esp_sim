@echo off
REM ═══════════════════════════════════════════════════════
REM  RFID Cut Station — Quick Deploy
REM  
REM  Put this file NEXT TO the EXE + config.ini
REM  on a USB drive. Plug into new PC, double-click.
REM  
REM  NO Python needed. NO source code needed.
REM  Just these 3 files:
REM    DEPLOY.bat
REM    RFID_CutStation.exe
REM    config.ini
REM ═══════════════════════════════════════════════════════

title RFID Cut Station — Deploy to this PC
echo.
echo   ╔═══════════════════════════════════════════════╗
echo   ║   🏭 RFID Cut Station — Quick Deploy          ║
echo   ╚═══════════════════════════════════════════════╝
echo.

set INSTALL_DIR=C:\RFID_CutStation
set SOURCE_DIR=%~dp0

REM Check EXE exists next to this script
if not exist "%SOURCE_DIR%RFID_CutStation.exe" (
    echo   ❌ ERROR: RFID_CutStation.exe not found!
    echo   Put this script next to the EXE file.
    pause
    exit /b
)

REM ─── Copy files ────────────────────────────────────────
echo   [1/3] Installing to %INSTALL_DIR% ...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
copy /Y "%SOURCE_DIR%RFID_CutStation.exe" "%INSTALL_DIR%\" >nul
copy /Y "%SOURCE_DIR%config.ini" "%INSTALL_DIR%\" >nul
echo   ✅ Files copied

REM ─── Desktop shortcut ─────────────────────────────────
echo   [2/3] Creating Desktop shortcut...
set VBS=%TEMP%\_rfid_shortcut.vbs
echo Set ws = CreateObject("WScript.Shell") > "%VBS%"
echo Set sc = ws.CreateShortcut(ws.SpecialFolders("Desktop") ^& "\RFID Cut Station.lnk") >> "%VBS%"
echo sc.TargetPath = "%INSTALL_DIR%\RFID_CutStation.exe" >> "%VBS%"
echo sc.WorkingDirectory = "%INSTALL_DIR%" >> "%VBS%"
echo sc.Description = "RFID Cut Station" >> "%VBS%"
echo sc.Save >> "%VBS%"
cscript //nologo "%VBS%"
del "%VBS%"
echo   ✅ Desktop shortcut created

REM ─── Auto-start on boot ───────────────────────────────
echo   [3/3] Adding to Windows Startup...
set STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set VBS=%TEMP%\_rfid_startup.vbs
echo Set ws = CreateObject("WScript.Shell") > "%VBS%"
echo Set sc = ws.CreateShortcut("%STARTUP%\RFID_CutStation.lnk") >> "%VBS%"
echo sc.TargetPath = "%INSTALL_DIR%\RFID_CutStation.exe" >> "%VBS%"
echo sc.WorkingDirectory = "%INSTALL_DIR%" >> "%VBS%"
echo sc.Description = "RFID Cut Station - Auto Start" >> "%VBS%"
echo sc.Save >> "%VBS%"
cscript //nologo "%VBS%"
del "%VBS%"
echo   ✅ Will auto-start on Windows boot

REM ─── Done ──────────────────────────────────────────────
echo.
echo   ╔═══════════════════════════════════════════════╗
echo   ║   ✅ DONE! Installed on this PC.              ║
echo   ║                                               ║
echo   ║   📁 Location: C:\RFID_CutStation             ║
echo   ║   🖥️ Desktop shortcut: ready                   ║
echo   ║   🔄 Auto-start on boot: enabled               ║
echo   ║                                               ║
echo   ║   First run:                                  ║
echo   ║     1. Double-click desktop shortcut          ║
echo   ║     2. Click ⚙️ Settings in browser            ║
echo   ║     3. Set your SQL Server + table names      ║
echo   ║     4. Click Auto-Detect ESP32                ║
echo   ║     5. Done! ✅                                ║
echo   ╚═══════════════════════════════════════════════╝
echo.
set /p STARTNOW="   Launch now? (Y/N): "
if /i "%STARTNOW%"=="Y" (
    start "" "%INSTALL_DIR%\RFID_CutStation.exe"
)
pause
