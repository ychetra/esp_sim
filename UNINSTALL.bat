@echo off
REM ═══════════════════════════════════════════════════════
REM  RFID Cut Station — Uninstaller
REM ═══════════════════════════════════════════════════════

title RFID Cut Station — Uninstall
echo.
echo   Removing RFID Cut Station...
echo.

REM Remove Startup shortcut
set STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
del /Q "%STARTUP_DIR%\RFID_CutStation.lnk" >nul 2>nul
echo   ✅ Removed from Windows Startup

REM Remove Desktop shortcut
del /Q "%USERPROFILE%\Desktop\RFID Cut Station.lnk" >nul 2>nul
echo   ✅ Removed Desktop shortcut

REM Remove install folder
set /p REMOVEFILES="   Delete C:\RFID_CutStation folder? (Y/N): "
if /i "%REMOVEFILES%"=="Y" (
    rmdir /S /Q "C:\RFID_CutStation" >nul 2>nul
    echo   ✅ Deleted C:\RFID_CutStation
)

echo.
echo   ✅ Uninstall complete!
echo.
pause
