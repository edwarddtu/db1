#!/bin/bash
# entrypoint.sh

PYMAKR_FILE=pycom.pymakr-preview-2.25.2.vsix
#PYLANCE_FILE=ms-python.vscode-pylance-2023.11.12.vsix

echo "Start of entrypoint"
echo "Current user is $(whoami)"

# Check if the home directory is empty and if it is then set it up
if [ -z "$(ls -A /home/user)" ]; then
    echo "Home directory is empty. Copying default files..."
    cp -r /etc/skel/. /home/user/
    mkdir /home/user/db1
    export PATH=/home/user/.local/bin:$PATH
    code-server --install-extension ms-python.python
    code-server --install-extension /home/tmp/$PYMAKR_FILE
 #   code-server --install-extension /home/tmp/$PYLANCE_FILE
    pip install --upgrade micropy-cli

    echo " "
    echo " "
    echo " "
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!!   Installation is done! You can close this window NOW   !!!"
    echo "!!!   Start the tools by using windows_db1tools.bat         !!!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo " "
    echo " "
    echo " "


fi

echo "IP Address of the VSCode server is $(hostname -I)"

# Execute the command provided as arguments to this script
exec "$@"

