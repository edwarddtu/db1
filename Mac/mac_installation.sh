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

# Function to check if Homebrew is installed
check_homebrew_installed() {
    which brew &> /dev/null
    return $?
}

# Function to install Homebrew
install_homebrew() {
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

execute_and_check xattr -d com.apple.quarantine "Mac Installation.app"
execute_and_check xattr -d com.apple.quarantine "DB1 Tools.app"
execute_and_check xattr -d com.apple.quarantine "DB1 Huzzah Firmware.app"
execute_and_check xattr -d com.apple.quarantine "DB1 Huzzah Erase.app"

# Main script execution
execute_and_check echo "Checking for Homebrew..."

if check_homebrew_installed; then
    execute_and_check echo "Homebrew is already installed."
else
    execute_and_check echo "Homebrew not found. Installing Homebrew..."
    execute_and_check install_homebrew
fi


# Function to check if Docker is installed
check_docker_installed() {
    which docker &> /dev/null
    return $?
}

pause(){
	read -p "Press any key to continue..." -n1 -s
	echo " "
}

# Function to install Docker
install_docker() {
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!!! Before you continue with the installation you'll have to !!!!"
    echo "!!!! install Docker manually from this web site:              !!!!"
    echo "!!!! https://www.docker.com/products/docker-desktop/          !!!!"
    echo "!!!! Rerun this script again after you've installed docker    !!!!"
    echo "!!!! and press any key to continue the installation           !!!!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    open "https://www.docker.com/products/docker-desktop/" &
    pause
    exit
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


# Main script execution
execute_and_check echo "Checking for Docker..."

if check_docker_installed; then
    execute_and_check echo "Docker is already installed."
else
    execute_and_check echo "Docker not found. Installing Docker..."
    execute_and_check install_docker
fi

execute_and_check echo "Starting Docker daemon..."
execute_and_check start_docker

execute_and_check echo "Docker is running."

# Stop all running containers
docker stop $(docker ps -a -q)

#Remove all containers
docker rm $(docker ps -a -q)

cd $SCRIPT_DIR

echo "pwd is: $(pwd)"

execute_and_check echo "Now we create the base image. This might take a while..."
execute_and_check $SCRIPT_DIR/make_db1_base.sh
execute_and_check echo "Now we confgure and create the db1 image..." 
execute_and_check $SCRIPT_DIR/init_dock.sh
execute_and_check check_user_directory

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

# Copy icons to the desktop
cp -r ./DB1*.app $HOME/Desktop
ln -snf $(pwd) "$HOME/Desktop/DB1 dock files"
docker image prune -f

CONTAINER_NAME="db1container"
docker run --name $CONTAINER_NAME -p 8080:8080 -v $SCRIPT_DIR/user:/home/user db1:latest

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!! The installation is done. Please close this window !!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"


