# Define the WSL user's home directory and the 'dock' subdirectory
$wslUserName= wsl sh -c 'echo $USER'
$dockDirectory = "/home/$wslUserName/dock"

Start-Process "http://localhost:8080"

function Run-BashScriptInWSL {
    param(
        [string]$bashScriptPath,
        [string]$userName = $wslUserName
    )
    # Make sure that the script is executable
    wsl -u $userName bash -c "chmod u+x $bashScriptPath"

    # Run the Bash script in WSL
    wsl -u $userName bash -c "bash $bashScriptPath"

    # Check the exit code
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    } 
}

Write-Host "Starting the db1 container "
Run-BashScriptInWSL -bashScriptPath "$dockDirectory/start_docker_daemon.sh" -userName "root"
Run-BashScriptInWSL -bashScriptPath "$dockDirectory/start_dock.sh"
