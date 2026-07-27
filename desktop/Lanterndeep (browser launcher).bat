@echo off
rem ============================================================
rem  LANTERNDEEP - launcher
rem  Opens the game in its own window (no browser chrome).
rem  Keep this file next to lanterndeep.html
rem ============================================================
setlocal EnableExtensions

set "GAME=%~dp0..\index.html"
if not exist "%GAME%" (
  echo.
  echo   index.html was not found.
  echo   Keep this launcher inside the repository folder.
  echo.
  pause
  exit /b 1
)

set "URLPATH=%GAME:\=/%"
set "PROFILE=%LOCALAPPDATA%\Lanterndeep\profile"

set "BROWSER="
for %%P in (
  "%ProgramFiles%\Google\Chrome\Application\chrome.exe"
  "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
  "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
  "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
  "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
  "%ProgramFiles%\BraveSoftware\Brave-Browser\Application\brave.exe"
) do if not defined BROWSER if exist %%P set "BROWSER=%%~P"

if defined BROWSER goto :appmode
start "" "%GAME%"
exit /b 0

:appmode
start "" "%BROWSER%" --app="file:///%URLPATH%" --user-data-dir="%PROFILE%" --start-maximized --no-first-run --disable-features=Translate,TranslateUI
exit /b 0
