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
Update-Shortcut -currentPath "$currentPath" -shortcutName "DB1 Tools.lnk" -targetFileName "windows_db1tools.bat"
 
# Copy the links to desktop 
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
cp *.lnk $desktopPath