# Check if WSL is available
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    
    # Update WSL if a new version is available
    wsl --update

    # Get WSL status and convert it to a string
    $wslStatus = wsl --status | Out-String

    # Remove null characters (ASCII 0) from the string
    $wslStatus = $wslStatus -replace "`0", ""

    # Check if the default distribution is Ubuntu
    if ($wslStatus -match "Default Distribution:.*Ubuntu") {
        # Check if WSL 2 is the default version
        if ($wslStatus -match "Default Version:.*2") {
            # WSL 2 with Ubuntu is set as default
            Write-Host "WSL 2 with Ubuntu is set as the default distribution."
            wsl
            exit 0
        }
        else {
            Write-Host "Ubuntu is not using WSL 2. Converting to WSL 2..."

            # Convert Ubuntu to use WSL 2
            wsl --set-version Ubuntu 2

            # Verify the conversion
            $verificationStatus = wsl --list --verbose | Out-String
            $verificationStatus = $verificationStatus -replace "`0", ""
            if ($verificationStatus -match "Ubuntu\s+.*\s+2") {
                Write-Host "Conversion to WSL 2 successful."
                wsl
                exit 0
            } else {
                Write-Host "Failed to convert Ubuntu to WSL 2."
                exit 1
            }
        }
    }
    else {
        # Open the Microsoft documentation in the default browser
        echo "We need to install Ubuntu. In the process you'll also need to "
        echo "create a user and set up a password. "
        wsl --install -d Ubuntu 
        exit 0
    }
} else {
    # WSL is not available
    Write-Host "WSL is not available on this machine. Please follow the instructions from your web browser to manually install it"
    Start-Process "https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-11-with-gui-support#1-overview"
    exit 3
}