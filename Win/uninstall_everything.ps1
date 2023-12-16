Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
Write-Host "!!!! This script uninstalls all the DB1tools including the Ubuntu instalation !!!!"
Write-Host "!!!! This means that all your Db1 files from the the container will be        !!!!" 
Write-Host "!!!! erased as well. Make sure that you've backed up any files that you       !!!!"
Write-Host "!!!! Still need fefore you continue...                                        !!!!"
Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
Write-Host ""


# Ask the user if they wish to continue
$response = Read-Host "Do you wish to continue? (yes/no)"

# Check the response
if ($response -eq "yes") {
    echo "Uninstalling the USB tools"
    winget uninstall --exact dorssel.usbipd-win
    echo "Uninstalling Ubuntu"
    wsl --unregister Ubuntu
    echo "Removing the desktop shortcuts for the DB1 tools"
    $desktopPath = [System.Environment]::GetFolderPath('Desktop')

    function Remove-FileIfExists {
        param(
            [string]$filePath
        )

        # Check if the file exists
        if (Test-Path $filePath) {
            # File exists, delete it
            Remove-Item $filePath -Force
            Write-Host "File deleted: $filePath"
        } else {
            # File does not exist
            Write-Host "File does not exist: $filePath"
        }
    }

    Remove-FileIfExists -filePath "$desktopPath\DB1 Connect Serial.lnk"
    Remove-FileIfExists -filePath "$desktopPath\DB1 Disconnect Serial.lnk"
    Remove-FileIfExists -filePath "$desktopPath\DB1 Tools.lnk"
    Remove-FileIfExists -filePath "$desktopPath\DOCK.lnk"
} elseif ($response -eq "no") {
    Write-Host "You've chosen not to proceed. We exit without uninstalling the Db1tools"
} else {
    Write-Host "Invalid response. Valid responses are ""yes"" or ""no"" (without the quotes)"
}

