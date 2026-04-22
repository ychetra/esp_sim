@echo off
REM RFID Cut Station - Uninstaller

title RFID Cut Station - Uninstall
echo.
echo   Removing RFID Cut Station...
echo.

set "STARTDIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
del /Q "%STARTDIR%\RFID_CutStation.lnk" 2>nul
echo   [OK] Removed from Windows Startup

del /Q "%USERPROFILE%\Desktop\RFID Cut Station.lnk" 2>nul
echo   [OK] Removed Desktop shortcut

set /p REMOVEFILES="  Delete C:\RFID_CutStation folder? (Y/N): "
if /i "%REMOVEFILES%"=="Y" (
    rmdir /S /Q "C:\RFID_CutStation" 2>nul
    echo   [OK] Folder deleted
)

echo.
echo   Uninstall complete!
echo.
pause
