@echo off
REM RFID Cut Station - Quick Deploy (no Python needed)
REM USB: DEPLOY.bat + RFID_CutStation.exe + config.ini

title RFID Cut Station - Deploy
echo.
echo   ========================================
echo     RFID Cut Station - Quick Deploy
echo   ========================================
echo.

if not exist "%~dp0RFID_CutStation.exe" (
    echo   [FAIL] RFID_CutStation.exe not found!
    echo   Put this script next to the EXE.
    pause
    exit /b 1
)

echo   [1/3] Copying to C:\RFID_CutStation ...
if not exist "C:\RFID_CutStation" mkdir "C:\RFID_CutStation"
copy /Y "%~dp0RFID_CutStation.exe" "C:\RFID_CutStation\RFID_CutStation.exe"
copy /Y "%~dp0config.ini" "C:\RFID_CutStation\config.ini"

if not exist "C:\RFID_CutStation\RFID_CutStation.exe" (
    echo   [FAIL] Copy failed! Run as Administrator.
    pause
    exit /b 1
)
echo   [OK] Files installed

echo   [2/3] Creating Desktop shortcut...
set "VBS=%TEMP%\rfid_d.vbs"
echo Set ws = CreateObject("WScript.Shell") > "%VBS%"
echo Set sc = ws.CreateShortcut(ws.SpecialFolders("Desktop") ^& "\RFID Cut Station.lnk") >> "%VBS%"
echo sc.TargetPath = "C:\RFID_CutStation\RFID_CutStation.exe" >> "%VBS%"
echo sc.WorkingDirectory = "C:\RFID_CutStation" >> "%VBS%"
echo sc.Save >> "%VBS%"
cscript //nologo "%VBS%"
del "%VBS%" 2>nul
echo   [OK] Desktop shortcut created

echo   [3/3] Adding to Windows Startup...
set "STARTDIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "VBS=%TEMP%\rfid_s.vbs"
echo Set ws = CreateObject("WScript.Shell") > "%VBS%"
echo Set sc = ws.CreateShortcut("%STARTDIR%\RFID_CutStation.lnk") >> "%VBS%"
echo sc.TargetPath = "C:\RFID_CutStation\RFID_CutStation.exe" >> "%VBS%"
echo sc.WorkingDirectory = "C:\RFID_CutStation" >> "%VBS%"
echo sc.Save >> "%VBS%"
cscript //nologo "%VBS%"
del "%VBS%" 2>nul
echo   [OK] Auto-start enabled

echo.
echo   ========================================
echo     DONE! Installed on this PC.
echo   ========================================
echo.
echo   Desktop shortcut: ready
echo   Auto-start: runs on boot
echo.

set /p STARTNOW="  Launch now? (Y/N): "
if /i "%STARTNOW%"=="Y" (
    start "" "C:\RFID_CutStation\RFID_CutStation.exe"
)
pause
