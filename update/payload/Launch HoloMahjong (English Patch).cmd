@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Update-HoloMahjongPatch.ps1" -GameDirectory "%~dp0" -Launch
if errorlevel 1 pause
