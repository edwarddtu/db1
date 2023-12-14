@echo off
:: Get the directory the batch file is located in
SET "scriptdir=%~dp0"

:: Change to that directory
cd /d "%scriptdir%"

call :RunPowerShellScript "./windows_db1tools.ps1"

if %errorlevel%  equ 0 pause

goto :eof

:RunPowerShellScript
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "%~1"
if %errorlevel% neq 0 goto :ErrorHandler
goto :eof

:ErrorHandler
echo There was an error. We stop here.
pause
exit /b %errorlevel%

:eof

