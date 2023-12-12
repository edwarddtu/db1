#!/bin/bash
set -x

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    ./install_docker.sh
}

# Function to check if Docker daemon is running and start it if not
start_docker_daemon() {
    if ! sudo service docker status > /dev/null 2>&1; then
        echo "Starting Docker daemon..."
        sudo service docker start
    else
        echo "Docker daemon is already running."
    fi
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    install_docker
else
    echo "Docker is already installed."
fi

# Check and start Docker daemon
echo "Starting the docker daemon"
start_docker_daemon
