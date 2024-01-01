# Define the WSL user's home directory and the 'dock' subdirectory
$wslUserName= wsl sh -c 'echo $USER'
$dockDirectory = "/home/$wslUserName/dock"

#making sure that we use WSL2 for ubuntu
wsl --set-version Ubuntu 2


# Create the 'dock' subdirectory in the WSL user's home directory
wsl mkdir -p $dockDirectory

function WaitForFileCreation {
    param (
        [string]$filePath
    )

    # Keep checking until the file is created
    while ($true) {
        if (Test-Path $filePath) {
            Write-Host "File found: $filePath"
            return
        } else {
            Write-Host "Waiting for file to be created: $filePath"
            Start-Sleep -Seconds 1
        }
    }
}

# Usage
# WaitForFileCreation -filePath "C:\path\to\your\file.txt"

wsl -u root apt-get -y update
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

Write-Host "Installing docker"
Run-BashScriptInWSL -bashScriptPath "$dockDirectory/check_and_install_docker.sh" -userName "root"

Write-Host "Giving the user access to use Docker"
wsl -u root usermod -aG docker $wslUserName

Write-Host "Making the image db1_base"
Run-BashScriptInWSL -bashScriptPath "$dockDirectory/make_db1_base.sh" -userName "root"

Write-Host "Making the image db1_image"
Run-BashScriptInWSL -bashScriptPath "$dockDirectory/init_dock.sh"

#Making sure that we have the tools that allow us to use the serial port in WSL
echo "Installing the usb tools"
winget install --exact dorssel.usbipd-win
wsl -u root apt install -y linux-tools-virtual hwdata
#wsl -u root update-alternatives --install /usr/local/bin/usbip usbip $(command -v ls /usr/lib/linux-tools/*/usbip | tail -n1) 20
$usbip_ver = wsl -u root "ls /usr/lib/linux-tools/*/usbip | tail -n1"
Write-Host "$usbip_ver"
wsl -u root update-alternatives --install /usr/local/bin/usbip usbip $usbip_ver 20
echo "Done installing the usb tools"

function Update-Shortcut {
    param(
        [string]$currentPath,
        [string]$shortcutName,
        [string]$targetFileName
    )

    # Constructing full paths for the shortcut and target file
    $lnkPath = Join-Path -Path $currentPath -ChildPath $shortcutName
    $newTargetPath = Join-Path -Path $currentPath -ChildPath $targetFileName

    try {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($lnkPath)
        $shortcut.TargetPath = $newTargetPath
        $shortcut.Save()
        Write-Host "Shortcut updated successfully. Path: $lnkPath"
    } catch {
        Write-Error "Error updating shortcut: $_"
    }
}

$currentPath = $PSScriptRoot
$winDockDirectory = "\\wsl.localhost\Ubuntu\home\$wslUserName\dock"
Write-Host "$winDockDirectory"

# Update the links to point to the current path of the installation directory
Update-Shortcut -currentPath "$currentPath" -shortcutName "DB1 Connect Serial.lnk" -targetFileName "connect_serial.bat"
Update-Shortcut -currentPath "$currentPath" -shortcutName "DB1 Disconnect Serial.lnk" -targetFileName "disconnect_serial.bat"
Update-Shortcut -currentPath "$currentPath" -shortcutName "DB1 Tools.lnk" -targetFileName "windows_db1tools.bat"

$lnkPath="DB1 dock files.lnk"
$newTargetPath = "$winDockDirectory"
try {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($lnkPath)
    $shortcut.TargetPath = $newTargetPath
    $shortcut.Save()
    Write-Host "Shortcut updated successfully. Path: $lnkPath"
} catch {
    Write-Error "Error updating shortcut: $_"
}
 
# Copy the links to desktop 
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
cp *.lnk $desktopPath


Write-Host "Starting the container db1container"
Run-BashScriptInWSL -bashScriptPath "$dockDirectory/start_dock.sh"

