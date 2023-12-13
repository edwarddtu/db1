#winget install --interactive --exact dorssel.usbipd-win
#wsl -u root apt install linux-tools-5.4.0-77-generic hwdata
#wsl -u root update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/5.4.0-77-generic/usbip 20

# Run the command and capture its output
$commandOutput = Invoke-Expression "usbipd list"

# Find the line containing 'CP210x'
$cp210xLine = $commandOutput | Select-String "CP210x"

# Check if the device was found
if ($cp210xLine -ne $null) {
    # Extract BUSID and COM Port using regex
    if ($cp210xLine.Line -match '^(?<BUSID>\S+)\s+\S+\s+.*?\(COM(?<COMPort>\d+)\)') {
        $busid = $Matches.BUSID
        $comPort = $Matches.COMPort

        # Output the extracted values
        Write-Host "Huzzah board was found"
        #Write-Host "BUSID: $busid"
        #Write-Host "COM Port: COM$comPort"
        Write-Host "Connecting the serial port of the Huzzah 32 board to WSL"
        usbipd bind -b $busid
        usbipd attach --wsl --busid $busid
        sleep 1
        wsl -u root sudo chmod ugo+wr /dev/ttyUSB0

        # You can use $busid and $comPort as variables here for further processing
    } else {
        Write-Host "Could not extract BUSID and COM Port."
    }
} else {
    Write-Host "!!!No Huzzah ESP32 board is connected"
}
