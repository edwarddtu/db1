#!/bin/bash

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
    echo "!!!!Before you continue with the installation you'll have to!!!!"
    echo "!!!!install Docker manually from this web site:             !!!!"
    echo "!!!!https://www.docker.com/products/docker-desktop/         !!!!"
    echo "!!!!Rerun this script again after you've installed docker   !!!!"
    open "https://www.docker.com/products/docker-desktop/"
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
DIRECTORY="$(pwd)"/user

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

execute_and_check echo "Now we create the base image. This might take a while..."
execute_and_check ./make_db1_base.sh
execute_and_check echo "Now we confgure and create the db1 image..." 
execute_and_check ./initDock.sh
execute_and_check check_user_directory
execute_and_check echo "!!!The installation is done!!!"

