@echo off

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!In this step we check if Windows Subsistem for Linux (WSL) and Ubuntu are intalled.!!!!" 
echo "!!!And we attempt to install them automatically if they are missing                    !!!!"
echo "!!!These are necessary before we continute with Step2 of the installation              !!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

wsl -l -v

:: Get the directory the batch file is located in
SET "scriptdir=%~dp0"

:: Change to that directory
cd /d "%scriptdir%"


call :RunPowerShellScript "./check_wsl_ps.ps1"
:: Add more scripts as needed

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
