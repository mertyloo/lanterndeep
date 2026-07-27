@echo off
rem ============================================================
rem  LANTERNDEEP -> builds a standalone .exe application.
rem  No Node.js required, only an internet connection.
rem ============================================================
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0make-exe.ps1"
if errorlevel 1 (
  echo.
  echo   Something went wrong. Check your internet connection and try again.
  pause
)
exit /b 0
