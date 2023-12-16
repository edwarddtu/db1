Write-Host "Uninstalling the USB tools"
winget uninstall --exact dorssel.usbipd-win
wsl -u root apt-get update
wsl -u root apt-get remove -y linux-tools-virtual hwdata

Write-Host "Installing the usb tools"
winget install --exact dorssel.usbipd-win
wsl -u root apt-get install -y linux-tools-virtual hwdata
$usbip_ver = wsl -u root ls /usr/lib/linux-tools/*/usbip | tail -n1
Write-Host "$usbip_ver"
wsl -u root update-alternatives --install /usr/local/bin/usbip usbip $usbip_ver 20

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

# Update the links to point to the current path of the installation directory
Update-Shortcut -currentPath "$currentPath" -shortcutName "DB1 Connect Serial.lnk" -targetFileName "connect_serial.bat"
Update-Shortcut -currentPath "$currentPath" -shortcutName "DB1 Disconnect Serial.lnk" -targetFileName "disconnect_serial.bat"
 
# Copy the links to desktop 
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
cp "DB1 Connect Serial.lnk" $desktopPath
cp "DB1 Disconnect Serial.lnk" $desktopPath