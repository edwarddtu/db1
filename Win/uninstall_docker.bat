@echo off
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!! This will uninstall the docker containers, images and docker itself.         !!!!"
echo "!!!! Ubuntu will still contitue to run and your DB1 files are still available    !!!!"
echo "!!!! If later on you want to reinstall the DB1Tools then you should run only     !!!!"
echo "!!!! the installation step 2 by right-clicking on windows_installation_step2.bat !!!!"
echo "!!!! and running it as an administrator.                                         !!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
:: Get the directory the batch file is located in
SET "scriptdir=%~dp0"

:: Change to that directory
cd /d "%scriptdir%"

wsl -u root ./uninstall_docker.sh

 echo "Uninstalling the USB tools"
 winget uninstall --exact dorssel.usbipd-win

pause