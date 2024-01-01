#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Function to execute a command, stream output, check for errors, and log to file
execute_and_check() {
    # Log file path
    LOG_FILE="install.log"

    # Execute the command and pipe its output
    "$@" 2>&1 | tee -a $LOG_FILE | while IFS= read -r line
    do
        echo "$line"
        # Check for the word "error" in the output (case insensitive)
        if echo "$line" | grep -iq "^error:"; then
            echo "Error detected in the above line. Exiting..."
            exit 1
        fi
    done
    # Capture the exit status of the command
    local status=$?
    if [ $status -ne 0 ]; then
        echo "Command exited with status $status. Exiting main script."
        exit $status
    fi
}

install_icons(){
    echo "Installing the incons"
    # Define the path to the disk image and the destination folder
    DISK_IMAGE_PATH="$SCRIPT_DIR/db1.dmg"
    echo "DISK_IMAGE_PATH=$DISK_IMAGE_PATH"
    DESTINATION_FOLDER="$SCRIPT_DIR"

    # Mount the disk image
    echo "Mounting the disk image..."
    MOUNT_POINT=$(hdiutil attach "$DISK_IMAGE_PATH" -nobrowse -readonly | awk '$NF ~ /Volumes/ {print $NF}')

    # Check if the mount was successful
    if [ -z "$MOUNT_POINT" ]; then
        echo "Failed to mount the disk image."
        exit 1
    fi

    echo "Disk image mounted at $MOUNT_POINT"

    # Copy files from the mounted image to the destination folder
    echo "Copying files..."
    cp -R "$MOUNT_POINT/"DB1* "$DESTINATION_FOLDER"

    # Unmount the disk image
    echo "Unmounting the disk image..."
    hdiutil detach "$MOUNT_POINT"
    xattr -d com.apple.quarantine "$DESTINATION_FOLDER/DB1 Tools.app"
    xattr -d com.apple.quarantine "$DESTINATION_FOLDER/DB1 Huzzah Firmware.app"
    xattr -d com.apple.quarantine "$DESTINATION_FOLDER/DB1 Huzzah Erase.app"    
}

execute_and_check install_icons

# Adding the current path to the PATH environment variable so that
# we can run the tools from the desktop icons
NEW_PATH=$(pwd)

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
update_path "$NEW_PATH"

pause(){
	read -p "Press any key to continue..." -n1 -s
	echo " "
}


# Function to start Docker
start_docker() {
    echo "Starting Docker..."
    open -a Docker
}



# Checks if the directory user exists and if not it creates it
check_user_directory(){
DIRECTORY=$SCRIPT_DIR/user

if [ -d "$DIRECTORY" ]; then
    echo "Directory exists: $DIRECTORY"
else
    echo "Directory does not exist. Creating: $DIRECTORY"
    mkdir -p "$DIRECTORY"
fi

}

# Checking for prerequisites
execute_and_check start_docker

# Check if esptool.py is installed and available in PATH
if ! command -v esptool.py &> /dev/null; then
    echo "Error: esptool.py is not installed or not found in PATH."
    echo "esptool should be install by the script from step 1."
    exit 1
fi

# If this point is reached, esptool.py is installed
echo "esptool.py is installed."

# Make sure that pyserial is installed
pip3 install pyserial

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
execute_and_check     echo "Error: Docker engine is not running. Make sure that you start docker before running installation step 2!"
    exit 1
else
execute_and_check     echo "Docker engine is running."
fi

# Removing the DB1container so that we can make a new one.
# Name of the Docker container
CONTAINER_NAME="db1container"

# Stop the container if it's running
docker stop "$CONTAINER_NAME"

# Remove the container
docker rm "$CONTAINER_NAME"

cd $SCRIPT_DIR

execute_and_check echo "Now we create the base image. This might take a while..."
execute_and_check $SCRIPT_DIR/make_db1_base.sh
execute_and_check echo "Now we confgure and create the db1 image..." 
execute_and_check $SCRIPT_DIR/init_dock.sh
execute_and_check check_user_directory

# Copy icons to the desktop
cp -r ./DB1*.app $HOME/Desktop
cp -r ./DB1*.app /Applications/
ln -snf $(pwd) "$HOME/Desktop/DB1 dock files"


docker image prune -f

CONTAINER_NAME="db1container"
docker run --name $CONTAINER_NAME -p 8080:8080 -v $SCRIPT_DIR/user:/home/user db1:latest

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!! The installation is done. Please close this window !!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"


