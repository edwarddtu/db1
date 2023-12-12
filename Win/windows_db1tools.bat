@echo off
:: Get the directory the batch file is located in
SET "scriptdir=%~dp0"

:: Change to that directory
cd /d "%scriptdir%"

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& './windows_db1tools.ps1'"
