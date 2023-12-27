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

# Main script execution
execute_and_check echo "Checking for Homebrew..."

if check_homebrew_installed; then
    execute_and_check echo "Homebrew is already installed."
else
    execute_and_check echo "Homebrew not found. Installing Homebrew..."
    execute_and_check install_homebrew
fi

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

# Adding also the path for homebrew
execute_and_check update_path "/opt/homebrew/bin/"

execute_and_check eval "$(/opt/homebrew/bin/brew shellenv)"

# Update Homebrew
execute_and_check echo "Updating Homebrew..."
execute_and_check brew update

# Install Python
execute_and_check echo "Installing Python..."

# Function to check if Python 3.10+ is installed
is_python3_10_or_higher_installed() {
    if ! command -v python3 &> /dev/null; then
        return 1 # Python3 is not installed
    fi

    # Extract the version of Python3
    PYTHON3_VERSION=$(python3 -V | awk '{print $2}')
    
    # Compare the version, return 0 if 3.10 or higher, 1 otherwise
    if [[ "$(printf '%s\n' "3.10" "$PYTHON3_VERSION" | sort -V | head -n1)" = "3.10" ]]; then
        return 0 # 3.10 or higher is installed
    else
        return 1 # Lower than 3.10
    fi
}

# Install Python using Homebrew
install_python_with_brew() {
    echo "Installing Python 3.10+ using Homebrew..."
    brew install python
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "Python installation completed."
}

# Main script logic
if is_python3_10_or_higher_installed; then
execute_and_check    echo "Python 3.10 or higher is already installed."
else
execute_and_check    echo "Python 3.10 or higher is not installed."

    # Install Homebrew if not already installed
    if ! command -v brew &> /dev/null; then
execute_and_check        echo "Homebrew is not installed. Installing Homebrew..."
execute_and_check        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install Python using Homebrew
execute_and_check    install_python_with_brew
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

#install esptool
brew install esptool
#brew link --overwrite six

# Function to create an alias if a command does not exist
create_alias_if_command_not_found() {
    local command_to_check=$1
    local command_to_alias=$2
    local alias_name=$3

    # Check if the command exists
    if ! command -v "$alias_name" &> /dev/null
    then
        echo "Command '$alias_name' not found. Adding alias..."

        # Add alias to .zprofile for Zsh users
        if [ -f ~/.zprofile ]; then
            echo "alias $alias_name=$command_to_alias" >> ~/.zprofile
        fi

        # Add alias to .bash_profile for Bash users
        if [ -f ~/.bash_profile ]; then
            echo "alias $alias_name=$command_to_alias" >> ~/.bash_profile
        else
            # If .bash_profile does not exist, try .profile
            echo "alias $alias_name=$command_to_alias" >> ~/.profile
        fi

        echo "Alias for '$alias_name' added. You might need to restart your terminal or source the profile for changes to take effect."
    else
        echo "Command '$alias_name' exists. No need to add alias."
    fi
}

# making an aliases for python and pip if necessasry
execute_and_check create_alias_if_command_not_found "python3" "python3" "python"
execute_and_check create_alias_if_command_not_found "pip3" "pip3" "pip"

# Function to check if Docker is installed
check_docker_installed() {
    which docker &> /dev/null
    return $?
}

pause(){
	read -p "Press any key to continue..." -n1 -s
	echo " "
}

# Function to start Docker
start_docker() {
    echo "Starting Docker...This can take up to a few minutes..."
    open -a Docker
}

# Function to install Docker
install_docker() {
    brew install --cask docker
    start_docker

    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!!! Before you continue with the installation we need to      !!!!"
    echo "!!!! make sure that docker is installed. We have attempled to  !!!!"
    echo "!!!! install it automatically.                                 !!!!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

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
sleep 3
execute_and_check start_docker
execute_and_check echo "If docker is installed correct then it shoud be running now."

execute_and_check echo "python version:"
execute_and_check python3 --version
execute_and_check echo "pip version:"
execute_and_check pip --version
execute_and_check echo "docker version:"
execute_and_check docker --version

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!! First installation step is done. Now we need to make !!!!"
echo "!!!! sure that docker is running and it's configured.     !!!!"
echo "!!!! If docker does not start by itself in at most 30     !!!!"
echo "!!!! seconds then you need to start it by yourself from   !!!!"
echo "!!!! the /Applications folder.                            !!!!"
echo "!!!! If you can't get docker to run then you'll need to   !!!!"
echo "!!!! install it manually from this web site:              !!!!"
echo "!!!! https://www.docker.com/products/docker-desktop/      !!!!"
echo "!!!! After docker is running then you can start the       !!!!"
echo "!!!! installation script for step2.                       !!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"


