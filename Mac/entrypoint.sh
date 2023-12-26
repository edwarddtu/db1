#!/bin/bash
# entrypoint.sh

PYMAKR_FILE=pycom.pymakr-preview-2.25.2.vsix

echo "Start of entrypoint"
echo "Current user is $(whoami)"

# Check if the home directory is empty and if it is then set it up
if [ -z "$(ls -A /home/user)" ]; then
    echo "Home directory is empty. Copying default files..."
    cp -r /etc/skel/. /home/user/
    mkdir /home/user/db1
    mkdir -p /home/user/.local/bin
    cp /home/tmp/*.sh /home/user/.local/bin/

    # Function to update PATH
    update_path() {
        if ! echo $PATH | grep -q "$1"; then
            echo "export PATH=\"$1:\$PATH\"" >> ~/.bash_profile
            echo "" >> ~/.zprofile
            echo "export PATH=\"$1:\$PATH\"" >> ~/.zprofile
            
            echo "Path $1 added to PATH"
        else
            echo "Path $1 is already in PATH"
        fi
    }

    # Call the function with NEW_PATH
    update_path "/home/user/.local/bin"

    code-server --install-extension ms-python.python
    code-server --install-extension /home/tmp/$PYMAKR_FILE
 
# Copy some installation files
    cp -r /home/tmp/*.code-workspace /home/user/
    cp -r /home/tmp/DefaultProj/* /home/user/db1/
    cp -r /home/tmp/*.sh /home/user/.local/bin

    echo " "
    echo " "
    echo " "
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!!   Installation is done! You can start the user interface for !!!"
    echo "!!!   the DB1 tools by clicking on the desktop icon \"DB1 Tools\"  !!!"
    echo "!!!   The user interface for the tools will be available in your !!!" 
    echo "!!!   web browser at the web address http://localhost:8080       !!!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo " "
    echo " "
    echo " "


fi

echo "IP Address of the VSCode server is $(hostname -I)"

# Execute the command provided as arguments to this script
exec "$@"

