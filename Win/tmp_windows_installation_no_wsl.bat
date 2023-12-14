@echo off

wsl -l -v

:: Get the directory the batch file is located in
SET "scriptdir=%~dp0"

:: Change to that directory
cd /d "%scriptdir%"


::call :RunPowerShellScript "./check_wsl.ps1"
call :RunPowerShellScript "./install.ps1"
::call :RunPowerShellScript "C:\path\to\script3.ps1"
:: Add more scripts as needed

pause

goto :eof

:RunPowerShellScript
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%~1"
if %errorlevel% neq 0 goto :ErrorHandler
goto :eof

:ErrorHandler
echo There was an error. We stop here.
pause
exit /b %errorlevel%

:eof
