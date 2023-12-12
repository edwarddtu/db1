# Define the WSL user's home directory and the 'dock' subdirectory
$wslUserName= wsl sh -c 'echo $USER'
$dockDirectory = "/home/$wslUserName/dock"

Start-Process "http://localhost:8080"

Write-Host "Starting the db1 container "
wsl  bash -c "chmod u+x $dockDirectory/startDock.sh"
wsl  bash -c "chmod u+x $dockDirectory/startDockerDaemon.sh"
& ".\connect_serial.ps1"
wsl -u root bash -c "bash $dockDirectory/startDockerDaemon.sh"
wsl  bash -c "bash $dockDirectory/startDock.sh"
