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

            # Define the WSL user's home directory and the 'dock' subdirectory
            $wslUserName= wsl sh -c 'echo $USER'
            $dockDirectory = "/home/$wslUserName/dock"

            # Create the 'dock' subdirectory in the WSL user's home directory
            wsl mkdir -p $dockDirectory


            # Copy all files from the current directory in PowerShell to the 'dock' directory in WSL
            wsl cp -rf * $dockDirectory

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
            wsl -u root apt install linux-tools-5.4.0-77-generic hwdata
            wsl -u root update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/5.4.0-77-generic/usbip 20
            echo "Done installing the usb tools"

            Write-Host "Starting the container db1container"
            wsl  bash -c "chmod u+x $dockDirectory/startDock.sh"
            wsl  bash -c "bash $dockDirectory/startDock.sh"            

           # echo "!!! The one time installation is done.From !!!!"
           # echo "!!! now on you can run the tools by double !!!!"
           # echo "!!! clicking on windows_db1tools.bat       !!!!"

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
            } else {
                Write-Host "Failed to convert Ubuntu to WSL 2."
            }
        }
    }
    else {
        # Open the Microsoft documentation in the default browser
        echo "We need to install Ubuntu. In the process you'll also need to "
        echo "create a user and set up a password. When you are done run the " 
        echo "installation file once again. For more info you can also look at the file"
        echo "that oppened in your browser"
        wsl --install
        Start-Process "https://learn.microsoft.com/en-us/windows/wsl/setup/environment"
    }
} else {
    # WSL is not available
    Write-Host "WSL is not available on this machine. Please upgrade Windows in order to use WSL. You can see more info in the web site opened in your browser"
    Start-Process "https://www.omgubuntu.co.uk/how-to-install-wsl2-on-windows-10"
}
pause