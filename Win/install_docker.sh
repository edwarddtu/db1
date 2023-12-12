#!/bin/bash
#The argument 1 is the user name of the wsl user

# Check if the operating system is Ubuntu
if grep -qi 'ubuntu' /etc/os-release; then
    echo "Ubuntu detected. Installing Docker..."

    # Update package information
    sudo apt update

    # Install packages to allow apt to use a repository over HTTPS
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker’s official GPG key
    rm -f /usr/share/keyrings/docker-archive-keyring.gpg
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Set up the stable repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    # Post-installation steps (optional, for running Docker as a non-root user)
    #sudo usermod -aG docker $1
    newgrp docker &

    echo "Docker installation complete."
else
    echo "This script only supports Ubuntu distributions in WSL."
    exit 1
fi
