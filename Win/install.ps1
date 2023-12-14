# Define the WSL user's home directory and the 'dock' subdirectory
$wslUserName= wsl sh -c 'echo $USER'
$dockDirectory = "/home/$wslUserName/dock"

# Create the 'dock' subdirectory in the WSL user's home directory
wsl mkdir -p $dockDirectory

$winDesktop= "$home\Desktop"
$winDockDirectory = "\\wsl.localhost\Ubuntu\home\$wslUserName\dock"

$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut( "$home\Desktop\DOCK.lnk")
$Shortcut.TargetPath = "$winDockDirectory"
$Shortcut.WindowStyle = 1
$Shortcut.Description = "Shortcut to the docker folder on Ubuntu(WSL)"
$Shortcut.WorkingDirectory = "$winDockDirectory"
$Shortcut.Save()

 wsl -u root apt-get install -y dos2unix

# Copy necessary files from the current directory in PowerShell to the 'dock' directory in WSL
wsl dos2unix *.sh
wsl dos2unix Docker*
wsl dos2unix ../Common/*.sh
wsl chmod +x ../Common/*.sh
wsl cp -rf *.sh $dockDirectory
wsl cp -rf Dockerfile* $dockDirectory

# Output the path of the 'dock' directory for future use
Write-Host "Files copied to WSL 'dock' directory at: $dockDirectory"

# Call the Bash script (if needed)
Write-Host "Installing docker"
wsl -u root bash -c "chmod u+x $dockDirectory/check_and_install_docker.sh"
wsl -u root bash -c "bash $dockDirectory/check_and_install_docker.sh $wslUserName"

echo "Giving the user access to use Docker"
wsl -u root usermod -aG docker $wslUserName
#wsl -u root newgrp docker &

Write-Host "Making the image db1_base"
wsl -u root bash -c "chmod u+x $dockDirectory/make_db1_base.sh"
wsl -u root bash -c "bash $dockDirectory/make_db1_base.sh"

Write-Host "Making the image db1_image"
wsl  bash -c "chmod u+x $dockDirectory/initDock.sh"
wsl  bash -c "bash $dockDirectory/initDock.sh"

#Making sure that we have the tools that allow us to use the serial port in WSL
echo "Installing the usb tools"
winget install --exact dorssel.usbipd-win
wsl -u root apt install -y linux-tools-virtual hwdata
wsl -u root update-alternatives --install /usr/local/bin/usbip usbip $(command -v ls /usr/lib/linux-tools/*/usbip | tail -n1) 20

#wsl -u root apt install linux-tools-5.4.0-77-generic hwdata
#wsl -u root update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/5.4.0-77-generic/usbip 20
echo "Done installing the usb tools"

Write-Host "Starting the container db1container"
wsl  bash -c "chmod u+x $dockDirectory/startDock.sh"
wsl  bash -c "bash $dockDirectory/startDock.sh"            

# echo "!!! The one time installation is done.From !!!!"
# echo "!!! now on you can run the tools by double !!!!"
# echo "!!! clicking on windows_db1tools.bat       !!!!"